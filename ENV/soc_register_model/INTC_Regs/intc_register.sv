`ifndef INTC_REGISTER_SV
`define INTC_REGISTER_SV

 class intc_id_reg extends uvm_reg;
   
    rand uvm_reg_field INTC_ID;

   `uvm_object_utils(intc_id_reg)

   function new(string name="intc_id_reg");
     super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   function void build();
     INTC_ID = uvm_reg_field::type_id::create("INTC_ID");
     INTC_ID.configure(this,32,0,"RO",0,'h494E_5443,1,1,1);
   endfunction

 endclass

 class intc_version_reg extends uvm_reg;

   rand uvm_reg_field INTC_VERSION;

   `uvm_object_utils(intc_version_reg)

   function new(string name="intc_version_reg");
     super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   function void build();
     INTC_VERSION = uvm_reg_field::type_id::create("INTC_VERSION");
     INTC_VERSION.configure(this,32,0,"RO",0,'h0001_0000,1,1,1);
   endfunction

 endclass

 class intc_enable_reg extends uvm_reg;

   rand uvm_reg_field IRQ_ENBALE;
   
   `uvm_object_utils(intc_enable_reg)

   function new(string name="intc_enable_reg");
     super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   function void build();
     IRQ_ENBALE = uvm_reg_field::type_id::create("IRQ_ENBALE");
     IRQ_ENBALE.configure(this,8,0,"RW",0,0,1,1,1);

   endfunction
   
 endclass

 class intc_pending_reg extends uvm_reg;
   
   rand uvm_reg_field IRQ_PENDING;

   `uvm_object_utils(intc_pending_reg)

   function new(string name="intc_pending_reg");
     super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   function void build();
     IRQ_PENDING = uvm_reg_field::type_id::create("IRQ_PENDING");
     IRQ_PENDING.configure(this,8,0,"RO",0,0,1,1,1);
   endfunction

 endclass

 class intc_priority_reg extends uvm_reg;
   
   rand uvm_reg_field IRQ_PRIORITY;
   
   `uvm_object_utils(intc_priority_reg)

   function new(string name="intc_priority_reg");
     super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   function void build();
     IRQ_PRIORITY = uvm_reg_field::type_id::create("IRQ_PRIORITY");
     IRQ_PRIORITY.configure(this,8,0,"RW",0,0,1,1,1);
   endfunction

 endclass

class inctc_clear_reg extends uvm_reg;

   rand uvm_reg_field INTC_CLEAR;

   `uvm_object_utils(inctc_clear_reg)

   function new(string name="inctc_clear_reg");
     super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   function void build();
     INTC_CLEAR = uvm_reg_field::type_id::create("INTC_CLEAR");
     INTC_CLEAR.configure(this,8,0,"WO",0,0,1,1,1);
   endfunction

endclass

`endif // INTC_REGISTER_SV
