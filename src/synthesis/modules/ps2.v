module ps2 (
    input clk,
    input rst_n,
    input ps2_clk,
    input ps2_data,
    output [15:0] code   // FIXED: 16 bits!
);

wire falling_edge;
red falling_edge_det (
    .clk(clk),
    .rst_n(rst_n),
    .in(~ps2_clk),
    .out(falling_edge)
);

reg [10:0] shift_reg; 
reg [3:0] bit_cnt;
reg [15:0] code_reg;

assign code = code_reg; 
always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        bit_cnt <= 4'd0;
        shift_reg <= 11'd0;
        code_reg <= 16'd0;
    end 
    else if (falling_edge) begin
        // ps2 sends data in reverse (least significant bit first), have to shift like this
        shift_reg <= {ps2_data, shift_reg[10:1]};
        
        if (bit_cnt == 4'd10) begin
            // received all 11 bits
            code_reg <= {code_reg[7:0], shift_reg[8:1]};
            bit_cnt <= 4'd0; // reset for next frame
        end else begin
            bit_cnt <= bit_cnt + 1'b1;
        end
    end
end

endmodule