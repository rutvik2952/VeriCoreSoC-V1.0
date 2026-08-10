`ifndef APB_ENVIRONMENT_SV
`define APB_ENVIRONMENT_SV

class apb_environment extends uvm_env;

  apb_agent apb_agt;

  //Factory Registration
  `uvm_component_utils(apb_environment)

  function new(string name ="apb_environment" ,uvm_component parent);
   super.new(name,parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
   apb_agt = apb_agent::type_id::create("apb_agt",this);
  endfunction

 
endclass

`endif //APB_ENVIRONMENT_SV
