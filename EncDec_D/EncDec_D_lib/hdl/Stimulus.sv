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


//In this simulation we will randomly pick the number of errors in the noise vector.
//this class is a random integer that can get the values 0,1,2(all the valid options for number of errors)
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

//prepare a random noise vector for each of the width sizes available. 
class RandNoise;
	rand bit [7:0] NoiseVector_8_1;
	rand bit [7:0] NoiseVector_8_2;
	
	rand bit [15:0] NoiseVector_16_1;
	rand bit [15:0] NoiseVector_16_2;
	
	rand bit [31:0] NoiseVector_32_1;
	rand bit [31:0] NoiseVector_32_2;
	
	
	rand bit [AMBA_ADDR_WIDTH-5:0] NoiseVector_Addr;

	//make sure only 1 or 2 errors can happen with the following constraints:
	constraint uptoOne8{$countones(NoiseVector_8_1) == 1;}
	constraint uptoTwo8{$countones(NoiseVector_8_2) == 2;}
	
	constraint uptoOne16{$countones(NoiseVector_16_1) == 1;}
	constraint uptoTwo16{$countones(NoiseVector_16_2) == 2;}
	
	constraint uptoOne32{$countones(NoiseVector_32_1) == 1;}
	constraint uptoTwo32{$countones(NoiseVector_32_2) == 2;}
	
	function void post_randomize();
		// $display("new NoiseVector_321 is: %32b.",NoiseVector_32_1);
		// $display("new NoiseVector_322 is: %32b.",NoiseVector_32_2);
	endfunction 
endclass


//For scanning a file:	
string  dataS = "../../../Tests/dataS";
string  dataM = "../../../Tests/dataM";
string  dataL = "../../../Tests/dataL";
string val,FileScanned,line;
integer data_file_0,data_file_1,data_file_2;
logic 	[31:0] 				Sample;

//randomized noise vector prepare:
logic 	[AMBA_WORD-1:0]		Noise;
noise_amount amount;
RandNoise randNoise;

//data width beeing checked:
logic [1:0] Width = 2'b00;

initial 
begin : stim_proc
	amount = new;
	randNoise = new;

    stim_bus.PSEL = 0;
    stim_bus.PWRITE = 0;
	stim_bus.PENABLE= 0;

    @(posedge stim_bus.clk); // wait til next rising edge (in other words, wait 20ns)
    // stim_bus.rst = 1;

	// ****How To Write To Registers:**//(in this stimulus)
			//1) stim_bus.PADDR =  Address Wanted
			//2) stim_bus.PWDATA = Data Wanted;
			//3) RegistersWrite();
			//*If you want to make sure that the data was written to the registers, use RegistersRead():*
			//*4) RegistersRead();
	// ********************************//
	
	// Starting work by reading Entering data to registers NOISE(random noise = can be vector 0) and Codewidth
	
	//Test for each sample:
	
	 //**************************************************************************************//
	//*********************************Test Codewidth = 8 : ********************************//
	//Set codeword width = 00: (8bit)
	Width = 2'b00;
	//a pard of the validation process is to make sure the DUT knows to look only at the offset of the adderess ( the 4 LSBs)
	GenerateNoise(2);
	stim_bus.PADDR =  {randNoise.NoiseVector_Addr,{4'b1000}}; 
	stim_bus.PWDATA ={{AMBA_WORD-2{1'b0}},Width};
	RegistersWrite();
	
	//read the data file, that was generated by matlab with random values ready with their parities:
	data_file_0 = $fopen($sformatf({dataS, val, ".txt"}), "r"); // opening file in reading format
    if (data_file_0 == `NULL) begin // checking if we mangaed to open it
      $display("8bit-data file handle was NULL");
      // $finish;
	end
	// For each line in dataS.txt, run full test with random noise:
			//**in this first test of 8 bits, we also check that the DUT works also when CTRL value is written again but stay the same:**//
			//We do this by doing the same operation twice for each line in the matlabs databse given:
	while(!$feof(data_file_0) )
	begin
		
		//Get next sample from data file:
		$fgets(line,data_file_0);
		Sample = line.atobin();
		//For the Golden Model to know what is the real full word with parity, no errors:
		stim_bus.FullWord ={{AMBA_WORD-8{1'b0}},Sample[7:0]};

		//********** Encode: **********
		//NOISE_REG:
		GenerateNoise(0);
		
		//DATA_IN_REG:
		stim_bus.PADDR =  {randNoise.NoiseVector_Addr,{4'b0100}}; 
		stim_bus.PWDATA ={{AMBA_WORD-8{1'b0}},{4'b0000},{Sample[7:4]}};
		RegistersWrite();
		 
		//CTRL_REG:
		stim_bus.PADDR =  {randNoise.NoiseVector_Addr,{4'b0000}}; 
		stim_bus.PWDATA ={AMBA_WORD{1'b0}};
		RegistersWrite();
		@(posedge stim_bus.clk); /// The cycle that need to write into the register
		//CTRL_REG:
		stim_bus.PADDR =  {randNoise.NoiseVector_Addr,{4'b0000}}; 
		stim_bus.PWDATA ={AMBA_WORD{1'b0}};
		RegistersWrite();
		@(posedge stim_bus.clk); /// The cycle that need to write into the register
		//********** Decode: **********
		//NOISE_REG:
		GenerateNoise(0);
		
		//DATA_IN_REG:
		stim_bus.PADDR =  {randNoise.NoiseVector_Addr,{4'b0100}}; 
		stim_bus.PWDATA ={{AMBA_WORD-8{1'b0}},Sample[7:0]} ^ {{AMBA_WORD-8{1'b0}},Noise[7:0]};
		RegistersWrite();
		
		//CTRL_REG:
		stim_bus.PADDR =  {randNoise.NoiseVector_Addr,{4'b0000}}; 
		stim_bus.PWDATA ={{AMBA_WORD-2{1'b0}},2'b01};
		RegistersWrite();
		@(posedge stim_bus.clk); /// The cycle that need to write into the register
		//CTRL_REG:
		stim_bus.PADDR =  {randNoise.NoiseVector_Addr,{4'b0000}}; 
		stim_bus.PWDATA ={{AMBA_WORD-2{1'b0}},2'b01};
		RegistersWrite();
		@(posedge stim_bus.clk); /// The cycle that need to write into the register
		// ********** Full Channel: **********
		//NOISE_REG:
		GenerateNoise(0);
		
		//DATA_IN_REG:
		stim_bus.PADDR =  {randNoise.NoiseVector_Addr,{4'b0100}}; 
		stim_bus.PWDATA ={{AMBA_WORD-8{1'b0}},{4'b0000},{Sample[7:4]}};
		RegistersWrite();
		 
		//CTRL_REG:
		stim_bus.PADDR =  {randNoise.NoiseVector_Addr,{4'b0000}}; 
		stim_bus.PWDATA ={{AMBA_WORD-2{1'b0}},2'b10};
		RegistersWrite();
		@(posedge stim_bus.clk); /// The cycle that need to write into the register(full channel requires 4 cycles)
		@(posedge stim_bus.clk); /// The cycle that need to write into the register
		//CTRL_REG:
		stim_bus.PADDR =  {randNoise.NoiseVector_Addr,{4'b0000}}; 
		stim_bus.PWDATA ={{AMBA_WORD-2{1'b0}},2'b10};
		RegistersWrite();
		@(posedge stim_bus.clk); /// The cycle that need to write into the register(full channel requires 4 cycles)
		@(posedge stim_bus.clk); /// The cycle that need to write into the register
	end
	 $fclose(data_file_0);
	@(posedge stim_bus.clk); /// 
	@(posedge stim_bus.clk); /// make some room for the next test in the wave form
	$display("8bit test finished");
		
		
		
	 //**************************************************************************************//
	//*********************************Test Codewidth = 16 : ********************************//
	//in this test we take each sample from the database gener from matlab, and use it for encode, decode, and full channel, with randomly generated noise vectors:
	//Set codeword width = 01: (16bit)
	Width = 2'b01;
	GenerateNoise(2);
	stim_bus.PADDR =  {randNoise.NoiseVector_Addr,{4'b1000}}; 
	stim_bus.PWDATA ={{AMBA_WORD-2{1'b0}},Width};
	RegistersWrite();
	//read the data file, that was generated by matlab with random values ready with their parities:
	data_file_1 = $fopen($sformatf({dataM, val, ".txt"}), "r"); // opening file in reading format
    if (data_file_1 == `NULL) begin // checking if we mangaed to open it
      $display("16bit data handle was NULL");
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
		GenerateNoise(1);
		
		//DATA_IN_REG:
		stim_bus.PADDR =  {randNoise.NoiseVector_Addr,{4'b0100}}; 
		stim_bus.PWDATA ={{AMBA_WORD-16{1'b0}},{8'b00000000},{Sample[15:5]}};
		RegistersWrite();
		 
		//CTRL_REG:
		stim_bus.PADDR =  {randNoise.NoiseVector_Addr,{4'b0000}}; 
		stim_bus.PWDATA ={AMBA_WORD{1'b0}};
		RegistersWrite();
		@(posedge stim_bus.clk); /// The cycle that need to write into the register
		//********** Decode: **********
		//NOISE_REG:
		GenerateNoise(1);
		
		//DATA_IN_REG:
		stim_bus.PADDR =  {randNoise.NoiseVector_Addr,{4'b0100}}; 
		stim_bus.PWDATA ={{AMBA_WORD-16{1'b0}},Sample[15:0]} ^ {{AMBA_WORD-16{1'b0}},Noise[15:0]};
		RegistersWrite();
		
		//CTRL_REG:
		stim_bus.PADDR =  {randNoise.NoiseVector_Addr,{4'b0000}}; 
		stim_bus.PWDATA ={{AMBA_WORD-2{1'b0}},2'b01};
		RegistersWrite();
		@(posedge stim_bus.clk); /// The cycle that need to write into the register
		// ********** Full Channel: **********
		//NOISE_REG:
		GenerateNoise(1);
		
		//DATA_IN_REG:
		stim_bus.PADDR =  {randNoise.NoiseVector_Addr,{4'b0100}}; 
		stim_bus.PWDATA ={{AMBA_WORD-16{1'b0}},{8'b00000000},{Sample[15:5]}};
		RegistersWrite();
		 
		//CTRL_REG:
		stim_bus.PADDR =  {randNoise.NoiseVector_Addr,{4'b0000}}; 
		stim_bus.PWDATA ={{AMBA_WORD-2{1'b0}},2'b10};
		RegistersWrite();
		@(posedge stim_bus.clk); /// The cycle that need to write into the register
		@(posedge stim_bus.clk); /// The cycle that need to write into the register
	end
	
	 $fclose(data_file_1);
	 $display("16bit test finished");

	 //**************************************************************************************//
	//*********************************Test Codewidth = 32 : ********************************//
	//in this test we take each sample from the database gener from matlab, and use it for encode, decode, and full channel, with randomly generated noise vectors:
	//Set codeword width = 10: (32bit)
	Width = 2'b10;
	GenerateNoise(2);
	stim_bus.PADDR =  {randNoise.NoiseVector_Addr,{4'b1000}}; 
	stim_bus.PWDATA ={{AMBA_WORD-2{1'b0}},Width};
	RegistersWrite();

	//read the data file, that was generated by matlab with random values ready with their parities:
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
		GenerateNoise(2);
		
		//DATA_IN_REG:
		stim_bus.PADDR =  {randNoise.NoiseVector_Addr,{4'b0100}}; 
		stim_bus.PWDATA ={{AMBA_WORD-26{1'b0}},{Sample[31:6]}};
		RegistersWrite();
		 
		//CTRL_REG:
		stim_bus.PADDR =  {randNoise.NoiseVector_Addr,{4'b0000}}; 
		stim_bus.PWDATA ={AMBA_WORD{1'b0}};
		RegistersWrite();
		@(posedge stim_bus.clk); /// The cycle that need to write into the register
		//********** Decode: **********
		//NOISE_REG:
		GenerateNoise(2);
		
		//DATA_IN_REG:
		stim_bus.PADDR =  {randNoise.NoiseVector_Addr,{4'b0100}}; 
		stim_bus.PWDATA =Sample^Noise;
		RegistersWrite();
		
		//CTRL_REG:
		stim_bus.PADDR =  {randNoise.NoiseVector_Addr,{4'b0000}}; 
		stim_bus.PWDATA ={{AMBA_WORD-2{1'b0}},2'b01};
		RegistersWrite();
		@(posedge stim_bus.clk); /// The cycle that need to write into the register
		// ********** Full Channel: **********
		//NOISE_REG:
		GenerateNoise(2);
		
		//DATA_IN_REG:
		stim_bus.PADDR =  {randNoise.NoiseVector_Addr,{4'b0100}}; 
		stim_bus.PWDATA ={{AMBA_WORD-26{1'b0}},{Sample[31:6]}};
		RegistersWrite();
		 
		//CTRL_REG:
		stim_bus.PADDR =  {randNoise.NoiseVector_Addr,{4'b0000}}; 
		stim_bus.PWDATA ={{AMBA_WORD-2{1'b0}},2'b10};
		RegistersWrite();
		@(posedge stim_bus.clk); /// The cycle that need to write into the register
		@(posedge stim_bus.clk); /// The cycle that need to write into the register
	end
	
		 $fclose(data_file_2);
		 $display("32bit test finished");


  
end

	task GenerateNoise(integer i);
	begin
		//**********generateNoise**********//
		amount.randomize();
		randNoise.randomize();
		case(i)
			0:	begin//8bit
				if(amount.getamount() == 0) 		Noise = {AMBA_WORD{1'b0}};
				else if(amount.getamount() == 1) 	Noise = {{AMBA_WORD-8{1'b0}},randNoise.NoiseVector_8_1};
				else								Noise = {{AMBA_WORD-8{1'b0}},randNoise.NoiseVector_8_2};
			end
			1:	begin//16bit
				if(amount.getamount() == 0) 		Noise = {AMBA_WORD{1'b0}};
				else if(amount.getamount() == 1) 	Noise = {{AMBA_WORD-16{1'b0}},randNoise.NoiseVector_16_1};
				else								Noise = {{AMBA_WORD-16{1'b0}},randNoise.NoiseVector_16_1};
			end
			2:	begin//32bit
				if(amount.getamount() == 0) 		Noise = {AMBA_WORD{1'b0}};
				else if(amount.getamount() == 1) 	Noise = randNoise.NoiseVector_32_1;
				else								Noise = randNoise.NoiseVector_32_2;
			end
			default:	begin//Noise for addr
													Noise[AMBA_ADDR_WIDTH:4]  = randNoise.NoiseVector_Addr;
			end
		endcase
		// if (i !=3)
			// $display("i: %d , New Noise: %32b",i,Noise);
		//for coverage check:
		stim_bus.NOISE = Noise;
		// Writing to Noise_Reg
		stim_bus.PADDR =  {randNoise.NoiseVector_Addr,{4'b1100}}; 
		stim_bus.PWDATA = Noise;
		
		RegistersWrite();
		
		//make sure register in RegSelector got the data
		// RegistersRead();
	end
	//********************************//
	endtask
	
	task RegistersWrite();
		begin
			//Write from the registers by the APB BUS PROTOCOL, DATA and ADDRESS are already set from outside
			//RegistersW is a signal for the golden model
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
			
			//make sure register in RegSelector got the data(by the coverage\checker):
			 RegistersRead();

		end
	endtask
	
	//Read from the registers by the APB BUS PROTOCOL, DATA and ADDRESS are already set from outside
	task RegistersRead();
		begin
			stim_bus.PSEL = 1;
			//RegistersR is a signal for the golden model
			stim_bus.RegistersR=1;
			stim_bus.PENABLE=1;
			@(posedge stim_bus.clk); /// The cycle that need to write into the register
			stim_bus.RegistersR=0;
			stim_bus.PENABLE=0;
			stim_bus.PSEL = 0;
			@(posedge stim_bus.clk); /// The cycle that need to write into the register

		end
	endtask
endmodule
