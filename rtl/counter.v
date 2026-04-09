module counter #(
    parameter N = 20
) (
    input              clk,
    input              rst,
    output reg [N-1:0] q
);
    always @(posedge clk) begin
        if (rst) q <= {N{1'b0}};
        else     q <= q + 1'b1;
    end
endmodule
