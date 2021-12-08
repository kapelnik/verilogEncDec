//
// Verilog Module EncDec_D_lib.GoldenModle
//
// Created:
//          by - benmaorr.UNKNOWN (L330W530)
//          at - 14:23:48 12/ 8/2021
//
// using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
//

`resetall
`timescale 1ns/10ps
module GoldenModle 
#(
    parameter DATA_WIDTH = 32,
	parameter AMBA_ADDR_WIDTH = 20,
	parameter AMBA_WORD = 32
)
( 
   // Port Declarations
   Interface.vsgoldenmodel gold_bus
);

`define NULL 0
logic [DATA_WIDTH-1:0] 	DataOut,
logic [AMBA_WORD-1:0] 	CTRL ,
logic [AMBA_WORD-1:0] 	DATA_IN,
logic [AMBA_WORD-1:0] 	CODEWORD_WIDTH,
logic [AMBA_WORD-1:0] 	NOISE,
logic [AMBA_WORD-1:0] 	RegistersOut

// Data Types
initial
begin : init_proc

	
end

always@(gold_bus.opration_done or gold_bus.RegistersR) begin
	// Data out
	if(gold_bus.opration_done == 1'b1)
		gold_bus.gm_DATA_OUT = DataOut;
	else
		gold_bus.gm_DATA_OUT = RegistersOut;
end


always@(posedge  gold_bus.opration_done) begin
	// NOF bus
	gold_bus.gm_number_of_errors[0] =  (^gold_bus.NOISE) & (|gold_bus.NOISE);
	gold_bus.gm_number_of_errors[1] = ~(^gold_bus.NOISE) & (|gold_bus.NOISE);
	// Data out
end
	
	
always@() begin

		// Encode - 
		if(CTRL==2'b00)
			DataOut = gold_bus.FullWord;		
		//Decode or Full Channel -
		else
		begin
		case(NOF)
			2'b10:
				DataOut = DATA_WIDTH-1{1'b0};		
			default: 		
				DataOut = gold_bus.FullWord;				
			endcase;
		end
end	
	
	
	
always @(posedge gold_bus.RegistersR or posedge gold_bus.RegistersW) begin : Register_Selction
  begin

		if( gold_bus.RegistersR) 
			begin//OFFSET OF THE ADDRES IS THE SELECTED REGISTER
				case(gold_bus.PADDR) // Check RTL
				  2'b00 : CTRL <= PWDATA;
				  2'b01 : DATA_IN <= PWDATA;
				  2'b10 : CODEWORD_WIDTH <= PWDATA;
				  default : NOISE <= PWDATA;
				endcase
			end
		else
		begin
			case(PADDR) // PREAD: CPU Reads from registers
			  2'b00 : RegistersOut <= CTRL;
			  2'b01 : RegistersOut <= DATA_IN;
			  2'b10 : RegistersOut <= CODEWORD_WIDTH;
			  default : RegistersOut <= NOISE;
			endcase
		end
	end




endmodule
