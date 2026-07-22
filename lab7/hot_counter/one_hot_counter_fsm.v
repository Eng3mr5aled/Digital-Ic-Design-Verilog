module one_hot_counter_fsm (clk, reset, oneHot);
input clk, reset;
output [9:0] oneHot;
// ------------------------------------------------- //
parameter S0 = 2'b00, // initial state
S1 = 2'b01, // shift left state
S2 = 2'b10; // shift right state
reg [9:0] oneHot;
reg [1:0] State;
// ------------------------------------------------- //
always @(posedge clk or posedge reset)
begin
if(reset) // reset the state to initial state and output to zeros
begin
State = S0;
oneHot <= 10'b0000_0000_01;
end
else
begin
case(State) // state transitions
S0: State <= S1; // move to state S1 (shift left state)
S1: if(oneHot < 10'b1000_0000_00)
oneHot <= oneHot << 1; // shift one left
else
State <= S2; // move to S2 (shift right state)
S2: if(oneHot > 10'b0000_0000_01)
oneHot <= oneHot >> 1; // shift one right
else
State <= S1; // move to S1 (shift left state)
endcase
end
end
// ------------------------------------------------- //
endmodule