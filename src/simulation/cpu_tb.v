// CPU testbench: comprehensive MOV + BEQ test
// Covers: MOV immediate, MOV register, BEQ taken/not-taken for all 4 operand combos
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

        // GPR: A=1, B=2, C=3, D=4, E=5.  PC starts at 8.
        // All registers start at 0.
        mem[0] = 16'h0000;
        mem[1] = 16'h0000; mem[2] = 16'h0000; mem[3] = 16'h0000;
        mem[4] = 16'h0000; mem[5] = 16'h0000;
        mem[6] = 16'h0000; mem[7] = 16'h0000;

        // =============================================================
        // Test 1: MOV immediate — MOV A, #0x1234
        // =============================================================
        mem[8]  = 16'h0108;   // MOV A, #imm  (opcode=0000, X=1, Z=1000)
        mem[9]  = 16'h1234;   // immediate value 0x1234
        mem[10] = 16'h8101;   // OUT A  -> expect 0x1234

        // =============================================================
        // Test 2: MOV register — MOV B, A  (copy A into B)
        // =============================================================
        mem[11] = 16'h0210;   // MOV B, A  (opcode=0000, X=2, Y=1, Z=0000)
        mem[12] = 16'h8201;   // OUT B  -> expect 0x1234

        // =============================================================
        // Test 3: BEQ taken — A(0x1234) == B(0x1234), branch to 17
        // =============================================================
        mem[13] = 16'h5128;   // BEQ X=1(A), Y=2(B), Z=1000
        mem[14] = 16'd17;     // jump target = 17
        // --- FAIL path (BEQ should have branched) ---
        mem[15] = 16'h8501;   // OUT E (E=0 -> failure indicator)
        mem[16] = 16'hF000;   // STOP

        // =============================================================
        // Test 4: MOV immediate #2 — MOV A, #0x5678
        //         (branch target from test 3)
        // =============================================================
        mem[17] = 16'h0108;   // MOV A, #0x5678
        mem[18] = 16'h5678;
        mem[19] = 16'h8101;   // OUT A  -> expect 0x5678

        // =============================================================
        // Test 5: BEQ not taken — A(0x5678) != B(0x1234), fall through
        // =============================================================
        mem[20] = 16'h5128;   // BEQ X=1(A), Y=2(B), Z=1000
        mem[21] = 16'd50;     // wrong-branch target (fail zone at 50)
        // --- PASS: fall-through ---
        mem[22] = 16'h8201;   // OUT B  -> expect 0x1234

        // =============================================================
        // Test 6: BEQ X=0, Y=C(=0) — compare 0 with C, should branch
        //         (C is still 0, so 0==0 -> branch)
        // =============================================================
        mem[23] = 16'h5038;   // BEQ X=0, Y=3(C), Z=1000
        mem[24] = 16'd27;     // jump target = 27
        // --- FAIL path ---
        mem[25] = 16'h8301;   // OUT C (C=0 -> failure indicator)
        mem[26] = 16'hF000;   // STOP

        // =============================================================
        // Test 7: BEQ X=0, Y=A(=0x5678) — compare 0 with A, NOT branch
        //         (branch target from test 6)
        // =============================================================
        mem[27] = 16'h5018;   // BEQ X=0, Y=1(A), Z=1000
        mem[28] = 16'd54;     // wrong-branch target (fail zone at 54)
        // --- PASS: fall-through ---
        mem[29] = 16'h8101;   // OUT A  -> expect 0x5678

        // =============================================================
        // Test 8: BEQ X=A(=0x5678), Y=0 — compare A with 0, NOT branch
        // =============================================================
        mem[30] = 16'h5108;   // BEQ X=1(A), Y=0, Z=1000
        mem[31] = 16'd58;     // wrong-branch target (fail zone at 58)
        // --- PASS: fall-through ---
        mem[32] = 16'h8101;   // OUT A  -> expect 0x5678

        // =============================================================
        // Test 9: BEQ X=0, Y=0 — always jump (0==0)
        // =============================================================
        mem[33] = 16'h5008;   // BEQ X=0, Y=0, Z=1000
        mem[34] = 16'd37;     // jump target = 37
        // --- FAIL path ---
        mem[35] = 16'h8401;   // OUT D (D=0 -> failure indicator)
        mem[36] = 16'hF000;   // STOP

        // =============================================================
        // ALL TESTS PASSED — MOV D, #0xBEEF and output it
        //         (branch target from test 9)
        // =============================================================
        mem[37] = 16'h0408;   // MOV D, #0xBEEF
        mem[38] = 16'hBEEF;
        mem[39] = 16'h8401;   // OUT D  -> 0xBEEF = SUCCESS
        mem[40] = 16'hF000;   // STOP

        // =============================================================
        // Wrong-branch failure zones (landed here = a "not taken" BEQ
        // incorrectly branched)
        // =============================================================
        // Test 5 wrong branch:
        mem[50] = 16'h0508;   // MOV E, #0xF005
        mem[51] = 16'hF005;
        mem[52] = 16'h8501;   // OUT E -> 0xF005
        mem[53] = 16'hF000;   // STOP

        // Test 7 wrong branch:
        mem[54] = 16'h0508;   // MOV E, #0xF007
        mem[55] = 16'hF007;
        mem[56] = 16'h8501;   // OUT E -> 0xF007
        mem[57] = 16'hF000;   // STOP

        // Test 8 wrong branch:
        mem[58] = 16'h0508;   // MOV E, #0xF008
        mem[59] = 16'hF008;
        mem[60] = 16'h8501;   // OUT E -> 0xF008
        mem[61] = 16'hF000;   // STOP
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
    parameter SIM_CYCLES  = 1000;

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
            $display("[trace] PC=%0d SP=%0d out=%0d (0x%04H)", pc, sp, cpu_out, cpu_out);

    initial begin
        rst_n = 0;
        #(2*CLK_PERIOD);
        rst_n = 1;
        #(SIM_CYCLES * CLK_PERIOD);

        $display("");
        $display("========== RESULT ==========");
        if (cpu_out === 16'hBEEF)
            $display("[PASS] All MOV+BEQ tests passed! cpu_out = 0x%04H", cpu_out);
        else if (cpu_out === 16'h0000)
            $display("[FAIL] A 'should-branch' BEQ did not branch (cpu_out = 0). Check trace for which test.");
        else if (cpu_out === 16'hF005)
            $display("[FAIL] Test 5: BEQ(not-taken) wrongly branched. A(0x5678) != B(0x1234).");
        else if (cpu_out === 16'hF007)
            $display("[FAIL] Test 7: BEQ(X=0,Y=A) wrongly branched. 0 != A(0x5678).");
        else if (cpu_out === 16'hF008)
            $display("[FAIL] Test 8: BEQ(X=A,Y=0) wrongly branched. A(0x5678) != 0.");
        else
            $display("[FAIL] Unexpected cpu_out = %0d (0x%04H).", cpu_out, cpu_out);
        $display("PC = %0d, SP = %0d", pc, sp);
        $display("============================");
        $finish;
    end
endmodule
