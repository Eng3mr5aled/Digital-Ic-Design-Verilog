// 7-segment decoder using a 7-bit output vector
module decoder_7seg (
    input A, B, C, D,
    output [6:0] seg 
);
    // seg[0]=a, seg[1]=b, seg[2]=c, seg[3]=d, seg[4]=e, seg[5]=f, seg[6]=g
    assign seg[0] = A | C | (B&D) | (~B&~D);
    assign seg[1] = ~B | (~C&~D) | (C&D);
    assign seg[2] = B | ~C | D;
    // Added parentheses around (~B&C) for strict operator precedence
    assign seg[3] = (~B&~D) | (C&~D) | (B&~C&D) | ((~B&C)|A); 
    assign seg[4] = (~B&~D) | (C&~D);
    assign seg[5] = A | (~C&~D) | (B&~C) | (B&~D);
    assign seg[6] = A | (B&~C) | (~B&C) | (C&~D);
endmodule

// Decimal-to-BCD encoder (one-hot keypad digit -> 4-bit BCD)
module decimal_to_bcd (
    input  [9:0] i,
    output [3:0] a
);
    assign a[0] = i[1] | i[3] | i[5] | i[7] | i[9];
    assign a[1] = i[2] | i[3] | i[6] | i[7];
    assign a[2] = i[4] | i[5] | i[6] | i[7];
    assign a[3] = i[8] | i[9];
endmodule

// Top module: 3 keypad digits -> 3 encoders -> 3 seven-seg displays
module encoder_to_decoder (
    input  [9:0] i, k, l,
    output [6:0] seg1, seg2, seg3
);
    wire [3:0] bcd1, bcd2, bcd3;

    // Instantiate Encoders
    decimal_to_bcd G1 (i, bcd1);
    decimal_to_bcd G2 (k, bcd2);
    decimal_to_bcd G3 (l, bcd3);

    // Instantiate Decoders
    // Passing the individual BCD bits and the 7-bit output vector
    decoder_7seg D1 (bcd1[3], bcd1[2], bcd1[1], bcd1[0], seg1);
    decoder_7seg D2 (bcd2[3], bcd2[2], bcd2[1], bcd2[0], seg2);
    decoder_7seg D3 (bcd3[3], bcd3[2], bcd3[1], bcd3[0], seg3);
endmodule
