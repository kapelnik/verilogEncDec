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
module Register_selctor
#(
parameter DATA_WIDTH = 32,
parameter AMBA_ADDR_WIDTH = 20,
parameter AMBA_WORD = 32
)
(
input wire clk,
input wire rst,
input wire [AMBA_ADDR_WIDTH-1:0] PADDR,
input wire [AMBA_WORD-1:0] PWDATA,
input wire PENABLE,
input wire PSEL,
input wire PWRITE,
output reg [AMBA_WORD-1:0] PRDATA,
output reg [AMBA_WORD-1:0] CTRL ,
output reg [AMBA_WORD-1:0] DATA_IN,
output reg [AMBA_WORD-1:0] CODEWORD_WIDTH,
output reg [AMBA_WORD-1:0] NOISE
);




always @(posedge clk or negedge rst) begin
  if(!rst) 
	  begin
		PRDATA <= {AMBA_WORD{1'b0}};
		CTRL <= {AMBA_WORD{1'b0}};
		DATA_IN <= {AMBA_WORD{1'b0}};
		CODEWORD_WIDTH <= {AMBA_WORD{1'b0}};
		NOISE <= {AMBA_WORD{1'b0}};
	  end
  else 
	  begin
		if( PSEL & PENABLE) 
			begin
			    if( PWRITE) 
					begin
						case(PADDR[3:2]) // Check RTL
						  2'b00 : CTRL <= PWDATA;
						  2'b01 : DATA_IN <= PWDATA;
						  2'b10 : CODEWORD_WIDTH <= PWDATA;
						  default : NOISE <= PWDATA;
						endcase
					end
			    else 
				begin
					case(PADDR[3:2]) // Read to CPU
					  2'b00 : PRDATA <= CTRL;
					  2'b01 : PRDATA <= DATA_IN;
					  2'b10 : PRDATA <= CODEWORD_WIDTH;
					  default : PRDATA <= NOISE;
					endcase
				end
			end
	  end
end

endmodule