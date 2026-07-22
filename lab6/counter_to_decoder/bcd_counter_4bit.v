module bcd_counter(  clk,   reset,  count);
input clk , reset ;
// 4 bits output
output [3:0] count; 
// 4 bits reg to hold the value of the output 
reg [3:0] count; 
// BCD counter
always @ (posedge clk or posedge reset)
	begin
		if(reset) // reset the counter circuit to initial (zero)
			count <= 0;
		else
			begin
				// check the count value equal nine to reset
				if (count == 9)
					count <= 4'b0;
				// if less than nine, add one
				else 
					count <= count + 1'b1;	
			end
	end
endmodule
