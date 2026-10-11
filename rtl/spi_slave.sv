module spi_slave #(parameter int W = 8) (
  input  logic         clk, rst_n,
  input  logic         cpol, cpha,
  input  logic [W-1:0] tx_data,
  output logic [W-1:0] rx_data,
  output logic         rx_valid,
  input  logic         sclk, mosi, cs_n,
  output logic         miso
);
  logic [2:0] sclk_s, cs_s;
  logic [1:0] mosi_s;
  logic [W-1:0] tx_reg, rx_reg;
  logic [$clog2(W+1)-1:0] bit_cnt;

  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) begin sclk_s <= '0; cs_s <= '1; mosi_s <= '0; end
    else begin
      sclk_s <= {sclk_s[1:0], sclk};
      cs_s   <= {cs_s[1:0],   cs_n};
      mosi_s <= {mosi_s[0],   mosi};
    end

  wire edge_d  = sclk_s[1] ^ sclk_s[2];
  wire active  = ~cs_s[1] & ~cs_s[2];
  wire lead    = edge_d & (sclk_s[1] != cpol);
  wire trail   = edge_d & (sclk_s[1] == cpol);
  wire samp_e  = cpha ? trail : lead;
  wire shft_e  = cpha ? lead  : trail;
  wire cs_fall = cs_s[2] & ~cs_s[1];

  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) begin
      miso <= 0; rx_valid <= 0; rx_data <= '0; tx_reg <= '0; rx_reg <= '0; bit_cnt <= 0;
    end else begin
      rx_valid <= 0;
      if (cs_fall) begin
        bit_cnt <= 0; rx_reg <= '0;
        if (cpha) begin miso <= 0;            tx_reg <= tx_data;      end
        else      begin miso <= tx_data[W-1]; tx_reg <= tx_data << 1; end
      end else if (cs_s[1]) miso <= 0;
      else if (active) begin
        if (samp_e) begin
          rx_reg  <= {rx_reg[W-2:0], mosi_s[1]};
          bit_cnt <= bit_cnt + 1;
          if (bit_cnt == W-1) begin
            rx_data  <= {rx_reg[W-2:0], mosi_s[1]};
            rx_valid <= 1;
          end
        end
        if (shft_e) begin miso <= tx_reg[W-1]; tx_reg <= tx_reg << 1; end
      end
    end
endmodule
