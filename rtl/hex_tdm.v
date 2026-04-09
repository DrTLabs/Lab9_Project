// Hex TDM Display Top (Instructor, Lab7)
// Drives a 4-digit seven-seg display using time-division multiplexing (TDM).
// Input is a packed 16-bit nibble vector `disp[15:0]` where each nibble is a hex digit:
//   disp[3:0]   -> rightmost digit
//   disp[7:4]   -> next digit
//   disp[11:8]  -> next digit
//   disp[15:12] -> leftmost digit

module hex_tdm #(
    parameter N = 20               // clock divider width
) (
    input         clk,
    input         btnC,            // active-high reset
    input  [15:0] disp,            // 4 hex digits packed into 16 bits
    output [6:0]  seg,             // {g,f,e,d,c,b,a}, active-low
    output [3:0]  an               // anode enables, active-low
);
    // Reset
    wire rst = btnC;

    // Clock divider to generate a uniform CE pulse
    wire [N-1:0] q;
    wire         ce;
    reg          msb_d;

    counter #(.N(N)) u_div (
        .clk(clk), .rst(rst), .q(q)
    );

    // One-cycle CE on rising edge of divider MSB
    always @(posedge clk) begin
        if (rst) msb_d <= 1'b0; else msb_d <= q[N-1];
    end
    assign ce = q[N-1] & ~msb_d;

    // Scan index and anode decode
    wire [1:0] idx;
    tdm_scan u_scan (
        .clk(clk), .rst(rst), .ce(ce), .idx(idx)
    );

    anode_decode u_an (
        .idx(idx), .an(an)
    );

    // Digit mux selects one nibble from `disp`
    wire [3:0] digit;
    mux u_mux (
        .disp(disp), .idx(idx), .digit(digit)
    );

    // 7-seg decode (active-low outputs), direct connect
    hex_to_7seg u_seg (
        .hex(digit), .seg(seg)
    );
endmodule
