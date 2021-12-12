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
module GoldenModel 
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
logic [DATA_WIDTH-1:0] 	DataOut;
logic [AMBA_WORD-1:0] 	CTRL ;
logic [AMBA_WORD-1:0] 	DATA_IN;
logic [AMBA_WORD-1:0] 	CODEWORD_WIDTH;
logic [AMBA_WORD-1:0] 	NOISE;

// Data Types
initial
begin : init_proc

	
end

always@(gold_bus.operation_done or gold_bus.RegistersR) begin : Data_Out_Control
	// Data out
	if(gold_bus.operation_done == 1'b1)
		gold_bus.gm_DATA_OUT = gold_bus.FullWord;
	else
		gold_bus.gm_DATA_OUT = DATA_IN;
end


always@(posedge  gold_bus.operation_done) begin : NOF_control
	// NOF bus
	case(CODEWORD_WIDTH[1:0]) // Check RTL
				  2'b00 : 
					begin
						gold_bus.gm_number_of_errors[0] =  (^NOISE[7:0]) & (|NOISE[7:0]);
						gold_bus.gm_number_of_errors[1] = ~(^NOISE[7:0]) & (|NOISE[7:0]);
					end
				  2'b01 :
					begin
						gold_bus.gm_number_of_errors[0] =  (^NOISE[15:0]) & (|NOISE[15:0]);
						gold_bus.gm_number_of_errors[1] = ~(^NOISE[15:0]) & (|NOISE[15:0]);
					end
				  default :
					begin
						gold_bus.gm_number_of_errors[0] =  (^NOISE) & (|NOISE);
						gold_bus.gm_number_of_errors[1] = ~(^NOISE) & (|NOISE);
					end
				endcase
	// Data out
end
	
	
	
always @(posedge gold_bus.RegistersR or posedge gold_bus.RegistersW) begin : Register_Selction
  

		if( gold_bus.RegistersW) 
			begin//OFFSET OF THE ADDRES IS THE SELECTED REGISTER
				case(gold_bus.PADDR[3:2]) // Check RTL
				  2'b00 : CTRL <= gold_bus.PWDATA;
				  2'b01 : DATA_IN <= gold_bus.PWDATA;
				  2'b10 : CODEWORD_WIDTH <= gold_bus.PWDATA;
				  default : NOISE <= gold_bus.PWDATA;
				endcase
			end
		else
		begin
			case(gold_bus.PADDR[3:2]) // PREAD: CPU Reads from registers
			  2'b00 : gold_bus.RegistersOut <= CTRL;
			  2'b01 : gold_bus.RegistersOut <= DATA_IN;
			  2'b10 : gold_bus.RegistersOut <= CODEWORD_WIDTH;
			  default : gold_bus.RegistersOut <= NOISE;
			endcase
		end
	end



	
// always@(FullWord,) begin

		// Encode - 
		// if(CTRL==2'b00)
			// DataOut = gold_bus.FullWord;		
		// Decode or Full Channel -
		// else
		// begin
		// case(NOF)
			// 2'b10:
				// DataOut = {(DATA_WIDTH-1){1'b0}};		
			// default: 		
				// DataOut = gold_bus.FullWord;				
			// endcase;
		// end
// end	
	

endmodule