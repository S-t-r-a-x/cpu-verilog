// ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  == 
// Copyright (c) 2014 by Terasic Technologies Inc.
// ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  == 
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development
//   Kits made by Terasic. Other use of this code, including the selling,
//   duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods. Terasic provides no warranty regarding the use
//   or functionality of this code.
//
// ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  == 
//
//  Terasic Technologies Inc
//  9F., No.176, Sec.2, Gongdao 5th Rd, East Dist, Hsinchu City, 30070. Taiwan
//
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  == 
//   Ver  :| Author            :| Mod. Date :| Changes Made:
//   V1.0 :| Yue Yang          :| 08/25/2014:| Initial Revision
// ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  == 

module DE0_CV_TOP(input CLOCK2_50,
                  input CLOCK3_50,
                  inout CLOCK4_50,
                  input CLOCK_50,
                  output [12:0] DRAM_ADDR,
                  output [1:0] DRAM_BA,
                  output DRAM_CAS_N,
                  output DRAM_CKE,
                  output DRAM_CLK,
                  output DRAM_CS_N,
                  inout [15:0] DRAM_DQ,
                  output DRAM_LDQM,
                  output DRAM_RAS_N,
                  output DRAM_UDQM,
                  output DRAM_WE_N,
                  inout [35:0] GPIO_0,
                  inout [35:0] GPIO_1,
                  output [6:0] HEX0,
                  output [6:0] HEX1,
                  output [6:0] HEX2,
                  output [6:0] HEX3,
                  output [6:0] HEX4,
                  output [6:0] HEX5,
                  input [3:0] KEY,
                  output [9:0] LEDR,
                  inout PS2_CLK,
                  inout PS2_CLK2,
                  inout PS2_DAT,
                  inout PS2_DAT2,
                  input RESET_N,
                  output SD_CLK,
                  inout SD_CMD,
                  inout [3:0] SD_DATA,
                  input [9:0] SW,
                  output [3:0] VGA_B,
                  output [3:0] VGA_G,
                  output VGA_HS,
                  output [3:0] VGA_R,
                  output VGA_VS);

    // ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  == 
    //  REG/WIRE declarations
    // ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  == 
    wire [9:0] led_core;
    wire [27:0] hex_core;

    assign LEDR = led_core;
    assign {HEX5, HEX4, HEX1, HEX0} = hex_core;
    assign {HEX3, HEX2} = 14'h3FFF;

    // ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  == ==  ==  ==  == 
    //  Structural coding
    // ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==
    // Unused board peripherals are disabled for this project top.
    assign DRAM_ADDR = 13'h0000;
    assign DRAM_BA = 2'b00;
    assign DRAM_CAS_N = 1'b1;
    assign DRAM_CKE = 1'b0;
    assign DRAM_CLK = 1'b0;
    assign DRAM_CS_N = 1'b1;
    assign DRAM_LDQM = 1'b1;
    assign DRAM_RAS_N = 1'b1;
    assign DRAM_UDQM = 1'b1;
    assign DRAM_WE_N = 1'b1;
    assign DRAM_DQ = 16'hZZZZ;
    assign GPIO_0 = 36'hZZZZZZZZZ;
    assign GPIO_1 = 36'hZZZZZZZZZ;
    assign PS2_CLK = 1'bZ;
    assign PS2_CLK2 = 1'bZ;
    assign PS2_DAT = 1'bZ;
    assign PS2_DAT2 = 1'bZ;
    assign SD_CLK = 1'b0;
    assign SD_CMD = 1'bZ;
    assign SD_DATA = 4'bZZZZ;
    assign VGA_B = 4'h0;
    assign VGA_G = 4'h0;
    assign VGA_HS = 1'b0;
    assign VGA_R = 4'h0;
    assign VGA_VS = 1'b0;

    top #(
        .DIVISOR(50_000_000),
        .FILE_NAME("mem_init.mif"),
        .ADDR_WIDTH(6),
        .DATA_WIDTH(16)
    ) top_inst (
        .clk(CLOCK_50),
        .rst_n(RESET_N),
        .btn(~KEY[2:0]),
        .sw(SW[8:0]),
        .led(led_core),
        .hex(hex_core)
    );

endmodule
