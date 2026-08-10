`ifndef APB_BASE_SEQUENCE_SV
`define APB_BASE_SEQUENCE_SV

 class apb_base_sequence extends uvm_sequence#(apb_transaction);

   apb_transaction apb_trans;

   //Factory Registration
   `uvm_object_utils(apb_base_sequence)

  function new(string name ="apb_base_sequence");
    super.new(name);
    apb_trans = apb_transaction::type_id::create("apb_trans");
  endfunction

  task body();
   repeat(10)begin
    `uvm_do(apb_trans);
   end
endtask

 endclass

`endif //APB_BASE_SEQUENCE_SV
