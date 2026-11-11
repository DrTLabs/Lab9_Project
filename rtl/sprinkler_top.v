// Sprinkler Top Module (Basys3) -- YOU COMPLETE THE TODOs
//
//   btnC = reset, btnU = start
//   led[4:0]  = valves (one-hot),  led[5] = done,  led[6] = last
//   led[15:9] = minutes remaining (binary, debug)
//   7-seg     = station | blank | minutes tens | minutes ones
//
// CYCLES_PER_MIN and TDM_N are parameters so the testbench can run this
// exact module fast. Leave the defaults alone for hardware.

module sprinkler_top #(
    parameter CYCLES_PER_MIN = 33_000_000,  // 1 "minute" = 0.33 s
    parameter TDM_N          = 16           // ~763 Hz digit refresh
) (
    input         clk,
    input         btnC,
    input         btnU,
    output [6:0]  seg,
    output [3:0]  an,
    output [15:0] led
);
    wire rst   = btnC;
    wire start = btnU;

    // ---------------- Control: controller -> datapath ----------------
    // TODO: declare the five 1-bit control wires:
    //       st_clr_w, st_inc_w, m_load_w, m_dec_w, c_clr_w


    // ---------------- Status: datapath -> controller ----------------
    // TODO: declare the three 1-bit status wires: done_w, last_w, tick_w


    // ---------------- Data: datapath -> outputs ----------------
    wire [2:0] station_w;
    wire [6:0] minutes_w;
    wire [4:0] valves_w;

    // ---------------- Controller ----------------
    // TODO: instantiate sprinkler_controller with instance name u_controller.
    //       Connect clk, rst, start, the three status wires, and the five
    //       control wires. Use the datapath instance below as a pattern.



    // ---------------- Datapath (given) ----------------
    sprinkler_datapath #(
        .CYCLES_PER_MIN(CYCLES_PER_MIN)
    ) u_datapath (
        .clk(clk),
        .rst(rst),
        .st_clr(st_clr_w),
        .st_inc(st_inc_w),
        .m_load(m_load_w),
        .m_dec(m_dec_w),
        .c_clr(c_clr_w),
        .done(done_w),
        .last(last_w),
        .tick(tick_w),
        .station(station_w),
        .minutes(minutes_w),
        .valves(valves_w)
    );

    // ---------------- Display (provided) ----------------
    // Station 0 means idle
    wire [3:0]  station_disp = {1'b0, station_w};
    wire [15:0] disp_w;
    wire [3:0]  an_raw_w;

    display u_display (
        .station_val(station_disp),
        .time_val(minutes_w),
        .disp_w(disp_w)
    );

    hex_tdm #(.N(TDM_N)) u_hex_tdm (
        .clk(clk),
        .btnC(btnC),
        .disp(disp_w),
        .seg(seg),
        .an(an_raw_w)
    );

    // Blank the second digit from the left
    assign an = {an_raw_w[3], 1'b1, an_raw_w[1:0]};

    // ---------------- LEDs ----------------
    assign led = {minutes_w, 2'b00, last_w, done_w, valves_w};
endmodule
