# Lab 9 Part 2: Building the Sprinkler Controller (Controller + Datapath)

**Due: Thursday 11/19.** You can start as soon as you have this repo, and finishing before Thanksgiving break is a good idea.

## Overview

In Part 1 you studied the sprinkler design: first as an FSMD with register transfers, then split into a controller and a datapath. Now you build exactly that design in Verilog. Keep the **Lab 9 Part 1 Design Handout** open while you work: every signal name in it is a port name in this repo.

The design splits into two halves:

- **Controller** (`sprinkler_controller.v`): a 5-state FSM that decides *when* things happen. It stores no numbers.
- **Datapath** (`sprinkler_datapath.v`): three registers (`station`, `minutes`, and a cycle counter `cyc`), a duration mux, three comparators, and a valve decoder. Nothing in it changes unless the controller says so.

```
             control: st_clr, st_inc, m_load, m_dec, c_clr
   start ──> ┌────────────┐ ─────────────────────────────> ┌──────────────┐ ──> valves (LEDs)
             │ Controller │                                │   Datapath   │ ──> station, minutes (display)
             │   (FSM)    │ <───────────────────────────── │              │
             └────────────┘     status: done, last, tick   └──────────────┘
```

### The controller (handout Figure 3)

```
              start                    tick & !done
   IDLE ────────────> NEXT ──> LOAD ──> RUN ─────────────> DEC
    ^ │ !start         ^ always  always  │ ^    always       │
    └─┘                │                 │ └─────────────────┘
                       └─ done & !last ──┤
    ^                                    │
    └────────────── done & last ─────────┘
```

| State | st_clr | st_inc | m_load | m_dec | c_clr | Register transfers |
|-------|:-:|:-:|:-:|:-:|:-:|---|
| IDLE  | 1 | 0 | 0 | 0 | 1 | station ← 0, cyc ← 0 (all valves off); wait for start |
| NEXT  | 0 | 1 | 0 | 0 | 1 | station ← station + 1, cyc ← 0 |
| LOAD  | 0 | 0 | 1 | 0 | 1 | minutes ← this station's duration, cyc ← 0 |
| RUN   | 0 | 0 | 0 | 0 | 0 | cyc ← cyc + 1 (count clock cycles) |
| DEC   | 0 | 0 | 0 | 1 | 1 | minutes ← minutes − 1, cyc ← 0 |

RUN has three arrows out. **`done` comes first**: when the station is finished, the controller leaves RUN even if `tick` is also 1.

### The datapath (handout Figure 2)

| Part | What it does |
|------|--------------|
| station register (3 bits) | `st_clr` → 0, `st_inc` → station + 1, otherwise hold. Station 0 means idle |
| minutes register (7 bits) | `m_load` → duration, `m_dec` → minutes − 1, otherwise hold |
| cycle counter `cyc` (26 bits) | `c_clr` → 0, otherwise cyc + 1. Like the laser range finder's counter: it is written in every state, so it needs no hold |
| duration mux | select = station; inputs 1–5 = 15, 32, 12, 8, 20 minutes (parameters `ST1_TIME`..`ST5_TIME`); 0 otherwise |
| comparators (status) | `done = (minutes == 0)`, `last = (station == 5)`, `tick = (cyc == CYCLES_PER_MIN - 1)` |
| valve decoder | station 1 → `00001` … station 5 → `10000`; station 0 → `00000` |

One minute is `CYCLES_PER_MIN` cycles counted in RUN plus one cycle in DEC. On the board `CYCLES_PER_MIN` = 33,000,000, so a minute is about 0.33 s.

---

## Your tasks

Every place you write code is marked `// TODO`.

1. **`rtl/sprinkler_controller.v`** (3 TODOs): the state register, next-state logic, and Moore output logic. The state names are given; the rest you write from Figure 3.
2. **`rtl/sprinkler_datapath.v`** (6 TODOs): the three registers, the duration mux, the three status comparators, and the valve decoder.
3. **`rtl/sprinkler_top.v`**: declare the five control wires and three status wires, and instantiate the controller. The datapath instance is given as a pattern.

**Suggested order:** do the controller first and get the `test-controller` job (or the `controller_tb` simulation) passing before you touch the datapath. That way you debug one half at a time.

---

## Lab activities

### Step 1: Vivado project setup
- [ ] Clone this repo with GitHub Desktop
- [ ] Create a Vivado project **outside** the repo folder, targeting the Basys3
- [ ] Add all `rtl/*.v` files as **design sources**
- [ ] Add both `tb/*.v` files as **simulation sources**
- [ ] Add `constraints/basys3.xdc`

### Step 2: Controller
- [ ] Complete the three TODO sections in `rtl/sprinkler_controller.v`
- [ ] Set `controller_tb` as the simulation top and run behavioral simulation
- [ ] All tests should print `ok`. Each `FAIL` line names the state you expected and the state you got
- [ ] Commit and push. The **Test sprinkler_controller** job should turn green

### Step 3: Datapath
- [ ] Complete the six TODO sections in `rtl/sprinkler_datapath.v`

### Step 4: Top module
- [ ] Declare `st_clr_w`, `st_inc_w`, `m_load_w`, `m_dec_w`, `c_clr_w` and `done_w`, `last_w`, `tick_w`
- [ ] Instantiate `sprinkler_controller` as `u_controller`

### Step 5: System simulation
- [ ] Set `sprinkler_tb` as the simulation top and run behavioral simulation (Vivado's default 1000 ns is not enough; run for about 20 µs, or type `run all` in the Tcl console)
- [ ] All tests should print `ok`. The test checks station order, each station's duration, and the return to IDLE
- [ ] Commit and push. Both CI jobs should be green

### Step 6: Hardware
- [ ] Set `sprinkler_top` as the top module; synthesize, implement, generate bitstream, program the board
- [ ] Press **btnU** to start. LEDs 0–4 step through the stations; the display shows the station number and minutes left
- [ ] **btnC** resets at any time

---

## Checking your work

| CI job | What it tests | Files compiled |
|--------|---------------|----------------|
| `test-controller` | Your FSM alone: every transition and every output, including that `done` and `tick` are ignored in NEXT, LOAD and DEC, and that `done` beats `tick` in RUN | `tb/controller_tb.v`, `rtl/sprinkler_controller.v` |
| `test-sprinkler` | Whole system: valve order, loaded minutes, how many clock cycles each station runs, return to IDLE, a second run | `tb/sprinkler_tb.v` and all `rtl/*.v` |

Both jobs must show **ALL TESTS PASS** for full credit.

---

## Hardware interface

| Port | Pin | Description |
|------|-----|-------------|
| `clk` | W5 | 100 MHz clock |
| `btnC` | U18 | Reset (active-high) |
| `btnU` | T18 | Start |
| `led[4:0]` | U16..W18 | Valves (one-hot) |
| `led[5]` | U15 | `done` (debug) |
| `led[6]` | U14 | `last` (debug) |
| `led[15:9]` | | Minutes remaining in binary (debug) |
| `seg`, `an` | | Display: station · blank · minutes tens · minutes ones |

---

## Common problems

**Controller**
- *Stuck in IDLE*: the IDLE case must check `start`.
- *"NEXT always goes to LOAD", "LOAD always goes to RUN" or "DEC always goes back to RUN" failed*: those arrows are **unconditional**. Don't check `done` or `tick` there.
- *"done beats tick" failed*: in RUN, test `done` before `tick`.
- *Stops after station 1, or never stops*: RUN needs both `done` and `last` (the arrows to NEXT and to IDLE in Figure 3).
- *Outputs show `x` in simulation*: you forgot the defaults at the top of the output block, or the `next_state = state;` default.
- *Used `<=` in a combinational block, or `=` in the clocked block*: use `=` in `always @(*)` and `<=` in `always @(posedge clk)`.

**Datapath**
- *Station 1 is skipped*: `st_clr` must load **0**. NEXT adds 1 before the first LOAD.
- *Durations are wrong or in the wrong order*: check the mux case items against the spec table.
- *"valve stays on for the station's duration" failed*: check the cycle counter (cleared by `c_clr`, otherwise +1), `tick = (cyc_r == CYCLES_PER_MIN - 1)`, and that `m_dec` subtracts 1.
- *Never returns to IDLE after station 5*: check `last = (station_r == 5)`.
- *An LED is on while idle*: the decoder's station 0 (default) must give `5'b00000`.

**Top**
- *Port name errors*: the controller port names are `st_clr`, `st_inc`, `m_load`, `m_dec`, `c_clr`, `done`, `last`, `tick`; connect each to its `_w` wire.
