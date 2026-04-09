module tdm_scan (
    input        clk,
    input        rst,
    input        ce,
    output reg [1:0] idx
);
    always @(posedge clk) begin
        if (rst)      idx <= 2'd0;
        else if (ce)  idx <= idx + 2'd1;
    end
endmodule
