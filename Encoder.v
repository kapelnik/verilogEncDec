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
input wire clk,
input wire rst,
input wire [AMBA_WORD-1:0] PWDATA,
output reg [AMBA_WORD-1:0] PRDATA,
output reg [AMBA_WORD-1:0] Y,
output reg [AMBA_WORD-1:0] CTRL ,
output reg [AMBA_WORD-1:0] DATA_IN,
output reg [AMBA_WORD-1:0] CODEWORD_WIDTH,
output reg [AMBA_WORD-1:0] NOISE
);
wire Small, Medium,Large;

always @(posedge clk or negedge rst) begin
  Y[4] = Small ?  B&4  : data[4];
end


always@(*) begin
  Small = ~(width[0] | width[1]);
  Medium = width[0] & ~width[1];
  Large = width[1] & ~width[0];
end

endmodule