class master_item extends uvm_sequence_item;
  rand bit [7:0] tx_data;
  rand bit       cpol, cpha;
  rand bit [7:0] clk_div;
  bit      [7:0] rx_data;

  constraint c_div  { clk_div inside {[8:20]}; }
  constraint c_data { tx_data dist {8'h00 := 5, 8'hFF := 5, 8'hAA := 3, 8'h55 := 3, [8'h01:8'hFE] :/ 84}; }

  `uvm_object_utils(master_item)
  function new(string name = "master_item"); super.new(name); endfunction
  function string convert2string();
    return $sformatf("tx=%02h rx=%02h cpol=%0b cpha=%0b div=%0d", tx_data, rx_data, cpol, cpha, clk_div);
  endfunction
endclass

class slave_item extends uvm_sequence_item;
  rand bit [7:0] tx_data;
  bit      [7:0] rx_data;

  constraint c_data { tx_data dist {8'h00 := 5, 8'hFF := 5, 8'hAA := 3, 8'h55 := 3, [8'h01:8'hFE] :/ 84}; }

  `uvm_object_utils(slave_item)
  function new(string name = "slave_item"); super.new(name); endfunction
  function string convert2string();
    return $sformatf("tx=%02h rx=%02h", tx_data, rx_data);
  endfunction
endclass
