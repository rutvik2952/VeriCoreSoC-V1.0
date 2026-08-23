`ifndef SOC_ENVIRONMENT_SV
`define SOC_ENVIRONMENT_SV

class soc_environment extends uvm_env;

 // APB VIP ENV
 apb_environment apb_env;

 // Virtual Sequencer 
 soc_virtual_sequencer vir_seqr;

 // Register Block
 soc_reg_block_model soc_reg_model;

 // Register Adapter
 soc_reg_adapter adapter;

 //Factory Registration
 `uvm_component_utils(soc_environment)

 function new(string name="soc_environment",uvm_component parent);
   super.new(name,parent);
 endfunction

 virtual function void build_phase(uvm_phase phase);
   super.build_phase(phase);
   apb_env  = apb_environment::type_id::create("apb_env",this);
   vir_seqr = soc_virtual_sequencer::type_id::create("vir_seqr",this);
   soc_reg_model = soc_reg_block_model::type_id::create("soc_reg_model");
   soc_reg_model.build(); 
   adapter = soc_reg_adapter::type_id::create("adapter");
  endfunction


 virtual function void connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   vir_seqr.apb_seqr = apb_env.apb_agt.apb_seqr; 
   //soc_reg_model.default_map.set_sequencer(apb_env.apb_agt.apb_seqr,adapter); 
 endfunction

endclass

`endif //SOC_ENVIRONMENT_SV
