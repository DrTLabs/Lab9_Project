module anode_decode (
    input  [1:0] idx,
    output reg [3:0] an
);
    always @(*) begin
        case (idx)
            2'd0: an = 4'b1110; // rightmost
            2'd1: an = 4'b1101;
            2'd2: an = 4'b1011;
            2'd3: an = 4'b0111; // leftmost
            default: an = 4'b1111; // all off
        endcase
    end
endmodule
