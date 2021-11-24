//
// Verilog Module Project_lib.TOP
//
// Created:
//          by - benmaorr.UNKNOWN (L330W516)
//          at - 11:11:58 11/23/2021
//
// using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
//

`resetall
`timescale 1ns/10ps
module TOP 
#(
//input Params
parameter DATA_WIDTH = 32,
parameter AMBA_ADDR_WIDTH = 20,
parameter AMBA_WORD = 32
)
(
input wire clk,
input wire rst,
input wire [AMBA_ADDR_WIDTH-1:0] 	PADDR,
input wire [AMBA_WORD-1:0] 			PWDATA,
input wire 							PENABLE,PSEL,PWRITE,
output reg [AMBA_WORD-1:0] 			PRDATA,
output reg [DATA_WIDTH-1:0] 		data_out,
output reg 							operation_done
);
//States 
parameter [1:0] IDLE 			= 2'b00,
				ENCODING 		= 2'b01,
				DECODING 		= 2'b10,
				NOISE 			= 2'b11;

//State reg controlled by the state machine
reg [1:0] State = 2'b00;
reg [1:0] Next_State = 2'b00;

//Register for full channel
reg [AMBA_WORD-1:0] FC_REG,
					DATA_IN_Pad;


//Registers, output from Register_selctor
wire [AMBA_WORD-1:0] CTRL_REG,
					 DATA_IN_REG,
					 CODEWORD_WIDTH_REG,
					 NOISE_REG,
					 PRDATA_REG;

// Decoder registers
wire [1:0] NOF;
wire [4:0] NOE_Out;

// Enititys Out put					 
wire [AMBA_WORD-1:0] Enc_Out,
					 Dec_Out;
// wire [AMBA_WORD-1:0] Enc_Out_f, //// Final out
					 // Dec_Out_f;

reg  Small, /// Control bits
	 Medium,
	 Large,
	 next_operation_done = 1'b1,
	// Enc_Done,
	// Dec_Done,
	 Noise_added = 1'b0;


//Create register selector
Register_selctor #(DATA_WIDTH , AMBA_ADDR_WIDTH , AMBA_WORD )	Register_selctor(
   clk,rst,PADDR,PWDATA,PENABLE,PSEL,PWRITE,PRDATA_REG,CTRL_REG,DATA_IN_REG,CODEWORD_WIDTH_REG,NOISE_REG
);

Encoder #(DATA_WIDTH , AMBA_ADDR_WIDTH , AMBA_WORD) Encoder(
	clk,rst,Small,Medium,Large,FC_REG,CODEWORD_WIDTH_REG[1:0],Enc_Out
);

Num_Of_Errors #() Num_Of_Errors(
   .clk            (clk),
   .Yin            (Enc_Out[5:0]),
   .DATA_IN        (FC_REG[5:0]),
   .Small          (Small),
   .Medium         (Medium),
   .NOF            (NOF),
   .OUT            (NOE_Out)
);

Error_fix #() Error_fix(
   .clk        (clk),
   .rst        (rst),
   .S          (NOE_Out),
   .NOF        (NOF),
   .Small      (Small),
   .Medium     (Medium),
//   .Enc_Done   (Enc_Done),
   .DATA_IN    (FC_REG),
//   .Error_Done (Error_Done),
   .OUT        (Dec_Out)
);






 
always@(*) begin // Next state chosing
	case (State)
		ENCODING: begin	//=================ENCODING State//=================
					case (CTRL_REG[1:0])
						2'b00: begin
								Next_State			       	<=       IDLE;
								next_operation_done         <=	 	 1'b1;
								data_out					<=		 Enc_Out[AMBA_WORD-1:0];
								
							end
						2'b01: begin
								Next_State					<= 		 DECODING;
							end
						2'b10: begin
								if(!Noise_added)begin
									Next_State	<= 		 ENCODING;
									Noise_added <= 1'b1 ;
								end
								else begin
									FC_REG      <= Enc_Out[AMBA_WORD-1:0]^NOISE_REG;
									Next_State  <= DECODING ;
								end
							end
						default: Next_State			       	<=       IDLE;
					endcase
				end
		DECODING: begin	////=================DECODING State//=================
					Next_State			       	<=       IDLE;
					data_out					<=		 Dec_Out[AMBA_WORD-1:0];
					next_operation_done         <=	 	 1'b1;
					Noise_added 				<= 		 1'b0;
				end
		default: begin	////=================IDLE State//=================
					if(PADDR[3:2] == 2'b00) begin
							Next_State <= ENCODING;
							next_operation_done         <=	 	 1'b0;
							FC_REG <= DATA_IN_Pad ;
						end
					
				end
	endcase
end

always@(*) begin //Control bit change
	case (State)
		ENCODING: begin	//=================ENCODING State//=================
					
				end
		DECODING: begin	////=================DECODING State//=================
				
				end
		NOISE: begin	////=================NOISE State//=================
				
				end
		default: begin	////=================IDLE State//=================
					
				end
	endcase
end

// Opration done
always@(posedge clk or negedge rst) begin
	if(!rst) begin
		operation_done<= 1'b0;	
	end
	else operation_done<= next_operation_done;
end


//State machine controller, each clock move to Next_State
always@(posedge clk or negedge rst) begin
	if(!rst) begin
		State<= IDLE;
		PRDATA<= {AMBA_WORD{1'b0}};
		data_out<=  {DATA_WIDTH{1'b0}};
		next_operation_done<= 1'b0;
		Noise_added <= 1'b0;
	end
	else State <= Next_State;
end


// always @(*) begin // Pirty Fixing
		// if(Small) begin
			// Enc_Out_f	<=	Enc_Out[AMBA_WORD-1:0];
			// Dec_Out_f	<=	Dec_Out[AMBA_WORD-1:0];
		// end
		// else if (Medium) begin
			// DATA_IN<= {DATA_IN_Pad<<16};
		// end
		// else begin
			// DATA_IN<= ATA_IN_Pad;
		// end
	
// end
always@(*)begin
	case (CTRL_REG[1:0])
		2'b01: begin
			DATA_IN_Pad <= DATA_IN_REG;
			end
		default: begin
				if(Small) begin
					DATA_IN_Pad<= {DATA_IN_REG[3:0],{4'b0000}};
				end
				else if (Medium) begin
					DATA_IN_Pad<= {DATA_IN_REG[11:0],{5'b00000}};
				end
				else begin
					DATA_IN_Pad<= {DATA_IN_REG[26:0],{6'b000000}};
				end
			end
	endcase
end

always@(*)begin
	case (CODEWORD_WIDTH_REG[1:0])
		2'b00: begin
				Small<= 1'b1;
				Medium <= 1'b0;
				Large <= 1'b0;
			end
		2'b00: begin
				Small<= 1'b0;
				Medium <= 1'b1;
				Large <= 1'b0;
			end
		default: begin
				Small<= 1'b0;
				Medium <= 1'b0;
				Large <= 1'b1;
			end
	endcase
end
 
endmodule