module cpu #(
    parameter DATA_WIDTH = 16,
    parameter ADDR_WIDTH = 6
) (
    input clk,
    input rst_n,
    input[DATA_WIDTH-1:0] mem,
    input[DATA_WIDTH-1:0] in,
    output reg we,
    output reg[ADDR_WIDTH-1:0] addr,
    output reg[DATA_WIDTH-1:0] data,
    output wire[DATA_WIDTH-1:0] out,
    output wire[ADDR_WIDTH-1:0] pc,
    output wire[ADDR_WIDTH-1:0] sp
);

// REGISTER INSTANTIATION
reg ld_pc, inc_pc;
reg [ADDR_WIDTH-1:0] in_pc;
wire [ADDR_WIDTH-1:0] out_pc; 
assign pc = out_pc;
register #(.DATA_WIDTH(ADDR_WIDTH)) pc_reg (
    .clk(clk),
    .rst_n(rst_n),
    .cl(1'b0),
    .ld(ld_pc),
    .inc(inc_pc),
    .dec(1'b0),
    .sr(1'b0),
    .ir(1'b0),
    .sl(1'b0),
    .il(1'b0),
    .in(in_pc),
    .out(out_pc)
);

reg ld_sp, inc_sp, dec_sp;
reg [ADDR_WIDTH-1:0] in_sp;
wire [ADDR_WIDTH-1:0] out_sp; 
assign sp = out_sp;
register #(.DATA_WIDTH(ADDR_WIDTH)) sp_reg (
    .clk(clk),
    .rst_n(rst_n),
    .cl(1'b0),
    .ld(ld_sp),
    .inc(inc_sp),
    .dec(dec_sp),
    .sr(1'b0),
    .ir(1'b0),
    .sl(1'b0),
    .il(1'b0),
    .in(in_sp),
    .out(out_sp)
);

reg ld_ir;
reg [31:0] in_ir;
wire [31:0] out_ir; 
register #(.DATA_WIDTH(32)) ir (
    .clk(clk),
    .rst_n(rst_n),
    .cl(1'b0),
    .ld(ld_ir),
    .inc(1'b0),
    .dec(1'b0),
    .sr(1'b0),
    .ir(1'b0),
    .sl(1'b0),
    .il(1'b0),
    .in(in_ir),
    .out(out_ir)
);

reg ld_mar, inc_mar;
reg [ADDR_WIDTH-1:0] in_mar;
wire [ADDR_WIDTH-1:0] out_mar; 
register #(.DATA_WIDTH(ADDR_WIDTH)) mar (
    .clk(clk),
    .rst_n(rst_n),
    .cl(1'b0),
    .ld(ld_mar),
    .inc(inc_mar),
    .dec(1'b0),
    .sr(1'b0),
    .ir(1'b0),
    .sl(1'b0),
    .il(1'b0),
    .in(in_mar),
    .out(out_mar)
);

reg ld_mdr, inc_mdr;
reg [DATA_WIDTH-1:0] in_mdr;
wire [DATA_WIDTH-1:0] out_mdr; 
register #(.DATA_WIDTH(DATA_WIDTH)) mdr (
    .clk(clk),
    .rst_n(rst_n),
    .cl(1'b0),
    .ld(ld_mdr),
    .inc(inc_mdr),
    .dec(1'b0),
    .sr(1'b0),
    .ir(1'b0),
    .sl(1'b0),
    .il(1'b0),
    .in(in_mdr),
    .out(out_mdr)
);

reg ld_acc;
reg [DATA_WIDTH-1:0] in_acc;
wire [DATA_WIDTH-1:0] out_acc; 
register #(.DATA_WIDTH(DATA_WIDTH)) acc (
    .clk(clk),
    .rst_n(rst_n),
    .cl(1'b0),
    .ld(ld_acc),
    .in(in_acc),
    .inc(1'b0),
    .dec(1'b0),
    .sr(1'b0),
    .ir(1'b0),
    .sl(1'b0),
    .il(1'b0),
    .out(out_acc)
);

// X, Y, Z value and address stores
reg [DATA_WIDTH-1:0] x_reg, y_reg, z_reg, x_next, y_next, z_next;
reg [ADDR_WIDTH-1:0] xAddr_reg, yAddr_reg, zAddr_reg, xAddr_next, yAddr_next, zAddr_next;

// ALU INSTANTIATION
reg [2:0] alu_oc;

wire [DATA_WIDTH-1:0] alu_out;
alu #(.DATA_WIDTH(DATA_WIDTH)) alu_unit (
    .oc(alu_oc),
    .a(y_reg),
    .b(z_reg),
    .f(alu_out)
);

// OPERAND REGISTERS
// Usually will only use X_addr, but Y and Z are here just in case, can remove later if no use, might even be able to use MAR instead, or MDR


// PROCESSOR PHASES
localparam INIT = 5'b00000;
localparam FETCH1 = 5'b00001;
localparam FETCH2 = 5'b00010;
localparam DECODE = 5'b00100;
localparam DECODE_X = 5'b00101;
localparam DECODE_X_INDIRECT_1 = 5'b00110;
localparam DECODE_X_INDIRECT_2 = 5'b00111;
localparam DECODE_Y = 5'b01000;
localparam DECODE_Y_INDIRECT_1 = 5'b01001;
localparam DECODE_Y_INDIRECT_2 = 5'b01010;
localparam DECODE_Z = 5'b01011;
localparam DECODE_Z_INDIRECT_1 = 5'b01100;
localparam DECODE_Z_INDIRECT_2 = 5'b01101;
localparam EXECUTE = 5'b01110;
// 2 WORD FETCHES
localparam FETCH3 = 5'b01111;
localparam FETCH4 = 5'b10000;

// JSR RTS STATES
localparam JSR_JMP = 5'b10001;
localparam RTS_RET = 5'b10010;

// MOV ARRAY STATES
localparam MOV_ARRAY_GET_Y = 5'b10011;
localparam MOV_ARRAY_SET_X = 5'b10100;

localparam STOP_Y = 5'b11101;
localparam STOP_Z = 5'b11110;
localparam HALT = 5'b11111;

// OPCODES
localparam MOV = 4'b0000;
localparam ADD = 4'b0001;
localparam SUB = 4'b0010;
localparam MUL = 4'b0011;
localparam DIV = 4'b0100;
localparam IN = 4'b0111;
localparam OUT = 4'b1000;
localparam STOP = 4'b1111;
// TEMPLATE ZA MOD
localparam JSR = 4'b1101;
localparam RTS = 4'b1110;

// ALU OPERATIONS
localparam ALU_ADD = 3'b000;
localparam ALU_SUB = 3'b001;
localparam ALU_MUL = 3'b010;
localparam ALU_DIV = 3'b011;


// 2-bit state registers
reg [4:0] state_reg, state_next;

// out register to keep light on
reg [DATA_WIDTH-1:0] out_reg, out_next;
assign out = out_reg;

// ========================================================
// 1. STATE MEMORY (Sequential - Only updates the state)
// ========================================================
always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        state_reg <= INIT;
        out_reg <= {DATA_WIDTH{1'b0}};
        x_reg <= 16'h0000; 
        y_reg <= 16'h0000; 
        z_reg <= 16'h0000; 
        xAddr_reg <= 6'b000000;
        yAddr_reg <= 6'b000000;
        zAddr_reg <= 6'b000000;
    end
    else begin 
        state_reg <= state_next;
        out_reg <= out_next;
        x_reg <= x_next; 
        y_reg <= y_next; 
        z_reg <= z_next; 
        xAddr_reg <= xAddr_next;
        yAddr_reg <= yAddr_next;
        zAddr_reg <= zAddr_next;
    end
end

// ========================================================
// 2. NEXT STATE & CONTROL LOGIC (Combinational)
// ========================================================
always @(*) begin
    // Default assignments to prevent latches and reset control wires!
    state_next = state_reg;
    out_next = out_reg;
    x_next = x_reg;
    y_next = y_reg;
    z_next = z_reg;
    xAddr_next = xAddr_reg;
    yAddr_next = yAddr_reg;
    zAddr_next = zAddr_reg;
    we = 1'b0;
    addr = {ADDR_WIDTH{1'b0}};
    data = {DATA_WIDTH{1'b0}};
    alu_oc = 3'b000;

    // Default all register controls to 0
    ld_pc = 1'b0; inc_pc = 1'b0; in_pc = {ADDR_WIDTH{1'b0}};
    ld_sp = 1'b0; inc_sp = 1'b0; dec_sp = 1'b0; in_sp = {ADDR_WIDTH{1'b0}};
    ld_ir = 1'b0; in_ir = 32'b0;
    ld_mar = 1'b0; inc_mar = 1'b0; in_mar = {ADDR_WIDTH{1'b0}};
    ld_mdr = 1'b0; inc_mdr = 1'b0; in_mdr = {DATA_WIDTH{1'b0}};
    ld_acc = 1'b0; in_acc = {DATA_WIDTH{1'b0}};

    case (state_reg)
        HALT: begin
            state_next = HALT;
        end
        INIT: begin
            // Setup Program Counter (starts at 8)
            in_pc = 6'd8;
            ld_pc = 1'b1;
            
            // Setup Stack Pointer (starts at last location: 63)
            in_sp = 6'd63; 
            ld_sp = 1'b1;
    
            state_next = FETCH1;
        end
        
        FETCH1: begin
            // 1. Put PC on the memory address bus
            we = 1'b0;
            addr = pc; 

            state_next = FETCH2;
        end
        
        FETCH2: begin
            // 1. The memory has NOW output the correct instruction on 'mem'
            // Route 'mem' into the 32-bit Instruction Register
            in_ir = {16'b0, mem}; 
            ld_ir = 1'b1;
            
            // 2. Increment PC so it points to the next instruction
            inc_pc = 1'b1; 
            
            // ir isnt loaded in this cycle, so we have to check from mem
            if(mem[15:12] == JSR) begin
                // MOV OF array
                state_next = FETCH3;
            end
            else if (mem[15:12] == RTS) begin
                state_next = EXECUTE;
            end
            else begin
                // 3. Move to DECODE to actually look at what we fetched
                state_next = DECODE;
            end
        end

        FETCH3: begin
            // 1. Put PC on the memory address bus
            we = 1'b0;
            addr = pc; 
            state_next = FETCH4;
        end
        
        FETCH4: begin
            // 1. The memory has NOW output the correct instruction on 'mem'
            // Route 'mem' into the 32-bit Instruction Register
            in_ir = {mem, out_ir[15:0]}; 
            ld_ir = 1'b1;
            
            // 2. Increment PC so it points to the next instruction
            inc_pc = 1'b1; 
            
            // 3. Move to DECODE to actually look at what we fetched
            if(out_ir[15:12] == JSR) begin
                state_next = EXECUTE;
            end
            else begin
                state_next = DECODE;
            end
        end

        DECODE: begin
            // Logic to decode IR goes here
            // GO TO MEM FOR X VALUE
            we = 1'b0;
            addr = {3'b000, out_ir[10:8]};
            state_next = DECODE_X;
        end
        
        DECODE_X: begin
            // Indirect BIT - out_ir[11]
            if(out_ir[11]) begin
                // Indirect mode, go to reg for X_addr, and place into mar
                in_mar = mem[ADDR_WIDTH-1:0];
                ld_mar = 1'b1;
                state_next = DECODE_X_INDIRECT_1;
            end
            else begin
                // Direct mode
                xAddr_next = {3'b000, out_ir[10:8]};
                x_next = mem;
                // CHECK IF INSTRUCTION ONLY REQUIRES X, OR WE NEED TO DECODE Y (AND Z)
                if (out_ir[15:12] == IN || out_ir[15:12] == OUT) begin
                    state_next = EXECUTE;
                end
                else begin
                    // HAVE TO DECODE Y, GO INTO MEM FOR Y
                    addr = {3'b000, out_ir[6:4]};
                    we = 1'b0;
                    state_next = DECODE_Y;
                end
            end
        end

        DECODE_X_INDIRECT_1: begin
            addr = out_mar;
            // Remember the address
            xAddr_next = out_mar;
            we = 1'b0;
            state_next = DECODE_X_INDIRECT_2;
        end

        DECODE_X_INDIRECT_2: begin
            // Get the value of X from memory
            x_next = mem;
            we = 1'b0;
            // CHECK IF INSTRUCTION ONLY REQUIRES X, OR WE NEED TO DECODE Y (AND Z)
            if (out_ir[15:12] == IN || out_ir[15:12] == OUT) begin
                state_next = EXECUTE;
            end
            else begin
                // HAVE TO DECODE Y, GO INTO MEM FOR Y
                addr = {3'b000, out_ir[6:4]};
                we = 1'b0;
                state_next = DECODE_Y;
            end
        end

        // ======================== DECODE Y ===========================
        
        DECODE_Y: begin
            // Indirect BIT - out_ir[7]
            if(out_ir[7]) begin
                // Indirect mode, go to reg for Y_addr, and place into mar
                in_mar = mem[ADDR_WIDTH-1:0];
                ld_mar = 1'b1;
                state_next = DECODE_Y_INDIRECT_1;
            end
            else begin
                // Direct mode
                yAddr_next = {3'b000, out_ir[6:4]};
                y_next = mem;
                // CHECK IF INSTRUCTION ONLY NEEDS X AND Y, OR WE NEED TO DECODE Z too
                if (out_ir[15:12] == MOV) begin
                    state_next = EXECUTE;
                end
                else begin
                    // HAVE TO DECODE Z, GO INTO MEM FOR Z
                    addr = {3'b000, out_ir[2:0]};
                    we = 1'b0;
                    state_next = DECODE_Z;
                end
            end
        end

        DECODE_Y_INDIRECT_1: begin
            addr = out_mar;
            // Remember the address
            yAddr_next = out_mar;
            we = 1'b0;
            state_next = DECODE_Y_INDIRECT_2;
        end

        DECODE_Y_INDIRECT_2: begin
            // Get the value of Y from memory
            y_next = mem;
            we = 1'b0;
            // CHECK IF INSTRUCTION ONLY NEEDS X AND Y, OR WE NEED TO DECODE Z TOO
            if (out_ir[15:12] == MOV) begin
                state_next = EXECUTE;
            end
            else begin
                // HAVE TO DECODE Z, GO INTO MEM FOR Z
                addr = {3'b000, out_ir[2:0]};
                we = 1'b0;
                state_next = DECODE_Z;
            end
        end

        // ======================== DECODE Z ===========================

        DECODE_Z: begin
            // Indirect BIT - out_ir[3]
            if(out_ir[3]) begin
                // Indirect mode, go to reg for Y_addr, and place into mar
                in_mar = mem[ADDR_WIDTH-1:0];
                ld_mar = 1'b1;
                state_next = DECODE_Z_INDIRECT_1;
            end
            else begin
                // Direct mode
                zAddr_next = {3'b000, out_ir[2:0]};
                z_next = mem;
                state_next = EXECUTE;
            end
        end

        DECODE_Z_INDIRECT_1: begin
            addr = out_mar;
            // Remember the address
            zAddr_next = out_mar;
            we = 1'b0;
            state_next = DECODE_Z_INDIRECT_2;
        end

        DECODE_Z_INDIRECT_2: begin
            // Get the value of Z from memory
            z_next = mem;
            we = 1'b0;
            state_next = EXECUTE;
        end

        // ======================== EXECUTE ===========================

        EXECUTE: begin
            // Logic to perform the operation goes here
            case (out_ir[15:12])
                MOV: begin
                    if(out_ir[3:0] == 4'b0000) begin
                        addr = xAddr_reg;
                        we = 1'b1;
                        data = y_reg;
                        state_next = FETCH1;
                    end
                    else if (out_ir[3] == 1'b0 && out_ir[2:0] != 3'b000) begin
                        // USE MDR AS COUNTER - prepare it
                        in_mdr = 16'b0;
                        ld_mdr = 1'b1;
                        // set memory address to the first yAddr
                        state_next = MOV_ARRAY_GET_Y;
                    end
                    else begin
                        state_next = FETCH1;
                    end
                end
                ADD, SUB, MUL, DIV: begin
                    // DEDUCT 1 FROM OPCODE TO GET ALU OPERATION
                    alu_oc = out_ir[14:12] - 3'b001;
                    addr = xAddr_reg;
                    data = alu_out;
                    we = 1'b1;
                    state_next = FETCH1;
                end
                IN: begin
                    addr = xAddr_reg;
                    we = 1'b1;
                    data = in;
                    state_next = FETCH1;
                end
                OUT: begin
                    out_next = x_reg;
                    state_next = FETCH1;
                end
                STOP: begin
                    if(out_ir[11:8] != 0) begin
                        out_next = x_reg;
                        if(out_ir[7:4] != 0) state_next = STOP_Y;
                        else if(out_ir[3:0] != 0) state_next = STOP_Z;
                        else state_next = HALT;
                    end
                    else if (out_ir[7:4] != 0) begin
                        out_next = y_reg;
                        if(out_ir[3:0] != 0) state_next = STOP_Z;
                        else state_next = HALT;
                    end
                    else if (out_ir[3:0] != 0) begin
                        out_next = z_reg;
                        state_next = HALT;
                    end
                    else begin
                        state_next = HALT;
                    end
                end
                JSR: begin
                    // WRITE OLD PC TO MEM
                    addr = out_sp;
                    data = {{(DATA_WIDTH - ADDR_WIDTH){1'b0}}, out_pc};
                    we = 1'b1;
                    // update SP
                    dec_sp = 1'b1;
                    // SET NEW PC FROM 2nd INSTR WORD
                    in_pc = out_ir[21:16];
                    ld_pc = 1'b1;
                    state_next = FETCH1;
                end
                RTS: begin
                    inc_sp = 1'b1;
                    addr = out_sp + 6'b000001;
                    state_next = RTS_RET;
                end
                JSR: begin
                    // WRITE OLD PC TO MEM
                    addr = out_sp;
                    data = {{(DATA_WIDTH - ADDR_WIDTH){1'b0}}, out_pc};
                    we = 1'b1;
                    // update SP
                    dec_sp = 1'b1;
                    // SET NEW PC FROM 2nd INSTR WORD
                    in_pc = out_ir[21:16];
                    ld_pc = 1'b1;
                    state_next = FETCH1;
                end
                RTS: begin
                    inc_sp = 1'b1;
                    addr = out_sp + 6'b000001;
                    state_next = RTS_RET;
                end
                default: begin
                    $display("[%0t] ERROR: Unknown opcode %b at PC=%0d. Halting.", $time, out_ir[15:12], pc);
                    state_next = HALT;
                end
            endcase
        end
        RTS_RET: begin
            in_pc = mem[ADDR_WIDTH-1:0];
            ld_pc = 1'b1;
            state_next = FETCH1;
        end
        MOV_ARRAY_GET_Y: begin
            if (out_mdr[2:0] == out_ir[2:0]) begin
                // LOOP END
                state_next = FETCH1;
            end
            else begin
                addr = yAddr_reg + {3'b000, out_mdr[2:0]};
                state_next = MOV_ARRAY_SET_X;
            end
        end
        MOV_ARRAY_SET_X: begin
            addr = xAddr_reg + {3'b000, out_mdr[2:0]};
            data = mem;
            we = 1'b1;
            inc_mdr = 1'b1;
            state_next = MOV_ARRAY_GET_Y;
        end
        STOP_Y: begin
            out_next = y_reg;
            if(out_ir[3:0] != 0) state_next = STOP_Z;
            else state_next = HALT;
        end
        STOP_Z: begin
            out_next = z_reg;
            state_next = HALT;
        end
        default: begin
            $display("[%0t] ERROR: CPU entered unknown state: %b. Halting.", $time, state_reg);
            state_next = HALT;
        end
    endcase
end

endmodule