`ifndef SOC_TEST_PACKAGE_SV
`define SOC_TEST_PACKAGE_SV

package soc_test_pkg;

  import uvm_pkg::*;
  `include"uvm_macros.svh"

  import apb_vip_pkg::*;
  import soc_env_pkg::*;
  import soc_seq_pkg::*;
 
  `include"soc_base_test.sv"

endpackage

`endif //SOC_TEST_PACKAGE_SV
