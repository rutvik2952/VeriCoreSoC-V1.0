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
    endfunction

    task body();
     repeat(10)begin
     `uvm_do_on(apb_seq.trans,p_sequencer.apb_seqr)
     end
    endtask

  endclass

`endif //SOC_VIRTUAL_SEQUENCE_SV
