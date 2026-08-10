`ifndef SOC_VIRTUAL_SEQUENCER_SV
`define SOC_VIRTUAL_SEQUENCER_SV

 class soc_virtual_sequencer extends uvm_sequencer;

  apb_sequencer apb_seqr;

  //Factory Registration
  `uvm_component_utils(soc_virtual_sequencer)

  function new(string name ="soc_virtual_sequencer" ,uvm_component parent);
    super.new(name,parent);
  endfunction

 endclass

`endif // SOC_VIRTUAL_SEQUENCER_SV
