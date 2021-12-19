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

// initial begin
	// $display("Coverage = %0.2f %%",cg_inst.get_inst_covarge());
// end
//Cover Groups:
covergroup signals_test @(posedge coverage_bus.clk);
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

always@(posedge coverage_bus.operation_done)
begin
	if(coverage_bus.CTRL_REG[1:0] != 2'b00)
		test = sample_walking_1(coverage_bus.NOISE);
end
		  
covergroup walking_1_cg @(negedge coverage_bus.operation_done);

   walking_1: coverpoint test iff(coverage_bus.CTRL_REG[1:0] != 2'b00){
      bins Noise_index[AMBA_WORD] = {[0:AMBA_WORD-1]};
	  bins no_noise = {-1 };
   }
   
endgroup

covergroup APB_bus @(posedge coverage_bus.clk);

   APB_PENABLE: coverpoint coverage_bus.PENABLE iff(coverage_bus.PSEL == 1){
      bins low_to_high_PENABLE = (0 => 1);
      bins high_to_low_PENABLE = (1 => 0);
   }
   APB_PSEL: coverpoint coverage_bus.PSEL{
      bins low_to_high_PSEL = (0 => 1);
      bins high_to_low_PSEL = (1 => 0);
   }
   PENABLE_X_PSEL: cross APB_PENABLE,APB_PSEL;
   
   
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

// function integer one_hot(bit[AMBA_WORD-1:0] x);
	// integer flag = 0 ;
		// flag = 0;
		// for(integer i=0;i<AMBA_WORD;i++) begin
			// if(x[i] == 1)
				// flag++ ;
		// end
		
		// if(flag == 1)
			// return 1;
		// else
			// return 0;
// endfunction

// function integer One_error_spot( bit[AMBA_WORD-1:0] x);
	// integer temp,flag ;
	// flag = 0 ;
	// for(integer i = 0 ; i <AMBA_WORD ; i++) begin
		// if(x[i] == 1)begin
			// flag++ ;
			// temp = i;
		// end
	// end
	// if(flag == 1)
		// return temp ;
	// else
		// return -1 ;
// endfunction

function integer sample(bit[AMBA_WORD-1:0] x, integer position);
   if (x[position]==1 && $onehot(x) )
        return position;
   else
		return -1;
endfunction

always@(posedge coverage_bus.operation_done)
begin
	if(coverage_bus.CTRL_REG[1:0] != 2'b00)
		test = sample_walking_1(coverage_bus.NOISE);
end

// function integer Two_errors (bit[AMBA_WORD-1:0] x);
	// for(integer i = 0 ; i < AMBA_WORD+1 ; i++)begin
		// if(i == AMBA_WORD+1)
			// return -1;
		// else
			// if(x[i] == 1)
				// if(i != AMBA_WORD)
					// for(integer j = i+1 ; j < AMBA_WORD+1)begin
						// if(j == AMBA_WORD+1)
							// return -1;
						// else
							// if(x[j] == 1)
								// for(integer k = 0 ; )begin
								// end
					// end
				// else
					// return -1 ;
	// end
// endfunction
//
// Instance of covergroup regular_test
	// initial begin
		signals_test 						tst1 = new();
		amount_of_noise_test 				tst3 = new();
		walking_1_cg 						tst4 = new();
		APB_bus								tst5 = new();
		// $display("signals_test Coverage = %0.2F %%",signals_test.get_inst_coverage());
		// $display("Noise_test Coverage = %0.2F %%",Noise_test.get_inst_coverage());
		// $display("amount_of_noise_test Coverage = %0.2F %%",amount_of_noise_test.get_inst_coverage());
	// end

endmodule
