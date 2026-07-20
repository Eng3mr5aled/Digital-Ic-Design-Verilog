// ------------ 4-Bit Johnson Counter ---------------//
module JohnsonCounter(d, rstn, clk, q);
// reset and clock are one-bit inputs 
input rstn, clk;
// d is a three-bit input 
input [3:0] d;
// q is a three-bit output
output [3:0] q;
// define a new wire not_q3 to invert the last bit of the q output
wire not_q3;
// invert the last bit q is a three-bit output
assign not_q3 = ~q[3];
// build the structure of the 4-bit Johnson Counter using four D flip-flops.
d_ff FF0 (not_q3, rstn, clk, q[0]) ;
d_ff FF1 (q[0], rstn, clk, q[1]) ;
d_ff FF2 (q[1], rstn, clk, q[2]) ;
d_ff FF3 (q[2], rstn, clk, q[3]) ;
endmodule
// --------------------------------------------------//

