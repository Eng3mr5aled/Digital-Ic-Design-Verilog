`timescale 10ns / 1ns

/* ------------------------  Module Declarations ----------------------------- */
module ITIBQS2_tb();

// ------------------------ Parameter Declarations --------------------------- //
// -------------------------- Inputs Declarations ---------------------------- //
// ------------------------- Outputs Declarations ---------------------------- //
// --------------------------- Wire Declarations ----------------------------- //
// empty and full flags 
wire emptyFlag, fullFlag; 
// alarm signals for empty and full vilotions.
wire emptyAlarm, fullAlarm; 
// seven segments display 
wire [6:0] pCountDisplay, waitTimeDisplay_1, waitTimeDisplay_2; 

// ---------------------------- Reg Declarations ----------------------------- //
    reg rstn;
    reg clk;
    reg frontSensorInput;
    reg backSensorInput;
    reg [2:0] tellers;

// --------------------------------------------------------------------------- //
// ---------------------------- Initial setup  ------------------------------- //
    // Generate clock 
    initial 
        begin
            clk = 0;
            forever #50 clk = ~clk; // forever only in tb not in implementations
        end

    // Stimulus block 
    initial begin
        // 1. Reset active low
        rstn = 0;
        frontSensorInput = 1;
        backSensorInput  = 1;
        tellers = 3'b001; // Start with 1 teller
        #100;              
        rstn = 1;            
        #100;                
        
        // 2. Empty alarm test
        // frontSensorInput (leave queue) while Pcout = 0 should trigger emptyAlarm
        #100 frontSensorInput = 0; 
        #100 frontSensorInput = 1;
        #100;

        // 3. Fill the queue to test backSensorInput (enter queue) and fullFlag
        // Pcout max is 7, so we trigger the back sensor 7 times
        repeat (7) begin
            #100 backSensorInput = 0; 
            #100 backSensorInput = 1;
        end
        #100;

        // 4. Full alarm test
        // backSensorInput (enter queue) while Pcout = 7 should trigger fullAlarm
        #100 backSensorInput = 0; 
        #100 backSensorInput = 1;
        #100;

        // 5. Normal Leave queue test (Count down)
        // Pcout should decrement from 7 to 5
        repeat (2) begin
            #100 frontSensorInput = 0; 
            #100 frontSensorInput = 1;
        end
        #100;

        // 6. Simultaneous Enter and Leave test
        // State 11 -> No Change
        #100;
        frontSensorInput = 0;
        backSensorInput  = 0;
        #100;
        frontSensorInput = 1;
        backSensorInput  = 1;
        #100;

        // 7. Wait Time Calculation Test
        // Change the number of active tellers to trigger wait time ROM/Calculation updates
        #100 tellers = 3'b011; // 2 tellers active
        #200 tellers = 3'b111; // 3 tellers active
        #200 tellers = 3'b001; // Back to 1 teller active
        #200;

        $display("--------------------------- Simulation Complete --------------------------------     ");
        $stop;  // end simulation
    end

    // display on transcript window
    initial
        begin
        $display("--------------------------- Test Bench for ITIBQS --------------------------------     ");
        $display("Time | rstn | frontSensor | backSensor | tellers | emptyFlag | fullFlag | emptyAlarm | fullAlarm | pCount");
        $monitor(" %d   %b    %b          %b          %b        %b           %b           %b           %b           %b",
        $time, rstn, frontSensorInput, backSensorInput, tellers,  emptyFlag,  fullFlag,  emptyAlarm, fullAlarm, pCountDisplay);
        end
    
// --------------------------------------------------------------------------- //
// ------------------------- Instantiation Modules --------------------------- //
ITIBQS ITIBQS_testUnit ( 
        .rstn(rstn),
        .clk(clk),
        .frontSensorInput(frontSensorInput),
        .backSensorInput(backSensorInput),
        .tellers(tellers), 
        .emptyFlag(emptyFlag), 
        .fullFlag(fullFlag), 
        .emptyAlarm(emptyAlarm), 
        .fullAlarm(fullAlarm),
        .pCountDisplay(pCountDisplay), 
        .waitTimeDisplay_1(waitTimeDisplay_1), 
        .waitTimeDisplay_2(waitTimeDisplay_2)
);

// --------------------------------------------------------------------------- //
// ----------------------- Combinational Logic  ------------------------------ //
// --------------------------------------------------------------------------- //
// ----------------------- Sequential  Logic  -------------------------------- //
// --------------------------------------------------------------------------- //
// --------------------------------------------------------------------------- //
endmodule
// ----------------------------- End of File ---------------------------------