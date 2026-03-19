# picoComputer FPGA Implementation

This project implements a custom 16-bit **picoComputer** (CPU architecture) targeting Altera/Intel Cyclone III (DE0) and Cyclone V (DE0-CV) FPGA boards. Originally based on a VLSI course's second pre-exam assignment, the project has been significantly extended to include **PS/2 Keyboard** support for asynchronous input and **VGA Output** for visual data representation.

## Features

- **Custom CPU Architecture**: A multi-cycle processor pipeline with Fetch, Decode, Execute, and Wait states.
- **Synchronous Memory**: 64x16-bit RAM divided into fixed GPR (General Purpose Registers) zero-page and free program/data zones.
- **PS/2 Keyboard Integration**: Fully custom PS/2 shift-register and scan-code translator enabling numeric key input directly into the CPU.
- **VGA Display Pipeline**: Hardware VGA controller with dynamically generated colors based on CPU computations.
- **Hardware Debouncing & Edge Detection**: Robust button and switch inputs.
- **Seven-Segment Diagnostics**: Real-time BCD-driven display of the Program Counter (PC) and Stack Pointer (SP).

---

## CPU Architecture

The picoComputer operates on a derived 1 Hz clock (`slow_clk`) for visual debugging while keyboard/VGA controllers operate at the native 50 MHz board clock. 

**Registers:**
- `PC` (Program Counter) - Starts at Address 8
- `SP` (Stack Pointer) - Starts at Address 63
- `IR` (Instruction Register, 32-bit)
- `MAR` (Memory Address Register)
- `MDR` (Memory Data Register)
- `ACC` (Accumulator)

**Instruction Set Architecture (ISA):**
Instructions are generally 1 or 2 words long. The CPU uses a 3-address format (Destination/X, Operand 1/Y, Operand 2/Z). Each operand specifies whether it uses direct or memory-indirect addressing. 

| Opcode | Mnemonic | Description |
|:---:|:---|:---|
| `0000` | **MOV** | `X = Y` (Data transfer) |
| `0001` | **ADD** | `X = Y + Z` |
| `0010` | **SUB** | `X = Y - Z` |
| `0011` | **MUL** | `X = Y * Z` |
| `0100` | **DIV** | `X = Y / Z` _(See hardware note below)_ |
| `0111` | **IN** | Blocks CPU and waits for user data via PS/2 keyboard |
| `1000` | **OUT** | Outputs `X` to internal color mappings and LEDs |
| `1111` | **STOP** | Halts execution, sequentially outputting non-zero operands |

> [!TIP]
> **A Note on Hardware Division:** The `DIV` instruction is fully supported within the CPU's state machine; however, it utilizes a 16-bit combinational divider in the ALU. While functional, combinational division is extremely resource-intensive for FPGAs. To ensure optimal timing performance ($F_{max}$) and resource efficiency, it is recommended to use bit-shifting or iterative subtraction for division operations where possible.

---

## Hardware Modules

### Core Modules
- `cpu.v` - Main State Machine coordinating execution phases.
- `memory.v` - Inferrable Block RAM initialized with `mem_init.mif`.
- `alu.v` - Arithmetic Logic Unit for math operations.

### Peripherals
- **Keyboard (`ps2.v`, `scan_codes.v`)**: Captures PS/2 clock falling edges, shifts out 11-bit frames, debounces break codes (`F0`), and translates numeric keys into 4-bit CPU data.
- **VGA (`vga.v`, `color_codes.v`)**: Decodes specific numbers from the CPU into 24-bit RGB values and generates horizontal and vertical sync signals for the monitor.
- **Displays (`bcd.v`, `ssd.v`)**: Binary-to-BCD conversion routed to onboard 7-segment displays.
- **Utilities (`red.v`, `debouncer.v`, `clk_div.v`)**: Signal cleanliness and domain derivation.

### Top-Level Wrappers
- `DE0_CV_TOP.v` - Physical pin mappings for the Cyclone V board.
- `DE0_TOP.v` - Physical pin mappings for the Cyclone III board.
- `top.v` - The primary structural integration bridging the CPU with the peripherals and memory.

---

## Project Structure

```text
├── src/synthesis/
│   ├── DE0_TOP.v           # Cyclone III Top
│   ├── DE0_CV_TOP.v        # Cyclone V Top
│   └── modules/            # Structural & Behavioral RTL
│       ├── cpu.v
│       ├── memory.v
│       ├── alu.v
│       ├── ps2.v, scan_codes.v
│       ├── vga.v, color_codes.v
│       ├── bcd.v, ssd.v
│       └── ...
├── mem_init.mif            # Assembly compiled to Memory Initialization format
├── plan.md                 # Initial implementation checklist and architecture spec
└── PROCESSOR SPECS.txt     # Rough CPU and ISA documentation
```

## Prerequisites

Before running the project, assure you have the following installed and setup:
- **Intel Quartus Prime** (or Quartus II) installed and added to your system `PATH`.
- **GNU Make** installed.
- **Hardware:** DE0 or DE0-CV FPGA development board.
- *(Optional)* **PS/2 Keyboard** and **VGA Monitor** connected to the board logic.

## How to Run

1. Connect your DE0 / DE0-CV FPGA board to your PC via USB (USB-Blaster).
2. Open a terminal in the root of the project repository.
3. Run the following command to synthesize the project and program the board:
   ```bash
   make synth_pgm
   ```
4. Once programmed, the CPU will begin execution automatically. If you have connected a PS/2 Keyboard, it will process the `IN` operations by pausing and awaiting key inputs, visualizing states via the onboard Seven-Segment displays and LEDs.
