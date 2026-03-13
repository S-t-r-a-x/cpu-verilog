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

reg ld_mdr;
reg [DATA_WIDTH-1:0] in_mdr;
wire [DATA_WIDTH-1:0] out_mdr; 
register #(.DATA_WIDTH(DATA_WIDTH)) mdr (
    .clk(clk),
    .rst_n(rst_n),
    .cl(1'b0),
    .ld(ld_mdr),
    .inc(1'b0),
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

reg ld_x_addr, cl_x_addr;
reg [ADDR_WIDTH-1:0] in_x_addr;
wire [ADDR_WIDTH-1:0] out_x_addr; 
register #(.DATA_WIDTH(ADDR_WIDTH)) X_addr_reg (
    .clk(clk),
    .rst_n(rst_n),
    .ld(ld_x_addr),
    .cl(cl_x_addr),
    .in(in_x_addr),
    .inc(1'b0),
    .dec(1'b0),
    .sr(1'b0),
    .ir(1'b0),
    .sl(1'b0),
    .il(1'b0),
    .out(out_x_addr)
);

reg ld_y_addr, cl_y_addr;
reg [ADDR_WIDTH-1:0] in_y_addr;
wire [ADDR_WIDTH-1:0] out_y_addr; 
register #(.DATA_WIDTH(ADDR_WIDTH)) Y_addr_reg (
    .clk(clk),
    .rst_n(rst_n),
    .ld(ld_y_addr),
    .cl(cl_y_addr),
    .in(in_y_addr),
    .inc(1'b0),
    .dec(1'b0),
    .sr(1'b0),
    .ir(1'b0),
    .sl(1'b0),
    .il(1'b0),
    .out(out_y_addr)
);

reg ld_z_addr, cl_z_addr;
reg [ADDR_WIDTH-1:0] in_z_addr;
wire [ADDR_WIDTH-1:0] out_z_addr; 
register #(.DATA_WIDTH(ADDR_WIDTH)) Z_addr_reg (
    .clk(clk),
    .rst_n(rst_n),
    .ld(ld_z_addr),
    .cl(cl_z_addr),
    .in(in_z_addr),
    .inc(1'b0),
    .dec(1'b0),
    .sr(1'b0),
    .ir(1'b0),
    .sl(1'b0),
    .il(1'b0),
    .out(out_z_addr)
);

reg ld_x, cl_x;
reg [DATA_WIDTH-1:0] in_x;
wire [DATA_WIDTH-1:0] out_x; 
register #(.DATA_WIDTH(DATA_WIDTH)) X_reg (
    .clk(clk),
    .rst_n(rst_n),
    .ld(ld_x),
    .cl(cl_x),
    .in(in_x),
    .inc(1'b0),
    .dec(1'b0),
    .sr(1'b0),
    .ir(1'b0),
    .sl(1'b0),
    .il(1'b0),
    .out(out_x)
);

reg ld_y, cl_y;
reg [DATA_WIDTH-1:0] in_y;
wire [DATA_WIDTH-1:0] out_y; 
register #(.DATA_WIDTH(DATA_WIDTH)) Y_reg (
    .clk(clk),
    .rst_n(rst_n),
    .ld(ld_y),
    .cl(cl_y),
    .in(in_y),
    .inc(1'b0),
    .dec(1'b0),
    .sr(1'b0),
    .ir(1'b0),
    .sl(1'b0),
    .il(1'b0),
    .out(out_y)
);


reg ld_z, cl_z;
reg [DATA_WIDTH-1:0] in_z;
wire [DATA_WIDTH-1:0] out_z; 
register #(.DATA_WIDTH(DATA_WIDTH)) Z_reg (
    .clk(clk),
    .rst_n(rst_n),
    .ld(ld_z),
    .cl(cl_z),
    .in(in_z),
    .inc(1'b0),
    .dec(1'b0),
    .sr(1'b0),
    .ir(1'b0),
    .sl(1'b0),
    .il(1'b0),
    .out(out_z)
);

// ALU INSTANTIATION
reg [2:0] alu_oc;

wire [DATA_WIDTH-1:0] alu_out;
alu #(.DATA_WIDTH(DATA_WIDTH)) alu_unit (
    .oc(alu_oc),
    .a(out_y),
    .b(out_z),
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
localparam FETCH_CONST1 = 5'b01111;
localparam FETCH_CONST2 = 5'b10000;
localparam HALT = 5'b11111;

// OPCODES
localparam MOV = 4'b0000;
localparam ADD = 4'b0001;
localparam SUB = 4'b0010;
localparam MUL = 4'b0011;
localparam DIV = 4'b0100;
localparam BEQ = 4'b0101;   // branch if Y == Z to address in X
localparam ADDC = 4'b0110;  // mem[X] = Y + constant (2-word instruction)
localparam IN = 4'b0111;
localparam OUT = 4'b1000;
localparam STOP = 4'b1111;

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
    end
    else begin 
        state_reg <= state_next;
        out_reg <= out_next;
    end
end

// ========================================================
// 2. NEXT STATE & CONTROL LOGIC (Combinational)
// ========================================================
always @(*) begin
    // Default assignments to prevent latches and reset control wires!
    state_next = state_reg;
    out_next = out_reg;
    we = 1'b0;
    addr = {ADDR_WIDTH{1'b0}};
    data = {DATA_WIDTH{1'b0}};
    alu_oc = 3'b000;

    // Default all register controls to 0
    ld_pc = 1'b0; inc_pc = 1'b0; in_pc = {ADDR_WIDTH{1'b0}};
    ld_sp = 1'b0; inc_sp = 1'b0; dec_sp = 1'b0; in_sp = {ADDR_WIDTH{1'b0}};
    ld_ir = 1'b0; in_ir = 32'b0;
    ld_mar = 1'b0; inc_mar = 1'b0; in_mar = {ADDR_WIDTH{1'b0}};
    ld_mdr = 1'b0; in_mdr = {DATA_WIDTH{1'b0}};
    ld_acc = 1'b0; in_acc = {DATA_WIDTH{1'b0}};
    ld_x = 1'b0; cl_x = 1'b0; in_x = {DATA_WIDTH{1'b0}};
    ld_y = 1'b0; cl_y = 1'b0; in_y = {DATA_WIDTH{1'b0}};
    ld_z = 1'b0; cl_z = 1'b0; in_z = {DATA_WIDTH{1'b0}};
    ld_x_addr = 1'b0; cl_x_addr = 1'b0; in_x_addr = {ADDR_WIDTH{1'b0}};
    ld_y_addr = 1'b0; cl_y_addr = 1'b0; in_y_addr = {ADDR_WIDTH{1'b0}};
    ld_z_addr = 1'b0; cl_z_addr = 1'b0; in_z_addr = {ADDR_WIDTH{1'b0}};

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
            
            // 3. Move to DECODE to actually look at what we fetched
            state_next = DECODE;
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
                in_x_addr = out_ir[10:8];
                ld_x_addr = 1'b1;
                in_x = mem;
                ld_x = 1'b1;
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
            in_x_addr = out_mar;
            ld_x_addr = 1'b1;
            we = 1'b0;
            state_next = DECODE_X_INDIRECT_2;
        end

        DECODE_X_INDIRECT_2: begin
            // Get the value of X from memory
            in_x = mem;
            ld_x = 1'b1;
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
                in_y_addr = out_ir[6:4];
                ld_y_addr = 1'b1;
                in_y = mem;
                ld_y = 1'b1;
                /* // CHECK IF INSTRUCTION ONLY NEEDS X AND Y, OR WE NEED TO DECODE Z too
                if (out_ir[15:12] == MOV) begin
                    state_next = EXECUTE;
                end
                else begin
                    // HAVE TO DECODE Z, GO INTO MEM FOR Z
                    addr = {3'b000, out_ir[2:0]};
                    we = 1'b0;
                    state_next = DECODE_Z;
                end */
                if (out_ir[15:12] == ADDC) begin
                    addr = pc;
                    we = 1'b0;
                    state_next = FETCH_CONST1;
                end
                else begin
                    addr = {3'b000, out_ir[2:0]};
                    we = 1'b0;
                    state_next = DECODE_Z;
                end
            end
        end

        DECODE_Y_INDIRECT_1: begin
            addr = out_mar;
            // Remember the address
            in_y_addr = out_mar;
            ld_y_addr = 1'b1;
            we = 1'b0;
            state_next = DECODE_Y_INDIRECT_2;
        end

        DECODE_Y_INDIRECT_2: begin
            // Get the value of Y from memory
            in_y = mem;
            ld_y = 1'b1;
            we = 1'b0;
            // CHECK IF INSTRUCTION ONLY NEEDS X AND Y, OR WE NEED TO DECODE Z TOO
            /* if (out_ir[15:12] == MOV) begin
                state_next = EXECUTE;
            end
            else begin
                // HAVE TO DECODE Z, GO INTO MEM FOR Z
                addr = {3'b000, out_ir[2:0]};
                we = 1'b0;
                state_next = DECODE_Z;
            end */
            if (out_ir[15:12] == ADDC) begin
                addr = pc;
                we = 1'b0;
                state_next = FETCH_CONST1;
            end
            else begin
                addr = {3'b000, out_ir[2:0]};
                we = 1'b0;
                state_next = DECODE_Z;
            end
        end

        // ======================== DECODE Z ===========================

        DECODE_Z: begin
            // Indirect BIT - out_ir[7]
            if(out_ir[3]) begin
                // Indirect mode, go to reg for Y_addr, and place into mar
                in_mar = mem[ADDR_WIDTH-1:0];
                ld_mar = 1'b1;
                state_next = DECODE_Z_INDIRECT_1;
            end
            else begin
                // Direct mode
                in_z_addr = out_ir[2:0];
                ld_z_addr = 1'b1;
                in_z = mem;
                ld_z = 1'b1;
                state_next = EXECUTE;
            end
        end

        DECODE_Z_INDIRECT_1: begin
            addr = out_mar;
            // Remember the address
            in_z_addr = out_mar;
            ld_z_addr = 1'b1;
            we = 1'b0;
            state_next = DECODE_Z_INDIRECT_2;
        end

        DECODE_Z_INDIRECT_2: begin
            // Get the value of Z from memory
            in_z = mem;
            ld_z = 1'b1;
            we = 1'b0;
            state_next = EXECUTE;
        end

        // ======================== FETCH CONSTANT (2-word instructions) ===
        
        FETCH_CONST1: begin
            addr = pc;
            we = 1'b0;
            state_next = FETCH_CONST2;
        end

        FETCH_CONST2: begin
            in_z = mem;
            ld_z = 1'b1;
            inc_pc = 1'b1;
            state_next = EXECUTE;
        end

        // ======================== EXECUTE ===========================

        EXECUTE: begin
            // Logic to perform the operation goes here
            case (out_ir[15:12])
                MOV: begin
                    if(out_z == 0) begin
                        addr = out_x_addr;
                        we = 1'b1;
                        data = out_y;
                    end
                    state_next = FETCH1;
                end
                ADD, SUB, MUL, DIV: begin
                    // DEDUCT 1 FROM OPCODE TO GET ALU OPERATION
                    alu_oc = out_ir[14:12] - 3'b001;
                    addr = out_x_addr;
                    data = alu_out;
                    we = 1'b1;
                    state_next = FETCH1;
                end
                BEQ: begin
                    if (out_y == out_z) begin
                        in_pc = out_x[ADDR_WIDTH-1:0];
                        ld_pc = 1'b1;
                    end
                    state_next = FETCH1;
                end
                ADDC: begin
                    alu_oc = ALU_ADD;
                    addr = out_x_addr;
                    data = alu_out;
                    we = 1'b1;
                    state_next = FETCH1;
                end
                IN: begin
                    addr = out_x_addr;
                    we = 1'b1;
                    data = in;
                    state_next = FETCH1;
                end
                OUT: begin
                    out_next = out_x;
                    state_next = FETCH1;
                end
                STOP: begin
                    if(out_ir[11:8] != 0) begin
                        out_next = out_x;
                    end
                    else if (out_ir[7:4] != 0) begin
                        out_next = out_y;
                    end
                    else if (out_ir[3:0] != 0) begin
                        out_next = out_z;
                    end
                    state_next = HALT;
                end
            endcase
        end

    endcase
end

endmodule