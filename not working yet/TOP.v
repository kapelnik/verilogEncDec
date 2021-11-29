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

input wire 							PENABLE,
									PSEL,
									PWRITE,
									
output reg [AMBA_WORD-1:0] 			PRDATA,
output reg [DATA_WIDTH-1:0] 		data_out,
output reg 							operation_done,
output reg [1:0]					num_of_errors

);
//States 
parameter [1:0] IDLE 			= 2'b00,
				ENCODING 		= 2'b01,
				DECODING 		= 2'b10,
				NOISE 			= 2'b11;

//State reg controlled by the state machine
reg [1:0] curent_state = 2'b00;
reg [1:0] Next_State = 2'b00;

//Register for full channel
reg [31:0] FC_REG;
reg [31:0] DATA_IN_Pad;


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

reg  Small = 1'b0, /// Control bits
	 Medium = 1'b0,
	 Large= 1'b1,
	 next_operation_done = 1'b1,
	// Enc_Done,
	// Dec_Done,
	 Noise_added = 1'b0;


//Create register selector
Register_selctor #(.DATA_WIDTH(DATA_WIDTH) , .AMBA_ADDR_WIDTH(AMBA_ADDR_WIDTH) , .AMBA_WORD(AMBA_WORD) )	Register_selctor(
   .clk            (clk),
   .rst            (rst),
   .PADDR          (PADDR),
   .PWDATA         (PWDATA),
   .PENABLE        (PENABLE),
   .PSEL           (PSEL),
   .PWRITE         (PWRITE),
   .PRDATA         (PRDATA_REG),
   .CTRL           (CTRL_REG),
   .DATA_IN        (DATA_IN_REG),
   .CODEWORD_WIDTH (CODEWORD_WIDTH_REG),
   .NOISE          (NOISE_REG)
);

Encoder #(.DATA_WIDTH(DATA_WIDTH) , .AMBA_ADDR_WIDTH(AMBA_ADDR_WIDTH) , .AMBA_WORD(32)) Encoder(
   .clk            (clk),
   .rst            (rst),
   .Small          (Small),
   .Medium         (Medium),
   .Large          (Large),
   .DATA_IN        (FC_REG),
   .CODEWORD_WIDTH (CODEWORD_WIDTH_REG[1:0]),
   .Enc_Out         (Enc_Out)
	// clk,rst,Small,Medium,Large,FC_REG,CODEWORD_WIDTH_REG[1:0],Enc_Out
);

Num_Of_Errors #(.DATA_WIDTH(32),.AMBA_ADDR_WIDTH(32),.AMBA_WORD(32)) Num_Of_Errors(
   .clk            (clk),
   .Yin            (Enc_Out[5:0]),
   .DATA_IN        (FC_REG[32+5-DATA_WIDTH:32-DATA_WIDTH]),
   .Small          (Small),
   .Medium         (Medium),
   .NOF            (NOF),
   .NOE_Out        (NOE_Out)
);

Error_fix #(.DATA_WIDTH(32),.AMBA_ADDR_WIDTH(32),.AMBA_WORD(32)) Error_fix(
   .clk        (clk),
   .rst        (rst),
   .S          (NOE_Out),
   .NOF        (NOF),
   .Small      (Small),
   .Medium     (Medium),
//   .Enc_Done   (Enc_Done),
   .DATA_IN    ({{32-DATA_WIDTH{1'b0}},FC_REG[31:32-DATA_WIDTH]}),
//   .Error_Done (Error_Done),
   .Dec_Out    (Dec_Out)
);






 
always@(*) begin // Next state chosing
	case (curent_state)
		ENCODING: begin	//=================ENCODING State//=================
					case (CTRL_REG[1:0])
						2'b00: begin
								Next_State			       	<=       IDLE;
								// next_operation_done         <=	 	 1'b1;
								data_out					<=		 Enc_Out[DATA_WIDTH-1:0];
								
							end
						2'b01: begin
								Next_State					<= 		 DECODING;
							end
						2'b10: begin
								
								 if(!Noise_added) 
								begin
									Next_State	<= 		 NOISE;
									FC_REG    	<= {{Enc_Out[DATA_WIDTH-1:0]^NOISE_REG[DATA_WIDTH-1:0]},{32-DATA_WIDTH{1'b0}}};
								end
								else 
								begin
									Next_State  <=       DECODING ;
								end
							end
						default: Next_State			       	<=       IDLE;
					endcase
				end
		DECODING: begin	////=================DECODING State//=================
					Next_State			       	<=       IDLE;
					data_out					<=		 Dec_Out[DATA_WIDTH-1:0]; //{DATA_WIDTH-AMBA_WORD{1'b0}},
					// next_operation_done         <=	 	 1'b1;
					Noise_added 				<= 		 1'b0;
				end
		NOISE 	: begin	////=================NOISE State//=================
					Next_State			       	<=       DECODING;
					
					Noise_added 				<= 		 1'b1;
				end	
		default: begin	////=================IDLE State//=================
					next_operation_done         <=	 	 1'b0;
					if(PADDR[3:2] == 2'b00 & PENABLE)
						begin
							Next_State <= ENCODING;
							
							FC_REG <= DATA_IN_Pad ;
						end
					
				end
	endcase
end

always@(*) begin //Control bit change
	case (curent_state)
		ENCODING: begin	//=================ENCODING State//=================
					case (CTRL_REG[1:0])
						2'b00: begin
								next_operation_done         <=	 	 1'b1;
							   end
						default: next_operation_done         <=	 	 1'b0;
					endcase
				end
		DECODING: begin	////=================DECODING State//=================
					next_operation_done         <=	 	 1'b1;
					Noise_added 				<= 		 1'b0;
				end
		NOISE 	: begin	////=================NOISE State//=================

					
					Noise_added 				<= 		 1'b1;
				end	
		default: begin	////=================IDLE State//=================
					next_operation_done         <=	 	 1'b0;
					
					
				end
	endcase
end

// Opration done
always@(posedge clk or negedge rst) begin
	if(!rst) 
	begin
		operation_done<= 1'b0;	
	end
	else 
		operation_done<= next_operation_done;
		
end


//State machine controller, each clock move to Next_State
always@(posedge clk or negedge rst) begin
	if(!rst) 
		begin
			curent_state<= IDLE;
			PRDATA<= {AMBA_WORD{1'b0}};
	//		data_out<=  {DATA_WIDTH{1'b0}};
		end
	else 
		begin
			num_of_errors <= NOF ;
			curent_state <= Next_State;
		end
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
				if(Small) 
				begin
					DATA_IN_Pad<= {{DATA_IN_REG},{24{1'b0}}};
				end
				else 
				if (Medium) 
				begin
					DATA_IN_Pad<= {{DATA_IN_REG},{16{1'b0}}};
				end
				else 
				begin
					DATA_IN_Pad<= DATA_IN_REG;
				end
			end
		default: begin
				if(Small) 
				begin
					DATA_IN_Pad<= {{DATA_IN_REG},{28{1'b0}}};
				end
				else 
				if (Medium) 
				begin
					DATA_IN_Pad<= {{DATA_IN_REG},{21{1'b0}}};
				end
				else 
				begin
					DATA_IN_Pad<= {{DATA_IN_REG},{6{1'b0}}};
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
		2'b01: begin
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