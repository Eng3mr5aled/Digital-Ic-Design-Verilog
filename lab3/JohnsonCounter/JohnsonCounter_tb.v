module JohnsonCounter_tb;
  reg rstn, clk;
  reg [3:0] d;
  wire [3:0] q;
  
  // Added the missing semicolon here
  JohnsonCounter JohnsonCounter_dut (d, rstn, clk, q); 

  // --- Clock Generator ---
  // This block runs concurrently and toggles the clock every 5 time units 
  // (creating a total clock period of 10)
  always #5 clk = ~clk;

  initial begin
    // Completed the monitor statement to track the output sequence
    $monitor("Time = %0t | rstn = %b | clk = %b | q = %b", $time, rstn, clk, q);
    
    // Initialize signals
    clk = 0;
    rstn = 0; 
    d = 4'b0000;
    
    // Release reset after 10 time units to let the counter start
    #10 rstn = 1; 
    
    // Let the simulation run long enough to see the full Johnson sequence 
    // (A 4-bit Johnson counter has 8 distinct states)
    #100 $finish; 
  end

endmodule