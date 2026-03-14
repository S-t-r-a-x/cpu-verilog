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
        // GPR: A=1, B=2, C=3, D=4, E=5. PC starts at 8.
        mem[0] = 16'h0000; mem[1] = 16'h0000; mem[2] = 16'h0000; mem[3] = 16'h0000;
        mem[4] = 16'h0000; mem[5] = 16'h0000; mem[6] = 16'h0000; mem[7] = 16'h0000;
        // --- Both MOV variants + ADD ---
        // MOV A, #42   (2-word: X=A=001, Z=1000)
        mem[8]  = 16'h0108;  // MOV A, #42  (word 1)
        mem[9]  = 16'h002A;  // 42 (word 2)
        // MOV B, A     (regular: X=B, Y=A, Z=0000)  -> B = 42
        mem[10] = 16'h0210;  // MOV B, A
        // MOV C, #7    (2-word: X=C=011, Z=1000)
        mem[11] = 16'h0308;  // MOV C, #7   (word 1)
        mem[12] = 16'h0007;  // 7 (word 2)
        // ADD D, B, C  -> D = 42 + 7 = 49
        mem[13] = 16'h1423;  // ADD D, B, C
        // MOV E, D     (regular: X=E, Y=D, Z=0000)  -> E = 49
        mem[14] = 16'h0540;  // MOV E, D    (X=101=E, Y=100=D, Z=0000)
        mem[15] = 16'h8101;  // OUT A      -> 42
        mem[16] = 16'h8201;  // OUT B      -> 42
        mem[17] = 16'h8301;  // OUT C     -> 7
        mem[18] = 16'h8501;  // OUT E     -> 49 (final)
        mem[19] = 16'hF501;  // STOP, print E
        for (i = 20; i < 64; i = i + 1)
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

    // No IN instructions in this test — sw_in unused but must be driven
    always @(*) begin
        sw_in = 16'd0;
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
        if (cpu_out === 16'd49)
            $display("[PASS] Both MOV variants + ADD: cpu_out = 49 (A=42, B=42, C=7, D=E=49).");
        else
            $display("[FAIL] cpu_out = %0d (expected 49 after OUT E).", cpu_out);
        $display("PC = %0d, SP = %0d", pc, sp);
        $finish;
    end
endmodule
