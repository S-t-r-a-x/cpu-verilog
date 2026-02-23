module register # (
    parameter DATA_WIDTH = 16
)(
    input wire clk,
    input wire rst_n,
    input wire cl,
    input wire ld,
    input wire [DATA_WIDTH-1:0] in,
    input wire inc,
    input wire dec,
    input wire sr,
    input wire ir,
    input wire sl,
    input wire il,
    output wire [DATA_WIDTH-1:0] out
);
    
    reg [DATA_WIDTH-1:0] out_reg;
    reg [DATA_WIDTH-1:0] out_next;

    assign out = out_reg;

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) 
            out_reg <= {DATA_WIDTH{1'b0}};
        else
            out_reg <= out_next;
    end

    always @(*) begin
        out_next = out_reg;
        if(cl)
            out_next = {DATA_WIDTH{1'h0}};
        else if(ld) 
            out_next = in;
        else if(inc)
            out_next = out_reg + 1'h1;
        else if(dec)
            out_next = out_reg - 1'h1;
        else if(sr)
            out_next = {ir, out_reg[DATA_WIDTH-1:1]};
        else if(sl) 
            out_next = {out_reg[DATA_WIDTH-2:0], il};
    end

endmodule