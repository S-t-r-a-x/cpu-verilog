module clk_div #(
    parameter DIVISOR = 50_000_000
) (
    input clk,
    input rst_n,
    output out
);  

    reg [25:0] counter;
    reg clk_out_reg;

    assign out = clk_out_reg;

    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            counter <= 26'b0;
            clk_out_reg <= 1'b0;
        end
        else begin
            counter <= counter + 1;
            if (counter == (DIVISOR / 2) - 1) begin
                clk_out_reg <= ~clk_out_reg;
                counter <= 31'b0;
            end
        end
    end

endmodule