//
// Verilog Module ECC_ENC_DEC_lib.Checker
//
// Created:
//          by - kapelnik.UNKNOWN (L330W529)
//          at - 14:40:43 12/ 6/2021
//
// using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
//

`resetall
`timescale 1ns/10ps
module Checker #(
//input Params
parameter DATA_WIDTH = 32,
parameter AMBA_ADDR_WIDTH = 20,
parameter AMBA_WORD = 32
)
( 
   // Port Declarations
   Interface.Checker checker_bus
);


//###### Properties ###### 

//##Reset properties: 			
property rst_active;
				@(checker_bus.rst) checker_bus.rst==1 |=> ((checker_bus.data_out >= 0) && (checker_bus.operation_done <= 1'b0)) || (checker_bus.num_of_errors == 2'b0);
				endproperty
assert property(rst_active)
  else $error("error with Reset");
  cover property(rst_active);
////##

//property ena_active;
//				@(checker_bus.ena) checker_bus.ena==1 |=> (checker_bus.iw_pixel >= 0) && (checker_bus.iw_pixel <= 255);
//				endproperty

//assert property(ena_active)
//  else $error("error with enable");
//  cover property(ena_active);


endmodule
