`ifndef APB_DRIVER_SV
`define APB_DRIVER_SV

 class apb_driver extends uvm_driver#(apb_transaction);

  apb_transaction trans;

  virtual apb_vif vif;

  // Factory Registration
  `uvm_component_utils(apb_driver)

  function new(string name ="apb_driver" ,uvm_component parent);
   super.new(name,parent);
  endfunction

 virtual task run_phase(uvm_phase phase);
  super.run_phase(phase);
  forever begin 
  seq_item_port.get_next_item(req);
  `uvm_info(get_type_name(),"APB Transaction Start",UVM_LOW)
   if(!vif.PRESETn) begin
      send_ideal_transaction();
      @(posedge vif.PRESETn);
   end
   else begin
      send_apb_transaction(req);
   end 
  `uvm_info(get_type_name(),"APB Transaction Complete",UVM_LOW)
  end
 endtask


 task send_ideal_transaction();
 `uvm_info(get_type_name() ," APB is in ideal State ",UVM_LOW)
   vif.PADDR   <= 0;
   vif.PSLEx   <= 0;
   vif.PENABLE <= 0;
   vif.PWDATA  <= 0;
 endtask

 task send_apb_transaction( apb_transaction trans);
    apb_setup_state(trans);
    apb_acces_state();
 endtask

 task apb_setup_state( apb_transaction trans);
   @(posedge vif.PCLK);
   `uvm_info(get_type_name() ," APB is in Setup State ",UVM_LOW)
   vif.PSLEx  <= 1;
   vif.PADDR  <= trans.apb_addr;
   vif.PWDATA <= (trans.apb_operation == WRITE)? trans.apb_wr_data : 0;
   vif.PWRITE <= (trans.apb_operation == WRITE)? 1 : (trans.apb_operation == READ)? 0 : 'bx;
 endtask

 task apb_acces_state();
   `uvm_info(get_type_name() ," APB is in Access State ",UVM_LOW)
   @(posedge vif.PCLK);
    vif.PENABLE = 1;
   @(posedge vif.PCLK);
   wait(vif.PREADY);
   @(posedge vif.PCLK); 
   send_ideal_transaction(); 
 endtask   

endclass

`endif //APB_DRIVER_SV
