module regN #(
	parameter WIDTH = 8
)(
	input clk,
	input rst_n,
	input ld,
	input inc,
	input [WIDTH-1:0] in,
	output [WIDTH-1:0] out
);

    reg [WIDTH-1:0] out_next, out_reg;
    
    assign out = out_reg;

    always @(posedge clk, negedge rst_n)
        if (!rst_n)
            out_reg <= {WIDTH{1'b0}};
        else
            out_reg <= out_next;

    always @(*) begin
        out_next = out_reg;
        if (ld)
            out_next = in;
        else if (inc)
            out_next = out_reg + 1'b1;
    end

endmodule
