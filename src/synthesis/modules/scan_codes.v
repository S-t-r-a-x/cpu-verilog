module scan_codes (
    input clk,
    input rst_n,
    input [15:0] code,
    input status,
    output control,
    output [3:0] num
);

localparam ZERO   = 8'h45;
localparam ONE    = 8'h16;
localparam TWO    = 8'h1E;
localparam THREE  = 8'h26;
localparam FOUR   = 8'h25;
localparam FIVE   = 8'h2E;
localparam SIX    = 8'h36;
localparam SEVEN  = 8'h3D;
localparam EIGHT  = 8'h3E;
localparam NINE   = 8'h46;

reg [3:0] num_reg;
reg control_reg;

assign num = num_reg;
assign control = control_reg;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        num_reg <= 4'd0;
        control_reg <= 1'b0;
    end else begin
        // reset control if status s 0
        if (status == 1'b0) begin
            control_reg <= 1'b0;
        end
        // Only translate if status == 1
        // AND the key was just released - code[15:8] == F0
        // AND it hasn't already been translated - control still 0
        else if (status == 1'b1 && code[15:8] == 8'hF0 && control_reg == 1'b0) begin

            // Look at the latest byte and translate
            control_reg <= 1'b1;
            case (code[7:0])
                ZERO : num_reg <= 4'd0;
                ONE  : num_reg <= 4'd1;
                TWO  : num_reg <= 4'd2;
                THREE: num_reg <= 4'd3;
                FOUR : num_reg <= 4'd4;
                FIVE : num_reg <= 4'd5;
                SIX  : num_reg <= 4'd6;
                SEVEN: num_reg <= 4'd7;
                EIGHT: num_reg <= 4'd8;
                NINE : num_reg <= 4'd9;
                default: control_reg <= 1'b0; // Ignore non digit keys
            endcase
            
        end
    end
end

endmodule