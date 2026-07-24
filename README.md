# Digital IC Design with Verilog HDL — Lab Portfolio

A collection of Verilog HDL labs progressing from basic combinational logic gates through sequential circuits, FSMs, and display-driven systems, culminating in a full queue-management system final project. All designs are simulated and verified in **ModelSim (Intel FPGA Edition, 2020.1)**.

## Course Progression

| # | Lab | Topics | Key Modules |
|---|---|---|---|
| 1 | [Basic Logic Gates](#1-basic-logic-gates) | Combinational logic, testbenches | `andGate`, `orGate` |
| 2 | [Mux & Full Adder](#2-21-mux--full-adder) | Structural design from gate primitives | `mux2t1`, `fulladder` |
| 3 | [Johnson Counter](#3-4-bit-johnson-counter) | Sequential logic, shift registers | `d_ff`, `JohnsonCounter` |
| 4 | [Decoder & Encoder](#4-7-segment-decoder--decimal-to-bcd-encoder) | Combinational encoding/decoding | `decoder_7seg`, `decimal_to_bcd` |
| 5 | [ALU & Keypad Display](#5-alu--keypad-encoderdecoder-display-system) | Arithmetic units, multi-module display pipelines | `ALU`, `sevenSegments`, `encoder_to_decoder` |
| 6 | [BCD Counters](#6-bcd-counters-0–9-and-00–59) | Synchronous counters, cascaded stages | `bcd_counter`, `bcd_counter2` |
| 7 | [FSM-Based Counters](#7-fsm-based-counters-one-hot--bcd) | Finite state machines, clock division | `one_hot_counter_fsm`, `bcd_counter_FSM` |
| — | [Final Project: ITI_BQS](#final-project-iti_bqs-bank-queue-monitoring-system) | Full system integration | `ITIBQS`, `controllerFSM`, `waitTime_rom` |

Each lab below is summarized; full module code, truth tables, run commands, and debugging notes live in that lab's own README within its folder.

---

## 1. Basic Logic Gates

Verilog implementations of 2-input **AND** and **OR** gates, each verified with a self-checking testbench sweeping all four input combinations.

```verilog
module andGate (a, b, c);
input a, b;
output c;
assign c = a & b;
endmodule
```

Establishes the basic module/testbench/ModelSim workflow used throughout the rest of the course: `vlib` → `vlog` → `vsim` → `run`.

---

## 2. 2:1 Mux & Full Adder

Two designs built **structurally** — instantiating gate-primitive modules rather than using `assign` behavioral logic:

- **`mux2t1`**: `y = (D0 & ~s) | (D1 & s)`, built from `andGate`, `orGate`, `notGate` instances.
- **`fulladder`**: sum/carry built from `xorGate`, `andGate`, `orGate` instances (`S = A ⊕ B ⊕ Cin`, `Cout = AB + Cin(A⊕B)`).

Introduces gate-level instantiation and multi-module hierarchy.

---

## 3. 4-Bit Johnson Counter

A twisted-ring counter built from four `d_ff` (async-reset D flip-flop) instances chained in a shift register, with the inverted final-stage output fed back to the first stage — producing an 8-state repeating sequence (`0000 → 0001 → 0011 → 0111 → 1111 → 1110 → 1100 → 1000 → repeat`) from just 4 bits.

First lab using `always @(posedge clk or negedge rstn)` sequential logic and a `.do` script for waveform automation.

---

## 4. 7-Segment Decoder & Decimal-to-BCD Encoder

Two standalone combinational designs, force-tested directly in the ModelSim GUI (no testbench):

- **`decoder_7seg`**: 4-bit BCD → seven segment-drive outputs, via sum-of-products logic per digit.
- **`decimal_to_bcd`**: 10-bit one-hot decimal input → 4-bit BCD output.

Building blocks reused throughout the rest of the course wherever a digit needs displaying.

---

## 5. ALU & Keypad Encoder/Decoder Display System

Two related display-driven systems:

- **`ALU_to_decoder`**: an 8-function 2-bit ALU (AND, OR, add, subtract, multiply, greater-than, less-than, equal) whose 4-bit result feeds a seven-segment decoder with special glyphs for comparison results (`A`, `b`, `=`).
- **`encoder_to_decoder`**: a 3-digit calculator-keypad interface — three one-hot keypad inputs each pass through a `decimal_to_bcd` encoder into a `decoder_7seg` decoder, driving three independent seven-segment displays.

First labs combining arithmetic/encoding logic directly with the seven-segment display chain from Lab 4, and the first to require careful **port-list consistency** between top module and testbench as designs were revised (documented as a recurring debugging theme).

---

## 6. BCD Counters (0–9 and 00–59)

Two versions of the same counter concept:

- **v1 — single digit**: a synchronous mod-10 counter (`bcd_counter`, 0–9) feeding one seven-segment display.
- **v2 — two digit**: extends v1 by adding an `Enable` pulse output on wraparound, and cascading a second mod-6 counter (`bcd_counter2`) gated by that pulse — producing a full 00–59 ("seconds") sequence across two displays, one count per clock.

Demonstrates counter cascading as a technique for multi-digit displays, and surfaces classic module-naming and port-width pitfalls when iterating a design across versions.

---

## 7. FSM-Based Counters (One-Hot & BCD)

Two independent finite-state-machine designs:

- **One-hot walking-bit counter**: a 3-state FSM (`S0`/`S1`/`S2`) walks a single lit bit left across a 10-bit vector, then bounces back right — a "Cylon eye" LED-chaser pattern — clocked at 1Hz via a 25-million-cycle `clock_divider`.
- **BCD FSM counter**: the same 0–9 counting behavior as Lab 6, but modeled explicitly as a 2-state FSM (`S0` init, `S1` count) rather than a plain up-counter — groundwork for FSMs needing more states later (pause, hold, direction-reversal, etc.).

First labs to explicitly separate **state** from **output logic** using `parameter`-defined state encodings and `case` statements — the FSM design pattern carried into the final project's `controllerFSM`.

---

## Final Project: ITI_BQS (Bank Queue Monitoring System)

A complete embedded system modeling a bank teller queue: two photocells track clients entering/leaving, an FSM-driven up/down counter tracks how many people are waiting (`Pcount`, 0–7), and a ROM-based lookup table computes expected waiting time (`Wtime`) from `Pcount` and the number of active tellers — all displayed on seven-segment digits, with empty/full flags and violation alarms.

**Architecture** (composed entirely from patterns established in Labs 1–7):

- **Edge detectors** (`D_FF` + combinational AND/NOT, Lab 3's flip-flop pattern) turn level-held photocell signals into single-cycle enter/leave event pulses.
- **`controllerFSM`** (Lab 7's FSM pattern) — a 3-state machine (`empty`/`count`/`full`) drives the counter's enable/direction and computes flags and alarms combinationally.
- **`upDownCounter`** (Lab 6's counter pattern) — a bounds-guarded 3-bit synchronous counter.
- **`waitTime_rom`** — a 32×8 ROM (`$readmemb`-loaded), addressed by `{tellersCount, Pcount}`, replacing live arithmetic with a precomputed lookup table.
- **`sevenSegmentsDecoder`** (Lab 4's decoder pattern) — instantiated three times for `Pcount` and the two `Wtime` digits.

Verified against a 7-case test strategy (reset, empty-alarm, fill-to-full, full-alarm, normal countdown, simultaneous enter/leave, and teller-count changes affecting `Wtime`), matching the assignment's required deliverables (I/O table, block diagram, FSM diagram, mixed-architecture model, and testbench with test strategy).

---

## Tooling

All labs use the same simulation workflow:

```tcl
vlib work
vlog <design files>.v <testbench or top module>.v
vsim work.<top_module_or_testbench>
add wave -r sim:/<top_module_or_testbench>/*
run -all
```

Several labs also include a `.do` script for scripted waveform setup and forced-signal simulation without a dedicated testbench.

## Author

Amr Khaled Sedik — Computer Engineering, Ain Shams University
