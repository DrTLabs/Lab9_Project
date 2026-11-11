// Sprinkler Datapath -- YOU COMPLETE THIS FILE
//
// Build this from the Lab 9 Part 1 Design Handout, Figure 2.
// The datapath holds the data and does the work, but only when the
// controller tells it to. Each register changes only on a control signal:
//
//   station : st_clr -> 0,         st_inc -> station + 1,   else hold
//   minutes : m_load -> duration,  m_dec  -> minutes - 1,   else hold
//   cyc     : c_clr  -> 0,         else cyc + 1   (counts clock cycles)
//
//   duration mux : select = station; inputs = each station's minutes
//   status       : done = (minutes == 0), last = (station == 5),
//                  tick = (cyc == CYCLES_PER_MIN - 1)
//   valve decoder: station -> one-hot valves (station 0 = all off)

module sprinkler_datapath #(
    parameter CYCLES_PER_MIN = 33_000_000,
    parameter ST1_TIME = 7'd15,
    parameter ST2_TIME = 7'd32,
    parameter ST3_TIME = 7'd12,
    parameter ST4_TIME = 7'd8,
    parameter ST5_TIME = 7'd20
) (
    input        clk,
    input        rst,

    // Control from controller
    input        st_clr,
    input        st_inc,
    input        m_load,
    input        m_dec,
    input        c_clr,

    // Status to controller
    output       done,
    output       last,
    output       tick,

    // Data outputs
    output [2:0] station,
    output [6:0] minutes,
    output [4:0] valves
);
    // ---------------- Registers (handout Figure 2) ----------------
    reg [2:0]  station_r;
    reg [6:0]  minutes_r;
    reg [25:0] cyc_r;
    reg [6:0]  duration;      // mux output (TODO 4)

    // TODO 1: station register. An always @(posedge clk) block.
    //   rst or st_clr -> station_r <= 0
    //   st_inc        -> station_r <= station_r + 1
    //   (otherwise it holds its value -- no else needed)



    // TODO 2: minutes register. An always @(posedge clk) block.
    //   rst    -> minutes_r <= 0
    //   m_load -> minutes_r <= duration
    //   m_dec  -> minutes_r <= minutes_r - 1
    //   (otherwise it holds)



    // TODO 3: cycle counter. An always @(posedge clk) block.
    //   rst or c_clr -> cyc_r <= 0
    //   otherwise    -> cyc_r <= cyc_r + 1   (it counts in every other cycle)



    assign station = station_r;
    assign minutes = minutes_r;

    // ---------------- Duration mux (handout Figure 2) ----------------
    // TODO 4: an always @(*) block with a case on station_r (the select).
    //   Select 1-5 picks ST1_TIME .. ST5_TIME. Default gives 0.



    // ---------------- Status (handout Figure 2) ----------------
    // TODO 5: three assign statements, one comparator each:
    //   done, last, tick



    // ---------------- Valve decoder (handout Figure 2) ----------------
    reg [4:0] valves_r;

    // TODO 6: an always @(*) block with a case on station_r.
    //   Station 1 -> 5'b00001, ... station 5 -> 5'b10000.
    //   Default (including station 0 = idle) -> 5'b00000.



    assign valves = valves_r;
endmodule
