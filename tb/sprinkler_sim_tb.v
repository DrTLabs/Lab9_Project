`timescale 1ns / 1ps

//==============================================================================
// Sprinkler Controller Vivado Simulation Testbench (zyBooks Version)
//
// This testbench uses SIMULATION-OPTIMIZED parameters:
//   - TDM_N = 5: Display updates every 32 clocks (320 ns) - FAST & VISIBLE
//   - CYCLES_PER_MIN = 100: Timer runs 330,000x faster than real hardware
//   - Runtime = 100 µs: Long enough to see full watering sequence
//
// HARDWARE uses different parameters (in sprinkler_top.v):
//   - TDM_N = 20: Display updates every ~1 ms (proper refresh rate)
//   - CYCLES_PER_MIN = 33,000,000: Real-time operation (1 min = 0.33 sec)
//
//==============================================================================

module sprinkler_sim_tb;

    //==========================================================================
    // Testbench Signals
    //==========================================================================
    reg         clk;
    reg         btnC;
    reg         btnU;
    wire [6:0]  seg;
    wire [3:0]  an;
    wire [4:0]  led;

    // Pass/Fail tracking
    integer fail_count;
    initial fail_count = 0;

    //==========================================================================
    // Clock Generation: 100 MHz (10ns period)
    //==========================================================================
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    //==========================================================================
    // Device Under Test (DUT)
    // Uses simulation-optimized parameters
    //==========================================================================
    sprinkler_top_sim dut (
        .clk(clk),
        .btnC(btnC),
        .btnU(btnU),
        .seg(seg),
        .an(an),
        .led(led)
    );

    //==========================================================================
    // Monitoring: Track TDM Cycling
    //==========================================================================
    reg [3:0] an_prev;
    integer an_change_count;

    initial begin
        an_prev = 4'b1111;
        an_change_count = 0;
    end

    always @(posedge clk) begin
        if (an != an_prev) begin
            an_change_count = an_change_count + 1;
            // Show first few changes to verify TDM is working
            if (an_change_count <= 10) begin
                $display("[%0t] TDM Update #%0d: an = %b", $time, an_change_count, an);
            end
            an_prev = an;
        end
    end

    //==========================================================================
    // Test Sequence
    //==========================================================================
    initial begin
        $display("================================================================================");
        $display("Sprinkler Controller Vivado Simulation (zyBooks HLSM+Datapath)");
        $display("================================================================================");
        $display("Simulation Parameters:");
        $display("  - TDM Counter N=5 (updates every 32 clocks = 320 ns)");
        $display("  - Timer: 100 clocks per minute (fast simulation)");
        $display("  - Stations: 15, 32, 12, 8, 20 minutes");
        $display("  - Total sequence: 87 minutes = 87,000 cycles = 870 µs");
        $display("================================================================================\n");

        //======================================================================
        // TEST 1: Reset
        //======================================================================
        $display("=== Test 1: Reset ===");
        btnC = 1;
        btnU = 0;
        #200;
        btnC = 0;
        #100;

        if (led != 5'b00000) begin
            $display("  FAIL: LEDs should be off after reset");
            fail_count = fail_count + 1;
        end else begin
            $display("  PASS: System in idle state (LED = %b)", led);
        end

        //======================================================================
        // TEST 2: Verify TDM is Cycling
        //======================================================================
        $display("\n=== Test 2: Verify TDM Cycling ===");
        #3000;  // Wait 3 microseconds

        if (an_change_count < 5) begin
            $display("  FAIL: TDM not cycling! Only %0d changes in 3us", an_change_count);
            $display("  Expected: ~9 changes with N=5");
            fail_count = fail_count + 1;
        end else begin
            $display("  PASS: TDM cycling properly (%0d anode changes observed)", an_change_count);
        end

        //======================================================================
        // TEST 3: Start Watering Sequence
        //======================================================================
        $display("\n=== Test 3: Start Watering Sequence ===");
        btnU = 1;
        #20;
        btnU = 0;
        #200;

        if (led != 5'b00001) begin
            $display("  FAIL: Station 1 should be active");
            fail_count = fail_count + 1;
        end else begin
            $display("  PASS: Station 1 active (LED = %b)", led);
        end

        //======================================================================
        // TEST 4: Station 1 → Station 2 Transition
        //======================================================================
        $display("\n=== Test 4: Station 1 (15 min) ===");
        $display("  Waiting for Station 1 to complete...");
        #15000;  // 15 minutes = 15,000 cycles = 15 µs
        #200;    // Settling time

        if (led != 5'b00010) begin
            $display("  FAIL: Should transition to Station 2");
            $display("    Expected: 00010, Got: %b", led);
            fail_count = fail_count + 1;
        end else begin
            $display("  PASS: Transitioned to Station 2 (LED = %b)", led);
        end

        //======================================================================
        // TEST 5: Station 2 → Station 3 Transition
        //======================================================================
        $display("\n=== Test 5: Station 2 (32 min) ===");
        $display("  Waiting for Station 2 to complete...");
        #32000;  // 32 minutes = 32 µs
        #200;

        if (led != 5'b00100) begin
            $display("  FAIL: Should transition to Station 3");
            $display("    Expected: 00100, Got: %b", led);
            fail_count = fail_count + 1;
        end else begin
            $display("  PASS: Transitioned to Station 3 (LED = %b)", led);
        end

        //======================================================================
        // TEST 6: Station 3 → Station 4 Transition
        //======================================================================
        $display("\n=== Test 6: Station 3 (12 min) ===");
        $display("  Waiting for Station 3 to complete...");
        #12000;  // 12 minutes = 12 µs
        #200;

        if (led != 5'b01000) begin
            $display("  FAIL: Should transition to Station 4");
            $display("    Expected: 01000, Got: %b", led);
            fail_count = fail_count + 1;
        end else begin
            $display("  PASS: Transitioned to Station 4 (LED = %b)", led);
        end

        //======================================================================
        // TEST 7: Station 4 → Station 5 Transition
        //======================================================================
        $display("\n=== Test 7: Station 4 (8 min) ===");
        $display("  Waiting for Station 4 to complete...");
        #8000;   // 8 minutes = 8 µs
        #200;

        if (led != 5'b10000) begin
            $display("  FAIL: Should transition to Station 5");
            $display("    Expected: 10000, Got: %b", led);
            fail_count = fail_count + 1;
        end else begin
            $display("  PASS: Transitioned to Station 5 (LED = %b)", led);
        end

        //======================================================================
        // TEST 8: Station 5 → Idle (Complete Sequence)
        //======================================================================
        $display("\n=== Test 8: Station 5 (20 min) ===");
        $display("  Waiting for Station 5 to complete...");
        #20000;  // 20 minutes = 20 µs
        #200;

        if (led != 5'b00000) begin
            $display("  FAIL: Should return to idle");
            $display("    Expected: 00000, Got: %b", led);
            fail_count = fail_count + 1;
        end else begin
            $display("  PASS: Returned to idle (LED = %b)", led);
        end

        //======================================================================
        // TEST 9: Verify TDM Continued Throughout
        //======================================================================
        $display("\n=== Test 9: Final TDM Check ===");
        $display("  Total TDM cycles observed: %0d", an_change_count);

        if (an_change_count < 200) begin
            $display("  WARNING: Fewer TDM cycles than expected");
            $display("    Expected: ~2700 changes in 87us, got: %0d", an_change_count);
        end else begin
            $display("  PASS: TDM cycled continuously throughout simulation");
        end

        //======================================================================
        // Summary
        //======================================================================
        $display("\n================================================================================");
        $display("Simulation Complete!");
        $display("================================================================================");
        if (fail_count == 0) begin
            $display("ALL TESTS PASS (%0d/9 tests passed)", 9);
        end else begin
            $display("SOME TESTS FAILED (%0d failures out of 9 tests)", fail_count);
        end
        $display("================================================================================");

        #1000;
        $finish;
    end

    //==========================================================================
    // Timeout Watchdog
    //==========================================================================
    initial begin
        #100000;  // 100 µs timeout (more than enough for 87µs sequence)
        $display("\nSimulation timeout at 100us");
        $finish;
    end

endmodule

//==============================================================================
// Sprinkler Top Module - SIMULATION VERSION
//
// This module wraps the real design with SIMULATION-OPTIMIZED parameters.
// DO NOT use this module for hardware synthesis!
//
// For hardware, use the regular sprinkler_top.v with default parameters.
//==============================================================================

module sprinkler_top_sim (
    input         clk,
    input         btnC,
    input         btnU,
    output [6:0]  seg,
    output [3:0]  an,
    output [4:0]  led
);

    //==========================================================================
    // SIMULATION PARAMETERS
    // These values make simulation fast and visible
    //==========================================================================
    localparam CYCLES_PER_MIN = 100;      // Timer: 100 cycles per "minute"
    localparam TDM_N = 5;                 // Display: Updates every 32 clocks
    localparam ST1_TIME = 7'd15;          // 15 minutes
    localparam ST2_TIME = 7'd32;          // 32 minutes
    localparam ST3_TIME = 7'd12;          // 12 minutes
    localparam ST4_TIME = 7'd8;           // 8 minutes
    localparam ST5_TIME = 7'd20;          // 20 minutes

    wire rst = btnC;
    wire start = btnU;

    //==========================================================================
    // Control Signals (HLSM → Datapath)
    //==========================================================================
    wire       load_w;
    wire [6:0] timer_val_w;
    wire [2:0] station_w;

    //==========================================================================
    // Status Signals (Datapath → HLSM)
    //==========================================================================
    wire       done_w;

    //==========================================================================
    // Data Signals
    //==========================================================================
    wire [6:0] time_val_w;
    wire [3:0] station_num_w;
    wire [4:0] valves_w;

    //==========================================================================
    // HLSM Controller
    //==========================================================================
    sprinkler_controller #(
        .ST1_TIME(ST1_TIME),
        .ST2_TIME(ST2_TIME),
        .ST3_TIME(ST3_TIME),
        .ST4_TIME(ST4_TIME),
        .ST5_TIME(ST5_TIME)
    ) u_controller (
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(done_w),
        .load(load_w),
        .timer_val(timer_val_w),
        .station(station_w)
    );

    //==========================================================================
    // Datapath
    //==========================================================================
    sprinkler_datapath #(
        .CYCLES_PER_MIN(CYCLES_PER_MIN)  // ← SIMULATION: Fast timer
    ) u_datapath (
        .clk(clk),
        .rst(rst),
        .load(load_w),
        .val(timer_val_w),
        .station(station_w),
        .done(done_w),
        .time_val(time_val_w),
        .station_num(station_num_w),
        .valves(valves_w)
    );

    //==========================================================================
    // Display Subsystem
    //==========================================================================
    wire [15:0] disp_w;

    display u_display (
        .station_val(station_num_w),
        .time_val(time_val_w),
        .disp_w(disp_w)
    );

    //==========================================================================
    // 7-Segment TDM Display Driver
    // *** SIMULATION: N=5 for fast, visible cycling ***
    //==========================================================================
    wire [3:0] an_raw_w;

    hex_tdm #(
        .N(TDM_N)  // ← SIMULATION: N=5 (updates every 32 clocks)
    ) u_hex_tdm (
        .clk(clk),
        .btnC(btnC),
        .disp(disp_w),
        .seg(seg),
        .an(an_raw_w)
    );

    // Turn off second-from-left display (blank digit)
    assign an = {an_raw_w[3], 1'b1, an_raw_w[1:0]};

    //==========================================================================
    // LED Outputs (Valve Control)
    //==========================================================================
    assign led = valves_w;

endmodule
