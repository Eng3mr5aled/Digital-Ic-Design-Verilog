// Top module counter_to_decoder
module counter_to_decoder ( 
    input clk, 
    input reset, 
    output [6:0] segment_leds1, 
    output [6:0] segment_leds2
);

    wire [3:0] count_wire1;
    wire [3:0] count_wire2;
    wire enable;

    // Instantiation of the primary BCD counter (Units)
    bcd_counter bcd_counter1_dut ( 
        .clk(clk), 
        .reset(reset), 
        .count(count_wire1), 
        .Enable(enable)
    );

    // Instantiation of the secondary BCD counter (Tens)
    bcd_counter2 bcd_counter2_dut ( 
        .clk(clk), 
        .reset(reset), 
        .Enable(enable), 
        .count(count_wire2)
    );

    // Instantiation of the seven segments decoder (Units)
    decoder_7seg decoder_7seg_dut1 ( 
        .A(count_wire1[3]), 
        .B(count_wire1[2]), 
        .C(count_wire1[1]), 
        .D(count_wire1[0]),
        .led_a(segment_leds1[0]), 
        .led_b(segment_leds1[1]), 
        .led_c(segment_leds1[2]), 
        .led_d(segment_leds1[3]), 
        .led_e(segment_leds1[4]), 
        .led_f(segment_leds1[5]), 
        .led_g(segment_leds1[6])
    );

    // Instantiation of the seven segments decoder (Tens)
    decoder_7seg decoder_7seg_dut2 ( 
        .A(count_wire2[3]), 
        .B(count_wire2[2]), 
        .C(count_wire2[1]), 
        .D(count_wire2[0]),
        .led_a(segment_leds2[0]), 
        .led_b(segment_leds2[1]), 
        .led_c(segment_leds2[2]), 
        .led_d(segment_leds2[3]), 
        .led_e(segment_leds2[4]), 
        .led_f(segment_leds2[5]), 
        .led_g(segment_leds2[6])
    );

endmodule
