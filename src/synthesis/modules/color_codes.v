module color_codes (
    input [5:0] num,
    output [23:0] code
);

// Hex color codes
localparam BLACK        = 12'h000;
localparam RED          = 12'hF00;
localparam ORANGE       = 12'hF80;
localparam YELLOW       = 12'hFF0;
localparam GREEN        = 12'h0F0;
localparam CYAN         = 12'h0FF;
localparam LIGHTBLUE    = 12'h08F;
localparam BLUE         = 12'h00F;
localparam MAGENTA      = 12'hF0F;
localparam WHITE        = 12'hFFF;

reg [11:0] color_tens;
reg [11:0] color_singles;

assign code = {color_tens, color_singles};

always @(*) begin
    case (num % 10)
        6'd0: color_singles = BLACK;
        6'd1: color_singles = RED;
        6'd2: color_singles = ORANGE;
        6'd3: color_singles = YELLOW;
        6'd4: color_singles = GREEN;
        6'd5: color_singles = CYAN;
        6'd6: color_singles = LIGHTBLUE;
        6'd7: color_singles = BLUE;
        6'd8: color_singles = MAGENTA;
        6'd9: color_singles = WHITE;
    endcase 
    case ((num/10) % 10)
        6'd0: color_tens = BLACK;
        6'd1: color_tens = RED;
        6'd2: color_tens = ORANGE;
        6'd3: color_tens = YELLOW;
        6'd4: color_tens = GREEN;
        6'd5: color_tens = CYAN;
        6'd6: color_tens = LIGHTBLUE;
        6'd7: color_tens = BLUE;
        6'd8: color_tens = MAGENTA;
        6'd9: color_tens = WHITE;
    endcase
end

endmodule