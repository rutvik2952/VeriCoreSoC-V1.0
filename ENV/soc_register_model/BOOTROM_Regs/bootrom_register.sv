`ifndef BOOTROM_REGISTER_SV
`define BOOTROM_REGISTER_SV

 class bootrom_id_reg extends uvm_reg;
 
   rand uvm_reg_field BOOTROM_ID;

   `uvm_object_utils(bootrom_id_reg)

   function new(string name ="bootrom_id_reg");
     super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   function void build();
     BOOTROM_ID = uvm_reg_field::type_id::create("BOOTROM_ID");
     BOOTROM_ID.configure(this,32,0,"RO",0,'h4252_4F4D,1,1,1);
    
   endfunction

 endclass

  class bootrom_version_reg extends uvm_reg;
 
   rand uvm_reg_field BOOTROM_VERSION;

   `uvm_object_utils(bootrom_version_reg)

   function new(string name ="bootrom_version_reg");
     super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   function void build();
     BOOTROM_VERSION = uvm_reg_field::type_id::create("BOOTROM_VERSION");
     BOOTROM_VERSION.configure(this,32,0,"RO",0,'h0001_0000,1,1,1);
    
   endfunction

 endclass

`endif //BOOTROM_REGISTER_SV
