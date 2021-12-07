//
// Verilog Module ECC_ENC_DEC_lib.Coverage
//
// Created:
//          by - kapelnik.UNKNOWN (L330W529)
//          at - 13:35:54 12/ 6/2021
//
// using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
//

`resetall
`timescale 1ns/10ps
module Coverage  #(
//input Params
parameter DATA_WIDTH = 32,
parameter AMBA_ADDR_WIDTH = 20,
parameter AMBA_WORD = 32
)
(
  Interface.Coverage coverage_bus
);

//Cover Groups:
covergroup signals_test @(posedge coverage_bus.clk);
    // did reset ranged from 1:0
			reset : coverpoint coverage_bus.rst{
       bins low = {0};
       bins high = {1};
     }
     
    // did operation_done ranged from 1:0
			op_done : coverpoint coverage_bus.operation_done{
       bins low = {0};
       bins high = {1};
     }
     
     
     
     
endgroup




//
// Instance of covergroup regular_test
signals_test tst1 = new();

endmodule
