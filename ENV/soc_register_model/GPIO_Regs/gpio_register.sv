`ifndef GPIO_REGISTER_SV
`define GPIO_REGISTER_SV

 class gpio_id_reg extends uvm_reg;

   rand uvm_reg_field GPIO_ID;

   `uvm_object_utils(gpio_id_reg)

   function new(string name="gpio_id_reg");
     super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   function void build();
     GPIO_ID = uvm_reg_field::type_id::create("GPIO_ID");
     GPIO_ID.configure(this,32,0,"RO",0,'h4750_494F,1,1,1);
   endfunction

 endclass

 class gpio_version_reg extends uvm_reg;

   rand uvm_reg_field GPIO_VERSION;

   `uvm_object_utils(gpio_version_reg)

   function new(string name="gpio_version_reg");
     super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   function void build();
     GPIO_VERSION = uvm_reg_field::type_id::create("GPIO_VERSION");
     GPIO_VERSION.configure(this,32,0,"RO",0,'h0001_0000,1,1,1);
     
   endfunction

 endclass

 class gpio_data_in_reg extends uvm_reg;

   rand uvm_reg_field GPIO_DATA_IN;
   
   `uvm_object_utils(gpio_data_in_reg)

   function new(string name="gpio_data_in_reg");
     super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   function void build();
      GPIO_DATA_IN = uvm_reg_field::type_id::create("GPIO_DATA_IN");
      GPIO_DATA_IN.configure(this,32,0,"RW",0,0,1,1,1);
   endfunction

 endclass

 class gpio_data_out_reg extends uvm_reg;
   
   rand uvm_reg_field GPIO_DATA_OUT;
  
   `uvm_object_utils(gpio_data_out_reg)

   function new(string name="gpio_data_out_reg");
     super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   function void build();
     GPIO_DATA_OUT = uvm_reg_field::type_id::create("GPIO_DATA_OUT");
     GPIO_DATA_OUT.configure(this,32,0,"RW",0,0,1,1,1);
   endfunction

 endclass

 class gpio_direction_reg extends uvm_reg;
   
   rand uvm_reg_field GPIO_DIRECTION;

   `uvm_object_utils(gpio_direction_reg)

   function new(string name="gpio_direction_reg");
     super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   function void build();
      GPIO_DIRECTION = uvm_reg_field::type_id::create("GPIO_DIRECTION");
      GPIO_DIRECTION.configure(this,32,0,"RW",0,0,1,1,1);
     
   endfunction
  
 endclass

 class gpio_output_en_reg extends uvm_reg;
    rand uvm_reg_field GPIO_OUTPUT_EN;
 
    `uvm_object_utils(gpio_output_en_reg)

    function new(string name="gpio_output_en_reg");
      super.new(name,32,UVM_NO_COVERAGE);
    endfunction

    function void build();
      GPIO_OUTPUT_EN = uvm_reg_field::type_id::create("GPIO_OUTPUT_EN");
      GPIO_OUTPUT_EN.configure(this,32,0,"RW",0,0,1,1,1);
      
    endfunction

 endclass

 class gpio_status_reg extends uvm_reg;
    
    rand uvm_reg_field ANY_INPUT_ACTIVE;
    rand uvm_reg_field ANY_IRQ_PENDING;

   `uvm_object_utils(gpio_status_reg)

   function new(string name="gpio_status_reg");
     super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   function void build();
     ANY_INPUT_ACTIVE = uvm_reg_field::type_id::create("ANY_INPUT_ACTIVE");
     ANY_INPUT_ACTIVE.configure(this,1,0,"RO",0,0,1,1,1);

     ANY_IRQ_PENDING = uvm_reg_field::type_id::create("ANY_IRQ_PENDING");
     ANY_IRQ_PENDING.configure(this,1,1,"RO",0,0,1,1,1);
     
   endfunction

 endclass

 class gpio_int_enable_reg extends uvm_reg;

    rand uvm_reg_field GPIO_INT_ENABLE;
    
    `uvm_object_utils(gpio_int_enable_reg)

    function new(string name="gpio_int_enable_reg");
      super.new(name,32,UVM_NO_COVERAGE);
    endfunction

    function void build();
      GPIO_INT_ENABLE = uvm_reg_field::type_id::create("GPIO_INT_ENABLE");
      GPIO_INT_ENABLE.configure(this,32,0,"RW",0,0,1,1,1);
    endfunction

 endclass

 class gpio_int_status_reg extends uvm_reg;
    
    rand uvm_reg_field GPIO_INT_STATUS;

   `uvm_object_utils(gpio_int_status_reg)

    function new(string name="gpio_int_status_reg");
      super.new(name,32,UVM_NO_COVERAGE);
    endfunction

    function void build();
      GPIO_INT_STATUS = uvm_reg_field::type_id::create("GPIO_INT_STATUS");
      GPIO_INT_STATUS.configure(this,32,0,"RO",0,0,1,1,1);
    endfunction
    
 endclass

  class gpio_int_clear_reg extends  uvm_reg;

    rand uvm_reg_field GPIO_INT_CLEAR;
   
    `uvm_object_utils(gpio_int_clear_reg)

    function new(string name="gpio_int_clear_reg");
      super.new(name,32,UVM_NO_COVERAGE);
    endfunction

    function void build();
      GPIO_INT_CLEAR = uvm_reg_field::type_id::create("GPIO_INT_CLEAR");
      GPIO_INT_CLEAR.configure(this,32,0,"WO",0,0,1,1,1);
      
    endfunction

 endclass

`endif //GPIO_REGISTER_SV
