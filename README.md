# UVM-Based Functional Verification of an SPI Master-Slave Controller

UVM testbench that verifies an SPI master talking to an SPI slave in all four SPI modes (CPOL/CPHA).

## Testbench structure

- **Master agent**: driver, monitor and sequencer for the SPI master's host interface
- **Slave agent**: driver, monitor and sequencer for the SPI slave's host interface
- **Scoreboard**: checks master TX = slave RX and slave TX = master RX for every transfer
- **Coverage**: SPI modes, corner data (00, FF, AA, 55), clock divider ranges
- **Sequences**: mode and corner-data sweep, back-to-back transfers at the fastest clock, constrained-random

## Repository layout

| Path | Contents |
|---|---|
| `rtl/` | SPI master and slave (design under test) |
| `tb/` | UVM testbench |
| `sim/quick_tb.sv` | Simple non-UVM test of the design (Icarus Verilog) |
| `docs/` | Simulation log screenshots |

## How to run

Tested on EDA Playground with Cadence Xcelium 25.03 and UVM 1.2.

- Compile options: `-timescale 1ns/1ps -coverage functional`
- Run options: `+UVM_TESTNAME=spi_regress_test`
- Tests available: `spi_base_test`, `spi_sweep_test`, `spi_fast_test`, `spi_regress_test`

## Results

| Metric | Result |
|---|---|
| Transfers checked | 596 passed, 0 failed |
| UVM_ERROR / UVM_FATAL / UVM_WARNING | 0 / 0 / 0 |
| Functional coverage | 100% |

The 596 transfers are 16 (mode and corner-data sweep), 80 (fastest clock) and 500 (constrained-random).

![Passing run](docs/WhatsApp%20Image%202026-10-10%20at%205.21.48%20PM.jpeg)

### Bug injection

To check that the testbench actually catches bugs, the sampling-edge condition in the master was changed (`==` to `!=`). The scoreboard reported 566 mismatches out of 596 transfers. The change was reverted afterwards.

![Bug detected](docs/WhatsApp%20Image%202026-10-10%20at%205.24.44%20PM.jpeg)

### Design-only check

`sim/quick_tb.sv` (Icarus Verilog): 92 transfers across all four modes, 0 errors.
