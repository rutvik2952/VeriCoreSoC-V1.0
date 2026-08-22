`ifndef TIMER_REG_BLOCK_SV
`define TIMET_REG_BLOCK_SV

 class timer_reg_block extends uvm_reg_block;

   timer_id_reg         TIMER_ID;
   timer_version_reg    TIMER_VERSION;
   timer_control_reg    TIMER_CONTROL;
   timer_laod_reg       TIMER_LOAD;
   timer_count_reg      TIMER_COUNT;
   timer_status_reg     TIMER_STATUS;
   timer_int_status_reg TIMER_INT_STATUS;
   timer_int_clear_reg  TIMER_INT_CLEAR;

   `uvm_object_utils(timer_reg_block)

   function new(string name="timer_reg_block");
     super.new(name,UVM_NO_COVERAGE);
   endfunction

   function void build();
      TIMER_ID = timer_id_reg::type_id::create("TIMER_ID");
      TIMER_ID.configure(this);
      TIMER_ID.build();

      TIMER_VERSION = timer_version_reg::type_id::create("TIMER_VERSION");
      TIMER_VERSION.configure(this);
      TIMER_VERSION.build();

      TIMER_CONTROL = timer_control_reg::type_id::create("TIMER_CONTROL");
      TIMER_CONTROL.configure(this);
      TIMER_CONTROL.build();

      TIMER_LOAD = timer_laod_reg::type_id::create("TIMER_LOAD");
      TIMER_LOAD.configure(this);
      TIMER_LOAD.build();

      TIMER_COUNT = timer_count_reg::type_id::create("TIMER_COUNT");
      TIMER_COUNT.configure(this);
      TIMER_COUNT.build();

      TIMER_STATUS = timer_status_reg::type_id::create("TIMER_STATUS");
      TIMER_STATUS.configure(this);
      TIMER_STATUS.build();
     
      TIMER_INT_STATUS = timer_int_status_reg::type_id::create("TIMER_INT_STATUS");
      TIMER_INT_STATUS.configure(this);
      TIMER_INT_STATUS.build();
 
      TIMER_INT_CLEAR = timer_int_clear_reg::type_id::create("TIMER_INT_CLEAR");
      TIMER_INT_CLEAR.configure(this);
      TIMER_INT_CLEAR.build();

      default_map  = create_map("default_map",'h4000_2000,4,UVM_LITTLE_ENDIAN);
      default_map.add_reg(TIMER_ID,'h0,"RW");
      default_map.add_reg(TIMER_VERSION ,'h4,"RW");
      default_map.add_reg(TIMER_CONTROL,'h8,"RW");
      default_map.add_reg(TIMER_LOAD,'hC,"RW");
      default_map.add_reg(TIMER_COUNT,'h10,"RW");
      default_map.add_reg(TIMER_STATUS,'h14,"RW");
      default_map.add_reg(TIMER_INT_STATUS,'h18,"RW");
      default_map.add_reg(TIMER_INT_CLEAR,'h1C,"RW");

      lock_model();
   endfunction
 

 endclass

`endif //TIMET_REG_BLOCK_SV 
