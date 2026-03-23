# 16-bit Custom CPU on FPGA - picoComputer Architecture

This repository contains the RTL implementation of a custom 16-bit Central Processing Unit (CPU) designed for Cyclone III (DE0) and Cyclone V (DE0-CV) FPGA development boards.

The project is written in Verilog and includes a complete toolchain setup for both simulation and synthesis, using Altera Quartus 13.1 and ModelSim/QuestaSim.

## CPU Architecture

This processor is based on the **picoComputer** architecture. Key technical specifications include:
- **16-bit Data / 6-bit Address Space**: The memory has 64 words of 16-bits each.
  - Memory locations `[0-7]`: General Purpose Registers (GPR).
  - Memory locations `[8+]`: Program memory (execution starts at `PC = 8`).
  - Stack grows downwards from the highest memory location (`SP` starts at 63).
- **Clock Management**: The board's native 50MHz clock is divided down to 1Hz for visibly tracing the processor's execution in hardware.

### Instruction Set

The CPU uses a 3-address instruction format (1 or 2 words long) supporting direct and indirect addressing modes.

| Opcode | Instruction | Description |
|--------|-------------|-------------|
| `0000` | `MOV`       | Data movement between memory locations / registers. |
| `0001` | `ADD`       | Arithmetic addition. |
| `0010` | `SUB`       | Arithmetic subtraction. |
| `0011` | `MUL`       | Arithmetic multiplication. |
| `0100` | `DIV`       | Arithmetic division (intentionally left unsupported). |
| `0111` | `IN`        | Reads input from standard input (PS/2 Keyboard). Blocking until ready. |
| `1000` | `OUT`       | Writes data to standard output (LEDs/VGA). |
| `1111` | `STOP`      | Halts execution and optionally outputs up to three values. |

### Integrated Peripherals

- **VGA Output**: Renders colors based on processed data natively.
- **PS/2 Keyboard Interface**: Capable of reading hardware keyboard inputs and scan codes for program input.
- **7-Segment Displays**: Live visualization of the Program Counter (PC) and Stack Pointer (SP).
- **Hardware Debouncing**: Clean input handling for buttons and switches.
- **Status LEDs**: `LED[5]` indicates when the processor is ready for input (`IN` instruction), while `LED[4:0]` function as standard output (`OUT`).

## Repository Structure

```text
Projekat/
├── src/
│   ├── simulation/
│   │   └── cpu_tb.v           # Testbench for verifying CPU behavior
│   └── synthesis/
│       ├── modules/
│       │   ├── alu.v          # Arithmetic Logic Unit
│       │   ├── cpu.v          # Core CPU State Machine
│       │   ├── memory.v       # 64x16-bit System Memory
│       │   ├── vga.v          # VGA Display Controller
│       │   ├── ps2.v          # PS/2 Keyboard Controller
│       │   └── ...            # Extracted components (BCD, SSD, Debouncer, etc.)
│       ├── DE0_CV_TOP.v       # Altera Cyclone V Top-Level Wrapper
│       └── DE0_TOP.v          # Altera Cyclone III Top-Level Wrapper
├── tooling/
│   ├── config/                # Board-specific configurations (.qdf, .sdc, TCL scripts)
│   ├── xpack/                 # Bundled build utilities for Windows (Make, Busybox)
│   ├── makefile               # Automated GNU Make script for building/simulating
│   └── mem_init.mif           # Initialization file containing the compiled program
├── Postavka.pdf.txt           # Official Project Specification document
└── README.md                  # This file
```

## Prerequisites

To simulate and synthesize this project, you need:
- **Altera Quartus II (13.1)**: For synthesizing the design onto the Cyclone FPGAs.
- **ModelSim or QuestaSim**: For running RTL simulations.
- *(Note: Make and other shell utilities are included within `tooling/xpack/bin`, so no external make installation is required on Windows).*

## How to Build and Run

The project build pipeline is fully automated via GNU Make. 
Open a terminal (e.g., PowerShell or Command Prompt) and navigate to the project directory.

### Simulation

To compile and run the simulation using ModelSim/QuestaSim:
```bash
cd tooling
./xpack/bin/make.exe simul_all
```
Other simulation targets:
- `simul_run_gui`: Starts the simulation in GUI mode to inspect waveforms.
- `simul_clean`: Cleans up simulation build artifacts.

### Synthesis

To run the full synthesis pipeline (Analysis & Synthesis, Map, Fit, Assemble, STA) for the FPGA:
```bash
cd tooling
./xpack/bin/make.exe synth_all
```
Other synthesis targets:
- `synth_pgm`: Automatically programs the connected FPGA device with the compiled `.sof` file.
- `synth_clean`: Removes Quartus build files and logs.

## Customizing the Target Board

By default, the compilation targets the Cyclone III `DE0_TOP`. To change this to Cyclone V `DE0_CV_TOP`, modify the following variables in `tooling/makefile`:
```makefile
SYNTH_TOP_LEVEL_MODULE = DE0_CV_TOP
SYNTH_DEVICE_FAMILY = CycloneV
SYNTH_DEVICE_PART = 5CEBA4F23C7
```

## Academic Context

This project was developed as a university assignment for the **Computer VLSI Systems (Računarski VLSI sistemi - 13E114VLSI)** course at the School of Electrical Engineering (ETF).
