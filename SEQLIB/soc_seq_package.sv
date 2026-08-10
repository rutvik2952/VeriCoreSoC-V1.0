`ifndef SOC_SEQ_PACKAGE_SV
`define SOC_SEQ_PACKAGE_SV

  package soc_seq_pkg;
    import uvm_pkg::*;
    `include"uvm_macros.svh"
    import apb_pkg::*;
    import soc_env_pkg::*;
    `include"soc_virtual_sequence.sv" 
  
  endpackage

`endif //SOC_SEQ_PACKAGE_SV 
