// Countdown Timer Module
// Counts down from a loaded value to 0 in scaled "minutes"
// Time scale: 1 minute = 0.33 seconds = 33,000,000 clock cycles at 100 MHz
//
// Inputs:
//   clk         - System clock (100 MHz)
//   rst         - Asynchronous reset (active high)
//   load        - Load new time value and start countdown
//   val         - Initial time value in minutes (0-99)
//
// Outputs:
//   time_val    - Current countdown value in minutes
//   done        - High when countdown reaches 0

module timer #(
    parameter CYCLES_PER_MIN = 33_000_000  // 0.33 seconds at 100 MHz
) (
    input              clk,
    input              rst,
    input              load,
    input  [6:0]       val,          // Max 99 minutes = 7 bits
    output reg [6:0]   time_val,
    output             done
);
    // Counter for clock cycles
    reg [25:0] cnt;  // 26 bits to hold 33,000,000
    wire cnt_done = (cnt == CYCLES_PER_MIN - 1);

    // Done signal - registered to avoid glitches
    // Clear immediately on load to prevent FSM from seeing spurious done during load cycle
    reg done_reg;
    assign done = done_reg && !load;

    // Cycle counter
    always @(posedge clk) begin
        if (rst || load || cnt_done) begin
            cnt <= 26'd0;
        end else if (!done_reg) begin
            cnt <= cnt + 1'b1;
        end
    end

    // Time value counter
    always @(posedge clk) begin
        if (rst) begin
            time_val <= 7'd0;
        end else if (load) begin
            time_val <= val;
        end else if (cnt_done && !done_reg) begin
            time_val <= time_val - 1'b1;
        end
    end

    // Done register - set on reset (timer starts "done"), clear on load, set when time reaches 0 after countdown
    always @(posedge clk) begin
        if (rst) begin
            done_reg <= 1'b1;  // Start in done state after reset (no spurious countdown from 0)
        end else if (load) begin
            done_reg <= 1'b0;  // Clear when new value is loaded
        end else if (cnt_done && time_val == 7'd1) begin
            // Will be done after next decrement
            done_reg <= 1'b1;
        end
    end
endmodule
