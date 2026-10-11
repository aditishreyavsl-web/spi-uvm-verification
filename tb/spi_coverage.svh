class spi_coverage extends uvm_subscriber #(master_item);
  `uvm_component_utils(spi_coverage)
  master_item item;

  covergroup cg;
    option.per_instance = 1;
    cp_cpol : coverpoint item.cpol;
    cp_cpha : coverpoint item.cpha;
    cp_mode : cross cp_cpol, cp_cpha;
    cp_tx   : coverpoint item.tx_data {
      bins zero = {8'h00};  bins ones = {8'hFF};
      bins alt1 = {8'hAA};  bins alt2 = {8'h55};
      bins other[4] = {[8'h01:8'hFE]};
    }
    cp_rx   : coverpoint item.rx_data {
      bins zero = {8'h00};  bins ones = {8'hFF};
      bins alt1 = {8'hAA};  bins alt2 = {8'h55};
      bins other[4] = {[8'h01:8'hFE]};
    }
    cp_div  : coverpoint item.clk_div {
      bins fast = {[8:11]}; bins mid = {[12:15]}; bins slow = {[16:20]};
    }
    x_mode_tx  : cross cp_cpol, cp_cpha, cp_tx;
    x_mode_div : cross cp_cpol, cp_cpha, cp_div;
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    cg = new();
  endfunction

  function void write(master_item t);
    item = t;
    cg.sample();
  endfunction

  function void report_phase(uvm_phase phase);
    `uvm_info("COV", $sformatf("Functional coverage = %0.2f%%", cg.get_inst_coverage()), UVM_NONE)
  endfunction
endclass
