module ALU ( A, B, ALU_sel, ALU_result);
input [1:0] A,B; // ALU 2-bit Inputs
input [2:0] ALU_sel; // ALU 3-bit Selector
output [3:0] ALU_result; // ALU 4-bit Output
reg [3:0] ALU_result;
always @(*)
begin
case(ALU_sel)
3'b000: // Logical and
ALU_result = A & B;
3'b001: // Logical or
ALU_result = A | B;
3'b010: // Addition
ALU_result = A + B;
3'b011: // Subtraction
ALU_result = A - B;
3'b100: // Multiplication
ALU_result = A * B;
3'b101: // Greater comparison
ALU_result = A > B? 4'b1010:4'b1011;
3'b110: // lower comparison
ALU_result = A < B? 4'b1011:4'b1010;
3'b111: // Equal comparison
ALU_result = A == B? 4'b1100:4'b0000;
default: ALU_result = 4'b0 ;
endcase
end
endmodule
module sevenSegments (bcd,dec);
input [3:0]bcd;
output reg [6:0] dec;
always@(bcd)
begin
case(bcd)
4'b0000 : dec = 7'b1111110; // 0
4'b0001 : dec = 7'b0110000; // 1
4'b0010 : dec = 7'b1101101; // 2
4'b0011 : dec = 7'b1111001; // 3
4'b0100 : dec = 7'b0110011; // 4
4'b0101 : dec = 7'b1011011; // 5
4'b0110 : dec = 7'b1011111; // 6
4'b0111 : dec = 7'b1110000; // 7
4'b1000 : dec = 7'b1111111; // 8
4'b1001 : dec = 7'b1111011; // 9
4'b1010 : dec = 7'b1110111; // A
4'b1011 : dec = 7'b1111111; // B
4'b1100 : dec = 7'b1001000; // =
default : dec = ~7'b1111110; //0 default
endcase
end
endmodule
module ALU_to_decoder (A, B, ALU_sel,Segmentleds,leds);
input [1:0] A,B; // ALU 2-bit Inputs
input [2:0] ALU_sel; // ALU 3-bit Selector
output [6:0] Segmentleds; //Seven segment leds
output [1:0] leds; // Leds
wire [3:0] ALU_result; // ALU 4-bit Output
// Instantiation of the ALU
ALU ALU_dut(A, B, ALU_sel, ALU_result);
// Instantiation of the Seven segment //Display Output on Seven segments
sevenSegments sevenSegments_dut (ALU_result,Segmentleds);
assign leds = ALU_result [1:0]; //Diplay Output on Leds
endmodule
