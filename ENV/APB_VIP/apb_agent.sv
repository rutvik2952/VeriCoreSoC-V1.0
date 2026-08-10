`ifndef APB_AGENT_SV
`define APB_AGENT_SV

class apb_agent extends uvm_agent;

  apb_sequencer apb_seqr;
  apb_driver    apb_dri;
  apb_monitor   apb_moni;

  virtual apb_vif vif;

  // Factory Registration
  `uvm_component_utils(apb_agent)

  function new(string name ="apb_agent" ,uvm_component parent);
   super.new(name,parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    apb_seqr = apb_sequencer::type_id::create("apb_seqr",this);
    apb_dri  = apb_driver::type_id::create("apb_dri",this);
    apb_moni = apb_monitor::type_id::create("apb_moni",this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(!uvm_config_db#(virtual apb_vif)::get(this,"","APB_VIF",vif)) 
     `uvm_fatal(get_type_name()," Unable to get APB Interface")
    else begin
     apb_dri.vif  = vif;
     apb_moni.vif = vif;
     apb_dri.seq_item_port.connect(apb_seqr.seq_item_export);
    end
  endfunction

endclass

`endif //APB_AGENT_SV
