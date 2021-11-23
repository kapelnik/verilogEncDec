//
// Verilog Module Project_lib.TOP
//
// Created:
//          by - benmaorr.UNKNOWN (L330W516)
//          at - 11:11:58 11/23/2021
//
// using Mentor Graphics HDL Designer(TM) 2019.2 (Build 5)
//

`resetall
`timescale 1ns/10ps
module TOP 
#(
//input Params
parameter DATA_WIDTH = 32,
parameter AMBA_ADDR_WIDTH = 20,
parameter AMBA_WORD = 32
)
(
input wire clk,
input wire rst,
input wire [AMBA_ADDR_WIDTH-1:0] 	PADDR,
input wire [AMBA_WORD-1:0] 			PWDATA,
input wire 							PENABLE,PSEL,PWRITE,
output reg [AMBA_WORD-1:0] 			PRDATA,
output reg [DATA_WIDTH-1:0] 		data_out,
output reg 							operation_done
);
//States 
parameter [1:0] IDLE 			= 2'b00,
				ENCODING 		= 2'b01,
				DECODING 		= 2'b10,
				NOISE 			= 2'b11;

//State reg controlled by the state machine
reg [1:0] State = 2'b00;
reg [1:0] Next_State = 2'b00;


//Registers, output from Register_selctor
wire [AMBA_WORD-1:0] CTRL_REG;
wire [AMBA_WORD-1:0] DATA_IN_REG;
wire [AMBA_WORD-1:0] CODEWORD_WIDTH_REG;
wire [AMBA_WORD-1:0] NOISE_REG;
wire [AMBA_WORD-1:0] PRDATA_REG;

reg  Small,Medium,Large,next_operation_done;


//Create register selector
Register_selctor #(DATA_WIDTH , AMBA_ADDR_WIDTH , AMBA_WORD )	Register_selctor(
   clk,rst,PADDR,PWDATA,PENABLE,PSEL,PWRITE,PRDATA_REG,CTRL_REG,DATA_IN_REG,CODEWORD_WIDTH_REG,NOISE_REG
);


 
always@(*) begin //
	case (State)
		ENCODING: begin	//=================ENCODING State//=================
					case (CTRL_REG[1:0])
						2'b00: begin
								Next_State			       	<=       IDLE;
							end
						default: Next_State			       	<=       IDLE;
					endcase
				end
		DECODING: begin	////=================DECODING State//=================
				
				end
		NOISE: begin	////=================NOISE State//=================
				
				end
		default: begin	////=================IDLE State//=================
					if(PADDR[3:2] == 2'b00) begin
							Next_State <= ENCODING;
						end
						
				end
	endcase
end

always@(*) begin //
	case (State)
		ENCODING: begin	//=================ENCODING State//=================

				end
		DECODING: begin	////=================DECODING State//=================
				
				end
		NOISE: begin	////=================NOISE State//=================
				
				end
		default: begin	////=================IDLE State//=================
					
				end
	endcase
end

//
always@(posedge clk or negedge rst) begin
	if(!rst) begin
		operation_done<= 1'b1;
		next_operation_done<= 1'b1;
	end
	else operation_done<= next_operation_done;
end


//State machine controller, each clock move to Next_State
always@(posedge clk or negedge rst) begin
	if(!rst) begin
		State<= IDLE;
		PRDATA<= {AMBA_WORD{1'b0}};
		data_out<=  {DATA_WIDTH{1'b0}};
		operation_done<= 1'b0;
	end
	else State <= Next_State;
end
























always@(*)
	case (CODEWORD_WIDTH_REG[1:0])
		2'b00: begin
				Small<= 1'b1;
				Medium <= 1'b0;
				Large <= 1'b0;
			end
		2'b00: begin
				Small<= 1'b0;
				Medium <= 1'b1;
				Large <= 1'b0;
			end
		default: begin
				Small<= 1'b0;
				Medium <= 1'b0;
				Large <= 1'b1;
			end
	endcase
end
 
endmodule