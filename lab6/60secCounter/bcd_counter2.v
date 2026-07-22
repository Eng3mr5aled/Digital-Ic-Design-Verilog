module bcd_counter2 ( 
     input clk, 
     input reset,
     input Enable,
     output reg [3:0] count 
);

    always @ (posedge clk or posedge reset) begin
        if (reset) begin 
            // reset the counter circuit to initial (zero)
            count <= 4'b0000;
        end else if (Enable) begin
            // If Enable is high, evaluate the counter
            if (count == 5) begin
                // reset to 0 AFTER 5 to act as a Modulo-6 counter (tens digit)
                count <= 4'b0000;
            end else begin
                // otherwise, add one
                count <= count + 1'b1;
            end
        end
    end

endmodule