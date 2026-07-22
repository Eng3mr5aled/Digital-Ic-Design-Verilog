module bcd_counter ( 
    input clk, 
    input reset, 
    output reg [3:0] count, 
    output reg Enable 
);

    always @ (posedge clk or posedge reset) begin
        if (reset) begin 
            // reset the counter and enable signal
            count <= 4'b0000;
            Enable <= 1'b0;
        end else begin
            if (count == 9) begin
                // check if count equals nine to reset and trigger enable
                count <= 4'b0000;
                Enable <= 1'b1;
            end else begin
                // if less than nine, add one and keep enable low
                count <= count + 1'b1;
                Enable <= 1'b0;
            end
        end
    end

endmodule
