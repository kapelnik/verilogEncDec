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
module Register_selctor
#(
// parameter DATA_WIDTH = 32,
// parameter AMBA_ADDR_WIDTH = 20,
parameter AMBA_WORD = 32
)
(
input wire clk,
input wire rst,
input wire [1:0] PADDR,
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

wire start_work;


// This module is the register bank of the ECC_ENC_DEC module. the parameter got from the top entity are the sizes of the registers.
// To interact with module(R/W), follow the AMBA APB bus protocol.


//when PSEL&PENABLE are 1 start work, depending on R/W -> PWRITE,PADDR
assign start_work = PSEL;



always @(posedge clk or negedge rst) begin : Register_Selction
  if(!rst) 
	  begin
		
		CTRL <= {AMBA_WORD{1'b0}};
		DATA_IN <= {AMBA_WORD{1'b0}};
		CODEWORD_WIDTH <= {AMBA_WORD{1'b0}};
		NOISE <= {AMBA_WORD{1'b0}};
	  end
  else 
	  begin
		if(start_work) 
			begin
			    if( PWRITE) 
					begin//OFFSET OF THE ADDRES IS THE SELECTED REGISTER
						case(PADDR) // Check RTL
						  2'b00 : CTRL <= PWDATA;
						  2'b01 : DATA_IN <= PWDATA;
						  2'b10 : CODEWORD_WIDTH <= PWDATA;
						  default : NOISE <= PWDATA;
						endcase
					end
			    // else 
				// begin
					// case(PADDR) // PREAD: CPU Reads from registers
					  // 2'b00 : PRDATA <= CTRL;
					  // 2'b01 : PRDATA <= DATA_IN;
					  // 2'b10 : PRDATA <= CODEWORD_WIDTH;
					  // default : PRDATA <= NOISE;
					// endcase
				// end
			end
	  end
end

endmodule