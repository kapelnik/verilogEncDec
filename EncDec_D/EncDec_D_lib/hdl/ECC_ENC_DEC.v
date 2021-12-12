//
// Verilog Module EncDec_D_lib.ECC_ENC_DEC
//
// Created:
//          by - benmaorr.refael,kapelnik.Tal (L330W509)
//          at - 17:34:12 12/ 2/2021
//
// using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
//

`resetall
`timescale 1ns/10ps
module ECC_ENC_DEC 
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
reg [31:0] FC_REG,
		   FC_REG_SAVE;
reg [31:0] DATA_IN_Pad,
		   Dec_in;


//Registers, output from Register_selctor
wire [AMBA_WORD-1:0] CTRL_REG,
					 DATA_IN_REG,
					 CODEWORD_WIDTH_REG,
					 NOISE_REG,
					 PRDATA_REG;

// Decoder registers
wire [1:0] NOF;
wire [4:0] NOE_Out;
reg [DATA_WIDTH-1:0] Enc_noise;

// Enititys Out put					 
wire [AMBA_WORD-1:0] Enc_Out,
					 Dec_Out;
// wire [AMBA_WORD-1:0] Enc_Out_f, //// Final out
					 // Dec_Out_f;

wire  Small , /// Control bits
	  Medium ,
	  Large;
reg	 next_operation_done ,
	// Enc_Done,
	// Dec_Done,
	 Noise_added ,
	 load ,
	 start_work;


//Create register selector
Register_selctor #(  .AMBA_WORD(AMBA_WORD) )	Register_selctor(
   .clk            (clk),
   .rst            (rst),
   .PADDR          (PADDR[3:2]),
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

Encoder #( .AMBA_WORD(32)) Encoder(
   .clk            (clk),
   .rst            (rst),
   .Small          (Small),
   .Medium         (Medium),
   .Large          (Large),
   .DATA_IN        (FC_REG),
   // .CODEWORD_WIDTH (CODEWORD_WIDTH_REG[1:0]),
   .Enc_Out         (Enc_Out)
	// clk,rst,Small,Medium,Large,FC_REG,CODEWORD_WIDTH_REG[1:0],Enc_Out
);

Num_Of_Errors Num_Of_Errors(
   // .clk            (clk),
   .Yin            (Enc_Out[4:0]),
   .DATA_IN        (FC_REG),
   .Small          (Small),
   .Medium         (Medium),
   .NOF            (NOF),
   .NOE_Out        (NOE_Out)
);

Error_fix #(.DATA_WIDTH(DATA_WIDTH)) Error_fix(
   .clk        (clk),
   .rst        (rst),
   .S          (NOE_Out),
   .NOF        (NOF),
   .Small      (Small),
   .Medium     (Medium),
//   .Enc_Done   (Enc_Done),
   .DATA_IN    (Dec_in),
//   .Error_Done (Error_Done),
   .Dec_Out    (Dec_Out)
);

//###########=================Top State Machine=================###########//
always@(current_state or CTRL_REG or Noise_added or start_work) 
begin: Top_state_machine // Next state chosing
	case (current_state)
		ENCODING: begin	//=================ENCODING State//=================
					case (CTRL_REG[1:0])
						2'b00: begin
								Next_State			       	=       IDLE;
							end
						2'b01: begin
								Next_State					= 		 DECODING;
							end
						2'b10: begin
								
								 if(!Noise_added) 
								begin
									Next_State	= 		NOISE;
								end
								else 
								begin
									Next_State  =      DECODING ;
								end
							end
						default: Next_State			       	=       IDLE;
					endcase
				end
		DECODING: begin	////=================DECODING State//=================
					Next_State			       	=       IDLE;
				end
		NOISE 	: begin	////=================NOISE State//=================
					Next_State			       	=       DECODING;
				end	
		default: begin	////=================IDLE State//=================
					if(start_work)  /// (PADDR[3:2] == 2'b00) & PENABLE & PWRITE
						begin
							Next_State = ENCODING;
						end
					else 
						begin
							Next_State 				= 		IDLE;	
						end
				end
	endcase
end

//#################################
//start work when control register changes
always@(PENABLE or PWRITE or PADDR) 
begin : Timing_Control 
	start_work = PENABLE & PWRITE & ~PADDR[3] & ~PADDR[2];
end

//#################################
//FC Register is 32 bits, we use it to implement the same EncDec machine that supports 3 types of data width
always@(Next_State or CTRL_REG) 
begin : FC_REG_Control //Control bit change
	case (Next_State)
		ENCODING: begin	//=================ENCODING State//=================
					case (CTRL_REG[1:0])
						2'b10: 		load = 1'b0 ;
						default:	load = 1'b0 ;
					endcase
				end
		DECODING: begin	////=================DECODING State//=================
					load			       	=       1'b1;
				end
		NOISE 	: begin	////=================NOISE State//=================
					load			       	=       1'b1;
				end		
					// Noise_added 				<= 		 1'b1;
		default: begin	////=================Any Other State//=================
					load       = 1'b0 ;
					
					
				end
	endcase
end

//#################################
//FC_control used to implement Full Channel - encoder->noise->encode->decode

always@(Enc_Out or NOISE_REG or Small or Medium)
begin : Noise_Adding
	if(Small)
		Enc_noise = {Enc_Out[7:0]^NOISE_REG[7:0],{DATA_WIDTH-8{1'b0}}};
	else if(Medium)
		Enc_noise = {Enc_Out[15:0]^NOISE_REG[15:0],{DATA_WIDTH-16{1'b0}}};
	else
		Enc_noise = Enc_Out[DATA_WIDTH-1:0]^NOISE_REG[DATA_WIDTH-1:0];
end

always@(FC_REG or Small or Medium)
begin : Entering_Dec_data
	if(Small)
		Dec_in = {{32-8{1'b0}},FC_REG[31:32-8]};
	else if(Medium)
		Dec_in = {{32-16{1'b0}},FC_REG[31:32-16]};
	else
		Dec_in = FC_REG;
end
// assign Enc_noise = Enc_Out[DATA_WIDTH-1:0]^NOISE_REG[DATA_WIDTH-1:0];

always@(Next_State or Enc_noise or FC_REG_SAVE or DATA_IN_Pad) 
begin: FC_control
	case (current_state)
		ENCODING: begin	//=================ENCODING State//=================
					case (CTRL_REG[1:0])
						2'b10: 		FC_REG  	   = {Enc_noise,{32-DATA_WIDTH{1'b0}}};
						default:	FC_REG  = FC_REG_SAVE;
					endcase
				end
		IDLE: begin	////=================DECODING State//=================
					FC_REG         =	 	 DATA_IN_Pad;
				end
		default: begin	////=================Any Other State//=================
					FC_REG  = FC_REG_SAVE;
					
					
				end
	endcase
			// if (load)
				// FC_REG  	   = {Enc_noise,{32-DATA_WIDTH{1'b0}}};
			// else
				// FC_REG         =	 	 DATA_IN_Pad;
		// end	
		
end

always@(posedge clk or negedge rst)
begin: Saving_data
	if(!rst)
		FC_REG_SAVE <= {32{1'b0}};
	else
		FC_REG_SAVE <= FC_REG ;
end

// assign FC_REG = load ? {Enc_noise,{32-DATA_WIDTH{1'b0}}} : DATA_IN_Pad;
//#################################
//Noise_Control - This flag used for the state machine to know whether noise has being added or not
always@(current_state) 
begin : Noise_Control 
	case (current_state)
		NOISE 	: begin	////=================NOISE State//=================
					Noise_added 				= 		 1'b1;
				end	
		default: begin	////=================Any Other State//=================
					Noise_added         =	 	 1'b0;	
				end
	endcase
end

//#################################
//DATA_OUT_Control
always@(posedge clk or negedge rst) 
begin : DATA_OUT_Control 
	if(!rst)
		data_out <= {DATA_WIDTH{1'b0}};
	else
		begin
			if(CTRL_REG[1:0] == 2'b00)
				data_out						<=		 Enc_Out[DATA_WIDTH-1:0];
			else
				data_out					<=		 Dec_Out[DATA_WIDTH-1:0];
		end

end

//#################################
//To make sure operation_done get the right value, we keep operation_done in Next_operation_done_Control
always@(current_state or CTRL_REG) 
begin : Next_operation_done_Control
	case (current_state)
		ENCODING: begin	//=================ENCODING State//=================
					case (CTRL_REG[1:0])
						2'b00: begin
								next_operation_done         =	 	 1'b1;
							   end
						default: next_operation_done         =	 	 1'b0;
					endcase
				end
		DECODING: begin	////=================DECODING State//=================
					next_operation_done         =	 	 1'b1;
				end
		default: begin	////=================IDLE State//=================
					next_operation_done         =	 	 1'b0;
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
// always@(posedge clk or negedge rst) 
// begin: REGISTERS_READ
	// if(!rst) 
			// PRDATA<= {AMBA_WORD{1'b0}};
	// else 
			// PRDATA<= PRDATA_REG;
// end

always @(posedge clk or negedge rst) begin : Register_Selction_Read
	if(!rst)
		PRDATA <= {AMBA_WORD{1'b0}};
	else
		begin
		  if(!PWRITE)
			begin
				case(PADDR[3:2]) // PREAD: CPU Reads from registers
				  2'b00 : PRDATA <= CTRL_REG;
				  2'b01 : PRDATA <= DATA_IN_REG;
				  2'b10 : PRDATA <= CODEWORD_WIDTH_REG;
				  default : PRDATA <= NOISE_REG;
				endcase
			end
		end
end




//#################################
//To make sure num_of_errors get the right value, we keep NOF in next_num_of_errors
always@(current_state or num_of_errors or NOF) 
begin : N_NOF_CONTROL
	case (current_state)
		NOISE: begin	//=================ENCODING State//=================
					next_num_of_errors = NOF;
				end			
		default: begin	////=================IDLE State//=================
					case(num_of_errors)
						2'b00: next_num_of_errors = 2'b00;
						2'b01: next_num_of_errors = 2'b01;
						default : next_num_of_errors = 2'b10;
							
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

assign Small  = ~CODEWORD_WIDTH_REG[1] & ~CODEWORD_WIDTH_REG[0];
assign Medium = ~CODEWORD_WIDTH_REG[1] &  CODEWORD_WIDTH_REG[0];
assign Large  =  CODEWORD_WIDTH_REG[1] & ~CODEWORD_WIDTH_REG[0];



//#################################
//This machine receives various types of data width. since we want to support all types of data, we padd with zeroes and push the data to the MSB bits.
always@(CTRL_REG or DATA_IN_REG or Small or Medium)
begin: Zero_padding
	case (CTRL_REG[1:0])
	
		2'b01: 	
			begin																		//default - encode or full channel, data received without parity bits
				if(Small) 
					begin
						DATA_IN_Pad = {{DATA_IN_REG[7:0]},{32-8{1'b0}}};		//Data width = 00x: data_in is 8 bits, when the 4 LSB are the values, and 4 MSB are zeroes or dont cares
					end
				else 
				if (Medium) 
					begin
						DATA_IN_Pad = {{DATA_IN_REG[15:0]},{32-16{1'b0}}};		//Data width = 01x: data_in is 16 bits, when the 11 LSB are the values, and 5 MSB are zeroes or dont cares
					end
				else 
					begin
						DATA_IN_Pad = DATA_IN_REG;		//Data width = 10x: data_in is 32 bits, when the 25 LSB are the values, and 6 MSB are zeroes or dont cares
					end
			end
				// DATA_IN_Pad = {{DATA_IN_REG[DATA_WIDTH-1:0]},{32-DATA_WIDTH{1'b0}}};		//Decode - need all data width since the parity is already added
		
		default: 
			begin																		//default - encode or full channel, data received without parity bits
				if(Small) 
					begin
						DATA_IN_Pad = {{DATA_IN_REG[3:0]},{28{1'b0}}};		//Data width = 00x: data_in is 8 bits, when the 4 LSB are the values, and 4 MSB are zeroes or dont cares
					end
				else 
				if (Medium) 
					begin
						DATA_IN_Pad = {{DATA_IN_REG[10:0]},{21{1'b0}}};		//Data width = 01x: data_in is 16 bits, when the 11 LSB are the values, and 5 MSB are zeroes or dont cares
					end
				else 
					begin
						DATA_IN_Pad = {{DATA_IN_REG[25:0]},{6{1'b0}}};		//Data width = 10x: data_in is 32 bits, when the 25 LSB are the values, and 6 MSB are zeroes or dont cares
					end
			end
	endcase
end
 
endmodule