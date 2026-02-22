module digits_generate_parameter #(
	parameter NUM = 4
)(
	input [9:0] in,
	output [NUM * 7 - 1 : 0] out
);

    genvar i;

    generate

    for (i = 0; i < NUM; i = i + 1) begin : name
        wire [3:0] digit = in / 10**i % 10;
        hex hex_inst (digit, out[(7 * (i + 1) - 1) -: 7]);
    end

    endgenerate

endmodule
