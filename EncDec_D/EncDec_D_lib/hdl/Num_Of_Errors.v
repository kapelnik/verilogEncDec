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
(
// input clk,
input [4:0] Yin, // Pirty from the encoder
input [31:0] DATA_IN, // Pirty from the data
input  Small,
input  Medium,
output reg [1:0] NOF , //Number of errors
output reg [4:0] NOE_Out  // telling what row to fix
);
reg [4:0] Prity_Y;
// reg [5:0] Prity_data;
reg [5:0] S;

//using the following lines - A-Z, we will implement  matrix multiply




always@(*) begin : Get_S // Cheking parity and size
  //============================================================// TODO move to another entity at the top
  //only one of the following will be 1, the rest 0
  // Small   <=  ~(CODEWORD_WIDTH[0] | CODEWORD_WIDTH[1]);
  // Medium  <=  CODEWORD_WIDTH[0] & ~CODEWORD_WIDTH[1];
  // Large   <=  CODEWORD_WIDTH[1] & ~CODEWORD_WIDTH[0];
  

  //============================================================//
  // S[4:0] <= Prity_Y[4:0] ^ Prity_data[4:0];
  // S[5]   <= Prity_Y[5] ^ Prity_data[4]^ Prity_data[3]^ Prity_data[2]^ Prity_data[1]^ Prity_data[0];
    if(Small) 
		begin
		  	S[5] <= ^DATA_IN;

			S[4:3] <= 2'b00;
			S[2] <= Prity_Y[2]^DATA_IN[26];
			S[1] <= Prity_Y[1]^DATA_IN[25];
			S[0] <= Prity_Y[0]^DATA_IN[24];
		end
	else 
		if (Medium) 
			begin
			  	S[5] <= ^DATA_IN;

				S[4] <= 1'b0;
				S[3:0] <= Prity_Y[3:0]^DATA_IN[19:16];
			end
		else 
			begin
			  	S[5] <= ^DATA_IN;

				S[4:0] <= Prity_Y[4:0]^DATA_IN[4:0];
			end
end

//============================================================//
always @(*) begin : Check_Number_Of_Errors// Number of errors
  // if(rst) begin
  
    // NOE_Out <= S[4:0]; // Index of error
		if(S[5])
			begin
				NOF[0] <= S[0] | S[1] | S[2] | S[3] | S[4] ;
				NOF[1] <= 1'b0;
			end
		else
			begin
				NOF[0] <= 1'b0;
				NOF[1] <= S[0] | S[1] | S[2] | S[3] | S[4] ;
			end
    // NOF[0] <= S[5] & ( S[0] | S[1] | S[2] | S[3] | S[4]) ;
	// NOF[1] <= ~S[5] & ( S[0] | S[1] | S[2] | S[3] | S[4]) ;
   
  end
  
  always @(*) begin : Index_Of_Errors// Number of errors
  // if(rst) begin
  
    NOE_Out <= S[4:0]; // Index of error 
    // NOF[0] <= S[5] & ( S[0] | S[1] | S[2] | S[3] | S[4]) ;
	// NOF[1] <= ~S[5] & ( S[0] | S[1] | S[2] | S[3] | S[4]) ;
   
  end
  

  
always @(*) begin : Get_Both_Parities// Pirty Fixing
		if(Small) 
			begin
				Prity_Y<={{2'b00},{Yin[2:0]}};
				// Prity_data<={{DATA_IN[3]},{2'b00},{DATA_IN[2:0]}};
			end
		else 
			if (Medium) 
				begin
					Prity_Y<={{1'b0},{Yin[3:0]}};
					// Prity_data<={{DATA_IN[4]},{1'b0},{DATA_IN[3:0]}};
				end
			else 
				begin
					Prity_Y<=Yin;
					// Prity_data<=DATA_IN;
				end
	
end


endmodule