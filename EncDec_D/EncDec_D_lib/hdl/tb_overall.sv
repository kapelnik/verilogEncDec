//
// Verilog Module ECC_ENC_DEC_lib.tb_overall
//
// Created:
//          by - kapelnik.UNKNOWN (L330W529)
//          at - 11:31:00 12/ 6/2021
//
// using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
//

`resetall
`timescale 1ns/10ps
module tb_overall #(
//input Params
parameter DATA_WIDTH = 32,
parameter AMBA_ADDR_WIDTH = 20,
parameter AMBA_WORD = 32
);

Interface tb();

Stimulus gen(
  .stim_bus(tb)
  );

ECC_ENC_DEC dut(
   .clk            (tb.clk),
   .rst            (tb.rst),
   .PADDR          (tb.PADDR),
   .PWDATA         (tb.PWDATA),
   .PENABLE        (tb.PENABLE),
   .PSEL           (tb.PSEL),
   .PWRITE         (tb.PWRITE),
   .PRDATA         (tb.PRDATA),
   .data_out       (tb.data_out),
   .operation_done (tb.operation_done),
   .num_of_errors  (tb.num_of_errors)
);

Coverage cov(
    .coverage_bus(tb)
    );
    
Checker check(
    .checker_bus(tb)
    );
    
//GoldModel res_test(
//    .gold_bus(tb)
//    );

// ### Please start your Verilog code here ### 

endmodule
