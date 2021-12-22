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
logic clk = 0;
logic rst = 0;

Interface  #(.DATA_WIDTH(DATA_WIDTH), .AMBA_ADDR_WIDTH(AMBA_ADDR_WIDTH), .AMBA_WORD(AMBA_WORD)) tb();

Stimulus gen(
  .stim_bus(tb)
  );

ECC_ENC_DEC  #(.DATA_WIDTH(DATA_WIDTH), .AMBA_ADDR_WIDTH(AMBA_ADDR_WIDTH), .AMBA_WORD(AMBA_WORD)) dut(
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

Coverage #(.DATA_WIDTH(DATA_WIDTH), .AMBA_ADDR_WIDTH(AMBA_ADDR_WIDTH), .AMBA_WORD(AMBA_WORD)) cov(
    .coverage_bus(tb)
    );
    
Checker #(.DATA_WIDTH(DATA_WIDTH), .AMBA_ADDR_WIDTH(AMBA_ADDR_WIDTH), .AMBA_WORD(AMBA_WORD)) check(
    .checker_bus(tb)
    );
    
GoldenModel #(.DATA_WIDTH(DATA_WIDTH), .AMBA_ADDR_WIDTH(AMBA_ADDR_WIDTH), .AMBA_WORD(AMBA_WORD)) goldmod(
   .gold_bus(tb)
   );
assign tb.clk = clk;
assign tb.rst = rst;    


//Simulate a clock for the verification system:
always begin : clock_generator_proc
  #10 clk = ~clk;
end

// this is a simulation of rst coming from outside(usynchronous rst). try to hit the rst both with and without waiting from clk posedge
initial 
begin : stim_proc
		rst = 0 ;
		
		@(posedge clk) ;
		rst = 1 ;
		
		repeat(306)@(posedge clk) ;
		#1.2;
	rst = 0;
	#100.2;
	rst = 1;
			repeat(303)@(posedge clk) ;
		#1.6;
	rst = 0;
	#100.5;
	rst = 1;
			repeat(306)@(posedge clk) ;
		#1.3;
	rst = 0;
	#100.8;
	rst = 1;
			repeat(306)@(posedge clk) ;
		#1.7;
	rst = 0;
	#100.6;
	rst = 1;
end
// ### Please start your Verilog code here ### 

endmodule
