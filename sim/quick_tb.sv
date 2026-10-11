`timescale 1ns/1ps
module quick_tb;
  logic clk=0, rst_n=0; always #5 clk=~clk;
  logic start=0, cpol=0, cpha=0; logic [7:0] m_tx, s_tx, div, m_rx, s_rx;
  logic busy, done, sclk, mosi, miso, cs_n, s_valid;
  spi_master M(.clk,.rst_n,.start,.tx_data(m_tx),.cpol,.cpha,.clk_div(div),.rx_data(m_rx),.busy,.done,.sclk,.mosi,.cs_n,.miso);
  spi_slave  S(.clk,.rst_n,.cpol,.cpha,.tx_data(s_tx),.rx_data(s_rx),.rx_valid(s_valid),.sclk,.mosi,.cs_n,.miso);
  int errs=0, n=0;
  task xfer(input [7:0] m, s, input pol, pha, input [7:0] d);
    begin
      cpol=pol; cpha=pha; div=d; s_tx=s; m_tx=m;
      @(posedge clk); start<=1; @(posedge clk); start<=0;
      @(posedge done); @(posedge clk); n++;
      if (s_rx!==m || m_rx!==s) begin errs++; $display("FAIL pol=%b pha=%b m=%h s=%h got s_rx=%h m_rx=%h",pol,pha,m,s,s_rx,m_rx); end
    end
  endtask
  initial begin
    repeat(5) @(posedge clk); rst_n=1; repeat(5) @(posedge clk);
    for (int md=0; md<4; md++) begin
      xfer(8'hA5,8'h3C,md[1],md[0],8);
      xfer(8'h00,8'hFF,md[1],md[0],8);
      xfer(8'hFF,8'h00,md[1],md[0],12);
      for (int i=0;i<20;i++) xfer($urandom,$urandom,md[1],md[0],8+$urandom_range(12));
    end
    $display("QUICK TB: %0d transfers, %0d errors", n, errs);
    $finish;
  end
endmodule
