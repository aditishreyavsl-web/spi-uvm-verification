# UVM-Based Functional Verification of an SPI Master-Slave Controller


## Results
Simulator: Cadence Xcelium 25.03 (EDA Playground), UVM 1.2, test `spi_regress_test`.

| Metric | Result |
|---|---|
| Transfers checked by scoreboard | 596 passed, 0 failed |
| UVM_ERROR / UVM_FATAL / UVM_WARNING | 0 / 0 / 0 |
| Functional coverage | 100% |

Compile options: `-timescale 1ns/1ps -coverage functional`
Run options: `+UVM_TESTNAME=spi_regress_test`
Transfers = 16 (mode/corner sweep) + 80 (fast clock) + 500 (random).
Log screenshots are in `docs/`.

### Bug-injection check
TODO: change `is_sample = (edge_cnt[0] == cpha)` to `!=` in `rtl/spi_master.sv`, run again and note the mismatches reported by the scoreboard.

RTL alone (`sim/quick_tb.sv`, Icarus Verilog): 92 transfers over all 4 modes, 0 errors.

## Architecture
```
 master_seq ─► master_agent ─► [ spi_master ] ══ sclk/mosi/miso/cs_n ══ [ spi_slave ] ◄─ slave_agent ◄─ slave_seq
                   │ mon                                                                  │ mon
                   ├──────────────► spi_scoreboard ◄──────────────────────────────────────┘
                   └──────────────► spi_coverage
```
Scoreboard rule per transfer:  `master.tx == slave.rx`  and  `slave.tx == master.rx`.

## Run
Questa:   `vlog -sv +incdir+tb -f tb/files.f && vsim -c tb_top +UVM_TESTNAME=spi_regress_test -do "run -all; quit"`
VCS:      `vcs -sverilog -full64 -ntb_opts uvm -f tb/files.f -debug_access+all && ./simv +UVM_TESTNAME=spi_regress_test`
Xcelium:  `xrun -uvm -f tb/files.f +UVM_TESTNAME=spi_regress_test`
EDA Playground (Cadence Xcelium): tick UVM 1.2, paste rtl/*.sv + tb/spi_if.sv + tb/spi_pkg.sv + the .svh files + tb_top.sv, plusarg `+UVM_TESTNAME=spi_regress_test`.

Tests: spi_base_test (random), spi_sweep_test (4 modes x corner data), spi_fast_test (clk_div=8 back-to-back), spi_regress_test (all).
RTL-only sanity (no UVM, works in iverilog): `iverilog -g2012 -o q rtl/*.sv sim/quick_tb.sv && vvp q`

## Verification plan
| ID | Feature | Checked by |
|----|---------|-----------|
| V1 | Master->slave data integrity (all 4 modes) | scoreboard |
| V2 | Slave->master data integrity (all 4 modes) | scoreboard |
| V3 | Corner data 00/FF/AA/55 | sweep seq + cp_tx/cp_rx |
| V4 | Clock divider range 8..20 | rand seq + cp_div |
| V5 | Back-to-back transfers | fast seq |
| V6 | No missing/extra transfers | scoreboard check_phase |

## Ideas to extend (for report / extra marks)
- SVA: CS low for exactly 2*W sclk edges, sclk idle == CPOL, done is a single-cycle pulse
- Reset-in-the-middle-of-transfer test
- Parameterise W (16/32 bit), multi-slave CS
- Inject a bug into RTL (e.g. swap CPHA sampling) and show the scoreboard catches it (mutation test)
