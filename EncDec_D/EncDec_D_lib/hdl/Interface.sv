//
// Verilog interface ECC_ENC_DEC_lib.Interface
//
// Created:
//          by - kapelnik.UNKNOWN (L330W529)
//          at - 10:58:36 12/ 6/2021
//
// using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
//

`resetall
`timescale 1ns/10ps
interface Interface #(
//input Params
parameter DATA_WIDTH = 32,
parameter AMBA_ADDR_WIDTH = 20,
parameter AMBA_WORD = 32
);

//signals declaration
logic clk;
logic rst;
logic ena;




//modports declaration
modport stimulus (output clk, rst, ena, im_pixel, w_pixel, param);
modport ECC_ENC_DEC (input clk, rst, PADDR, PWDATA, PENABLE, PSEL,PWRITE, output PRDATA, data_out, operation_done, num_of_errors);
modport checker_coverager (input clk, rst, ena, im_pixel, w_pixel, param, iw_pixel);
modport vsgoldenmodel (input ena, iw_pixel);

endinterface
