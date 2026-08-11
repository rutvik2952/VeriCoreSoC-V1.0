`ifndef SOC_VIRTUAL_SEQUENCE_SV
`define SOC_VIRTUAL_SEQUENCE_SV

 
  class soc_virtual_sequence extends uvm_sequence;

    //APB Sequence
    apb_base_sequence apb_seq;

    // Factory Registration
    `uvm_object_utils(soc_virtual_sequence)

    `uvm_declare_p_sequencer(soc_virtual_sequencer)

    function new(string name ="soc_virtual_sequence");
      super.new(name);
      apb_seq = apb_base_sequence::type_id::create("apb_seq");
    endfunction

    task body();
      `uvm_info(get_type_name(),"Body call",UVM_LOW)
       repeat(10)begin
         `uvm_do_on(apb_seq.apb_trans,p_sequencer.apb_seqr)
         apb_seq.apb_trans.print();
       end
    endtask

  endclass

`endif //SOC_VIRTUAL_SEQUENCE_SV
