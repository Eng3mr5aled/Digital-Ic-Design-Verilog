# 4-Bit Johnson Counter — Verilog & ModelSim

A 4-bit Johnson (twisted-ring) counter built from four asynchronous-reset D flip-flops, simulated in ModelSim.

## Overview

| Module | File | Built From |
|---|---|---|
| `JohnsonCounter` | `JohnsonCounter.v` | 4x `d_ff` |
| `d_ff` | `d_ff.v` | Async-reset D flip-flop primitive |

The counter feeds the inverted output of the last flip-flop back into the first, producing an 8-state repeating sequence from 4 bits.

## Repository Structure

```
├── d_ff.v                    # D flip-flop primitive (async reset)
├── JohnsonCounter.v           # 4-bit Johnson counter (structural)
├── JohnsonCounter_tb.v          # Testbench w/ clock gen + $monitor
├── JohnsonCounter.do              # ModelSim do-script (waveform, force signals)
├── JohnsonCounter.mpf              # ModelSim project file
├── JohnsonCounter_cr.mti             # ModelSim compile record
│
├── transcript                        # Simulation log
└── vsim.wlf                           # Waveform database
```

## Design

### D Flip-Flop

Positive-edge-triggered, asynchronous active-low reset:

```verilog
module d_ff (d, rstn, clk, q);
input d, rstn, clk;
output reg q;

always @ (posedge clk or negedge rstn)
    if (!rstn) q <= 0;
    else       q <= d;
endmodule
```

### 4-Bit Johnson Counter

Four D flip-flops in a shift-register chain, with the complement of `q[3]` fed back into `FF0`:

```verilog
module JohnsonCounter (d, rstn, clk, q);
input rstn, clk;
input  [3:0] d;
output [3:0] q;

wire not_q3 = ~q[3];

d_ff FF0 (not_q3, rstn, clk, q[0]);
d_ff FF1 (q[0],   rstn, clk, q[1]);
d_ff FF2 (q[1],   rstn, clk, q[2]);
d_ff FF3 (q[2],   rstn, clk, q[3]);
endmodule
```

**State sequence** (after reset, `q = 0000`):

| Cycle | q[3:0] |
|---|---|
| 0 | 0000 |
| 1 | 0001 |
| 2 | 0011 |
| 3 | 0111 |
| 4 | 1111 |
| 5 | 1110 |
| 6 | 1100 |
| 7 | 1000 |
| 8 | 0000 (repeats) |

## Testbench

`JohnsonCounter_tb.v` generates a free-running clock (period 10, via `always #5 clk = ~clk`), holds `rstn` low for 10 time units, then releases it and lets the counter run for 100 time units — enough to observe the full 8-state cycle. `$monitor` logs `time`, `rstn`, `clk`, and `q` on every change.

## Running the Simulation

Tested with **ModelSim – Intel FPGA Edition (2020.1)**.

```tcl
vlib work
vlog d_ff.v JohnsonCounter.v JohnsonCounter_tb.v
vsim work.JohnsonCounter_tb
add wave -r sim:/JohnsonCounter_tb/*
run -all
```

Alternatively, replay the included do-script (drives the DUT directly with forced clock/reset signals rather than the testbench):

```tcl
do JohnsonCounter.do
```

## Results

Design compiled and simulated with **0 errors**. The output `q` cycles correctly through the 8-state Johnson sequence after reset is released. Waveforms are available in `vsim.wlf` (open with `vsim -view vsim.wlf`).

## Author

Amr Khaled Sedik — ECE Engineering, Ain Shams University
