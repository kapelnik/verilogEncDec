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
   // modport Checker 		(input clk, rst, PADDR, PWDATA, PENABLE, PSEL, PWRITE, PRDATA, data_out, operation_done, num_of_errors, gm_DATA_OUT,gm_number_of_errors);
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


//##operation_done properties: 	
//operation should be done in two to three cycles:
// PSEL&PENABLE&PWRITE	&& PADDR==00 ( write to control) => ## after 2-3  cycles  - operation_done=1.
property operation_done_active;
				@(checker_bus.clk) ( checker_bus.PSEL && checker_bus.PENABLE && checker_bus.PWRITE && (checker_bus.PADDR[3:0] == 4'b0000)) |-> ## [1:8] checker_bus.operation_done;
				endproperty
assert property(operation_done_active)
  else $error("error with operation_done");
	cover property(operation_done_active);
	
property ResultCheck;
				@(checker_bus.operation_done) (checker_bus.operation_done == 1) |-> (checker_bus.data_out == checker_bus.gm_DATA_OUT);
				endproperty
assert property(ResultCheck)
  else $error("error with ResultCheck");
	cover property(ResultCheck);
	
property NumOfErrorsCheck;
				@(checker_bus.operation_done) (checker_bus.operation_done == 1) |-> (checker_bus.gm_number_of_errors == checker_bus.num_of_errors);
				endproperty
assert property(NumOfErrorsCheck)
  else $error("error with NumOfErrorsCheck");
	cover property(NumOfErrorsCheck);
	
property RegistersReadCheck;
				@(checker_bus.clk) ((checker_bus.PENABLE == 1'b1)&& (checker_bus.PSEL == 1'b1) && (checker_bus.PWRITE == 1'b0)) |->  (checker_bus.PRDATA == checker_bus.RegistersOut);
				endproperty
assert property(RegistersReadCheck)
  else $error("error with RegistersReadCheck");
	cover property(RegistersReadCheck);
////##

//property ena_active;
//				@(checker_bus.ena) checker_bus.ena==1 |=> (checker_bus.iw_pixel >= 0) && (checker_bus.iw_pixel <= 255);
//				endproperty

//assert property(ena_active)
//  else $error("error with enable");
//  cover property(ena_active);


endmodule
