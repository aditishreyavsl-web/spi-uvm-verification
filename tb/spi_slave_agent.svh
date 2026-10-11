typedef uvm_sequencer #(slave_item) slave_sequencer;

class slave_driver extends uvm_driver #(slave_item);
  `uvm_component_utils(slave_driver)
  virtual slave_if vif;
  function new(string name, uvm_component parent); super.new(name, parent); endfunction

  function void build_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual slave_if)::get(this, "", "s_vif", vif))
      `uvm_fatal("NOVIF", "slave_if not set")
  endfunction

  task run_phase(uvm_phase phase);
    vif.drv_cb.tx_data <= 8'h00;
    wait (vif.rst_n === 1'b1);
    forever begin
      seq_item_port.get_next_item(req);
      @(vif.drv_cb);
      vif.drv_cb.tx_data <= req.tx_data;
      do @(vif.drv_cb); while (!vif.drv_cb.rx_valid);
      seq_item_port.item_done();
    end
  endtask
endclass

class slave_monitor extends uvm_monitor;
  `uvm_component_utils(slave_monitor)
  virtual slave_if vif;
  uvm_analysis_port #(slave_item) ap;
  function new(string name, uvm_component parent); super.new(name, parent); endfunction

  function void build_phase(uvm_phase phase);
    ap = new("ap", this);
    if (!uvm_config_db#(virtual slave_if)::get(this, "", "s_vif", vif))
      `uvm_fatal("NOVIF", "slave_if not set")
  endfunction

  task run_phase(uvm_phase phase);
    slave_item item;
    bit prev_cs = 1;
    wait (vif.rst_n === 1'b1);
    forever begin
      @(vif.mon_cb);
      if (prev_cs && !vif.mon_cb.cs_n) begin
        item = slave_item::type_id::create("s_mon_item");
        item.tx_data = vif.mon_cb.tx_data;
        do @(vif.mon_cb); while (!vif.mon_cb.rx_valid);
        item.rx_data = vif.mon_cb.rx_data;
        `uvm_info("S_MON", item.convert2string(), UVM_MEDIUM)
        ap.write(item);
      end
      prev_cs = vif.mon_cb.cs_n;
    end
  endtask
endclass

class slave_agent extends uvm_agent;
  `uvm_component_utils(slave_agent)
  slave_sequencer sqr;
  slave_driver    drv;
  slave_monitor   mon;
  function new(string name, uvm_component parent); super.new(name, parent); endfunction

  function void build_phase(uvm_phase phase);
    mon = slave_monitor::type_id::create("mon", this);
    if (get_is_active() == UVM_ACTIVE) begin
      sqr = slave_sequencer::type_id::create("sqr", this);
      drv = slave_driver::type_id::create("drv", this);
    end
  endfunction
  function void connect_phase(uvm_phase phase);
    if (get_is_active() == UVM_ACTIVE) drv.seq_item_port.connect(sqr.seq_item_export);
  endfunction
endclass
