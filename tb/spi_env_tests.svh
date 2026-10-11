class spi_env extends uvm_env;
  `uvm_component_utils(spi_env)
  master_agent    magt;
  slave_agent     sagt;
  spi_scoreboard  sb;
  spi_coverage    cov;
  function new(string name, uvm_component parent); super.new(name, parent); endfunction

  function void build_phase(uvm_phase phase);
    magt = master_agent  ::type_id::create("magt", this);
    sagt = slave_agent   ::type_id::create("sagt", this);
    sb   = spi_scoreboard::type_id::create("sb",   this);
    cov  = spi_coverage  ::type_id::create("cov",  this);
  endfunction
  function void connect_phase(uvm_phase phase);
    magt.mon.ap.connect(sb.m_imp);
    sagt.mon.ap.connect(sb.s_imp);
    magt.mon.ap.connect(cov.analysis_export);
  endfunction
endclass

class spi_base_test extends uvm_test;
  `uvm_component_utils(spi_base_test)
  spi_env env;
  function new(string name, uvm_component parent); super.new(name, parent); endfunction

  function void build_phase(uvm_phase phase);
    env = spi_env::type_id::create("env", this);
  endfunction

  virtual task run_master_seqs();
    spi_rand_seq s = spi_rand_seq::type_id::create("s");
    s.start(env.magt.sqr);
  endtask

  task run_phase(uvm_phase phase);
    slave_rand_seq ss = slave_rand_seq::type_id::create("ss");
    phase.raise_objection(this);
    fork ss.start(env.sagt.sqr); join_none
    run_master_seqs();
    #2us;
    phase.drop_objection(this);
  endtask
endclass

class spi_sweep_test extends spi_base_test;
  `uvm_component_utils(spi_sweep_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  task run_master_seqs();
    spi_sweep_seq s = spi_sweep_seq::type_id::create("s");
    s.start(env.magt.sqr);
  endtask
endclass

class spi_fast_test extends spi_base_test;
  `uvm_component_utils(spi_fast_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  task run_master_seqs();
    spi_fast_seq s = spi_fast_seq::type_id::create("s");
    s.start(env.magt.sqr);
  endtask
endclass

class spi_regress_test extends spi_base_test;
  `uvm_component_utils(spi_regress_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  task run_master_seqs();
    spi_sweep_seq s1 = spi_sweep_seq::type_id::create("s1");
    spi_fast_seq  s2 = spi_fast_seq ::type_id::create("s2");
    spi_rand_seq  s3 = spi_rand_seq ::type_id::create("s3");
    s3.n = 500;
    s1.start(env.magt.sqr);
    s2.start(env.magt.sqr);
    s3.start(env.magt.sqr);
  endtask
endclass
