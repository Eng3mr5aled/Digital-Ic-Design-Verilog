`timescale 10ns / 1ns
/* ------------------------  Module Declarations ----------------------------- */
module controllerFSM ( rstn, clk, leaveSensorEvent, enterSensorEvent, pCount,
					enable, upDown, emptyFlag, fullFlag, emptyAlarm, fullAlarm);
// ------------------------ Parameter Declarations --------------------------- //
parameter 	empty = 2'b00, // initial state - empty queue 
			count = 2'b01, // customers enter and leave queue- count up and down  
			full  = 2'b10; // full queue 
parameter counterwidth = 3;			
// -------------------------- Inputs Declarations ---------------------------- //
input rstn, clk;
// events from front and back sensors coming for edge detectors modules. 
input leaveSensorEvent, enterSensorEvent;
// customers number from the up down counter. 
input [counterwidth-1:0] pCount;
// ------------------------- Outputs Declarations ---------------------------- //
// enable signal for counting 
output reg enable; 
// control signal for counting up or down
output reg upDown;
// empty and full flags 
output emptyFlag, fullFlag; 
// alarm signals for empty and full vilotions.
output emptyAlarm, fullAlarm; 
// --------------------------- Wire Declarations ----------------------------- //
// ---------------------------- Reg Declarations ----------------------------- //
// fsm state variable 
reg [1:0] state;
// --------------------------------------------------------------------------- //
// ---------------------------- Initial setup  ------------------------------- //
// --------------------------------------------------------------------------- //
// ------------------------- Instantiation Modules --------------------------- //
// --------------------------------------------------------------------------- //
// ----------------------- Combinational Logic  ------------------------------ //
// empty flag , Once customers number equal to zeros
	nor(emptyFlag, pCount[2],pCount[1],pCount[0]);
// full flag , Once customers number equal to seven
    and(fullFlag,pCount[2],pCount[1],pCount[0]);
// empty alarm if the queue is empty and someone tries to leave the queue
assign emptyAlarm = (emptyFlag & leaveSensorEvent)? 1'b1: 1'b0; 
// full alarm if the queue is full and someone tries to enter the queue
assign fullAlarm = (fullFlag & enterSensorEvent)? 1'b1: 1'b0;  
// --------------------------------------------------------------------------- //
// ----------------------- Sequential  Logic  -------------------------------- //
always@(posedge clk, negedge rstn)
	begin
		if (~rstn)
			begin
				// the output of counter is zero at negative reset
				state <= empty;
				enable	  <= 1'b0;
				upDown	  <= 1'b0;
			end
		else
			begin
				case(state) // state transitions  
					// empty state where no customers in the queue. 		
					empty: 
					begin 
						case ({enterSensorEvent,leaveSensorEvent })
							2'b00, 2'b11, 2'b01 : 
							begin enable <= 1'b0; upDown <= 1'b0;  end  // stop count
							2'b10 :  
							begin state <= count; enable <= 1'b1; upDown <= 1'b1; end // count up
						endcase
					end
					// count up and down state based on enter and leave customers. 		
					count: 
					begin
						case ({enterSensorEvent,leaveSensorEvent })
							2'b00, 2'b11 :  begin enable <= 1'b0; upDown <= 1'b0; end
							2'b10 : 
								begin 	
									if (pCount < 7) 
										begin 
										state <= count; 
										enable <= 1'b1; upDown	<= 1'b1; // count up
										end
									else 
										begin 
										state <= full; 
										enable <= 1'b0; upDown	<= 1'b0; // stop count
									end
								end	
							2'b01 : 
								begin
									if (pCount > 0) 
										begin 
										state <= count; 
										enable <= 1'b1; upDown	<= 1'b0; // count down
										end
									else 
										begin 
										state <= empty; 
										enable <= 1'b0; upDown	<= 1'b0; // stop count
										end
								end		
						endcase
					end	
					// full state where customers fulfill the queue. 		
					full: 
					begin
						case ({enterSensorEvent,leaveSensorEvent })
							2'b00, 2'b11, 2'b10 : 
							begin enable <= 1'b0; upDown <= 1'b0; end  // stop count
							2'b01 :  
							begin state <= count; enable <= 1'b1; upDown <= 1'b0; end// count down
						endcase
					end
				endcase
			end 
	end
// --------------------------------------------------------------------------- //
endmodule
// ----------------------------- End of File --------------------------------- //
