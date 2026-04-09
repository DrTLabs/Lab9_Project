// Double-Dabble Algorithm: 14-bit Binary to 4-digit BCD
// Converts a 14-bit binary number (0..16383) to 4 BCD digits (0..9999 shown correctly).
// Algorithm: For each bit (MSB->LSB): add-3 to any BCD digit >= 5, then shift left by 1.

module bin2bcd (
    input  [13:0] binary,       // 14-bit binary input
    output [3:0]  bcd_ones,     // BCD ones
    output [3:0]  bcd_tens,     // BCD tens
    output [3:0]  bcd_hundreds, // BCD hundreds
    output [3:0]  bcd_thousands // BCD thousands
);
    // Format: {thousands, hundreds, tens, ones, binary}
    // Width: 4*4 + 14 = 30 bits
    reg [29:0] stage [0:14];
    integer i;

    always @(*) begin
        // Initialize with BCD=0, binary=input
        stage[0] = {16'h0000, binary};

        // 14 iterations: add-3 where needed, then shift
        for (i = 0; i < 14; i = i + 1) begin
            // Add-3 to digits >= 5
            stage[i+1][29:26] = (stage[i][29:26] >= 4'd5) ? stage[i][29:26] + 4'd3 : stage[i][29:26]; // thousands
            stage[i+1][25:22] = (stage[i][25:22] >= 4'd5) ? stage[i][25:22] + 4'd3 : stage[i][25:22]; // hundreds
            stage[i+1][21:18] = (stage[i][21:18] >= 4'd5) ? stage[i][21:18] + 4'd3 : stage[i][21:18]; // tens
            stage[i+1][17:14] = (stage[i][17:14] >= 4'd5) ? stage[i][17:14] + 4'd3 : stage[i][17:14]; // ones
            // Carry over binary portion
            stage[i+1][13:0]  = stage[i][13:0];

            // Shift left by 1
            stage[i+1] = stage[i+1] << 1;
        end
    end

    // Outputs from final stage
    assign bcd_thousands = stage[14][29:26];
    assign bcd_hundreds  = stage[14][25:22];
    assign bcd_tens      = stage[14][21:18];
    assign bcd_ones      = stage[14][17:14];
endmodule
