// Sprinkler Controller Top Module (zyBooks HLSM + Datapath Architecture)
//
// STUDENT TEMPLATE VERSION
// Complete the TODOs to wire up the controller and datapath
//
// This module demonstrates the zyBooks methodology of separating:
// - Controller (HLSM): High-Level State Machine for control logic
// - Datapath: Data processing and storage
// - Top Level: Integration and I/O interfacing
//
// The top module:
// 1. Instantiates the HLSM controller
// 2. Instantiates the datapath
// 3. Connects control and status signals between them
// 4. Instantiates display subsystem
// 5. Maps to Basys3 board I/O pins

module sprinkler_top (
    input         clk,
    input         btnC,
    input         btnU,
    output [6:0]  seg,
    output [3:0]  an,
    output [15:0] led    // Expanded for debug
);

    // ========================================
    // I/O Signal Mapping
    // ========================================
    wire rst = btnC;
    wire start = btnU;

    // ========================================
    // Control Signals (HLSM -> Datapath)
    // ========================================
    // TODO: Declare wires for control signals from controller to datapath
    //
    // You need three wires:
    // 1. load_w        - 1-bit wire to trigger timer load
    // 2. timer_val_w   - 7-bit wire for timer value
    // 3. station_w     - 3-bit wire for station selection
    //
    // EXAMPLE: First wire is declared for you:
    wire       load_w;

    // TODO: Declare timer_val_w (7 bits)

    // TODO: Declare station_w (3 bits)


    // ========================================
    // Status Signals (Datapath -> HLSM)
    // ========================================
    // TODO: Declare wire for status signal from datapath to controller
    //
    // You need one wire:
    // done_w - 1-bit wire indicating timer completion

    // TODO: Declare done_w


    // ========================================
    // Data Signals (Datapath -> Display)
    // ========================================
    // These are provided for you (no changes needed)
    wire [6:0] time_val_w;
    wire [3:0] station_num_w;
    wire [4:0] valves_w;

    // ========================================
    // HLSM Controller Instantiation
    // ========================================
    // TODO: Instantiate the sprinkler_controller module
    //
    // The controller implements the state machine that sequences through
    // the 5 watering stations based on timer completion status
    //
    // Module: sprinkler_controller
    // Instance name: u_controller
    //
    // Parameters to set:
    //   .ST1_TIME(7'd15)   - Station 1: 15 minutes
    //   .ST2_TIME(7'd32)   - Station 2: 32 minutes
    //   .ST3_TIME(7'd12)   - Station 3: 12 minutes
    //   .ST4_TIME(7'd8)    - Station 4: 8 minutes
    //   .ST5_TIME(7'd20)   - Station 5: 20 minutes
    //
    // Ports to connect:
    //   .clk(clk)              - System clock
    //   .rst(rst)              - Reset signal
    //   .start(start)          - Start button
    //   .done(done_w)          - Timer done status FROM datapath
    //   .load(load_w)          - Load signal TO datapath
    //   .timer_val(timer_val_w) - Timer value TO datapath
    //   .station(station_w)    - Station select TO datapath
    //
    // HINT: Follow this pattern:
    //   sprinkler_controller #(
    //       .ST1_TIME(7'd15),
    //       ...
    //   ) u_controller (
    //       .clk(clk),
    //       ...
    //   );

    // TODO: Write the complete instantiation here:







    // ========================================
    // Datapath Instantiation
    // ========================================
    // This is provided for you (no changes needed)
    // The datapath contains the countdown timer, station register,
    // and valve decoder
    sprinkler_datapath #(
        .CYCLES_PER_MIN(33_000_000)  // Time scale: 1 min = 0.33 sec
    ) u_datapath (
        .clk(clk),
        .rst(rst),

        // Control from HLSM
        .load(load_w),
        .val(timer_val_w),
        .station(station_w),

        // Status to HLSM
        .done(done_w),

        // Data outputs
        .time_val(time_val_w),
        .station_num(station_num_w),
        .valves(valves_w)
    );

    // ========================================
    // Display Subsystem (Provided - No changes needed)
    // ========================================
    // Format display data
    wire [15:0] disp_w;

    display u_display (
        .station_val(station_num_w),
        .time_val(time_val_w),
        .disp_w(disp_w)
    );

    // 7-Segment TDM Display Driver
    wire [3:0] an_raw_w;

    hex_tdm #(
        .N(16)  // Hardware: 763 Hz refresh rate (smooth, flicker-free)
    ) u_hex_tdm (
        .clk(clk),
        .btnC(btnC),
        .disp(disp_w),
        .seg(seg),
        .an(an_raw_w)
    );

    // Use only 3 of 4 displays: station (leftmost), tens, ones (rightmost)
    // Turn off the second-from-left display (anode[2])
    // Anodes are active-low: 0=on, 1=off
    assign an = {an_raw_w[3], 1'b1, an_raw_w[1:0]};

    // ========================================
    // LED Outputs (Debug Mode)
    // ========================================
    // led[4:0]  - Valve control signals
    // led[5]    - done status (debug)
    // led[15:8] - time_val lower 8 bits (debug)
    assign led = {time_val_w, 2'b00, done_w, valves_w};

endmodule
