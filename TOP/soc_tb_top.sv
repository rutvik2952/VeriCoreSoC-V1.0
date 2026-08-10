//`include"../RTL/SOC_TOP/soc_top.sv"

module soc_tb_top;

  logic clk;
  logic resetn;

  import uvm_pkg::*;
  `include"uvm_macros.svh"
   import soc_test_pkg::*;

  //APB VIP Interface
  apb_vif apb_if(.PCLK(clk),
                 .PRESETn(resetn));


  //SoC TOP RTL
  soc_top soc_rtl (.clk(apb_if.PCLK),
                   .rst_n(apb_if.PRESETn),
                   .apb_master_enable(1),
                   .cpu_master_enable(0),
                   .apb_psel(apb_if.PSLEx),
                   .apb_penable(apb_if.PENABLE),
                   .apb_pwrite(apb_if.PWRITE),
                   .apb_paddr(apb_if.PADDR),
	           .apb_pwdata(apb_if.PWDATA),
		   .apb_prdata(apb_if.PRDATA),
	           .apb_pready(apb_if.PREADY),
		   .apb_pslverr(apb_if.PSLVERR));


  always #5 clk = ~clk;

  initial begin
    clk = 0;
    resetn = 0;
    repeat(5) begin
      @(posedge clk);
    end
    resetn =1;
  end

  initial begin
   uvm_config_db#(virtual apb_vif)::set(null,"*","APB_VIF",apb_if);
   run_test("soc_base_test");
  end

endmodule    
