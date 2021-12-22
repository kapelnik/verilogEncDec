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

integer test,test1,test2 ;
logic [1:0] APB_bus_Test ;


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
		begin
			test = sample_walking_1(coverage_bus.NOISE[DATA_WIDTH-1:0]);
			if($countones(coverage_bus.NOISE[DATA_WIDTH-1:0]) == 2) begin
				test1 = Sample_two(coverage_bus.NOISE[DATA_WIDTH-1:0],0);
				test2 = Sample_two(coverage_bus.NOISE[DATA_WIDTH-1:0],test1+1);
				
			end
			else begin
						test2 = -1;
						test1 = -1;
					end
		end
end
		  
covergroup Error_spot @(negedge coverage_bus.operation_done);

   One_error_spot: coverpoint test iff(coverage_bus.CTRL_REG[1:0] != 2'b00){
      bins Noise_index[] = {[0:DATA_WIDTH-1]};
	  ignore_bins Noise_two_zero = {-1 };
   }
   Two_error_spot1: coverpoint test1 iff(coverage_bus.CTRL_REG[1:0] != 2'b00){
      bins Noise_index1[] = {[0:DATA_WIDTH-2]};
	  ignore_bins Noise_two_zero1 = {-1 };
   }
   Two_error_spot2: coverpoint test2 iff(coverage_bus.CTRL_REG[1:0] != 2'b00){
      bins Noise_index2[] = {[1:DATA_WIDTH-1]};
	  ignore_bins Noise_two_zero2 = {-1 };
   }
	Two_error_spot : cross Two_error_spot1,Two_error_spot2 {
	ignore_bins ignore_the_opposite = Two_error_spot with ((Two_error_spot1 > Two_error_spot2)|| (Two_error_spot1 == Two_error_spot2));
	}
   
endgroup

function integer sample_walking_1(bit[DATA_WIDTH-1:0] x);
	integer temp ;
	if($onehot(x)) begin
	   for(integer i=0;i<DATA_WIDTH;i++)begin
		temp = sample(x, i);
		if(temp > -1 )
			return temp; 
	   end
	end
	else
		return -1 ;
endfunction

//for each index in NOISE vector, if onehot is true, sample this index.
function integer sample(bit[DATA_WIDTH-1:0] x, integer position);
   if (x[position]==1)
        return position;
   else
		return -1;
endfunction

function integer Sample_two(bit[AMBA_WORD-1:0] x,Init);
	integer temp ;
		for(integer i = Init ; i<DATA_WIDTH ; i++)begin
			temp = sample(x, i);
		if(temp > -1 )
			return temp; 
	   end
	return -1 ;
endfunction
//add all covergroups to the Coverage:
		signals_test 						tst1 = new();
		amount_of_noise_test 				tst2 = new();
		Error_spot 							tst3 = new();

endmodule
