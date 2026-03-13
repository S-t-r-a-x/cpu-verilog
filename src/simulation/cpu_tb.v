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
        // Program (same as mem_init.mif): PC starts at 8
        mem[0] = 16'h0000; mem[1] = 16'h0000; mem[2] = 16'h0000; mem[3] = 16'h0000;
        mem[4] = 16'h0000; mem[5] = 16'h0000; mem[6] = 16'h0000; mem[7] = 16'h0000;
        mem[8]  = 16'h7101;  // IN A
        mem[9]  = 16'h8101;  // OUT A
        mem[10] = 16'h0210;  // MOV B, A
        mem[11] = 16'h1312;  // ADD C, A, B
        mem[12] = 16'h8301;  // OUT C
        mem[13] = 16'h7401;  // IN D
        mem[14] = 16'h2334;  // SUB C, C, D
        mem[15] = 16'h0530;  // MOV E, C
        mem[16] = 16'h8501;  // OUT E
        mem[17] = 16'h7301;  // IN C
        mem[18] = 16'h3553;  // MUL E, E, C
        mem[19] = 16'h8501;  // OUT E
        mem[20] = 16'hF000;  // STOP
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
    // IN A  is at addr  8, so during its EXECUTE pc = 9  -> need sw_in = 8
    // IN D  is at addr 13, so during its EXECUTE pc = 14 -> need sw_in = 9
    // IN C  is at addr 17, so during its EXECUTE pc = 18 -> need sw_in = 3
    always @(*) begin
        if      (pc < 14) sw_in = 16'd8;
        else if (pc < 18) sw_in = 16'd9;
        else              sw_in = 16'd3;
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

    initial begin
        rst_n = 0;
        #(2*CLK_PERIOD);
        rst_n = 1;
        #(SIM_CYCLES * CLK_PERIOD);
        if (cpu_out === 16'd21)
            $display("[PASS] cpu_out = 21 at end of run.");
        else
            $display("[CHECK] cpu_out = %0d (expected 21 if IN values were correct).", cpu_out);
        $display("PC = %0d, SP = %0d", pc, sp);
        $finish;
    end
endmodule
