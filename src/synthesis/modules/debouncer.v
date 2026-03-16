module debouncer (
    input clk,
    input rst_n,
    input in,
    output out
);

    reg [1:0] ff;
    reg [19:0] cnt; // 20-bit counter for ~20ms delay at 50MHz
    reg out_reg;
    
    assign out = out_reg;
    wire in_changed = (ff[0] ^ ff[1]);

    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            ff <= 2'b00;
            cnt <= 20'd0;
            out_reg <= 1'b0;
        end else begin
            // Shift the input to synchronize it
            ff[0] <= in;
            ff[1] <= ff[0];
            
            if (in_changed) begin
                // Input is bouncing, reset the counter
                cnt <= 20'd0;
            end else if (cnt < 20'd1_000_000) begin
                // Input is stable, keep counting up to 20ms
                cnt <= cnt + 1'b1;
            end else begin
                // Counter reached the max, input has been stable for long enough
                out_reg <= ff[1];
            end
        end
    end

endmodule
