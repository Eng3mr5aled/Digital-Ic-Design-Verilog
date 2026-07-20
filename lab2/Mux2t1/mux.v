// AND Gate
module andGate (a, b, c);
    input a, b;         // Changed 'inout' to 'input'
    output c;
    
    assign c = a & b;
endmodule

// NOT Gate
module notGate (h, g);
    input h;
    output g;
    
    assign g = ~h;
endmodule

// OR Gate
module orGate (j, n, m);
    input j, n;         // Changed 'inout' to 'input'
    output m;
    
    assign m = j | n;
endmodule           // Removed trailing semicolon

// 2-to-1 Mux
module mux2t1 (s, D0, D1, y);
    input s, D0, D1;    // Changed 'inout' to 'input' and 'Do' to 'D0'
    output y;
    
    wire nots, out_G2, out_G3;
    
    notGate G1 (s, nots);
    andGate G2 (D0, nots, out_G2);
    andGate G3 (s, D1, out_G3);
    orGate G4 (out_G2, out_G3, y);
endmodule
