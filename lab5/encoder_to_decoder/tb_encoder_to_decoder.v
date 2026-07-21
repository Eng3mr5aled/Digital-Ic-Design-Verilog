`timescale 1ns / 1ps

module tb_encoder_to_decoder;

    // Inputs
    reg [9:0] i, k, l;

    // Outputs (Now using 7-bit vectors to match the new design)
    wire [6:0] seg1;
    wire [6:0] seg2;
    wire [6:0] seg3;

    // Instantiate the Unit Under Test (UUT)
    encoder_to_decoder uut (
        .i(i), 
        .k(k), 
        .l(l),
        .seg1(seg1), 
        .seg2(seg2), 
        .seg3(seg3)
    );

    initial begin
        // Initialize Inputs to zero
        i = 0; k = 0; l = 0;
        #10;

        // Test Case 1: i=5, k=2, l=9
        i = 10'b0000100000; // Bit 5 is high
        k = 10'b0000000100; // Bit 2 is high
        l = 10'b1000000000; // Bit 9 is high
        #10;

        // Test Case 2: i=0, k=7, l=4
        i = 10'b0000000001; // Bit 0 is high
        k = 10'b0010000000; // Bit 7 is high
        l = 10'b0000010000; // Bit 4 is high
        #10;

        $stop; // End simulation
    end

endmodule