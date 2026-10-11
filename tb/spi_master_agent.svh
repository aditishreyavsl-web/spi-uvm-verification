typedef uvm_sequencer #(master_item) master_sequencer;

class master_driver extends uvm_driver #(master_item);
  `uvm_component_utils(master_driver)
  virtual master_if vif;
  function new(string name, uvm_component parent); super.new(name, parent); endfunction

  function void build_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual master_if)::get(this, "", "m_vif", vif))
      `uvm_fatal("NOVIF", "master_if not set")
  endfunction

  task run_phase(uvm_phase phase);
    vif.drv_cb.start <= 0;
    wait (vif.rst_n === 1'b1);
    repeat (20) @(vif.drv_cb);
    forever begin
      seq_item_port.get_next_item(req);
      @(vif.drv_cb);
      vif.drv_cb.tx_data <= req.tx_data;
      vif.drv_cb.cpol    <= req.cpol;
      vif.drv_cb.cpha    <= req.cpha;
      vif.drv_cb.clk_div <= req.clk_div;
      vif.drv_cb.start   <= 1;
      @(vif.drv_cb);
      vif.drv_cb.start   <= 0;
      do @(vif.drv_cb); while (!vif.drv_cb.done);
      repeat (2) @(vif.drv_cb);
      seq_item_port.item_done();
    end
  endtask
endclass

class master_monitor extends uvm_monitor;
  `uvm_component_utils(master_monitor)
  virtual master_if vif;
  uvm_analysis_port #(master_item) ap;
  function new(string name, uvm_component parent); super.new(name, parent); endfunction

  function void build_phase(uvm_phase phase);
    ap = new("ap", this);
    if (!uvm_config_db#(virtual master_if)::get(this, "", "m_vif", vif))
      `uvm_fatal("NOVIF", "master_if not set")
  endfunction

  task run_phase(uvm_phase phase);
    master_item item;
    wait (vif.rst_n === 1'b1);
    forever begin
      @(vif.mon_cb);
      if (vif.mon_cb.start) begin
        item = master_item::type_id::create("m_mon_item");
        item.tx_data = vif.mon_cb.tx_data;
        item.cpol    = vif.mon_cb.cpol;
        item.cpha    = vif.mon_cb.cpha;
        item.clk_div = vif.mon_cb.clk_div;
        do @(vif.mon_cb); while (!vif.mon_cb.done);
        item.rx_data = vif.mon_cb.rx_data;
        `uvm_info("M_MON", item.convert2string(), UVM_MEDIUM)
        ap.write(item);
      end
    end
  endtask
endclass

class master_agent extends uvm_agent;
  `uvm_component_utils(master_agent)
  master_sequencer sqr;
  master_driver    drv;
  master_monitor   mon;
  function new(string name, uvm_component parent); super.new(name, parent); endfunction

  function void build_phase(uvm_phase phase);
    mon = master_monitor::type_id::create("mon", this);
    if (get_is_active() == UVM_ACTIVE) begin
      sqr = master_sequencer::type_id::create("sqr", this);
      drv = master_driver::type_id::create("drv", this);
    end
  endfunction
  function void connect_phase(uvm_phase phase);
    if (get_is_active() == UVM_ACTIVE) drv.seq_item_port.connect(sqr.seq_item_export);
  endfunction
endclass
