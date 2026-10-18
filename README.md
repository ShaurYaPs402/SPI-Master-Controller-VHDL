# SPI Master Controller in VHDL

This is a simple SPI Master Controller (Mode 0) written in VHDL. It converts 8-bit parallel data into serial data on MOSI and receives serial data from MISO.

## Features
- SPI Mode 0 (CPOL = 0, CPHA = 0)
- Takes 8-bit input data and sends it bit by bit
- Generates SCLK clock from a 50MHz system clock
- Uses a simple 4-state FSM (IDLE, LOAD, TRANSFER, FINISH)
- Active-low Chip Select (`cs_n`) signal

## Project Files
- `rtl/spi_master.vhd` - Main SPI Master design code
- `tb/spi_master_tb.vhd` - Testbench code for simulation
- `docs/epwave_waveform.png` - Simulation waveform screenshot

## How It Works
1. When `start` signal goes high, state changes from IDLE to LOAD.
2. `tx_data` is loaded into a shift register.
3. In TRANSFER state, `sclk` starts toggling. It sends data on MOSI and reads MISO.
4. After 8 bits are done, state changes to FINISH and `done` signal goes high.

## Simulation Result
Tested this on EDA Playground using GHDL simulator. Verified that 0xA5 is transmitted correctly and 0x3C is received properly.

![Waveform](docs/epwave_waveform.png)
