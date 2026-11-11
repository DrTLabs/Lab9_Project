`timescale 1ns / 1ps
// Full-system test of sprinkler_top (your top module, run with fast timing)
//
// For each station it checks:
//   - the right valve LED turns on, one at a time, in order 1..5
//   - the minutes register loads that station's duration (led[15:9])
//   - the valve stays on for that station's duration
//     (one minute = CPM clock cycles counted in RUN, plus one DEC cycle)
// Then it checks the return to idle and a second run.

module sprinkler_tb;
    localparam CPM = 10;  // clock cycles per "minute" in simulation

    reg clk = 0, btnC = 1, btnU = 0;
    wire [6:0]  seg;
    wire [3:0]  an;
    wire [15:0] led;
    integer fails = 0, tests = 0;

    always #5 clk = ~clk;

    sprinkler_top #(.CYCLES_PER_MIN(CPM), .TDM_N(3)) dut (
        .clk(clk), .btnC(btnC), .btnU(btnU),
        .seg(seg), .an(an), .led(led)
    );

    wire [4:0] valves  = led[4:0];
    wire [6:0] minutes = led[15:9];

    reg [6:0] dur [1:5];
    initial begin
        dur[1] = 15; dur[2] = 32; dur[3] = 12; dur[4] = 8; dur[5] = 20;
    end

    task check(input ok, input [8*64-1:0] msg);
        begin
            tests = tests + 1;
            if (ok) $display("  ok  : %0s", msg);
            else begin fails = fails + 1; $display("  FAIL: %0s", msg); end
        end
    endtask

    // Watch the valves for one full watering cycle
    task run_sequence(input integer pass);
        integer k, cycles, max_wait, peak;
        reg [4:0] want;
        begin
            $display("--- Watering sequence, run %0d ---", pass);
            @(negedge clk) btnU = 1;
            @(negedge clk) btnU = 0;

            for (k = 1; k <= 5; k = k + 1) begin
                want = 5'b00001 << (k - 1);

                // Wait for this station's valve (at most 2 cycles)
                max_wait = 0;
                while (valves !== want && max_wait < 2) begin
                    @(negedge clk); max_wait = max_wait + 1;
                end
                check(valves === want, {"station valve turns on (one-hot, in order)"});
                if (valves !== want)
                    $display("        station %0d: expected valves=%b, got %b", k, want, valves);

                // Count how long it stays on, and record the loaded minutes
                cycles = 0; peak = 0;
                while (valves === want && cycles < 4000) begin
                    if (minutes > peak) peak = minutes;
                    @(negedge clk); cycles = cycles + 1;
                end
                check(peak == dur[k], "minutes loads this station's duration");
                if (peak != dur[k])
                    $display("        station %0d: expected %0d minutes loaded, saw %0d", k, dur[k], peak);
                check(cycles >= dur[k]*(CPM+1) && cycles <= dur[k]*(CPM+1) + 4,
                      "valve stays on for the station's duration");
                if (!(cycles >= dur[k]*(CPM+1) && cycles <= dur[k]*(CPM+1) + 4))
                    $display("        station %0d: on for %0d cycles, expected about %0d (%0d min)",
                             k, cycles, dur[k]*(CPM+1), dur[k]);
                if (k < 5)
                    check(valves === (want << 1), "next station follows with no gap");
            end

            repeat (3) @(negedge clk);
            check(valves === 5'b0, "all valves off after station 5 (back to IDLE)");
            repeat (50) @(negedge clk);
            check(valves === 5'b0, "stays idle until start is pressed again");
        end
    endtask

    // Count anode changes so we know the display is scanning
    integer an_changes = 0;
    reg [3:0] an_prev = 4'b1111;
    always @(posedge clk) if (an !== an_prev) begin an_changes = an_changes + 1; an_prev = an; end

    initial begin
        $display("=== sprinkler_top system test (CYCLES_PER_MIN = %0d) ===", CPM);
        repeat (3) @(negedge clk);
        btnC = 0;
        repeat (3) @(negedge clk);
        check(valves === 5'b0, "after reset all valves are off");
        repeat (20) @(negedge clk);
        check(valves === 5'b0, "no watering without start");

        run_sequence(1);
        run_sequence(2);

        check(an_changes > 100, "7-segment display is scanning");

        $display("");
        if (fails == 0) $display("ALL TESTS PASS (%0d/%0d)", tests, tests);
        else            $display("SOME TESTS FAILED (%0d of %0d failed)", fails, tests);
        $finish;
    end

    initial begin #4_000_000; $display("TIMEOUT -- FSM is probably stuck"); $finish; end
endmodule
