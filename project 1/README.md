# ITI_BQS — Bank Teller Queue Monitoring System

A Verilog model of an embedded queue-monitoring system for the ITI bank branch in Smart Village. The system tracks how many clients are waiting in line, estimates their expected waiting time, and displays both on seven-segment displays — while flagging (and alarming on) empty/full queue violations. Built with a mixed structural/behavioral architecture and verified in ModelSim.

## Project Specification

Two photocells — one at the front of the queue, one at the back — detect clients entering (back) and leaving (front) the line. Each photocell outputs `1` while its light beam is clear and `0` while a client is interrupting it. From this, the system must:

- Track `Pcount`, the number of clients currently waiting (0–7), incrementing on entry and decrementing on exit — counting each crossing exactly once, even if a client lingers in the beam.
- Compute `Wtime`, the expected waiting time in seconds, from a lookup-table ROM rather than live arithmetic, using:
  - `Wtime(Pcount = 0) = 0`
  - `Wtime(Pcount ≠ 0, Tcount) = ⌊3 × (Pcount + Tcount − 1) / Tcount⌋`, where `Tcount ∈ {1, 2, 3}` is the number of active tellers.
- Maintain `emptyFlag` / `fullFlag` reflecting queue status, and raise `emptyAlarm` / `fullAlarm` if a client tries to leave an empty queue or enter a full one.
- Support an active-low system reset that clears `Pcount` and `fullFlag`, and sets `emptyFlag`.

The full assignment brief (deliverables, hints, and the reference edge-detector circuit from Dr. Ahmed Shalaby) is included as `ITI_BQS_Project.pdf`.

## Architecture

The design is decomposed into small, reusable modules rather than one large block, per the assignment's hierarchy/modularity requirement:

```
                         ┌───────────────┐
 frontSensorInput ─────► │ Edge Detector │──leaveSensorEvent──┐
                         └───────────────┘                    │
                                                                ▼
                         ┌───────────────┐             ┌───────────────┐        ┌──────────────┐
 backSensorInput  ─────► │ Edge Detector │──enterSensorEvent──►│controllerFSM │──enable/upDown──►│ upDownCounter │──pCount──┐
                         └───────────────┘             └───────────────┘        └──────────────┘          │
                                                                │  │                                        │
                                                     emptyFlag,fullFlag                                    │
                                                     emptyAlarm,fullAlarm                                   │
                                                                                                             ▼
 tellers[2:0] ──► (popcount) ──tellersCount──┐                                          ┌─────────────────────────┐
                                              ├──addr = {tellersCount, pCount}──►────────►│      waitTime_rom       │
                                              │                                           └─────────────────────────┘
                                              │                                                       │ data[7:0]
                                              │                                     ┌─────────────────┴─────────────────┐
                                              │                                     ▼                                   ▼
                                              │                          sevenSegmentsDecoder             sevenSegmentsDecoder
                                              │                            (data[3:0], units)              (data[7:4], tens)
                                              │
                                              └──────────────► sevenSegmentsDecoder ({1'b0,pCount}) ──► pCountDisplay
```

## Repository Structure

```
├── ITIBQS.v                    # Top-level module — instantiates and wires everything together
├── controllerFSM.v               # 3-state FSM: queue empty / counting / full, drives counter + flags
├── upDownCounter.v                 # 3-bit synchronous up/down counter (behavioral)
├── edgeDetector.v                    # Single-pulse edge detector for each photocell input
├── D_FF.v                              # D flip-flop primitive used inside the edge detector
├── waitTime_rom.v                        # 32x8 ROM: Wtime lookup by {tellersCount, pCount}
├── waitTime_rom.txt                        # ROM contents, loaded via $readmemb
├── sevenSegmentsDecoder.v                    # BCD-to-7-segment decoder (shared, instantiated 3x)
├── module.v                                    # Empty module template/scaffold (unused)
│
├── ITIBQS_tb.v                    # Basic testbench (reset + single empty-alarm check)
├── ITIBQS2_tb.v                     # Full testbench covering the assignment's test strategy
├── do.do                              # ModelSim do-script driving ITIBQS directly via force commands
│
├── wtime.xlsx                     # Wtime lookup table worked out offline before ROM population
├── Notes.pdf                        # Hand-drawn design notes: I/O table, block diagram, FSM sketch
├── ITI_BQS_Project.pdf                # Original assignment brief
│
├── transcript                     # Simulation log
└── vsim.wlf                         # Waveform database
```

## Design

### Top Module — `ITIBQS`

```verilog
module ITIBQS (rstn, clk, frontSensorInput, backSensorInput, tellers,
               emptyFlag, fullFlag, emptyAlarm, fullAlarm,
               pCountDisplay, waitTimeDisplay_1, waitTimeDisplay_2);
```

| Signal | Direction | Width | Meaning |
|---|---|---|---|
| `clk` | input | 1 | System clock |
| `rstn` | input | 1 | Active-low reset — clears `Pcount`, sets `emptyFlag`, clears `fullFlag` |
| `frontSensorInput` | input | 1 | Front photocell (`1` = clear, `0` = interrupted) — leave side |
| `backSensorInput` | input | 1 | Back photocell (`1` = clear, `0` = interrupted) — enter side |
| `tellers[2:0]` | input | 3 | One bit per teller (1–3), `1` = in service |
| `emptyFlag` / `fullFlag` | output | 1 each | Queue status |
| `emptyAlarm` / `fullAlarm` | output | 1 each | Violation alarms (leave-while-empty / enter-while-full) |
| `pCountDisplay[6:0]` | output | 7 | 7-segment pattern for `Pcount` (0–7) |
| `waitTimeDisplay_1[6:0]` | output | 7 | 7-segment pattern, `Wtime` units digit |
| `waitTimeDisplay_2[6:0]` | output | 7 | 7-segment pattern, `Wtime` tens digit |

`tellersCount` is derived combinationally as a bit population count: `tellersCount = tellers[2] + tellers[1] + tellers[0]`, giving the number of active tellers (0–3). The ROM address concatenates this with `pCount`: `addr = {tellersCount, pCount}`.

### Edge Detector + D Flip-Flop

Converts a level-held photocell interruption into a single one-cycle pulse, so a client isn't double-counted while standing in the beam:

```verilog
module edgeDetector (sensorInput, rstn, clk, edgeEvent);
...
D_FF delayUnit (sensorInput, rstn, clk, delayInput);
assign edgeEvent = delayInput & ~sensorInput;
endmodule
```

Since the sensors here are active-low (idle = `1`, interrupted = `0`), this detects the *falling* edge of the raw signal — the instant a client breaks the beam — by ANDing the previous cycle's value (still `1`) with the inverted current value (now `0`). This is functionally equivalent to the rising-edge circuit shown in the assignment brief, adapted for this design's active-low sensor convention.

### Controller FSM

A 3-state Moore-style machine drives the counter and computes the flags/alarms:

| State | Meaning |
|---|---|
| `empty` (`2'b00`) | No clients in queue (initial/reset state) |
| `count` (`2'b01`) | Counting clients up or down |
| `full` (`2'b10`) | Queue at maximum capacity (`Pcount = 7`) |

**Transitions** (keyed on `{enterSensorEvent, leaveSensorEvent}`):

- **`empty`**: enter-only (`10`) → `count`, start counting up. Any other combination → stay, no counting.
- **`count`**: enter-only (`10`) → count up if `Pcount < 7`, else move to `full` and stop. Leave-only (`01`) → count down if `Pcount > 0`, else move to `empty` and stop. Simultaneous or no events (`00`/`11`) → stay, no counting (net zero change).
- **`full`**: leave-only (`01`) → `count`, start counting down. Any other combination → stay, no counting.

Flags and alarms are computed combinationally, independent of the FSM's registered state:

```verilog
nor(emptyFlag, pCount[2], pCount[1], pCount[0]);   // true when Pcount == 0
and(fullFlag,  pCount[2], pCount[1], pCount[0]);   // true when Pcount == 7
assign emptyAlarm = emptyFlag & leaveSensorEvent;
assign fullAlarm  = fullFlag  & enterSensorEvent;
```

This guarantees the counter never wraps past its bounds: the FSM only asserts `enable` for an increment when `Pcount < 7`, and only for a decrement when `Pcount > 0` — the boundary case is absorbed by transitioning to `full`/`empty` and de-asserting `enable` instead.

### Up-Down Counter

A generic, reusable 3-bit (default width, parameterizable) synchronous counter with an external enable and direction control — it has no bounds-checking of its own, relying entirely on the controller FSM to gate `enable` at the 0/7 boundaries:

```verilog
always @(posedge clk, negedge rstn)
    if (~rstn)
        pCount <= 0;
    else if (enable)
        pCount <= upDown ? pCount + 1 : pCount - 1;
    else
        pCount <= pCount;
```

### Wait Time ROM

A 32×8 ROM (`reg [7:0] arom [0:31]`), initialized at time 0 via `$readmemb("waitTime_rom.txt", arom)`. The 5-bit address concatenates `tellersCount` (2 bits) and `Pcount` (3 bits), so each 8-bit word holds two packed BCD digits — `data[3:0]` is the units digit, `data[7:4]` is the tens digit — pre-computed offline (see `wtime.xlsx`) from the `Wtime` formula rather than calculated live in hardware, per the assignment's performance recommendation.

### Seven-Segment Decoder

Standard combinational BCD-to-7-segment decoder, instantiated three times — once for `Pcount`, once each for the `Wtime` tens/units digits:

```verilog
case(binaryCode)
    4'b0000 : decimalPattern = 7'b1111110; // 0
    ...
    4'b1001 : decimalPattern = 7'b1111011; // 9
    default : decimalPattern = 7'b0000000; // off
endcase
```

## Test Strategy

`ITIBQS2_tb.v` implements the comprehensive test plan called for by the assignment (deliverable h/i):

| # | Test | Verifies |
|---|---|---|
| 1 | Assert `rstn` low, then release | Reset correctly clears `Pcount` and sets `emptyFlag` |
| 2 | Pulse `frontSensorInput` while `Pcount = 0` | `emptyAlarm` asserts on a leave-attempt against an empty queue |
| 3 | Pulse `backSensorInput` 7 times | `Pcount` climbs to 7 and `fullFlag` asserts, with no wraparound |
| 4 | Pulse `backSensorInput` once more | `fullAlarm` asserts on an enter-attempt against a full queue; `Pcount` stays at 7 |
| 5 | Pulse `frontSensorInput` twice | `Pcount` decrements normally (7 → 5) |
| 6 | Drive both sensors low, then high, simultaneously | Simultaneous enter+leave event results in no net change to `Pcount` |
| 7 | Change `tellers` (1 → 2 → 3 → 1 active) | `Wtime` display updates correctly as the ROM address's `tellersCount` field changes |

`ITIBQS_tb.v` is a lighter-weight smoke test covering just reset and one empty-alarm event, useful for quick sanity checks during development.

## Running the Simulation

Tested with **ModelSim – Intel FPGA Edition (2020.1)**.

**Via testbench:**
```tcl
vlib work
vlog D_FF.v edgeDetector.v upDownCounter.v controllerFSM.v waitTime_rom.v sevenSegmentsDecoder.v ITIBQS.v ITIBQS2_tb.v
vsim work.ITIBQS2_tb
add wave -r sim:/ITIBQS2_tb/*
run -all
```

**Via the included do-script** (drives `ITIBQS` directly with forced sensor/teller signals rather than through a testbench):
```tcl
do do.do
```

> **Note:** `waitTime_rom.v` loads `waitTime_rom.txt` via a relative path (`$readmemb("waitTime_rom.txt", arom)`) — make sure the `.txt` file sits in the same directory you launch `vsim` from, or the ROM will read as all-zero.

## Design Notes

- **Watch `force` value syntax when using the do-script.** One line in `do.do` forces `backSensorInput` to the string `St0` rather than `0` (`force -freeze sim:/ITIBQS/backSensorInput St0 0`) — an invalid value for a 1-bit signal. This won't hard-error, but it leaves the signal unknown (`x`) rather than deasserted, which will stall sensor-driven transitions until corrected.
- **Vector `force` values need an explicit radix.** `force -freeze sim:/ITIBQS/tellers 011 0` relies on ModelSim's default interpretation for a 3-bit value; since `modelsim.ini` sets `DefaultRadix = symbolic`, it's safer to write this explicitly as `3'b011` to avoid ambiguity between binary and decimal interpretation.
- **`module.v` is an unused scaffold file** — just the module template header/footer comments with no actual module declaration. Safe to ignore or delete; it isn't instantiated anywhere.

## Results

The design compiles and simulates with **0 errors**. `Pcount`, the empty/full flags, both alarms, and the `Wtime` display all respond correctly across the full test sequence in `ITIBQS2_tb.v`. Waveforms are available in `vsim.wlf` (open with `vsim -view vsim.wlf`).

## Author

Amr Khaled Sedik — Computer Engineering, Ain Shams University
*(Course project for Dr. Ahmed Shalaby's Digital Design lab, ITI_BQS final project)*
