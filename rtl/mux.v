// Digit mux for 4x hex display (Instructor version)
// Selects a 4-bit nibble from `disp` based on scan index `idx`.

module mux (
    input  [15:0] disp,
    input  [1:0]  idx,
    output reg [3:0] digit
);
    always @(*) begin
        case (idx)
            2'd0: digit = disp[3:0];
            2'd1: digit = disp[7:4];
            2'd2: digit = disp[11:8];
            2'd3: digit = disp[15:12];
            default: digit = 4'h0;
        endcase
    end
endmodule
