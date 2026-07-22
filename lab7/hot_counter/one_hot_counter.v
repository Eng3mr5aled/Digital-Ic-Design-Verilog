module one_hot_counter (clk, reset, oneHot);
input clk, reset;
output [9:0] oneHot;
// Instantiation of the clcok divider
clock_divider clock_divider_1Hz (clk, reset, CLK1Hz);
// Instantiation of the one hot couter fsm
one_hot_counter_fsm one_hot_cnt (CLK1Hz,reset, oneHot);
endmodule
