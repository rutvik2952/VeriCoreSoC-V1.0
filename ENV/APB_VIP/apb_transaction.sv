`ifndef APB_TRANSACTION_SV
`define APB_TRANSACION_SV

class apb_transaction extends uvm_sequence_item;

  rand bit[ADDR_WIDTH-1] apb_addr;
  rand bit[DATA_WIDTH-1] apb_wr_data;
  rand operation apb_operation;
       bit[DATA_WIDTH-1] apb_rd_data;


 // Factory Registration
 `uvm_object_utils_begin(apb_transaction)
 `uvm_field_int(apb_addr,UVM_ALL_ON | UVM_HEX)
 `uvm_field_int(apb_wr_data,UVM_ALL_ON | UVM_HEX)
 `uvm_field_enum(operation,apb_operation,UVM_ALL_ON)
 `uvm_field_int(apb_rd_data,UVM_ALL_ON | UVM_HEX)
 `uvm_object_utils_end

 function new(string name ="apb_transaction");
   super.new(name);
 endfunction

 constraint apb_ope {apb_operation != IDEAL;}

endclass

`endif //APB_TRANSACION_SV 
