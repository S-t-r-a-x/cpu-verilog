//`include "src\synthesis\modules\memory.v"
module top #(
    parameter DIVISOR = 50_000_000,
    parameter FILE_NAME = "mem_init.mif",
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
)(
    input wire clk,
    input wire rst_n,
    input wire [2:0]btn,
    input wire [8:0]sw,
    output wire [9:0]led,
    output wire [27:0]hex
);

    wire slow_clk;
    clk_div #(.DIVISOR(DIVISOR)) u_div (
        .clk(clk),
        .rst_n(rst_n),
        .out(slow_clk)
    );

    wire cpu_we;
    wire [ADDR_WIDTH-1:0] cpu_addr;
    wire [DATA_WIDTH-1:0] cpu_data;
    wire [DATA_WIDTH-1:0] cpu_out;
    wire [DATA_WIDTH-1:0] mem_out;
    wire [ADDR_WIDTH-1:0] pc;
    wire [ADDR_WIDTH-1:0] sp;

    // --- BUTTONS: DEBOUNCER + RED (for presses) ---
    wire [2:0] btn_db, btn_clean;
    debouncer u_btn_db0 (.clk(clk), .rst_n(rst_n), .in(btn[0]), .out(btn_db[0]));
    debouncer u_btn_db1 (.clk(clk), .rst_n(rst_n), .in(btn[1]), .out(btn_db[1]));
    debouncer u_btn_db2 (.clk(clk), .rst_n(rst_n), .in(btn[2]), .out(btn_db[2]));
    
    red u_red0 (.clk(clk), .rst_n(rst_n), .in(btn_db[0]), .out(btn_clean[0]));
    red u_red1 (.clk(clk), .rst_n(rst_n), .in(btn_db[1]), .out(btn_clean[1]));
    red u_red2 (.clk(clk), .rst_n(rst_n), .in(btn_db[2]), .out(btn_clean[2]));

    // --- SWITCHES: ONLY DEBOUNCER (no RED) ---
    wire [8:0] sw_clean;
    genvar i;
    generate
        for (i=0; i<9; i=i+1) begin : SW_PROC
            debouncer u_db (
                .clk(clk),
                .rst_n(rst_n),
                .in(sw[i]),
                .out(sw_clean[i])  
            );
        end
    endgenerate

    wire [DATA_WIDTH-1:0] cpu_in;
    assign cpu_in = {{(DATA_WIDTH-4){1'b0}}, sw_clean[3:0]};  

    // --- MEMORY ---
    memory #(
        .FILE_NAME(FILE_NAME),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_mem (
        .clk(slow_clk),
        .we(cpu_we),
        .rst_n(rst_n),
        .addr(cpu_addr),
        .data(cpu_data),
        .out(mem_out)
    );

    // --- CPU ---
    cpu #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_cpu (
        .clk(slow_clk),
        .rst_n(rst_n),
        .mem(mem_out),
        .in(cpu_in),     
        .we(cpu_we),
        .addr(cpu_addr),
        .data(cpu_data),
        .out(cpu_out),
        .pc(pc),
        .sp(sp)
    );

    // --- LEDS ---
    assign led[9:0] = {{5{1'b0}}, cpu_out[4:0]};

    // --- BCD + SSD for PC and SP ---
    wire [3:0] pc_ones, pc_tens, sp_ones, sp_tens;
    bcd u_bcd_pc (.in(pc), .ones(pc_ones), .tens(pc_tens));
    bcd u_bcd_sp (.in(sp), .ones(sp_ones), .tens(sp_tens));

    wire [6:0] pc_ones_ssd, pc_tens_ssd, sp_ones_ssd, sp_tens_ssd;
    ssd u_ssd_pc_ones (.in(pc_ones), .out(pc_ones_ssd));
    ssd u_ssd_pc_tens (.in(pc_tens), .out(pc_tens_ssd));
    ssd u_ssd_sp_ones (.in(sp_ones), .out(sp_ones_ssd));
    ssd u_ssd_sp_tens (.in(sp_tens), .out(sp_tens_ssd));

    assign hex = {
        sp_tens_ssd,
        sp_ones_ssd,
        pc_tens_ssd,
        pc_ones_ssd
    };

endmodule