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
reg [1:0] current_state;
reg [1:0] Next_State,
		  next_num_of_errors;

//Register for full channel
reg [31:0] FC_REG ;
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

reg  Small , /// Control bits
	 Medium ,
	 Large,
	 next_operation_done ,
	// Enc_Done,
	// Dec_Done,
	 Noise_added ,
	 load ,
	 start_work;


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
   .DATA_IN        (FC_REG),
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

//###########=================Top State Machine=================###########//
always@(*) 
begin: Top_state_machine // Next state chosing
	case (current_state)
		ENCODING: begin	//=================ENCODING State//=================
					case (CTRL_REG[1:0])
						2'b00: begin
								Next_State			       	<=       IDLE;
							end
						2'b01: begin
								Next_State					<= 		 DECODING;
							end
						2'b10: begin
								
								 if(!Noise_added) 
								begin
									Next_State	<= 		NOISE;
								end
								else 
								begin
									Next_State  <=      DECODING ;
								end
							end
						default: Next_State			       	<=       IDLE;
					endcase
				end
		DECODING: begin	////=================DECODING State//=================
					Next_State			       	<=       IDLE;
				end
		NOISE 	: begin	////=================NOISE State//=================
					Next_State			       	<=       DECODING;
				end	
		default: begin	////=================IDLE State//=================
					next_operation_done         <=	 	 1'b0;
					if(start_work)  /// (PADDR[3:2] == 2'b00) & PENABLE & PWRITE
						begin
							Next_State <= ENCODING;
						end
					else 
						begin
							Next_State 				<= 		IDLE;	
						end
				end
	endcase
end

//#################################
//start work when control register changes
always@(*) 
begin : Timing_Control 
	start_work <= PENABLE & PWRITE & ~PADDR[3] & ~PADDR[2];
end

//#################################
//FC Register is 32 bits, we use it to implement the same EncDec machine that supports 3 types of data width
always@(*) 
begin : FC_REG_Control //Control bit change
	case (Next_State)
		ENCODING: begin	//=================ENCODING State//=================
					case (CTRL_REG[1:0])
						2'b10: 		load <= 1'b1 ;
						default:	load <= 1'b0 ;
					endcase
				end
		DECODING: begin	////=================DECODING State//=================
					load			       	<=       1'b1;
				end
		NOISE 	: begin	////=================NOISE State//=================
					load			       	<=       1'b1;
				end		
					// Noise_added 				<= 		 1'b1;
		default: begin	////=================Any Other State//=================
					load <= 1'b0 ;
					
					
				end
	endcase
end

//#################################
//FC_control
always@(posedge clk or negedge rst) 
begin: FC_control
	if(!rst) 
		begin
			FC_REG <= {32{1'b0}};	
		end
	else 
		begin
			if (load)
				FC_REG  	   <= {{Enc_Out[DATA_WIDTH-1:0]^NOISE_REG[DATA_WIDTH-1:0]},{32-DATA_WIDTH{1'b0}}};
			else
				FC_REG         <=	 	 DATA_IN_Pad;
		end	
		
end

//#################################
//Noise_Control
always@(*) 
begin : Noise_Control 
	case (current_state)
		NOISE 	: begin	////=================NOISE State//=================
					Noise_added 				<= 		 1'b1;
				end	
		default: begin	////=================Any Other State//=================
					Noise_added         <=	 	 1'b0;	
				end
	endcase
end

//#################################
//DATA_OUT_Control
always@(*) 
begin : DATA_OUT_Control 
	case (current_state)
		ENCODING: begin	//=================ENCODING State//=================
					case (CTRL_REG[1:0])
						2'b00: data_out						<=		 Enc_Out[DATA_WIDTH-1:0];
						default: data_out					<=		 Dec_Out[DATA_WIDTH-1:0];
					endcase
				end
		DECODING: 	////=================DECODING State//=================
			data_out										<=		 Dec_Out[DATA_WIDTH-1:0]; //{DATA_WIDTH-AMBA_WORD{1'b0}},
		
		default: begin	////=================Any Other State//=================
					data_out								<=		 Enc_Out[DATA_WIDTH-1:0];
				end
	endcase
end

//#################################
//To make sure operation_done get the right value, we keep operation_done in Next_operation_done_Control
always@(*) 
begin : Next_operation_done_Control
	case (current_state)
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
				end
		default: begin	////=================IDLE State//=================
					next_operation_done         <=	 	 1'b0;
				end
	endcase
end

//#################################
// Opration done
always@(posedge clk or negedge rst) 
begin: Operation_bit_control
	if(!rst) 
		operation_done<= 1'b0;	
	else 
		operation_done<= next_operation_done;
		
end

//#################################
//State machine controller, each clock move to Next_State
always@(posedge clk or negedge rst) 
begin: State_control
	if(!rst) 
			current_state<= IDLE;
	else 
			current_state <= Next_State;
end

//#################################
//Assert PRDATA output to PRDATA_REG from RegisterSelector
always@(*) 
begin: REGISTERS_READ
	if(!rst) 
			PRDATA<= {AMBA_WORD{1'b0}};
	else 
			PRDATA<= PRDATA_REG;
end



//#################################
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


//#################################
//To make sure num_of_errors get the right value, we keep NOF in next_num_of_errors
always@(*) 
begin : N_NOF_CONTROL
	case (current_state)
		NOISE: begin	//=================ENCODING State//=================
					next_num_of_errors <= NOF;
				end			
		default: begin	////=================IDLE State//=================
					case(num_of_errors)
						2'b00: next_num_of_errors <= 2'b00;
						2'b01: next_num_of_errors <= 2'b01;
						default : next_num_of_errors <= 2'b10;
							
					endcase
					
				end
	endcase
end

//#################################
// control the num_of_errors output
always@(posedge clk or negedge rst) 
begin: NOF_control
	if(!rst) 
		num_of_errors <= 2'b00;	
	else 
		num_of_errors<= next_num_of_errors;
		
end


//#################################
//Check what is the size of the input: small - 8 bits, medium 16 bits, Large - 32 bits.
always@(*)
begin: data_out_width
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


//#################################
//This machine receives various types of data width. since we want to support all types of data, we padd with zeroes and push the data to the MSB bits.
always@(*)
begin: Zero_padding
	case (CTRL_REG[1:0])
	
		2'b01: 	DATA_IN_Pad<= {{DATA_IN_REG[DATA_WIDTH-1:0]},{32-DATA_WIDTH{1'b0}}};		//Decode - need all data width since the parity is already added
		
		default: begin																		//default - encode or full channel, data received without parity bits
				if(Small) 
					begin
						DATA_IN_Pad<= {{DATA_IN_REG[3:0]},{28{1'b0}}};		//Data width = 00x: data_in is 8 bits, when the 4 LSB are the values, and 4 MSB are zeroes or dont cares
					end
				else 
				if (Medium) 
					begin
						DATA_IN_Pad<= {{DATA_IN_REG[10:0]},{21{1'b0}}};		//Data width = 01x: data_in is 16 bits, when the 11 LSB are the values, and 5 MSB are zeroes or dont cares
					end
				else 
					begin
						DATA_IN_Pad<= {{DATA_IN_REG[25:0]},{6{1'b0}}};		//Data width = 10x: data_in is 32 bits, when the 25 LSB are the values, and 6 MSB are zeroes or dont cares
					end
			end
	endcase
end
 
endmodule