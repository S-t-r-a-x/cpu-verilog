module digits_generate (
	input [9:0] in,
	output [27:0] out
);

    genvar i;

    generate

    for (i = 0; i < 4; i = i + 1) begin : name
        wire [3:0] digit = in / 10**i % 10;
        hex hex_inst (digit, out[(7 * (i + 1) - 1) : 7 * i]);
    end

    endgenerate

endmodule 
