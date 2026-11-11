`timescale 1ns / 1ps
// Controller unit test
// Drives start/done/last/tick directly and checks the controller outputs.
// Each state has its own output pattern {st_clr, st_inc, m_load, m_dec, c_clr}:
//   IDLE = 10001   NEXT = 01001   LOAD = 00101   RUN = 00000   DEC = 00011

module controller_tb;
    reg clk = 0, rst = 1, start = 0, done = 0, last = 0, tick = 0;
    wire st_clr, st_inc, m_load, m_dec, c_clr;
    integer fails = 0, tests = 0;

    always #5 clk = ~clk;

    sprinkler_controller dut (
        .clk(clk), .rst(rst), .start(start),
        .done(done), .last(last), .tick(tick),
        .st_clr(st_clr), .st_inc(st_inc), .m_load(m_load), .m_dec(m_dec), .c_clr(c_clr)
    );

    wire [4:0] outs = {st_clr, st_inc, m_load, m_dec, c_clr};
    localparam [4:0] O_IDLE = 5'b10001, O_NEXT = 5'b01001, O_LOAD = 5'b00101,
                     O_RUN  = 5'b00000, O_DEC  = 5'b00011;

    function [8*4-1:0] name(input [4:0] o);
        case (o)
            O_IDLE:  name = "IDLE";
            O_NEXT:  name = "NEXT";
            O_LOAD:  name = "LOAD";
            O_RUN:   name = "RUN ";
            O_DEC:   name = "DEC ";
            default: name = "????";
        endcase
    endfunction

    // Advance one clock and check the outputs
    task step_expect(input [4:0] exp, input [8*56-1:0] msg);
        begin
            @(posedge clk); #1;
            tests = tests + 1;
            if (outs !== exp) begin
                fails = fails + 1;
                $display("  FAIL: %0s -- expected %0s (%b), got %0s (%b)", msg,
                         name(exp), exp, name(outs), outs);
            end else
                $display("  ok  : %0s -> %0s", msg, name(exp));
        end
    endtask

    initial begin
        $display("=== sprinkler_controller unit test ===");
        @(posedge clk); #1;
        step_expect(O_IDLE, "reset puts the FSM in IDLE");
        rst = 0;
        step_expect(O_IDLE, "IDLE waits while start = 0");
        done = 1; last = 1; tick = 1;
        step_expect(O_IDLE, "IDLE ignores done, last and tick");
        done = 0; last = 0; tick = 0;

        start = 1;
        step_expect(O_NEXT, "IDLE + start goes to NEXT");
        start = 0; done = 1; tick = 1;
        step_expect(O_LOAD, "NEXT always goes to LOAD (done, tick ignored)");
        step_expect(O_RUN,  "LOAD always goes to RUN (done, tick ignored)");
        done = 0; tick = 0;
        step_expect(O_RUN,  "RUN counts while tick = 0");
        step_expect(O_RUN,  "RUN still counting");
        last = 1;
        step_expect(O_RUN,  "RUN counts while done = 0 (even if last)");
        last = 0; tick = 1;
        step_expect(O_DEC,  "RUN + tick + !done goes to DEC");
        step_expect(O_RUN,  "DEC always goes back to RUN (tick ignored)");
        tick = 0;
        step_expect(O_RUN,  "RUN counts again after DEC");
        tick = 1;
        step_expect(O_DEC,  "RUN + tick goes to DEC again");
        tick = 0; done = 1;
        step_expect(O_RUN,  "DEC always goes back to RUN (done ignored)");
        done = 1; tick = 1;
        step_expect(O_NEXT, "RUN + done + !last goes to NEXT (done beats tick)");
        done = 0; tick = 0;
        step_expect(O_LOAD, "NEXT goes to LOAD (st_inc lasts 1 cycle)");
        step_expect(O_RUN,  "LOAD goes to RUN (m_load lasts 1 cycle)");

        // Middle stations: count, decrement once, then done while not last
        repeat (3) begin
            tick = 1;
            step_expect(O_DEC,  "RUN + tick goes to DEC");
            tick = 0;
            step_expect(O_RUN,  "DEC goes back to RUN");
            done = 1;
            step_expect(O_NEXT, "RUN + done + !last goes to NEXT");
            done = 0;
            step_expect(O_LOAD, "NEXT goes to LOAD");
            step_expect(O_RUN,  "LOAD goes to RUN");
        end

        done = 1; last = 1;
        step_expect(O_IDLE, "RUN + done + last goes to IDLE");
        done = 0; last = 0;
        step_expect(O_IDLE, "back in IDLE, waiting for start");

        // Restart works, and reset in the middle of a run returns to IDLE
        start = 1;
        step_expect(O_NEXT, "second start goes to NEXT");
        start = 0;
        step_expect(O_LOAD, "NEXT goes to LOAD");
        step_expect(O_RUN,  "LOAD goes to RUN");
        tick = 1;
        step_expect(O_DEC,  "RUN + tick goes to DEC");
        tick = 0; rst = 1;
        step_expect(O_IDLE, "reset during DEC goes to IDLE");
        rst = 0;
        step_expect(O_IDLE, "stays in IDLE after reset");

        $display("");
        if (fails == 0) $display("ALL TESTS PASS (%0d/%0d)", tests, tests);
        else            $display("SOME TESTS FAILED (%0d of %0d failed)", fails, tests);
        $finish;
    end

    initial begin #10000; $display("TIMEOUT"); $finish; end
endmodule
