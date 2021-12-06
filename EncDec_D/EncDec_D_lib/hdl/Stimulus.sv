//
// Verilog Module ECC_ENC_DEC_lib.Stimulus
//
// Created:
//          by - kapelnik.UNKNOWN (L330W529)
//          at - 11:12:18 12/ 6/2021
//
// using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
//

`resetall
`timescale 1ns/10ps
module Stimulus #(
//input Params 
parameter DATA_WIDTH = 32,
parameter AMBA_ADDR_WIDTH = 20,
parameter AMBA_WORD = 32
)
(
//Port Declerations:      Stim_Bus is the implementation of AMBA APB  
  Interface.Stimulus stim_bus
);
`define NULL 0
// Data Types



//clk simulation:
always begin : clock_generator_proc
  #10 stim_bus.clk = ~stim_bus.clk;
end

initial 
begin : stim_proc
  // Initilization
    stim_bus.clk = 1; // start with clock and reset at '1', while enable at '0'
    stim_bus.rst = 1;
    @(posedge stim_bus.clk); // wait til next rising edge (in other words, wait 20ns)
    stim_bus.rst = 0;
  
end

// ### Please start your Verilog code here ### 

endmodule
