//
// Verilog Module Project1_lib.Register_selctor
//
// Created:
//          by - benmaorr.UNKNOWN (L330W509)
//          at - 11:29:09 11/15/2021
//
// using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
//

`resetall
`timescale 1ns/10ps
module Encoder
//Here we use parameters, BUT we will not change the default values. Top entity will pad zeroes to the input.
#(
parameter DATA_WIDTH = 32,
parameter AMBA_ADDR_WIDTH = 32,
parameter AMBA_WORD = 32
)
(
input  clk,
input  rst,
input [AMBA_WORD-1:0] DATA_IN,
input [1:0] CODEWORD_WIDTH,
output reg [AMBA_WORD-1:0] OUT = {AMBA_WORD{1'b0}}
);
reg Small, Medium,Large;
//using the following lines - A-Z, we will implement  matrix multiply
reg A,B,C,E,F,G,H,I,J,K,M,O,P,Q,R,T,V,W,Y,Z,AC,ACE,ACEG,AE,IK,PR;
reg [AMBA_WORD-1:0] YOUT = {AMBA_WORD{1'b0}};




always@(*) begin
  //============================================================//
  //only one of the following will be 1, the rest 0
  Small   <=  ~(CODEWORD_WIDTH[0] | CODEWORD_WIDTH[1]);
  Medium  <=  CODEWORD_WIDTH[0] & ~CODEWORD_WIDTH[1];
  Large   <=  CODEWORD_WIDTH[1] & ~CODEWORD_WIDTH[0];
  

  //============================================================//
  A   <= DATA_IN[31]^DATA_IN[30];
  B   <= DATA_IN[30]^DATA_IN[29];
  C   <= DATA_IN[29]^DATA_IN[28];
  //D<= DATA_IN[28]^DATA_IN[27]; NOT USED
  E   <= DATA_IN[27]^DATA_IN[26];
  F   <= DATA_IN[26]^DATA_IN[25];
  G   <= DATA_IN[25]^DATA_IN[24];
  H   <= DATA_IN[24]^DATA_IN[23];
  I   <= DATA_IN[23]^DATA_IN[22];
  J   <= DATA_IN[22]^DATA_IN[21];
  K   <= DATA_IN[21]^DATA_IN[20];
  //L <= DATA_IN[20]^DATA_IN[19]; NOT USED
  M   <= DATA_IN[19]^DATA_IN[18];
  //N <= DATA_IN[18]^DATA_IN[17]; NOT USED
  O   <= DATA_IN[17]^DATA_IN[16];
  P   <= DATA_IN[16]^DATA_IN[15];
  Q   <= DATA_IN[15]^DATA_IN[14];
  R   <= DATA_IN[14]^DATA_IN[13];
  //S <= DATA_IN[13]^DATA_IN[12]; NOT USED
  T   <= DATA_IN[12]^DATA_IN[11];
  //U <= DATA_IN[11]^DATA_IN[10];
  V   <= DATA_IN[10]^DATA_IN[9];
  W   <= DATA_IN[9]^DATA_IN[8];
  //X <= DATA_IN[8]^DATA_IN[7]; NOT USED
  Y   <= DATA_IN[7]^DATA_IN[6];
  Z   <= DATA_IN[31]^DATA_IN[29]^DATA_IN[27];
  AC  <= A^C;
  ACE <= AC^E;
  ACEG<= ACE^G;
  AE  <=A^E;
  IK  <=I^K;
  PR  <=P^R;  
end

//============================================================//
always @(*) begin
  // if(rst) begin
      
    //This block is for the parity of the small input
    YOUT[31:28] <=DATA_IN[31:28];
    YOUT[27] <= Small ?  B^DATA_IN[28]  : DATA_IN[27];//C5
    YOUT[26] <= Small ?  A^DATA_IN[29]  : DATA_IN[26];//C6
    YOUT[25] <= Small ?  A^DATA_IN[28]  : DATA_IN[25];//C7
    YOUT[24] <= Small ?  C^DATA_IN[31]  : DATA_IN[24];//C8
    
    YOUT[23:21] <=DATA_IN[23:21];
    
    // This block is for the parity of the medium input
    YOUT[20] <= Medium ?  DATA_IN[31]^DATA_IN[28]^DATA_IN[21]^F^I   : DATA_IN[20];//C12
    YOUT[19] <= Medium ?  DATA_IN[25]^ACE                          : DATA_IN[19];//C13
    YOUT[18] <= Medium ?  A^C^H^DATA_IN[22]                        : DATA_IN[18];//C14
    YOUT[17] <= Medium ?  AE^H^DATA_IN[21]                        : DATA_IN[17];//C15
    YOUT[16] <= Medium ?  Z^G^J                                   : DATA_IN[16];//C16
    
    YOUT[15:6] <=DATA_IN[15:6];
    
    // This block is for the parity of the large input
    YOUT[5] <= Large ?  B^H^O^Y^DATA_IN[27]^DATA_IN[20]^DATA_IN[18]^DATA_IN[13]^DATA_IN[20]^DATA_IN[8]  : 0;//C27
    YOUT[4] <= Large ?  ACEG^IK^M^DATA_IN[17]  : 0;//C28
    YOUT[3] <= Large ?  ACEG^PR^T^DATA_IN[10]  : 0;//C29
    YOUT[2] <= Large ?  AC^IK^PR^W^DATA_IN[7]  : 0;//C30
    YOUT[1] <= Large ?  AE^I^M^P^T^V^DATA_IN[8]^DATA_IN[6]  : 0;//C31
    YOUT[0] <= Large ?  Z^O^V^Y^DATA_IN[25]^DATA_IN[23]^DATA_IN[21]^DATA_IN[19]^DATA_IN[14]^DATA_IN[12]  : 0;//C32
    // end
  // else begin 
      // YOUT <= {AMBA_WORD{1'b0}};
    // end
  end
  
  
always @(posedge clk or negedge rst) begin//TODO Maybe change clk to negedge
  if(rst) begin
		if(Small) begin
			OUT<={YOUT>>24};
		end
		else if (Medium) begin
			OUT<={YOUT>>16};
		end
		else begin
			OUT<=YOUT;
		end
	end
	else begin
		OUT<={AMBA_WORD{1'b0}};
	end
	
end


endmodule