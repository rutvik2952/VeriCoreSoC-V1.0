`ifndef SOC_ENV_PACKAGE_SV
`define SOC_ENV_PACKAGE_SV

 package soc_env_pkg;

   import uvm_pkg::*;
  `include"uvm_macros.svh"
  
   import apb_pkg::*;
  `include"soc_virtual_sequencer.sv"
  `include"soc_environment.sv"

 endpackage

`endif // SOC_ENV_PACKAGE_SV  
