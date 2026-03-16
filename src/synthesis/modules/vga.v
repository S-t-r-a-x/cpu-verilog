module vga (
    input clk,
    input rst_n,
    input [23:0] code,
    output hsync,
    output vsync,
    output [3:0] red,
    output [3:0] green,
    output [3:0] blue
);

// CLOCK - 25MHz from 50MHz
reg pclk_en;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) pclk_en <= 1'b0;
    else pclk_en <= ~pclk_en;
end

// COUNTERS
reg [9:0] h_cnt; // 0 - 799
reg [9:0] v_cnt; // 0 - 524


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        h_cnt <= 10'd0;
        v_cnt <= 10'd0;
    end else if (pclk_en) begin
        if (h_cnt == 10'd799) begin
            h_cnt <= 10'd0;
            if (v_cnt == 10'd524) begin // TODO might need to change the condition to if (v_cnt == 10'd520), because back porch is 33 here but elsewhere 29  
                v_cnt <= 10'd0;
            end else begin
                v_cnt <= v_cnt + 1'b1;
            end
        end else begin
            h_cnt <= h_cnt + 1'b1;
        end
    end
end

// HSYNC - sync pulse 96 lines
// hsync - low from 656 to 751 (640+16 to 640+16+96-1) 
assign hsync = (h_cnt >= 10'd656 && h_cnt < 10'd752) ? 1'b0 : 1'b1;

// VSYNC - sync pulse 2 lines 
// vsync is low from 490 to 491 (480+10 to 480+10+2-1)
assign vsync = (v_cnt >= 10'd490 && v_cnt < 10'd492) ? 1'b0 : 1'b1;

// COLOR OUTPUT
// Upper 12 bits for left half, lower 12 for right half
wire video_on = (h_cnt < 10'd640) && (v_cnt < 10'd480);
wire left_half = (h_cnt < 10'd320);

wire [11:0] current_color = left_half ? code[23:12] : code[11:0];

// If in sync regions, output must be 0000 - no colors
assign red   = video_on ? current_color[11:8] : 4'h0;
assign green = video_on ? current_color[7:4]  : 4'h0;
assign blue  = video_on ? current_color[3:0]  : 4'h0;

endmodule
