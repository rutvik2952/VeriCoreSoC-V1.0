`ifndef APB_MONITOR_SV
`define APB_MONITOR_SV

 class apb_monitor extends uvm_monitor;

  apb_transaction trans;

  virtual apb_vif vif;

  //Factory Registration
  `uvm_component_utils(apb_monitor)

  function new(string name ="apb_monitor",uvm_component parent);
    super.new(name,parent);
  endfunction

 
 task run_phase(uvm_phase phase);  
   super.run_phase(phase);
   forever begin
    @(posedge vif.PCLK);
    if(vif.PENABLE && vif.PREADY && vif.PSLEx) begin
     trans = apb_transaction::type_id::create("trans");
     trans.apb_addr      = vif.PADDR;
     trans.apb_wr_data   = vif.PWDATA;
     trans.apb_operation = (vif.PWRITE)? WRITE : READ;
     trans.apb_rd_data   = vif.PRDATA;
     `uvm_info(get_type_name()," APB Monitor Collect Transaction From DUT",UVM_LOW)
      trans.print();
    end
   end
 endtask

endclass

`endif // APB_MONITOR_SV
