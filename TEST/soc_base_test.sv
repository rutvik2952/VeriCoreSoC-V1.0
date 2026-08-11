`ifndef SOC_BASE_TEST_SV
`define SOC_BASE_TEST_SV

 class soc_base_test extends uvm_test;

   soc_environment       soc_env;
   soc_virtual_sequence  soc_virtual_seqc;

   //Factory Registration
   `uvm_component_utils(soc_base_test)

   function new(string name ="soc_base_test" ,uvm_component parent);
      super.new(name,parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     soc_env = soc_environment::type_id::create("soc_env",this);
   endfunction

   virtual task run_phase(uvm_phase phase);
     super.run_phase(phase);
      phase.raise_objection(this);
  
       soc_virtual_seqc = soc_virtual_sequence::type_id::create("soc_virtual_seqc");
       soc_virtual_seqc.start(soc_env.vir_seqr);

      phase.drop_objection(this);
   endtask

 endclass

`endif //SOC_BASE_TEST_SV
