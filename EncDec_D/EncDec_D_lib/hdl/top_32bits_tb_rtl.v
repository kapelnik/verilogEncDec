//
// Test Bench Module Project_lib.TOP_tb.TOP_tester
//
// Created:
//          by - benmaorr.UNKNOWN (L330W516)
//          at - 13:49:22 11/24/2021
//
// Generated by Mentor Graphics' HDL Designer(TM) 2019.2 (Build 5)
//
`resetall
`timescale 1ns/10ps

module TOP_32bits_tb;

// Local declarations
parameter AMBA_WORD = 32;
parameter AMBA_ADDR_WIDTH = 32;
parameter DATA_WIDTH = 32;
parameter IDLE = 2'b00;
parameter ENCODING = 2'b01;
parameter DECODING = 2'b10;
parameter NOISE = 2'b11;

// Internal signal declarations
logic                         clk = 1'b0;
logic                         rst = 1'b0;
reg [AMBA_ADDR_WIDTH - 1:0] PADDR;
reg [AMBA_WORD - 1:0]       PWDATA;
logic                         PENABLE;
logic                         PSEL;
logic                         PWRITE;
reg [AMBA_WORD - 1:0]       PRDATA;
reg [DATA_WIDTH - 1:0]      data_out;
logic                         operation_done;
reg [1:0] 				     num_of_errors;


ECC_ENC_DEC #(.DATA_WIDTH(DATA_WIDTH) , .AMBA_ADDR_WIDTH(AMBA_ADDR_WIDTH) , .AMBA_WORD(AMBA_WORD)) U_0(
   .clk            (clk),
   .rst            (rst),
   .PADDR          (PADDR),
   .PWDATA         (PWDATA),
   .PENABLE        (PENABLE),
   .PSEL           (PSEL),
   .PWRITE         (PWRITE),
   .PRDATA         (PRDATA),
   .data_out       (data_out),
   .operation_done (operation_done),
   .num_of_errors  (num_of_errors)
);

//clock always block:
always
#1 clk <=~clk;

initial begin

$display("8 bits Top Test Bench");


#10.2ns;  //asyncrounsly de-assert asrtn
rst <= 1'b0;
#10;
@(posedge clk) rst <= 1'b1;

repeat(10)@(posedge clk);

// WRITE TO REGISTERS TEST

PWDATA 	<=	 32'b00000001010100101111000000001010; // 10101010
PADDR 	<= 	{{AMBA_ADDR_WIDTH-4{1'b0}},{4'b0100}}; // DATA
PSEL	<= 	1'b1;
PWRITE	<= 	1'b1;

#2;
PENABLE <= 1'b1;
#2;
PSEL <= 1'b0;
PENABLE <= 1'b0;

repeat(5)@(posedge clk);

PWDATA <= {{AMBA_WORD-2{1'b1}},{2'b10}};  //// 0000000000
PADDR <= {{AMBA_ADDR_WIDTH-4{1'b0}},{4'b1000}}; // WIDTH
PSEL <= 1'b1;

#2;
PENABLE <= 1'b1;
#2;
PSEL <= 1'b0;
PENABLE <= 1'b0;

repeat(5)@(posedge clk);
// Data 1 error
PWDATA <= {{AMBA_WORD-8{1'b0}},{8'b01000000}}; // 11111__1100
PADDR <= {{AMBA_ADDR_WIDTH-4{1'b0}},{4'b1100}}; // NOISE
PSEL <= 1'b1;

#2;
PENABLE <= 1'b1;
#2;
PSEL <= 1'b0;
PENABLE <= 1'b0;

repeat(5)@(posedge clk);

PWDATA <= {{AMBA_WORD-3{1'b0}},{3'b010}}; // 11111000
PADDR <= {{AMBA_ADDR_WIDTH-4{1'b0}},{4'b0000}}; // CTRL
PSEL <= 1'b1;



#2;
PENABLE <= 1'b1;
#2;
PSEL <= 1'b0;
PENABLE <= 1'b0;

#7;
$display("operation_done: %b",operation_done);
$display("%b",32'b01010100101111000000001010101101);
$display("%b",data_out);
$display("Test 1 Data_Out: 			%b",32'b01010100101111000000001010101101==data_out);
$display("Test 1 Number_of_Errors: 	%b",2'b01==num_of_errors);


repeat(5)@(posedge clk);
// 0 error
PWDATA <= {{AMBA_WORD-8{1'b0}},{8'b00000000}}; // 11111__1100
PADDR <= {{AMBA_ADDR_WIDTH-4{1'b0}},{4'b1100}}; // NOISE
PSEL <= 1'b1;

#2;
PENABLE <= 1'b1;
#2;
PSEL <= 1'b0;
PENABLE <= 1'b0;

repeat(5)@(posedge clk);

PWDATA <= {{AMBA_WORD-3{1'b0}},{3'b010}}; // 11111000
PADDR <= {{AMBA_ADDR_WIDTH-4{1'b0}},{4'b0000}}; // CTRL
PSEL <= 1'b1;

#2;
PENABLE <= 1'b1;
#2;
PSEL <= 1'b0;
PENABLE <= 1'b0;

#6;
// $display("%b",32'b01010100101111000000001010101101);
// $display("%b",data_out);
$display("Test 2 Data_Out: 			%b",32'b01010100101111000000001010101101==data_out);
$display("Test 2 Number_of_Errors: 	%b",2'b00==num_of_errors);


repeat(5)@(posedge clk);
// Parity 1 error
PWDATA <= {{AMBA_WORD-8{1'b0}},{8'b00000010}}; // 11111__1100
PADDR <= {{AMBA_ADDR_WIDTH-4{1'b0}},{4'b1100}}; // NOISE
PSEL <= 1'b1;

#2;
PENABLE <= 1'b1;
#2;
PSEL <= 1'b0;
PENABLE <= 1'b0;

repeat(5)@(posedge clk);

PWDATA <= {{AMBA_WORD-3{1'b0}},{3'b010}}; // 11111000
PADDR <= {{AMBA_ADDR_WIDTH-4{1'b0}},{4'b0000}}; // CTRL
PSEL <= 1'b1;

#2;
PENABLE <= 1'b1;
#2;
PSEL <= 1'b0;
PENABLE <= 1'b0;

#6;
// $display("%b",32'b01010100101111000000001010101101);
// $display("%b",data_out);
$display("Test 3 Data_Out: 			%b",32'b01010100101111000000001010101101==data_out);
$display("Test 3 Number_of_Errors: 	%b",2'b01==num_of_errors);


repeat(5)@(posedge clk);
// Parity 2 error
PWDATA <= {{AMBA_WORD-8{1'b0}},{8'b00000110}}; // 11111__1100
PADDR <= {{AMBA_ADDR_WIDTH-4{1'b0}},{4'b1100}}; // NOISE
PSEL <= 1'b1;

#2;
PENABLE <= 1'b1;
#2;
PSEL <= 1'b0;
PENABLE <= 1'b0;

repeat(5)@(posedge clk);

PWDATA <= {{AMBA_WORD-3{1'b0}},{3'b010}}; // 11111000
PADDR <= {{AMBA_ADDR_WIDTH-4{1'b0}},{4'b0000}}; // CTRL
PSEL <= 1'b1;

#2;
PENABLE <= 1'b1;
#2;
PSEL <= 1'b0;
PENABLE <= 1'b0;

#6;
$display("Test 4 Data_Out: 			%b",32'b01010100101111000000001010101101!=data_out);
$display("Test 4 Number_of_Errors: 	%b",2'b10==num_of_errors);




repeat(5)@(posedge clk);
// mix 2 error
PWDATA <= {{AMBA_WORD-8{1'b0}},{8'b01000010}}; // 11111__1100
PADDR <= {{AMBA_ADDR_WIDTH-4{1'b0}},{4'b1100}}; // NOISE
PSEL <= 1'b1;

#2;
PENABLE <= 1'b1;
#2;
PSEL <= 1'b0;
PENABLE <= 1'b0;

repeat(5)@(posedge clk);

PWDATA <= {{AMBA_WORD-3{1'b0}},{3'b010}}; // 11111000
PADDR <= {{AMBA_ADDR_WIDTH-4{1'b0}},{4'b0000}}; // CTRL
PSEL <= 1'b1;

#2;
PENABLE <= 1'b1;
#2;
PSEL <= 1'b0;
PENABLE <= 1'b0;

#6;
$display("Test 5 Data_Out: 			%b",32'b01010100101111000000001010101101!=data_out);
$display("Test 5 Number_of_Errors: 	%b",2'b10==num_of_errors);


repeat(5)@(posedge clk);
// Data 2 error
PWDATA <= {{AMBA_WORD-8{1'b0}},{8'b11000000}}; // 11111__1100
PADDR <= {{AMBA_ADDR_WIDTH-4{1'b0}},{4'b1100}}; // NOISE
PSEL <= 1'b1;

#2;
PENABLE <= 1'b1;
#2;
PSEL <= 1'b0;
PENABLE <= 1'b0;

repeat(5)@(posedge clk);

PWDATA <= {{AMBA_WORD-3{1'b0}},{3'b010}}; // 11111000
PADDR <= {{AMBA_ADDR_WIDTH-4{1'b0}},{4'b0000}}; // CTRL
PSEL <= 1'b1;

#2;
PENABLE <= 1'b1;
#2;
PSEL <= 1'b0;
PENABLE <= 1'b0;

#6;
$display("Test 6 Data_Out: 			%b",32'b01010100101111000000001010101101!=data_out);
$display("Test 6 Number_of_Errors: 	%b",2'b10==num_of_errors);



// READ FROM REGISTERS TEST

PWRITE <= 1'b0;

//CTRL
repeat(20)@(posedge clk);

PADDR <= {{AMBA_ADDR_WIDTH-4{1'b0}},{4'b0000}}; // CTRL
PSEL <= 1'b1;

#2;
PENABLE <= 1'b1;
#2;
PSEL <= 1'b0;
PENABLE <= 1'b0;

//DATA_IN
repeat(30)@(posedge clk);

PADDR <= {{AMBA_ADDR_WIDTH-4{1'b0}},{4'b0100}}; // DATA
PSEL <= 1'b1;

#2;
PENABLE <= 1'b1;
#2;
PSEL <= 1'b0;
PENABLE <= 1'b0;

//WIDTH
repeat(10)@(posedge clk);

PADDR <= {{AMBA_ADDR_WIDTH-4{1'b0}},{4'b1000}}; // WIDTH
PSEL <= 1'b1;

#2;
PENABLE <= 1'b1;
#2;
PSEL <= 1'b0;
PENABLE <= 1'b0;

//NOISE
repeat(10)@(posedge clk);

PADDR <= {{AMBA_ADDR_WIDTH-4{1'b0}},{4'b1100}}; // NOISE
PSEL <= 1'b1;

#2;
PENABLE <= 1'b1;
#2;
PSEL <= 1'b0;
PENABLE <= 1'b0;




#10000
$finish(0);
end

endmodule // TOP_tb


