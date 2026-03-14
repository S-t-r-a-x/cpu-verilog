// CPU testbench: runs CPU + memory with program loaded in initial block.
// No external .mif/.hex: memory contents are set below via the memory interface.
// Use: make simul_all (from tooling/) or make simul_cmp && make simul_run

`timescale 1 ns / 1 ps

// Simulation-only memory: same ports as memory.v, contents filled here.
module memory_sim #(
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
)(
    input clk,
    input we,
    input rst_n,
    input [ADDR_WIDTH-1:0] addr,
    input [DATA_WIDTH-1:0] data,
    output reg [DATA_WIDTH-1:0] out
);
    reg [DATA_WIDTH-1:0] mem [0:(2**ADDR_WIDTH)-1];

    integer i;
    initial begin
        for (i = 0; i < 2**ADDR_WIDTH; i = i + 1)
            mem[i] = {DATA_WIDTH{1'b0}};
        // Program (Block MOV test): PC starts at 8
        mem[0] = 16'h0000; mem[1] = 16'h0000; mem[2] = 16'h0000; mem[3] = 16'h0000;
        mem[4] = 16'd10;   mem[5] = 16'd20;   mem[6] = 16'd30;   mem[7] = 16'h0000;
        mem[8]  = 16'h0143;  // Block MOV: X=1, Y=4, N=3 => copy mem[4..6] to mem[1..3]
        mem[9]  = 16'h8100;  // OUT 1 (should be 10)
        mem[10] = 16'h8200;  // OUT 2 (should be 20)
        mem[11] = 16'h8300;  // OUT 3 (should be 30)
        mem[12] = 16'hF000;  // STOP
        mem[13] = 16'h0000;
        mem[14] = 16'h0000;
        mem[15] = 16'h0000;
        mem[16] = 16'h0000;
        mem[17] = 16'h0000;
        mem[18] = 16'h0000;
        mem[19] = 16'h0000;
        mem[20] = 16'h0000;
        for (i = 21; i < 64; i = i + 1)
            mem[i] = 16'h0000;
    end

    always @(posedge clk) begin
        if (we)
            mem[addr] = data;
        out <= mem[addr];
    end
endmodule

module cpu_tb;
    parameter ADDR_WIDTH = 6;
    parameter DATA_WIDTH = 16;
    parameter CLK_PERIOD = 20;   // 20 ns period => 50 MHz
    parameter SIM_CYCLES  = 500;

    reg clk;
    reg rst_n;
    reg [DATA_WIDTH-1:0] sw_in;
    wire we;
    wire [ADDR_WIDTH-1:0] addr;
    wire [DATA_WIDTH-1:0] cpu_data;
    wire [DATA_WIDTH-1:0] cpu_out;
    wire [DATA_WIDTH-1:0] mem_out;
    wire [ADDR_WIDTH-1:0] pc, sp;

    // Clock
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // CPU input (for IN instruction): driven combinationally from PC.
    // PC is already incremented to N+1 when EXECUTE of instruction at N runs.
    always @(*) begin
        if      (pc == 9)   sw_in = 16'd10;  // for IN R1 at PC=8
        else if (pc == 10)  sw_in = 16'd5;   // for IN R2 at PC=9
        else                sw_in = 16'd0;
    end

    memory_sim #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) u_mem (
        .clk(clk),
        .we(we),
        .rst_n(rst_n),
        .addr(addr),
        .data(cpu_data),
        .out(mem_out)
    );

    cpu #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) u_cpu (
        .clk(clk),
        .rst_n(rst_n),
        .mem(mem_out),
        .in(sw_in),
        .we(we),
        .addr(addr),
        .data(cpu_data),
        .out(cpu_out),
        .pc(pc),
        .sp(sp)
    );

    // Print PC, SP, and output whenever PC changes (after reset)
    always @(pc, cpu_out)
        if (rst_n)
            $display("[trace] PC=%0d SP=%0d out=%0d", pc, sp, cpu_out);

    initial begin
        rst_n = 0;
        #(2*CLK_PERIOD);
        rst_n = 1;
        #(SIM_CYCLES * CLK_PERIOD);
        if (cpu_out === 16'd30)
            $display("[PASS] cpu_out = 30 at end of run.");
        else
            $display("[CHECK] cpu_out = %0d (expected 30 if Block MOV worked).", cpu_out);
        $display("PC = %0d, SP = %0d", pc, sp);
        $finish;
    end
endmodule
