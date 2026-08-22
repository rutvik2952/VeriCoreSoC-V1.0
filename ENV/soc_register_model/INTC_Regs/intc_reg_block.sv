`ifndef INTC_REG_BLOCK_SV
`define INTC_REG_BLOCK_SV

 class intc_reg_block extends uvm_reg_block;

   intc_id_reg       INITC_ID;
   intc_version_reg  INITC_VERSION;
   intc_enable_reg   INITC_ENANLE;
   intc_pending_reg  INTC_PENDING;
   intc_priority_reg INTC_PRIORITY;
   inctc_clear_reg   INTC_CLEAR;

   `uvm_object_utils(intc_reg_block)

   function new(string name="intc_reg_block");
     super.new(name,UVM_NO_COVERAGE);
   endfunction

   function void build();
     INITC_ID = intc_id_reg::type_id::create("INITC_ID");
     INITC_ID.configure(this);
     INITC_ID.build();

     INITC_VERSION = intc_version_reg::type_id::create("INITC_VERSION");
     INITC_VERSION.configure(this);
     INITC_VERSION.build();

     INITC_ENANLE = intc_enable_reg::type_id::create("INITC_ENANLE");
     INITC_ENANLE.configure(this);
     INITC_ENANLE.build();

     INTC_PENDING = intc_pending_reg::type_id::create("INTC_PENDING");
     INTC_PENDING.configure(this);
     INTC_PENDING.build();

     INTC_PRIORITY = intc_priority_reg::type_id::create("INTC_PRIORITY");
     INTC_PRIORITY.configure(this);
     INTC_PRIORITY.build();

     INTC_CLEAR = inctc_clear_reg::type_id::create("INTC_CLEAR");
     INTC_CLEAR.configure(this);
     INTC_CLEAR.build();

     default_map = create_map("default_map",'h4000_7000,4,UVM_LITTLE_ENDIAN);
     default_map.add_reg(INITC_ID,'h0,"RW");
     default_map.add_reg(INITC_VERSION,'h4,"RW");
     default_map.add_reg(INITC_ENANLE,'h8,"RW");
     default_map.add_reg(INTC_PENDING,'hC,"RW");
     default_map.add_reg(INTC_PRIORITY,'h10,"RW");
     default_map.add_reg(INTC_CLEAR,'h14,"RW");

     lock_model();
   endfunction

 endclass

`endif //INTC_REG_BLOCK_SV
