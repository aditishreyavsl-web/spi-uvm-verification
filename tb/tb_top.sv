`timescale 1ns/1ps
`include "uvm_macros.svh"
module tb_top;
  import uvm_pkg::*;
  import spi_pkg::*;

  logic clk = 0, rst_n = 0;
  always #5 clk = ~clk;
  initial begin repeat (5) @(posedge clk); rst_n = 1; end

  master_if mif (clk, rst_n);
  slave_if  sif (clk, rst_n);
  logic sclk, mosi, miso, cs_n;

  spi_master dut_m (.clk, .rst_n, .start(mif.start), .tx_data(mif.tx_data),
                    .cpol(mif.cpol), .cpha(mif.cpha), .clk_div(mif.clk_div),
                    .rx_data(mif.rx_data), .busy(mif.busy), .done(mif.done),
                    .sclk, .mosi, .cs_n, .miso);

  spi_slave  dut_s (.clk, .rst_n, .cpol(mif.cpol), .cpha(mif.cpha),
                    .tx_data(sif.tx_data), .rx_data(sif.rx_data), .rx_valid(sif.rx_valid),
                    .sclk, .mosi, .cs_n, .miso);

  assign sif.cs_n = cs_n;

  initial begin
    uvm_config_db#(virtual master_if)::set(null, "*", "m_vif", mif);
    uvm_config_db#(virtual slave_if )::set(null, "*", "s_vif", sif);
    run_test();
  end

  initial begin
    if ($test$plusargs("dump")) begin $dumpfile("spi.vcd"); $dumpvars(0, tb_top); end
  end
endmodule
