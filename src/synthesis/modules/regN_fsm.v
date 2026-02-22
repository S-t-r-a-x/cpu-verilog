module regN_fsm #(
    parameter WIDTH = 8,
    parameter HIGH = WIDTH - 1
)(
	input clk,
	input rst_n,
	input select,
	input ld_inc,
	input [HIGH:0] in,
	output [HIGH:0] out
);

    localparam ld = 1'b0;
    localparam inc = 1'b1;

    reg state_next, state_reg;
    reg [HIGH:0] out_next, out_reg;

    assign out = out_reg;

    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            state_reg <= ld;
            out_reg <= {WIDTH{1'b0}};
        end
        else begin
            state_reg <= state_next;
            out_reg <= out_next;
        end
    end

    always @(*) begin
        state_next = state_reg;
        out_next = out_reg;
        
        case (state_reg)
        
            ld: begin
                if (select == 1'b1)
                    state_next = inc;
                if (ld_inc)
                    out_next = in;
            end
            
            inc: begin
                if (select == 1'b0)
                    state_next = ld;
                if (ld_inc)
                    out_next = out_reg + 1'b1;
            end
        
        endcase
    end

endmodule
