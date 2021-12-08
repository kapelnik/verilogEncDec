//
// Verilog Module EncDec_D_lib.GoldenModle
//
// Created:
//          by - benmaorr.UNKNOWN (L330W530)
//          at - 14:23:48 12/ 8/2021
//
// using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
//

`resetall
`timescale 1ns/10ps
module GoldenModle 
#(
    parameter DATA_WIDTH = 32,
	parameter AMBA_ADDR_WIDTH = 20,
	parameter AMBA_WORD = 32
)
( 
   // Port Declarations
   Interface.vsgoldenmodel gold_bus
);

`define NULL 0
// Data Types
initial
begin : init_proc
	always@(posedge  gold_bus.opration_done) begin
		// NOF bus
		gold_bus.gm_number_of_errors[0] =  (^gold_bus.NOISE) & (|gold_bus.NOISE);
		gold_bus.gm_number_of_errors[1] = ~(^gold_bus.NOISE) & (|gold_bus.NOISE);
		
		// Data out
		
		gold_bus.gm_DATA_OUT = gold_bus.DATA_IN ;
	end
	
end



endmodule
