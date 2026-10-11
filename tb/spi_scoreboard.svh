`uvm_analysis_imp_decl(_m)
`uvm_analysis_imp_decl(_s)

class spi_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(spi_scoreboard)
  uvm_analysis_imp_m #(master_item, spi_scoreboard) m_imp;
  uvm_analysis_imp_s #(slave_item,  spi_scoreboard) s_imp;
  master_item mq[$];
  slave_item  sq[$];
  int unsigned n_pass, n_fail;

  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void build_phase(uvm_phase phase);
    m_imp = new("m_imp", this);
    s_imp = new("s_imp", this);
  endfunction

  function void write_m(master_item t); mq.push_back(t); compare(); endfunction
  function void write_s(slave_item  t); sq.push_back(t); compare(); endfunction

  function void compare();
    master_item m; slave_item s;
    while (mq.size() > 0 && sq.size() > 0) begin
      m = mq.pop_front();
      s = sq.pop_front();
      if (m.tx_data === s.rx_data && s.tx_data === m.rx_data) begin
        n_pass++;
        `uvm_info("SCB", $sformatf("PASS  M->S %02h/%02h   S->M %02h/%02h  (cpol=%0b cpha=%0b)",
                  m.tx_data, s.rx_data, s.tx_data, m.rx_data, m.cpol, m.cpha), UVM_HIGH)
      end else begin
        n_fail++;
        `uvm_error("SCB", $sformatf("MISMATCH  master{%s}  slave{%s}", m.convert2string(), s.convert2string()))
      end
    end
  endfunction

  function void check_phase(uvm_phase phase);
    if (mq.size() != 0 || sq.size() != 0)
      `uvm_error("SCB", $sformatf("Unmatched transactions: master=%0d slave=%0d", mq.size(), sq.size()))
    if (n_pass + n_fail == 0) `uvm_error("SCB", "No transactions were compared")
  endfunction

  function void report_phase(uvm_phase phase);
    `uvm_info("SCB", $sformatf("RESULT: %0d passed, %0d failed", n_pass, n_fail), UVM_NONE)
  endfunction
endclass
