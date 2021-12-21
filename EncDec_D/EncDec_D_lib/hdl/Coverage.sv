//
// Verilog Module ECC_ENC_DEC_lib.Coverage
//
// Created:
//          by - kapelnik.UNKNOWN (L330W529)
//          at - 13:35:54 12/ 6/2021
//
// using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
//
// https://verificationguide.com/systemverilog/systemverilog-coverage-options/ 
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

integer test ;
logic [1:0] APB_bus_Test ;
// initial begin
	// $display("Coverage = %0.2f %%",cg_inst.get_inst_covarge());
// end
//Cover Groups:

//This is an internal signal for coverage on the APB protocol simulated at stimulus
assign APB_bus_Test = {coverage_bus.PENABLE,coverage_bus.PSEL};

//This is the covergroup for all the signals simulated at the stimulus module to make sure all the data has been covered
covergroup signals_test @(posedge coverage_bus.clk, negedge coverage_bus.rst);
		// did reset ranged from 1:0
		reset : coverpoint coverage_bus.rst{
		   bins low = {0};
		   bins high = {1};
		 }
     
          // checking if the result PENABLE went to all the ranges
        PENABLE : coverpoint coverage_bus.PENABLE{
         bins low = {0};
         bins high = {1};
          }
		  
          // checking if the result PSEL went to all the ranges
        PSEL : coverpoint coverage_bus.PSEL{
         bins low = {0};
         bins high = {1};
          }
		  
          // checking if the result PWRITE went to all the ranges
        PWRITE : coverpoint coverage_bus.PWRITE{
         bins low = {0};
         bins high = {1};
          }
		  
          // checking if the result operation_done went to all the ranges
        Operation_done : coverpoint coverage_bus.operation_done{
         bins low = {0};
         bins high = {1};
          }
		 // PENABLE_X_PSEL: cross PENABLE,PSEL;
		 APB_bus_rule_test : coverpoint  APB_bus_Test{
		 bins Good = {2'b00,2'b01,2'b11} ;
		 illegal_bins bad = {2'b10} ;
		 }
		 
endgroup



covergroup amount_of_noise_test @(negedge coverage_bus.operation_done);
		 // checking if the amount of noise is good or passing the oreder for only 2 error at max
        amount : coverpoint coverage_bus.num_of_errors iff(coverage_bus.CTRL_REG[1:0] != 2'b00){
		 bins no_error = {0};
         bins one_error = {1};
		 bins two_error = {2};
		 bins system_error = default;
		 }
		amount_gm : coverpoint coverage_bus.gm_number_of_errors iff(coverage_bus.CTRL_REG[1:0] != 2'b00){
		 bins no_error = {0};
         bins one_error = {1};
		 bins two_error = {2};
		 bins system_error = default;
		 }
		
endgroup

//the next folowing blocks are ment to make sure that the Noise got all the options of one_hot 
always@(posedge coverage_bus.operation_done)
begin
	if(coverage_bus.CTRL_REG[1:0] != 2'b00)
		test = sample_walking_1(coverage_bus.NOISE);
end
		  
covergroup Error_spot @(negedge coverage_bus.operation_done);

   One_error_spot: coverpoint test iff(coverage_bus.CTRL_REG[1:0] != 2'b00){
      bins Noise_index[AMBA_WORD] = {[0:AMBA_WORD-1]};
	  bins Noise_two_zero = {-1 };
   }
   
endgroup

function integer sample_walking_1(bit[AMBA_WORD-1:0] x);
	integer temp ;
	
   for(integer i=0;i<AMBA_WORD;i++)begin
    temp = sample(x, i);
	if(temp > -1 )
		return temp; 
   end
   return -1 ;
endfunction

//for each index in NOISE vector, if onehot is true, sample this index.
function integer sample(bit[AMBA_WORD-1:0] x, integer position);
   if (x[position]==1 && $onehot(x) )
        return position;
   else
		return -1;
endfunction


//add all covergroups to the Coverage:
		signals_test 						test1 = new();
		amount_of_noise_test 				test2 = new();
		Error_spot 							test3 = new();

endmodule
