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
   // modport vsgoldenmodel : Input -  rst, PWDATA,PADDR,RegistersW,RegistersR, FullWord,operation_done, Output -  RegistersOut, gm_DATA_OUT,gm_number_of_errors,CTRL_REG

);
 
`define NULL 0

//Golden model registers and output signals:
reg [DATA_WIDTH-1:0] 	DataOut;
reg [AMBA_WORD-1:0] 	CTRL ;
reg [AMBA_WORD-1:0] 	DATA_IN;
reg [AMBA_WORD-1:0] 	CODEWORD_WIDTH;
reg [AMBA_WORD-1:0] 	NOISE;
reg flag;


//With Data_Out_Flag we this modules synchronize with the stimulus module:
assign Data_Out_Flag = gold_bus.RegistersW & (~gold_bus.PADDR[3]) & gold_bus.PADDR[2] ;

//Data out should be available with the correct output when operation_done is 1/ rst = 0
always@(gold_bus.rst or Data_Out_Flag) begin : Reseting
	if(!gold_bus.rst)
		DataOut = {DATA_WIDTH{1'b0}};
	else
		begin
			if(Data_Out_Flag)
				DataOut = gold_bus.FullWord ;
		end
end 

//DataOut have the correct output from stimulus, from when the data_reg was loaded
always@(gold_bus.operation_done or gold_bus.RegistersR) begin : Data_Out_Control
	// Data out
	if(gold_bus.operation_done == 1'b1)
		gold_bus.gm_DATA_OUT = DataOut;
	else
		gold_bus.gm_DATA_OUT = DATA_IN;
end


//if control_reg=encoding, NOF=0, else, set NOF as the number of 1's in NOISE_REG
always@(posedge  gold_bus.operation_done) begin : NOF_control
	if(CTRL[1:0] == 2'b00 ) begin
		gold_bus.gm_number_of_errors = 2'b00;
	end
	
	else
	begin
			// gm.NOF bus contol:
			//Check the onescount(noise) in the right width:
		case(CODEWORD_WIDTH[1:0]) 
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
	end
end
	
	
//this is the register bank of the golden model. we keep those values so the checker/coverage module will be able to verificate the data of the DUT.
always @( gold_bus.RegistersR or  gold_bus.RegistersW or  gold_bus.rst) 
begin : Register_Selction
	if(!gold_bus.rst)
		begin
			CTRL = {AMBA_WORD{1'b0}};
			DATA_IN = {AMBA_WORD{1'b0}};
			CODEWORD_WIDTH = {AMBA_WORD{1'b0}};
			NOISE = {AMBA_WORD{1'b0}};
			gold_bus.RegistersOut = {AMBA_WORD{1'b0}} ;
		end
  
	else
		begin	//RegistersW and RegistersR are signals from the stimulus, those are ment to check that out DUT works with the APB BUS protocol. 
				if( gold_bus.RegistersW) 
					begin//OFFSET OF THE ADDRES IS THE SELECTED REGISTER
						case(gold_bus.PADDR[3:2]) 
						  2'b00 : CTRL = gold_bus.PWDATA;
						  2'b01 : DATA_IN = gold_bus.PWDATA;
						  2'b10 : CODEWORD_WIDTH = gold_bus.PWDATA;
						  default : NOISE = gold_bus.PWDATA;
						endcase
					end
				else
				begin
					case(gold_bus.PADDR[3:2]) // RegistersR: CPU Reads from registers
					  2'b00 : gold_bus.RegistersOut = CTRL;
					  2'b01 : gold_bus.RegistersOut = DATA_IN;
					  2'b10 : gold_bus.RegistersOut = CODEWORD_WIDTH;
					  default : gold_bus.RegistersOut = NOISE;
					endcase
				end
		end
end
//this signal is for the checker and coverage modules, to know what operation is beeing validate at each cycle
assign gold_bus.CTRL_REG = CTRL ; 

endmodule