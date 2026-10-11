interface master_if (input logic clk, input logic rst_n);
  logic       start;
  logic [7:0] tx_data, rx_data, clk_div;
  logic       cpol, cpha, busy, done;

  clocking drv_cb @(posedge clk);
    default input #1step output #1;
    output start, tx_data, cpol, cpha, clk_div;
    input  rx_data, busy, done;
  endclocking
  clocking mon_cb @(posedge clk);
    default input #1step;
    input start, tx_data, cpol, cpha, clk_div, rx_data, busy, done;
  endclocking
endinterface

interface slave_if (input logic clk, input logic rst_n);
  logic [7:0] tx_data, rx_data;
  logic       rx_valid, cs_n;

  clocking drv_cb @(posedge clk);
    default input #1step output #1;
    output tx_data;
    input  rx_data, rx_valid, cs_n;
  endclocking
  clocking mon_cb @(posedge clk);
    default input #1step;
    input tx_data, rx_data, rx_valid, cs_n;
  endclocking
endinterface
