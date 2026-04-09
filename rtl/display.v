// Display Wrapper Module
// Converts station number and time value to display format
//
// Display format (16 bits, left to right on 7-segment displays):
//   [15:12] - Station number (leftmost display)
//   [11:8]  - Blank (4'b0)
//   [7:4]   - Timer tens digit
//   [3:0]   - Timer ones digit (rightmost display)
//
// Inputs:
//   station_val - Current station number (0-5)
//   time_val    - Current timer value in minutes (0-99)
//
// Outputs:
//   disp_w      - 16-bit display value for hex_tdm module

module display (
    input  [3:0]  station_val,
    input  [6:0]  time_val,
    output [15:0] disp_w
);
    // Pad time_val to 14 bits for bin2bcd module
    wire [13:0] time_disp;
    assign time_disp = {7'b0, time_val};

    // BCD outputs
    wire [3:0] bcd_thousands;
    wire [3:0] bcd_hundreds;
    wire [3:0] bcd_tens;
    wire [3:0] bcd_ones;

    // Instantiate bin2bcd converter (double_dabble_14bit from Lab7)
    bin2bcd u_bin2bcd (
        .binary(time_disp),
        .bcd_ones(bcd_ones),
        .bcd_tens(bcd_tens),
        .bcd_hundreds(bcd_hundreds),
        .bcd_thousands(bcd_thousands)
    );

    // Format display output: {station, blank, tens, ones}
    assign disp_w = {station_val, 4'b0000, bcd_tens, bcd_ones};

endmodule
