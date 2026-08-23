`ifndef SOC_REG_ADAPTER_SV
`define SOC_REG_ADAPTER_SV
`include"../APB_VIP/apb_common.sv"
`include"../APB_VIP/apb_transaction.sv"

 class soc_reg_adapter extends uvm_reg_adapter;

   apb_transaction apb_trans;

  `uvm_object_utils(soc_reg_adapter)

  function new(string name="soc_reg_adapter");
    super.new(name);
  endfunction

  function  uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    apb_trans = apb_transaction::type_id::create("apb_trans");
    apb_trans.apb_addr = rw.addr;
    apb_trans.apb_operation = (rw.kind==UVM_WRITE) ? WRITE : READ;
     if(rw.kind==UVM_WRITE)  apb_trans.apb_wr_data = rw.data;
     else  apb_trans.apb_rd_data = rw.data;
    return apb_trans;
  endfunction

 function void bus2reg(uvm_sequence_item bus_item,
                                     ref uvm_reg_bus_op rw);
     apb_trans = apb_transaction::type_id::create("apb_trans");
    rw.addr = apb_trans.apb_addr;
    if(apb_trans.apb_operation != IDEAL) begin
     rw.kind = (apb_trans.apb_operation == WRITE) ? UVM_WRITE : UVM_READ;
     rw.status = UVM_IS_OK;   
    end
  endfunction

 endclass

`endif // SOC_REG_ADAPTER_SV
