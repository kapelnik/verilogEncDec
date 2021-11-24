//
// Verilog Module Project_lib.Num_Of_Errors
//
// Created:
//          by - benmaorr.UNKNOWN (L330W516)
//          at - 12:18:28 11/22/2021
//
// using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
//

`resetall
`timescale 1ns/10ps
module Num_Of_Errors 
#(
parameter DATA_WIDTH = 32,
parameter AMBA_ADDR_WIDTH = 20,
parameter AMBA_WORD = 32
)
(
input clk,
input [5:0] Yin, // Pirty from the encoder
input [5:0] DATA_IN, // Pirty from the data
input  Small,
input  Medium,
output reg [1:0] NOF = {2'b00}, //Number of errors
output reg [4:0] OUT = {5'b00000} // telling what row to fix
);
reg [5:0] Prity_Y;
reg [5:0] Prity_data;
reg [5:0] S;

//using the following lines - A-Z, we will implement  matrix multiply




always@(*) begin // Cheking parity and size
  //============================================================// TODO move to another entity at the top
  //only one of the following will be 1, the rest 0
  // Small   <=  ~(CODEWORD_WIDTH[0] | CODEWORD_WIDTH[1]);
  // Medium  <=  CODEWORD_WIDTH[0] & ~CODEWORD_WIDTH[1];
  // Large   <=  CODEWORD_WIDTH[1] & ~CODEWORD_WIDTH[0];
  

  //============================================================//
  S <= Prity_Y ^ Prity_data;
  
  
end

//============================================================//
always @(*) begin // Number of errors
  // if(rst) begin
  
    OUT <= S[4:0];  
    NOF[0] <= S[5];
	NOF[1] <= ~S[5] & ( S[0] | S[1] | S[2] | S[3] | S[4]) ;
   
  end
  

  
always @(*) begin // Pirty Fixing
		if(Small) begin
			Prity_Y<={{Yin[3]},{2'b00},{Yin[2:0]}};
			Prity_data<={{DATA_IN[3]},{2'b00},{DATA_IN[2:0]}};
		end
		else if (Medium) begin
			Prity_Y<={{Yin[4]},{1'b0},{Yin[3:0]}};
			Prity_data<={{DATA_IN[4]},{1'b0},{DATA_IN[3:0]}};
		end
		else begin
			Prity_Y<=Yin;
			Prity_data<=DATA_IN;
		end
	
end


endmodule