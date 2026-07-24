`timescale 10ns / 1ns
/* ------------------------  Module Declarations ----------------------------- */
module ITIBQS_tb();
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
			forever #50 clk = ~clk;
		end
	// Stimulus block 
    initial begin
        // 1. Reset active low
        rstn = 0;
        frontSensorInput = 1;
        backSensorInput  = 1;
        tellers = 3'b001;
        #100;              
        rstn = 1;            
        #100;                
        // 2. frontSensorInput / empty alarm
        # 100 frontSensorInput = 0;
        # 100 frontSensorInput = 1;		
		// Enjoy Continue testbench

        $stop;  // end simulation
    end
	// dispaly on transcript window
	initial
		begin
		$display("--------------------------- Test Bench for ITIBQS --------------------------------     ");
		$display("Time | rstn | frontSensor | backSensor | tellers | emptyFlag | fullFlag | emptyAlarm | fullAlarm | pCount");
		$monitor(" %d   %b    %b      	%b        	%b       %b    		%b    		%b         %b          %b",
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
		.waitTimeDisplay_2(waitTimeDisplay_2));
// --------------------------------------------------------------------------- //
// ----------------------- Combinational Logic  ------------------------------ //
// --------------------------------------------------------------------------- //
// ----------------------- Sequential  Logic  -------------------------------- //
// --------------------------------------------------------------------------- //
// --------------------------------------------------------------------------- //
endmodule
// ----------------------------- End of File --------------------------------- //
