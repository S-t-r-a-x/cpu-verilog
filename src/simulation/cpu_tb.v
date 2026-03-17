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
        // Program: Full Instruction Set Test (PC starts at 8)
        mem[0] = 16'h0000; mem[1] = 16'h0000; mem[2] = 16'h0000; mem[3] = 16'h0000;
        mem[4] = 16'h0000; mem[5] = 16'h0000; mem[6] = 16'h0000; mem[7] = 16'h0000;
        
        mem[8]  = 16'h7100;  // IN R1        (R1 = 10 from sw_in)
        mem[9]  = 16'h7200;  // IN R2        (R2 = 5 from sw_in)
        mem[10] = 16'h1312;  // ADD R3,R1,R2 (R3 = 10 + 5 = 15)
        mem[11] = 16'h2432;  // SUB R4,R3,R2 (R4 = 15 - 5 = 10)
        mem[12] = 16'h3542;  // MUL R5,R4,R2 (R5 = 10 * 5 = 50)
        mem[13] = 16'h4652;  // DIV R6,R5,R2 (R6 = 50 / 5 = 10)
        mem[14] = 16'h0760;  // MOV R7,R6    (R7 = 10)
        mem[15] = 16'h8700;  // OUT R7       (Out = 10)
        mem[16] = 16'hF527;  // STOP R5,R2,R7(Out loops 50, then 5, then 10, then halts)
        for (i = 17; i < 64; i = i + 1)
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

    reg control;
    wire status;

    // Pulse control for one cycle when status is high to satisfy the IN handshake
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            control <= 1'b0;
        end else begin
            if (status) begin
                control <= 1'b1;
            end else begin
                control <= 1'b0;
            end
        end
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
        .control(control),
        .status(status),
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
        if (cpu_out === 16'd10)
            $display("[PASS] cpu_out = 10 at end of run. Halt trace should show Output 50, then 5, then 10.");
        else
            $display("[CHECK] cpu_out = %0d (expected 10 if all ops and multi-STOP worked).", cpu_out);
        $display("PC = %0d, SP = %0d", pc, sp);
        $finish;
    end
endmodule
