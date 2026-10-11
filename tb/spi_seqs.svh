class spi_rand_seq extends uvm_sequence #(master_item);
  `uvm_object_utils(spi_rand_seq)
  int unsigned n = 200;
  function new(string name = "spi_rand_seq"); super.new(name); endfunction
  task body();
    repeat (n) begin
      req = master_item::type_id::create("req");
      start_item(req);
      if (!req.randomize()) `uvm_error("SEQ", "randomize failed")
      finish_item(req);
    end
  endtask
endclass

class spi_sweep_seq extends uvm_sequence #(master_item);
  `uvm_object_utils(spi_sweep_seq)
  function new(string name = "spi_sweep_seq"); super.new(name); endfunction
  task body();
    bit [7:0] corners [4];
    bit       v_pol, v_pha;
    bit [7:0] v_dat;
    corners = '{8'h00, 8'hFF, 8'hAA, 8'h55};
    for (int m = 0; m < 4; m++)
      foreach (corners[i]) begin
        v_pol = m[1]; v_pha = m[0]; v_dat = corners[i];
        req = master_item::type_id::create("req");
        start_item(req);
        if (!req.randomize() with { cpol == v_pol; cpha == v_pha; tx_data == v_dat; })
          `uvm_error("SEQ", "randomize failed")
        finish_item(req);
      end
  endtask
endclass

class spi_fast_seq extends uvm_sequence #(master_item);
  `uvm_object_utils(spi_fast_seq)
  function new(string name = "spi_fast_seq"); super.new(name); endfunction
  task body();
    bit v_pol, v_pha;
    for (int m = 0; m < 4; m++)
      repeat (20) begin
        v_pol = m[1]; v_pha = m[0];
        req = master_item::type_id::create("req");
        start_item(req);
        if (!req.randomize() with { cpol == v_pol; cpha == v_pha; clk_div == 8; })
          `uvm_error("SEQ", "randomize failed")
        finish_item(req);
      end
  endtask
endclass

class slave_rand_seq extends uvm_sequence #(slave_item);
  `uvm_object_utils(slave_rand_seq)
  function new(string name = "slave_rand_seq"); super.new(name); endfunction
  task body();
    forever begin
      req = slave_item::type_id::create("req");
      start_item(req);
      if (!req.randomize()) `uvm_error("SEQ", "randomize failed")
      finish_item(req);
    end
  endtask
endclass
