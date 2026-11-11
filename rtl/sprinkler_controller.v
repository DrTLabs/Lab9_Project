// Sprinkler Controller (FSM) -- YOU COMPLETE THIS FILE
//
// Build this from the Lab 9 Part 1 Design Handout, Figure 3.
//
// The controller decides WHEN things happen. It holds no data: no station
// numbers, no minutes and no clock counts. Those live in the datapath.
//
//   Status in   (datapath -> controller): done, last, tick
//   Control out (controller -> datapath): st_clr, st_inc, m_load, m_dec, c_clr
//
// Five states: IDLE, NEXT, LOAD, RUN, DEC  (see the handout for what each does)

module sprinkler_controller (
    input      clk,
    input      rst,
    input      start,

    // Status from datapath
    input      done,
    input      last,
    input      tick,

    // Control to datapath
    output reg st_clr,
    output reg st_inc,
    output reg m_load,
    output reg m_dec,
    output reg c_clr
);
    // ---------------- State encoding (given) ----------------
    localparam IDLE = 3'd0,
               NEXT = 3'd1,
               LOAD = 3'd2,
               RUN  = 3'd3,
               DEC  = 3'd4;

    reg [2:0] state, next_state;

    // ---------------- 1. State register ----------------
    // TODO: on every rising clock edge, go to IDLE if rst is 1,
    //       otherwise move to next_state.



    // ---------------- 2. Next-state logic ----------------
    // TODO: a combinational always @(*) block with a case on state.
    //  - Start with a default (next_state = state;) so every path assigns it.
    //  - One case item per state. Use the arrow conditions in Figure 3.
    //  - RUN has three arrows out. Check done first: a station that is
    //    finished leaves RUN even if tick is also 1.
    //  - Add a default item that goes to IDLE.



    // ---------------- 3. Output logic (Moore) ----------------
    // TODO: a combinational always @(*) block.
    //  - First set all five outputs to 0 (the defaults).
    //  - Then a case on state that sets to 1 only the outputs listed
    //    for that state in Figure 3. Some states list two.



endmodule
