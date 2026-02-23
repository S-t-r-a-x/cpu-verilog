module digits (
	input [9:0] in,
	output [6:0] out_ones,
	output [6:0] out_tens,
	output [6:0] out_hundreds,
	output [6:0] out_thousands
);

    wire [3:0] ones = in % 10;
    wire [3:0] tens = in / 10 % 10;
    wire [3:0] hundreds = in / 100 % 10;
    wire [3:0] thousands = in / 1000 % 10;

    ssd ssd_inst1 (ones, out_ones);
    ssd ssd_inst2 (tens, out_tens);
    ssd ssd_inst3 (hundreds, out_hundreds);
    ssd ssd_inst4 (thousands, out_thousands);

endmodule
