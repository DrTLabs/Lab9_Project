# Lab 9: Sprinkler Controller (HLSM + Datapath)

## Overview

In this lab, you will complete a sprinkler controller design that uses the zyBooks HLSM + Datapath architecture. The controller sequences through 5 watering stations, each with a configurable duration, using a finite state machine (FSM) that communicates with a datapath through control and status signals.

You will complete two files -- the controller FSM and the top-level module that wires everything together. All other modules (datapath, timer, display) are provided.

**Design Hierarchy:**
```
sprinkler_top (top-level wrapper)
├── sprinkler_controller  - FSM control logic (YOU COMPLETE)
├── sprinkler_datapath    - Timer, station register, valve decoder (provided)
│   └── timer             - Countdown timer (provided)
└── display + hex_tdm     - 7-segment TDM display (provided, from Lab 7)
    ├── counter            - Clock divider
    ├── tdm_scan           - 2-bit scan index
    ├── anode_decode        - Active-low anode selection
    ├── mux                - Nibble selector
    └── hex_to_7seg        - Hex-to-segment decoder
```

**Architecture Diagram:**
```
┌─────────────────────────────────────────────────┐
│              sprinkler_top.v                     │
│  ┌──────────────┐          ┌─────────────────┐  │
│  │ Controller   │          │   Datapath       │  │
│  │   (HLSM)    │          │                  │  │
│  │              │──load_w──>│   - timer        │  │
│  │  You will    │          │   - station reg  │  │
│  │  complete    │──timer───>│   - valve dec    │  │
│  │  this FSM!   │  _val_w  │                  │  │
│  │              │          │                  │  │
│  │              │<─done_w──│                  │  │
│  └──────────────┘          └─────────────────┘  │
│                                                  │
│              Display & I/O (provided)            │
└──────────────────────────────────────────────────┘
```

---

## Your Tasks

1. **Complete `rtl/sprinkler_controller.v`** -- Implement FSM next state logic and Moore output logic for Stations 2-5 (Station 1 provided as example)
2. **Complete `rtl/sprinkler_top.v`** -- Declare missing wires and instantiate the controller module

---

## Lab Activities

### Step 1: Vivado Project Setup
- [ ] Clone or download the Lab 9 template files
- [ ] Launch Vivado and create a new project
- [ ] Set the project location *outside* of the template directory
- [ ] Add all `.v` files from `rtl/` as **design sources**
- [ ] Add testbench files from `tb/` as **simulation sources**
- [ ] Add the constraint file from `constraints/`
- [ ] Select the Basys3 board as target

### Step 2: Study the Provided Example (Station 1)
- [ ] Open `rtl/sprinkler_controller.v` and study the Station 1 next state logic (LOAD_ST1, RUN_ST1)
- [ ] Study the Station 1 output logic (load, station, timer_val for LOAD_ST1 and RUN_ST1)
- [ ] Understand the pattern: LOAD states are unconditional transitions; RUN states wait for `done`

### Step 3: Complete the Controller Next State Logic
- [ ] Open `rtl/sprinkler_controller.v`
- [ ] Search for `// TODO: Complete Station 2` and implement LOAD_ST2/RUN_ST2 transitions
- [ ] Repeat for Stations 3, 4, and 5
- [ ] Rules:
  - LOAD states: **always** transition to the corresponding RUN state (unconditional)
  - RUN states: transition to the next LOAD state **when `done` is high**
  - RUN_ST5: return to IDLE when done

### Step 4: Complete the Controller Output Logic
- [ ] Search for `// TODO: Complete Station 2 outputs` in the same file
- [ ] For each station, set three outputs: `load`, `station`, `timer_val`
- [ ] Rules:
  - LOAD states: `load=1`, `station=N`, `timer_val=STN_TIME`
  - RUN states: `load=0`, `station=N`, `timer_val=STN_TIME`
- [ ] Parameter reference: ST1=15, ST2=32, ST3=12, ST4=8, ST5=20 minutes

### Step 5: Declare Wires in Top Module
- [ ] Open `rtl/sprinkler_top.v`
- [ ] Search for `// TODO: Declare timer_val_w`
- [ ] Declare: `wire [6:0] timer_val_w;` (7-bit timer value)
- [ ] Declare: `wire [2:0] station_w;` (3-bit station number)
- [ ] Declare: `wire done_w;` (1-bit timer done status)

### Step 6: Instantiate the Controller
- [ ] Search for `// TODO: Write the complete instantiation here:`
- [ ] Instantiate `sprinkler_controller` with instance name `u_controller`
- [ ] Set all 5 station time parameters
- [ ] Connect all 7 ports: `clk`, `rst`, `start`, `done`, `load`, `timer_val`, `station`

### Step 7: Simulation
- [ ] Set `sprinkler_sim_tb` as the simulation top module
- [ ] Run behavioral simulation
- [ ] Verify all 9 tests report PASS
- [ ] Fix any failures before proceeding to hardware

### Step 8: Hardware Implementation
- [ ] Set `sprinkler_top` as the top module for synthesis
- [ ] Synthesize, implement, and generate bitstream
- [ ] Program the Basys3
- [ ] Press **btnU** (Up) to start the watering sequence
- [ ] Verify LEDs cycle through stations: led[0] through led[4]
- [ ] Verify 7-segment display shows station number and countdown timer
- [ ] Press **btnC** (Center) to reset at any time

---

## Checking Your Work

When you push your code, GitHub Actions will automatically compile and test your design:

| CI Job | What It Tests | Files Compiled |
|--------|--------------|----------------|
| `test-sprinkler` | Full controller + datapath integration | All `rtl/*.v` + `tb/sprinkler_sim_tb.v` |

The job must show **ALL TESTS PASS** for full credit. The testbench runs 9 tests covering reset, TDM display cycling, and all 5 station transitions.

---

## File Structure

```
├── rtl/
│   ├── sprinkler_controller.v   # FSM controller (YOU COMPLETE)
│   ├── sprinkler_top.v          # Top-level integration (YOU COMPLETE)
│   ├── sprinkler_datapath.v     # Datapath: timer + station + valves (provided)
│   ├── timer.v                  # Countdown timer (provided)
│   ├── display.v                # Display formatter (provided)
│   ├── bin2bcd.v                # Binary to BCD converter (provided)
│   ├── hex_tdm.v                # TDM display wrapper (provided)
│   ├── counter.v                # Clock divider (provided)
│   ├── tdm_scan.v               # Scan controller (provided)
│   ├── anode_decode.v           # Anode decoder (provided)
│   ├── mux.v                   # Nibble mux (provided)
│   └── hex_to_7seg.v           # 7-seg decoder (provided)
├── tb/
│   └── sprinkler_sim_tb.v      # Self-checking testbench (provided)
├── constraints/
│   └── basys3.xdc              # Pin assignments for Basys3
└── .github/workflows/
    └── test.yml                 # CI - auto-tests on push
```

---

## Hardware Interface

### Inputs
| Port | Pin | Description |
|------|-----|-------------|
| `clk` | W5 | 100 MHz system clock |
| `btnC` | U18 | Center button = synchronous reset (active-high) |
| `btnU` | T18 | Up button = start watering sequence (active-high) |

### Outputs
| Port | Pins | Description |
|------|------|-------------|
| `seg[6:0]` | W7..U7 | 7-segment cathodes {g,f,e,d,c,b,a} (active-low) |
| `an[3:0]` | U2..W4 | 7-segment anodes (active-low, one-hot) |
| `led[4:0]` | U16..W18 | Station valve indicators (one-hot) |
| `led[5]` | U15 | Timer done status (debug) |
| `led[15:8]` | V13..L1 | Timer value (debug) |

### Display Layout
| Position | Content | Description |
|----------|---------|-------------|
| Leftmost (digit 3) | Station # | Current station (1-5, 0 = idle) |
| Second from left | Blank | Display off |
| Second from right | Tens digit | Timer minutes remaining (tens) |
| Rightmost (digit 0) | Ones digit | Timer minutes remaining (ones) |

---

## Common Issues and Troubleshooting

### Controller Next State Logic
- **Stuck in LOAD state**: LOAD transitions are unconditional -- do not add an `if` condition
- **Stuck in RUN state**: Make sure you check `if (done)` before transitioning
- **Wrong station order**: Verify RUN_ST2 goes to LOAD_ST3 (not LOAD_ST4), etc.
- **Never leaves IDLE**: Verify you check `if (start)` in the IDLE state

### Controller Output Logic
- **Wrong timer value**: Each station uses its own parameter (ST1_TIME, ST2_TIME, etc.)
- **Load always high**: `load=1` only in LOAD states, `load=0` in RUN states
- **Wrong station number**: Station numbers are 1-5 (3'd1 through 3'd5), not 0-4

### Top Module
- **Undeclared identifier errors**: Missing wire declarations -- check bit widths (`[6:0]` for timer_val_w, `[2:0]` for station_w)
- **Port connection mismatch**: Verify port names match exactly (e.g., `.done(done_w)` not `.done(done)`)
- **Forgot semicolon**: Module instantiation ends with `);` on the last line

---

## What to Submit

Demo your working hardware to the instructor during lab. Start the watering sequence and show all 5 stations cycling with correct LED and display output.

No code submission is required -- GitHub CI will verify your Verilog automatically when you push.
