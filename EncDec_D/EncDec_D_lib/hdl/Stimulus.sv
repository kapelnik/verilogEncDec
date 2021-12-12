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
//Port Declerations:      stim_bus is the implementation of AMBA APB  
  Interface.Stimulus stim_bus
); /// modport Stimulus 		(output clk, rst, PADDR, PWDATA, PENABLE, PSEL, PWRITE,NOISE,RegistersW,RegistersR,FullWord, input  data_out, operation_done, num_of_errors);
`define NULL 0



class noise_amount;
	rand integer amount;
	
	constraint two{amount<3;amount>-1;}
	
	function void post_randomize();
		// $display("new error amount is: %0d.",amount);	
	endfunction 
	
	function integer getamount();
		return amount;
	endfunction
endclass


class RandNoise;
	rand bit [AMBA_WORD-1:0] NoiseVector_1;
	rand bit [AMBA_WORD-1:0] NoiseVector_2;
	rand bit [AMBA_ADDR_WIDTH-5:0] NoiseVector_3;
	
	constraint uptoOne{$countones(NoiseVector_1) == 1;}
	constraint uptoTwo{$countones(NoiseVector_2) == 2;}
	
	function void post_randomize();
		// $display("new NoiseVector1 is: %32b.",NoiseVector_1);
		// $display("new NoiseVector2 is: %32b.",NoiseVector_2);
	endfunction 
endclass
	
string  dataS = "../Tests/dataS.txt";
string  dataM = "../Tests/dataM.txt";
string  dataL = "../Tests/dataL.txt";

logic 	[AMBA_WORD-1:0]		Noise;

noise_amount amount;
RandNoise randNoise;
//clk simulation:
always begin : clock_generator_proc
  #10 stim_bus.clk = ~stim_bus.clk;
end




initial 
begin : stim_proc
	amount = new;
	randNoise = new;

  // Initilization
    stim_bus.clk = 1; // start with clock and reset at '1', while enable at '0'
    stim_bus.rst = 0;
    stim_bus.PSEL = 0;
    stim_bus.PWRITE = 0;
	stim_bus.PENABLE= 0;

    @(posedge stim_bus.clk); // wait til next rising edge (in other words, wait 20ns)
    stim_bus.rst = 1;

	// **********generateNoise**********//
		// How To Write To Registers:
			// stim_bus.PADDR =  Address Wanted
			// stim_bus.PWDATA = Data Wanted;
			// RegistersWrite();
			//If you want to make sure that the data was written to the registers, use RegistersRead:
			// RegistersRead();
	// ********************************//
	
	// Starting work by reading Entering data to registers NOISE(random noise = can be vector 0) and Codewidth
	
	GenerateNoise();
	
	stim_bus.PADDR =  {randNoise.NoiseVector_3,{4'b0100}}; 
	stim_bus.PWDATA ={{AMBA_WORD-8{1'b0}},8'b00001010};
	stim_bus.FullWord ={{AMBA_WORD-8{1'b0}},8'b10101010};
	RegistersWrite();
	 
	stim_bus.PADDR =  {randNoise.NoiseVector_3,{4'b1000}}; 
	stim_bus.PWDATA ={AMBA_WORD{1'b0}};
	RegistersWrite();
	
	stim_bus.PADDR =  {randNoise.NoiseVector_3,{4'b0000}}; 
	stim_bus.PWDATA ={AMBA_WORD{1'b0}};
	RegistersWrite();
	
	
	// stim_bus.PADDR =  {randNoise.NoiseVector_3,{4'b1100}}; /// Sending Noise
	// stim_bus.PWDATA = Noise;
	// RegistersWrite();
	// make sure register in RegSelector got the data
	// RegistersRead();

	
	
	
	
	
	// Starting work by reading the data from external files
  
  
  
end

	task GenerateNoise();
	begin
		//**********generateNoise**********//
		amount.randomize();
		randNoise.randomize();
		if(amount.getamount() == 0) 		Noise = {AMBA_WORD{1'b0}};
		else if(amount.getamount() == 1) 	Noise = randNoise.NoiseVector_1;
		else								Noise = randNoise.NoiseVector_2;	
		$display("This new noise %32b",Noise);
			stim_bus.PADDR =  {randNoise.NoiseVector_3,{4'b1100}}; /// Sending Noise
		stim_bus.PWDATA = Noise;
		RegistersWrite();
		//make sure register in RegSelector got the data
		// RegistersRead();
	end
	//********************************//
	endtask
	
	task RegistersWrite();
			// input logic     	PENABLE;
			// input logic			PSEL;
			// input logic			PWRITE;
			// input logic			RegistersW;
			// input logic			RegistersR;
			// input logic [AMBA_WORD-1:0] PWDATA;
		// input logic [AMBA_ADDR_WIDTH-1:0] PADDRin;
		 // input logic [AMBA_WORD-1:0] PWDATAin;
		begin
			stim_bus.RegistersW = 1;
			stim_bus.PWRITE = 1;
			stim_bus.PSEL = 1;
			// stim_bus.PADDR = PADDRin;
			// stim_bus.PWDATA = PWDATAin;
			@(posedge stim_bus.clk); /// The cycle that need to write into the register
			stim_bus.PENABLE=1;
			@(posedge stim_bus.clk); /// The cycle that need to write into the register
			stim_bus.PENABLE=0;
			stim_bus.RegistersW=0;
			stim_bus.PWRITE=0;
			@(posedge stim_bus.clk); /// The cycle that need to write into the register
		//make sure register in RegSelector got the data
		RegistersRead();
		end
	endtask
	
	task RegistersRead();
		begin
			stim_bus.RegistersR=1;
			stim_bus.PENABLE=1;
			@(posedge stim_bus.clk); /// The cycle that need to write into the register
			stim_bus.RegistersR=0;
			stim_bus.PENABLE=0;
			@(posedge stim_bus.clk); /// The cycle that need to write into the register

		end
	endtask



// ### Please start your Verilog code here ### 

endmodule
