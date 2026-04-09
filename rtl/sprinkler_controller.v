// Sprinkler Controller HLSM (zyBooks Style - Two-State Design)
// High-Level State Machine that controls the watering sequence
//
// STUDENT TEMPLATE VERSION
// Complete the TODOs to implement the full state machine
//
// This module follows the zyBooks HLSM + Datapath design methodology where:
// - HLSM contains only the control logic (state machine)
// - HLSM outputs control signals to direct datapath operations
// - HLSM inputs status signals from datapath for decision making
// - No data storage or processing occurs in the HLSM
//
// Design Approach: TWO STATES PER STATION
// Each station has two explicit states:
//   1. LOAD state: Loads the timer with the station's duration
//   2. RUN state: Waits for timer to complete
//
// Sequence:
//   IDLE -> LOAD_ST1 -> RUN_ST1 -> LOAD_ST2 -> RUN_ST2 -> ... -> RUN_ST5 -> IDLE

module sprinkler_controller #(
    parameter ST1_TIME = 7'd15,   // 15 minutes
    parameter ST2_TIME = 7'd32,   // 32 minutes
    parameter ST3_TIME = 7'd12,   // 12 minutes
    parameter ST4_TIME = 7'd8,    // 8 minutes
    parameter ST5_TIME = 7'd20    // 20 minutes
) (
    // External inputs
    input              clk,
    input              rst,
    input              start,

    // Status inputs from datapath
    input              done,

    // Control outputs to datapath
    output reg         load,
    output reg [6:0]   timer_val,
    output reg [2:0]   station
);

    // ========================================
    // State Definitions (11 states, need 4 bits)
    // ========================================
    localparam IDLE      = 4'd0;

    // Station 1: Load and Run states
    localparam LOAD_ST1  = 4'd1;
    localparam RUN_ST1   = 4'd2;

    // Station 2: Load and Run states
    localparam LOAD_ST2  = 4'd3;
    localparam RUN_ST2   = 4'd4;

    // Station 3: Load and Run states
    localparam LOAD_ST3  = 4'd5;
    localparam RUN_ST3   = 4'd6;

    // Station 4: Load and Run states
    localparam LOAD_ST4  = 4'd7;
    localparam RUN_ST4   = 4'd8;

    // Station 5: Load and Run states
    localparam LOAD_ST5  = 4'd9;
    localparam RUN_ST5   = 4'd10;

    // ========================================
    // State Register
    // ========================================
    reg [3:0] state, next;

    always @(posedge clk) begin
        if (rst)
            state <= IDLE;
        else
            state <= next;
    end

    // ========================================
    // Next State Logic
    // ========================================
    // TODO: Complete the next state logic for all states
    //
    // Rules:
    // - From IDLE: wait for start button, then go to LOAD_ST1
    // - From LOAD states: always advance to corresponding RUN state (unconditional)
    // - From RUN states: wait for done, then advance to next LOAD state
    // - From RUN_ST5: go back to IDLE when done
    //
    // EXAMPLE: Station 1 is completed for you below
    always @(*) begin
        next = state;  // Default: stay in current state

        case (state)
            IDLE: begin
                if (start)
                    next = LOAD_ST1;
            end

            // ============================================
            // Station 1 - EXAMPLE (Completed for you)
            // ============================================
            LOAD_ST1: begin
                next = RUN_ST1;  // Unconditional transition
            end

            RUN_ST1: begin
                if (done)
                    next = LOAD_ST2;
            end

            // ============================================
            // TODO: Complete Station 2
            // ============================================
            LOAD_ST2: begin
                // TODO: Implement unconditional transition to RUN_ST2
            end

            RUN_ST2: begin
                // TODO: When done, transition to LOAD_ST3
            end

            // ============================================
            // TODO: Complete Station 3
            // ============================================
            LOAD_ST3: begin
                // TODO: Implement unconditional transition to RUN_ST3
            end

            RUN_ST3: begin
                // TODO: When done, transition to LOAD_ST4
            end

            // ============================================
            // TODO: Complete Station 4
            // ============================================
            LOAD_ST4: begin
                // TODO: Implement unconditional transition to RUN_ST4
            end

            RUN_ST4: begin
                // TODO: When done, transition to LOAD_ST5
            end

            // ============================================
            // TODO: Complete Station 5
            // ============================================
            LOAD_ST5: begin
                // TODO: Implement unconditional transition to RUN_ST5
            end

            RUN_ST5: begin
                // TODO: When done, return to IDLE (wrap around)
            end

            default: next = IDLE;
        endcase
    end

    // ========================================
    // Output Logic (Moore Machine Style)
    // ========================================
    // TODO: Complete the output logic for all states
    //
    // Rules for each state:
    // - IDLE: load=0, station=0, timer_val=0
    // - LOAD states: load=1, station=station_number, timer_val=STATION_TIME
    // - RUN states: load=0, station=station_number, timer_val=STATION_TIME
    //
    // EXAMPLE: IDLE and Station 1 are completed for you below
    always @(*) begin
        // Default outputs
        load = 1'b0;
        station = 3'd0;
        timer_val = 7'd0;

        case (state)
            // ============================================
            // IDLE - EXAMPLE (Completed for you)
            // ============================================
            IDLE: begin
                load = 1'b0;
                station = 3'd0;
                timer_val = 7'd0;
            end

            // ============================================
            // Station 1 - EXAMPLE (Completed for you)
            // ============================================
            LOAD_ST1: begin
                load = 1'b1;              // Load the timer!
                station = 3'd1;
                timer_val = ST1_TIME;
            end

            RUN_ST1: begin
                load = 1'b0;              // Don't load, let it count
                station = 3'd1;
                timer_val = ST1_TIME;     // Keep value (not used)
            end

            // ============================================
            // TODO: Complete Station 2 outputs
            // ============================================
            LOAD_ST2: begin
                // TODO: Set load=1, station=2, timer_val=ST2_TIME
            end

            RUN_ST2: begin
                // TODO: Set load=0, station=2, timer_val=ST2_TIME
            end

            // ============================================
            // TODO: Complete Station 3 outputs
            // ============================================
            LOAD_ST3: begin
                // TODO: Set load=1, station=3, timer_val=ST3_TIME
            end

            RUN_ST3: begin
                // TODO: Set load=0, station=3, timer_val=ST3_TIME
            end

            // ============================================
            // TODO: Complete Station 4 outputs
            // ============================================
            LOAD_ST4: begin
                // TODO: Set load=1, station=4, timer_val=ST4_TIME
            end

            RUN_ST4: begin
                // TODO: Set load=0, station=4, timer_val=ST4_TIME
            end

            // ============================================
            // TODO: Complete Station 5 outputs
            // ============================================
            LOAD_ST5: begin
                // TODO: Set load=1, station=5, timer_val=ST5_TIME
            end

            RUN_ST5: begin
                // TODO: Set load=0, station=5, timer_val=ST5_TIME
            end

            default: begin
                load = 1'b0;
                station = 3'd0;
                timer_val = 7'd0;
            end
        endcase
    end

endmodule
