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


//For scanning a file:	
string  dataS = "../../../Tests/dataS";
string  dataM = "../../../Tests/dataM";
string  dataL = "../../../Tests/dataL";
string val,FileScanned,line;
integer data_file_0,data_file_1,data_file_2;
logic 	[31:0] 				Sample;


logic 	[AMBA_WORD-1:0]		Noise;

noise_amount amount;
RandNoise randNoise;
//clk simulation:
// always begin : clock_generator_proc
  // #10 stim_bus.clk = ~stim_bus.clk;
// end


logic [1:0] Width = 2'b00;

initial 
begin : stim_proc
	amount = new;
	randNoise = new;

  // Initilization
    // stim_bus.clk = 1; // start with clock and reset at '1', while enable at '0'
    // stim_bus.rst = 0;
    stim_bus.PSEL = 0;
    stim_bus.PWRITE = 0;
	stim_bus.PENABLE= 0;

    @(posedge stim_bus.clk); // wait til next rising edge (in other words, wait 20ns)
    // stim_bus.rst = 1;

	// **********generateNoise**********//
		// How To Write To Registers:
			// stim_bus.PADDR =  Address Wanted
			// stim_bus.PWDATA = Data Wanted;
			// RegistersWrite();
			//If you want to make sure that the data was written to the registers, use RegistersRead:
			// RegistersRead();
	// ********************************//
	
	// Starting work by reading Entering data to registers NOISE(random noise = can be vector 0) and Codewidth
	
	//Test for each sample:
	
	 //**************************************************************************************//
	//*********************************Test Codewidth = 8 : ********************************//
	//Set codeword width = 00: (8bit)
	Width = 2'b00;
	GenerateNoise();
	stim_bus.PADDR =  {randNoise.NoiseVector_3,{4'b1000}}; 
	stim_bus.PWDATA ={{AMBA_WORD-2{1'b0}},Width};
	RegistersWrite();
	
	data_file_0 = $fopen($sformatf({dataS, val, ".txt"}), "r"); // opening file in reading format
    if (data_file_0 == `NULL) begin // checking if we mangaed to open it
      $display("data_file_0 handle was NULL");
      // $finish;
	end
	// For each line in dataS.txt, run full test with random noise:
	while(!$feof(data_file_0) )
	begin
		
		//Get next sample from data file:
		$fgets(line,data_file_0);
		Sample = line.atobin();
		//For the Golden Model to know what is the real full word with parity, no errors:
		stim_bus.FullWord ={{AMBA_WORD-8{1'b0}},Sample[7:0]};

		//********** Encode: **********
		//NOISE_REG:
		GenerateNoise();
		
		//DATA_IN_REG:
		stim_bus.PADDR =  {randNoise.NoiseVector_3,{4'b0100}}; 
		stim_bus.PWDATA ={{AMBA_WORD-8{1'b0}},{4'b0000},{Sample[7:4]}};
		RegistersWrite();
		 
		//CTRL_REG:
		stim_bus.PADDR =  {randNoise.NoiseVector_3,{4'b0000}}; 
		stim_bus.PWDATA ={AMBA_WORD{1'b0}};
		RegistersWrite();
		@(posedge stim_bus.clk); /// The cycle that need to write into the register
		@(posedge stim_bus.clk); /// The cycle that need to write into the register
		
		//********** Decode: **********
		//NOISE_REG:
		GenerateNoise();
		
		//DATA_IN_REG:
		stim_bus.PADDR =  {randNoise.NoiseVector_3,{4'b0100}}; 
		stim_bus.PWDATA ={{AMBA_WORD-8{1'b0}},Sample[7:0]} ^ {{AMBA_WORD-8{1'b0}},Noise[7:0]};
		RegistersWrite();
		
		//CTRL_REG:
		stim_bus.PADDR =  {randNoise.NoiseVector_3,{4'b0000}}; 
		stim_bus.PWDATA ={{AMBA_WORD-2{1'b0}},2'b01};
		RegistersWrite();
		@(posedge stim_bus.clk); /// The cycle that need to write into the register
		@(posedge stim_bus.clk); /// The cycle that need to write into the register
		@(posedge stim_bus.clk); /// The cycle that need to write into the register
		
		// ********** Full Channel: **********
		//NOISE_REG:
		GenerateNoise();
		
		//DATA_IN_REG:
		stim_bus.PADDR =  {randNoise.NoiseVector_3,{4'b0100}}; 
		stim_bus.PWDATA ={{AMBA_WORD-8{1'b0}},{4'b0000},{Sample[7:4]}};
		RegistersWrite();
		 
		//CTRL_REG:
		stim_bus.PADDR =  {randNoise.NoiseVector_3,{4'b0000}}; 
		stim_bus.PWDATA ={{AMBA_WORD-2{1'b0}},2'b10};
		RegistersWrite();
		@(posedge stim_bus.clk); /// The cycle that need to write into the register
		@(posedge stim_bus.clk); /// The cycle that need to write into the register
		@(posedge stim_bus.clk); /// The cycle that need to write into the register
		@(posedge stim_bus.clk); /// The cycle that need to write into the register
	end
	 $fclose(data_file_0);
	//check for synchronous reset
	@(posedge stim_bus.clk); /// The cycle that need to write into the register
	// stim_bus.rst = 0;
	@(posedge stim_bus.clk); /// The cycle that need to write into the register
	// stim_bus.rst = 1;

		
	 //**************************************************************************************//
	//*********************************Test Codewidth = 16 : ********************************//
	//Set codeword width = 01: (16bit)
	Width = 2'b01;
	GenerateNoise();
	stim_bus.PADDR =  {randNoise.NoiseVector_3,{4'b1000}}; 
	stim_bus.PWDATA ={{AMBA_WORD-2{1'b0}},Width};
	RegistersWrite();
	
	data_file_1 = $fopen($sformatf({dataM, val, ".txt"}), "r"); // opening file in reading format
    if (data_file_1 == `NULL) begin // checking if we mangaed to open it
      $display("data_file_1 handle was NULL");
      $finish;
	end
	// For each line in dataS.txt, run full test with random noise:
	while(!$feof(data_file_1) )
	begin
		$fgets(line,data_file_1);
		Sample = line.atobin();
		stim_bus.FullWord ={{AMBA_WORD-8{1'b0}},Sample[15:0]};

		//********** Encode: **********
		//NOISE_REG:
		GenerateNoise();
		
		//DATA_IN_REG:
		stim_bus.PADDR =  {randNoise.NoiseVector_3,{4'b0100}}; 
		stim_bus.PWDATA ={{AMBA_WORD-16{1'b0}},{8'b00000000},{Sample[15:5]}};
		RegistersWrite();
		 
		//CTRL_REG:
		stim_bus.PADDR =  {randNoise.NoiseVector_3,{4'b0000}}; 
		stim_bus.PWDATA ={AMBA_WORD{1'b0}};
		RegistersWrite();
		@(posedge stim_bus.clk); /// The cycle that need to write into the register
		@(posedge stim_bus.clk); /// The cycle that need to write into the register
		
		//********** Decode: **********
		//NOISE_REG:
		GenerateNoise();
		
		//DATA_IN_REG:
		stim_bus.PADDR =  {randNoise.NoiseVector_3,{4'b0100}}; 
		stim_bus.PWDATA ={{AMBA_WORD-16{1'b0}},Sample[15:0]} ^ {{AMBA_WORD-16{1'b0}},Noise[15:0]};
		RegistersWrite();
		
		//CTRL_REG:
		stim_bus.PADDR =  {randNoise.NoiseVector_3,{4'b0000}}; 
		stim_bus.PWDATA ={{AMBA_WORD-2{1'b0}},2'b01};
		RegistersWrite();
		@(posedge stim_bus.clk); /// The cycle that need to write into the register
		@(posedge stim_bus.clk); /// The cycle that need to write into the register
		@(posedge stim_bus.clk); /// The cycle that need to write into the register
		
		// ********** Full Channel: **********
		//NOISE_REG:
		GenerateNoise();
		
		//DATA_IN_REG:
		stim_bus.PADDR =  {randNoise.NoiseVector_3,{4'b0100}}; 
		stim_bus.PWDATA ={{AMBA_WORD-16{1'b0}},{8'b00000000},{Sample[15:5]}};
		RegistersWrite();
		 
		//CTRL_REG:
		stim_bus.PADDR =  {randNoise.NoiseVector_3,{4'b0000}}; 
		stim_bus.PWDATA ={{AMBA_WORD-2{1'b0}},2'b10};
		RegistersWrite();
		@(posedge stim_bus.clk); /// The cycle that need to write into the register
		@(posedge stim_bus.clk); /// The cycle that need to write into the register
		@(posedge stim_bus.clk); /// The cycle that need to write into the register
		@(posedge stim_bus.clk); /// The cycle that need to write into the register
	end
	
		
			 $fclose(data_file_1);

	//check for usynchronous reset
	// #1.2;
	// stim_bus.rst = 0;
	// #100.2;
	// stim_bus.rst = 1;

	 //**************************************************************************************//
	//*********************************Test Codewidth = 32 : ********************************//
	//Set codeword width = 10: (32bit)
	Width = 2'b10;
	GenerateNoise();
	stim_bus.PADDR =  {randNoise.NoiseVector_3,{4'b1000}}; 
	stim_bus.PWDATA ={{AMBA_WORD-2{1'b0}},Width};
	RegistersWrite();
	
	data_file_2 = $fopen($sformatf({dataL, val, ".txt"}), "r"); // opening file in reading format
    if (data_file_2 == `NULL) begin // checking if we mangaed to open it
      $display("data_file_2 handle was NULL");
      $finish;
	end
	// For each line in dataS.txt, run full test with random noise:
	while(!$feof(data_file_2) )
	begin

		$fgets(line,data_file_2);
		Sample = line.atobin();
		stim_bus.FullWord =Sample;
		//********** Encode: **********
		//NOISE_REG:
		GenerateNoise();
		
		//DATA_IN_REG:
		stim_bus.PADDR =  {randNoise.NoiseVector_3,{4'b0100}}; 
		stim_bus.PWDATA ={{AMBA_WORD-26{1'b0}},{Sample[31:6]}};
		RegistersWrite();
		 
		//CTRL_REG:
		stim_bus.PADDR =  {randNoise.NoiseVector_3,{4'b0000}}; 
		stim_bus.PWDATA ={AMBA_WORD{1'b0}};
		RegistersWrite();
		@(posedge stim_bus.clk); /// The cycle that need to write into the register
		@(posedge stim_bus.clk); /// The cycle that need to write into the register
		
		//********** Decode: **********
		//NOISE_REG:
		GenerateNoise();
		
		//DATA_IN_REG:
		stim_bus.PADDR =  {randNoise.NoiseVector_3,{4'b0100}}; 
		stim_bus.PWDATA =Sample^Noise;
		RegistersWrite();
		
		//CTRL_REG:
		stim_bus.PADDR =  {randNoise.NoiseVector_3,{4'b0000}}; 
		stim_bus.PWDATA ={{AMBA_WORD-2{1'b0}},2'b01};
		RegistersWrite();
		@(posedge stim_bus.clk); /// The cycle that need to write into the register
		@(posedge stim_bus.clk); /// The cycle that need to write into the register
		@(posedge stim_bus.clk); /// The cycle that need to write into the register
		
		// ********** Full Channel: **********
		//NOISE_REG:
		GenerateNoise();
		
		//DATA_IN_REG:
		stim_bus.PADDR =  {randNoise.NoiseVector_3,{4'b0100}}; 
		stim_bus.PWDATA ={{AMBA_WORD-26{1'b0}},{Sample[31:6]}};
		RegistersWrite();
		 
		//CTRL_REG:
		stim_bus.PADDR =  {randNoise.NoiseVector_3,{4'b0000}}; 
		stim_bus.PWDATA ={{AMBA_WORD-2{1'b0}},2'b10};
		RegistersWrite();
					// check for usynchronous reset
	// #1.2;
	// stim_bus.rst = 0;
	// #100.2;
	// stim_bus.rst = 1;
		@(posedge stim_bus.clk); /// The cycle that need to write into the register
		@(posedge stim_bus.clk); /// The cycle that need to write into the register
		@(posedge stim_bus.clk); /// The cycle that need to write into the register
		@(posedge stim_bus.clk); /// The cycle that need to write into the register
	end
	
		 $fclose(data_file_2);

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
		$display("New Noise: %32b",Noise);
		// Writing to Noise_Reg
		stim_bus.PADDR =  {randNoise.NoiseVector_3,{4'b1100}}; 
		stim_bus.PWDATA = Noise;
		RegistersWrite();
		//for coverage check:
		stim_bus.NOISE = Noise;
		//make sure register in RegSelector got the data
		RegistersRead();
	end
	//********************************//
	endtask
	
	task RegistersWrite();
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
			// RegistersRead();

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
