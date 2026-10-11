module spi_master #(parameter int W = 8) (
  input  logic         clk, rst_n,
  input  logic         start,
  input  logic [W-1:0] tx_data,
  input  logic         cpol, cpha,
  input  logic [7:0]   clk_div,
  output logic [W-1:0] rx_data,
  output logic         busy, done,
  output logic         sclk, mosi, cs_n,
  input  logic         miso
);
  typedef enum logic [1:0] {IDLE, XFER, FINISH} state_t;
  state_t state;
  logic [7:0]               div_cnt;
  logic [$clog2(2*W)-1:0]   edge_cnt;
  logic [W-1:0]             tx_reg, rx_reg;

  wire tick      = (div_cnt == clk_div - 1);
  wire is_sample = (edge_cnt[0] == cpha);

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= IDLE; sclk <= 0; mosi <= 0; cs_n <= 1; busy <= 0; done <= 0;
      rx_data <= '0; div_cnt <= 0; edge_cnt <= 0; tx_reg <= '0; rx_reg <= '0;
    end else begin
      done <= 0;
      case (state)
        IDLE: if (start) begin
          cs_n <= 0; busy <= 1; sclk <= cpol; rx_reg <= '0;
          div_cnt <= 0; edge_cnt <= 0;
          if (cpha) begin mosi <= 0;            tx_reg <= tx_data;      end
          else      begin mosi <= tx_data[W-1]; tx_reg <= tx_data << 1; end
          state <= XFER;
        end
        XFER: begin
          if (tick) begin
            div_cnt <= 0;
            sclk    <= ~sclk;
            if (is_sample) rx_reg <= {rx_reg[W-2:0], miso};
            else begin mosi <= tx_reg[W-1]; tx_reg <= tx_reg << 1; end
            if (edge_cnt == 2*W-1) begin edge_cnt <= 0; state <= FINISH; end
            else edge_cnt <= edge_cnt + 1;
          end else div_cnt <= div_cnt + 1;
        end
        FINISH: begin
          if (tick) begin
            cs_n <= 1; busy <= 0; done <= 1; rx_data <= rx_reg; mosi <= 0;
            div_cnt <= 0; state <= IDLE;
          end else div_cnt <= div_cnt + 1;
        end
        default: state <= IDLE;
      endcase
    end
  end
endmodule
