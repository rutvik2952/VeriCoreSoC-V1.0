`ifndef TIMER_REGISTER_SV
`define TIMER_REGISTER_SV

 class timer_id_reg extends uvm_reg;

   rand uvm_reg_field TIMER_ID;

   `uvm_object_utils(timer_id_reg)

   function new(string name="timer_id_reg");
     super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   function void build();
     TIMER_ID = uvm_reg_field::type_id::create("TIMER_ID");
     TIMER_ID.configure(this,32,0,"RO",0,'h5449_4D52,1,1,1);
   endfunction

 endclass

 class timer_version_reg extends uvm_reg;

   rand uvm_reg_field TIMER_VERSION;

   `uvm_object_utils(timer_version_reg)

   function new(string name="timer_version_reg");
     super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   function void build();
     TIMER_VERSION = uvm_reg_field::type_id::create("TIMER_VERSION");
     TIMER_VERSION.configure(this,32,0,"RO",0,'h0001_0000,1,1,1);
   endfunction

 endclass

 class timer_control_reg extends uvm_reg;

   rand uvm_reg_field TIMER_ENABLE;
   rand uvm_reg_field TIMER_MDOE;
   rand uvm_reg_field TIMER_IRQ_ENABLE;

   `uvm_object_utils(timer_control_reg)

   function new(string name="timer_control_reg");
     super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   function void build();
      TIMER_ENABLE = uvm_reg_field::type_id::create("TIMER_ENABLE");
      TIMER_ENABLE.configure(this,1,0,"RW",0,0,1,1,1);

      TIMER_MDOE = uvm_reg_field::type_id::create("TIMER_MDOE");
      TIMER_MDOE.configure(this,1,1,"RW",0,0,1,1,1);

      TIMER_IRQ_ENABLE = uvm_reg_field::type_id::create("TIMER_IRQ_ENABLE");
      TIMER_IRQ_ENABLE.configure(this,1,2,"RW",0,0,1,1,1);
   endfunction

 endclass

 class timer_laod_reg extends uvm_reg;

   rand uvm_reg_field TIMER_LOAD;

   `uvm_object_utils(timer_laod_reg)

   function new(string name="timer_laod_reg");
     super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   function void build();
      TIMER_LOAD = uvm_reg_field::type_id::create("TIMER_LOAD");
      TIMER_LOAD.configure(this,32,0,"RW",0,0,1,1,1);
   endfunction  

 endclass

 class timer_count_reg extends uvm_reg;

   rand uvm_reg_field TIMER_COUNT;

   `uvm_object_utils(timer_count_reg)

   function new(string name = "timer_count_reg");
     super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   function void build();
     TIMER_COUNT = uvm_reg_field::type_id::create("TIMER_COUNT");
     TIMER_COUNT.configure(this,32,0,"RO",0,0,1,1,1);
   endfunction 

 endclass

 class timer_status_reg extends uvm_reg;

   rand uvm_reg_field TIMER_RUNNING;
   rand uvm_reg_field TIMER_TIMEOUT;
   
   `uvm_object_utils(timer_status_reg)
   
   function new(string name ="timer_status_reg");
     super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   function void build();
     TIMER_RUNNING = uvm_reg_field::type_id::create("TIMER_RUNNING");
     TIMER_RUNNING.configure(this,1,0,"RO",0,0,1,1,1);

     TIMER_TIMEOUT = uvm_reg_field::type_id::create("TIMER_TIMEOUT");
     TIMER_TIMEOUT.configure(this,1,1,"RO",0,0,1,1,1);
   endfunction

 endclass

 class timer_int_status_reg extends uvm_reg;
   
   rand uvm_reg_field TIMER_IRQ_PENDIING;

  `uvm_object_utils(timer_int_status_reg)

  function new(string name="timer_int_status_reg");
    super.new(name,32,UVM_NO_COVERAGE);
  endfunction

  function void build();
    TIMER_IRQ_PENDIING = uvm_reg_field::type_id::create("TIMER_IRQ_PENDIING");
    TIMER_IRQ_PENDIING.configure(this,1,0,"RO",0,0,1,1,1);
  endfunction

 endclass

 class timer_int_clear_reg extends uvm_reg;
   
   rand uvm_reg_field TIMER_IRQ_CLEAR;

   `uvm_object_utils(timer_int_clear_reg)

   function new(string name="timer_int_clear_reg");
     super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   function void build();
     TIMER_IRQ_CLEAR = uvm_reg_field::type_id::create("TIMER_IRQ_CLEAR");
     TIMER_IRQ_CLEAR.configure(this,1,0,"RO",0,0,1,1,1);
   endfunction

 endclass

`endif //TIMER_REGISTER_SV
