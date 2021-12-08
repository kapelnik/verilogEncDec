//
// Verilog Module Project1_lib.Register_selctor
//
// Created:
//          by - benmaorr.refael,kapelnik.Tal (L330W509)
//          at - 11:29:09 11/15/2021
//
// using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
//

`resetall
`timescale 1ns/10ps
module Encoder
//Here we use parameters, BUT we will not change the default values. Top entity will pad zeroes to the input.
#(
// parameter DATA_WIDTH = 32,
// parameter AMBA_ADDR_WIDTH = 20,
parameter AMBA_WORD = 32
)
(
input    clk,
input    rst,
input    Small,
input    Medium,
input    Large,
input   [AMBA_WORD-1:0] DATA_IN,
// input wire  [1:0] CODEWORD_WIDTH,
output reg 	[AMBA_WORD-1:0] Enc_Out 

);

//using the following lines - A-Z, we will implement  matrix multiply
// With this component we calculate the parity, in order to reduce calculation and space (XOR gates)
 // in the design, we minimized the XOR gates by using repeating calculations for C1, … , Cn. 
//reg A,B,C,E,F,G,H,I,J,K,M,O,P,R,T,V,W,Y,Z,AC,ACE,ACEG,AE,IK,PR;
wire [31:0] YOUT;// 		= {32{1'b0}};
wire [24:0] xor_gates ;


  assign xor_gates[0]   = DATA_IN[31]^DATA_IN[30];   // A
  assign xor_gates[1]   = DATA_IN[30]^DATA_IN[29];	// B
  assign xor_gates[2]   = DATA_IN[29]^DATA_IN[28];	// C
  //D<= DATA_IN[28]^DATA_IN[27]; NOT USED
  assign xor_gates[3]   = DATA_IN[27]^DATA_IN[26];	// E
  assign xor_gates[4]   = DATA_IN[26]^DATA_IN[25];	// F
  assign xor_gates[5]   = DATA_IN[25]^DATA_IN[24];	// G
  assign xor_gates[6]   = DATA_IN[24]^DATA_IN[23];	// H
  assign xor_gates[7]   = DATA_IN[23]^DATA_IN[22];	// I
  assign xor_gates[8]   = DATA_IN[22]^DATA_IN[21];	// J
  assign xor_gates[9]   = DATA_IN[21]^DATA_IN[20];	// K
  //L <= DATA_IN[20]^DATA_IN[19]; NOT USED
  assign xor_gates[10]   = DATA_IN[19]^DATA_IN[18];	// M
  //N <= DATA_IN[18]^DATA_IN[17]; NOT USED
  assign xor_gates[11]   = DATA_IN[17]^DATA_IN[16];	// O
  assign xor_gates[12]   = DATA_IN[16]^DATA_IN[15];	// P
  //Q <= DATA_IN[15]^DATA_IN[14]; NOT USED
  assign xor_gates[13]   = DATA_IN[14]^DATA_IN[13];	// R
  //S <= DATA_IN[13]^DATA_IN[12]; NOT USED
  assign xor_gates[14]   = DATA_IN[12]^DATA_IN[11];	// T
  //U <= DATA_IN[11]^DATA_IN[10];
  // assign xor_gates[15]   = DATA_IN[10]^DATA_IN[9];	//// V
  assign xor_gates[16]   = DATA_IN[9]^DATA_IN[8];	// W
  //X <= DATA_IN[8]^DATA_IN[7]; NOT USED
  assign xor_gates[17]   = DATA_IN[7]^DATA_IN[6];	// Y
  assign xor_gates[18]   = DATA_IN[31]^DATA_IN[29]^DATA_IN[27];	// Z
  // AC  <= A^C;
  // ACE <= AC^E;
  // ACEG<= ACE^G;
  // xor_gates[20]  <=A^E;
  // IK  <=I^K;
  // PR  <=P^R;
  assign xor_gates[19]  = xor_gates[0]^xor_gates[2];	// AC
  assign xor_gates[20]  = xor_gates[0]^xor_gates[3];	// AE
  assign xor_gates[21]  =xor_gates[7]^xor_gates[9];	// IK
  assign xor_gates[22]  =xor_gates[12]^xor_gates[13];	// PR
  assign xor_gates[23] = xor_gates[19]^xor_gates[3];	// ACE
  assign xor_gates[24]= xor_gates[23]^xor_gates[5];	// ACEG

//============================================================//
//always @(*) begin : Encode_Data
  // if(rst) begin
      
    //This block is for the parity of the small input
    assign YOUT[31:28] = DATA_IN[31:28];
    assign YOUT[27]    = Small ?  xor_gates[1]^DATA_IN[28]  : DATA_IN[27];//C5
    assign YOUT[26]    = Small ?  xor_gates[0]^DATA_IN[29]  : DATA_IN[26];//C6
    assign YOUT[25]    = Small ?  xor_gates[0]^DATA_IN[28]  : DATA_IN[25];//C7
    assign YOUT[24]    = Small ?  xor_gates[2]^DATA_IN[31]  : DATA_IN[24];//C8
    
    assign YOUT[23:21] = DATA_IN[23:21];
    
    // This block is for the parity of the medium input
    assign YOUT[20] = Medium ?  DATA_IN[31]^DATA_IN[28]^DATA_IN[21]^xor_gates[4]^xor_gates[7]    : DATA_IN[20];//C12
    assign YOUT[19] = Medium ?  DATA_IN[25]^xor_gates[23]                         				 : DATA_IN[19];//C13
    assign YOUT[18] = Medium ?  xor_gates[0]^xor_gates[2]^xor_gates[6]^DATA_IN[22]               : DATA_IN[18];//C14
    assign YOUT[17] = Medium ?  xor_gates[20]^xor_gates[6]^DATA_IN[21]                     	     : DATA_IN[17];//C15
    assign YOUT[16] = Medium ?  xor_gates[18]^xor_gates[5]^xor_gates[8]                          : DATA_IN[16];//C16
    
    assign YOUT[15:6] = DATA_IN[15:6];
    
    // This block is for the parity of the large input
    assign YOUT[5] = Large ?  xor_gates[1]^xor_gates[6]^xor_gates[11]^xor_gates[17]^DATA_IN[27]^DATA_IN[20]^DATA_IN[18]^DATA_IN[13]^DATA_IN[11]^DATA_IN[8] 	    			: DATA_IN[5];//C27
    assign YOUT[4] = Large ?  xor_gates[24]^xor_gates[21]^xor_gates[10]^DATA_IN[17] 																	  	    			: DATA_IN[4];//C28
    assign YOUT[3] = Large ?  xor_gates[24]^xor_gates[22]^xor_gates[14]^DATA_IN[10]																		 	    			: DATA_IN[3];//C29
    assign YOUT[2] = Large ?  xor_gates[19]^xor_gates[21]^xor_gates[22]^xor_gates[16]^DATA_IN[7]  													    					: DATA_IN[2];//C30
    assign YOUT[1] = Large ?  xor_gates[20]^xor_gates[7]^xor_gates[10]^xor_gates[12]^xor_gates[14]^DATA_IN[8]^DATA_IN[6]^DATA_IN[9]							 		   		: DATA_IN[1];//C31
    assign YOUT[0] = Large ?  xor_gates[18]^xor_gates[11]^DATA_IN[9]^DATA_IN[10]^xor_gates[17]^DATA_IN[25]^DATA_IN[23]^DATA_IN[21]^DATA_IN[19]^DATA_IN[14]^DATA_IN[12]   	: DATA_IN[0];//C32

	
 
always @(posedge clk or negedge rst) begin : Size_Check    
	if(!rst) 
		begin
			Enc_Out <= {AMBA_WORD{1'b0}};
		end
	else 
		begin
			//YOUT is the encoded word, set it to Enc_Out with padding to the left
			if(Small) 
				begin
					Enc_Out<={YOUT[AMBA_WORD-9:0],YOUT[31:24]};
				end
			else 
				if (Medium) 
					begin
						Enc_Out<={YOUT[AMBA_WORD-17:0],YOUT[31:16]};
					end
				else 
					begin
						Enc_Out<=YOUT;
					end
		end
	
end


endmodule