module memory #(
	parameter FILE_NAME = "mem_init.mif",
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
)(
    input clk,
    input we,
    input rst_n,
    input [ADDR_WIDTH - 1:0] addr,
    input [DATA_WIDTH - 1:0] data,
    output reg [DATA_WIDTH - 1:0] out
);

	(* ram_init_file = FILE_NAME *) reg [DATA_WIDTH - 1:0] mem [2**ADDR_WIDTH - 1:0];

    always @(posedge clk) begin
        if (we) begin
            // Executes first due to blocking assignment (=). 
            // This allows the CPU to safely set `addr = new_addr` and `data = mem (old data)` in the same cycle.  
            // The memory will write the old data to the new address, and then output that same data.
            mem[addr] = data;
        end
        out <= mem[addr];
    end

endmodule
