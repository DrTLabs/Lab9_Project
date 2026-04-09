// Sprinkler Datapath Module (zyBooks Style)
// Contains all data storage and processing elements
//
// This module follows the zyBooks HLSM + Datapath design methodology where:
// - Datapath contains registers, functional units, and status logic
// - Controller (HLSM) sends control signals to direct datapath operations
// - Datapath sends status signals back to controller for decision making
//
// Control Signals (from HLSM):
//   load      - Load timer with new value and start countdown
//   val       - Value to load into timer (in minutes)
//   station   - Current station selection (0=idle, 1-5=stations)
//
// Status Signals (to HLSM):
//   done      - Timer has reached zero
//
// Data Outputs:
//   time_val     - Current countdown value
//   station_num  - Current station number for display
//   valves       - Valve control signals (one-hot encoded)

module sprinkler_datapath #(
    parameter CYCLES_PER_MIN = 33_000_000  // 0.33 seconds at 100 MHz
) (
    input              clk,
    input              rst,

    // Control signals from HLSM
    input              load,
    input  [6:0]       val,
    input  [2:0]       station,      // 0-5 encoded in 3 bits

    // Status signals to HLSM
    output             done,

    // Data outputs
    output [6:0]       time_val,
    output [3:0]       station_num,
    output [4:0]       valves
);

    // ========================================
    // Countdown Timer (Functional Unit)
    // ========================================
    timer #(
        .CYCLES_PER_MIN(CYCLES_PER_MIN)
    ) u_timer (
        .clk(clk),
        .rst(rst),
        .load(load),
        .val(val),
        .time_val(time_val),
        .done(done)
    );

    // ========================================
    // Station Number Register
    // ========================================
    // Stores current station for display
    reg [3:0] station_reg;

    always @(posedge clk) begin
        if (rst)
            station_reg <= 4'd0;
        else
            station_reg <= {1'b0, station};  // Extend 3-bit to 4-bit for display
    end

    assign station_num = station_reg;

    // ========================================
    // Valve Decoder (Combinational Logic)
    // ========================================
    // Converts station selection to one-hot valve control
    reg [4:0] valve_decode;

    always @(*) begin
        case (station)
            3'd0:    valve_decode = 5'b00000;  // Idle
            3'd1:    valve_decode = 5'b00001;  // Station 1
            3'd2:    valve_decode = 5'b00010;  // Station 2
            3'd3:    valve_decode = 5'b00100;  // Station 3
            3'd4:    valve_decode = 5'b01000;  // Station 4
            3'd5:    valve_decode = 5'b10000;  // Station 5
            default: valve_decode = 5'b00000;
        endcase
    end

    assign valves = valve_decode;

endmodule
