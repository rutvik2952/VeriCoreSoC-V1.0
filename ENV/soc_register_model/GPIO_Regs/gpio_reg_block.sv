`ifndef GPIO_REG_BLOCK_SV
`define GPIO_REG_BLOCK_SV

 class gpio_reg_block extends uvm_reg_block;
  
    gpio_id_reg         GPIO_ID;
    gpio_version_reg    GPIO_VERSION;
    gpio_data_in_reg    GPIO_DATA_IN;
    gpio_data_out_reg   GPIO_DATA_OUT;
    gpio_direction_reg  GPIO_DIRECTION;
    gpio_output_en_reg  GPIO_OUTPUT_EN;
    gpio_status_reg     GPIO_STATUS;
    gpio_int_enable_reg GPIO_INT_ENABLE;
    gpio_int_status_reg GPIO_INT_STATUS;
    gpio_int_clear_reg  GPIO_INT_CLEAR;

    `uvm_object_utils(gpio_reg_block)

    function new(string name="gpio_reg_block");
      super.new(name,UVM_NO_COVERAGE);
    endfunction

    function void build();
       GPIO_ID = gpio_id_reg::type_id::create("GPIO_ID");
       GPIO_ID.configure(this);
       GPIO_ID.build();
    
       GPIO_VERSION = gpio_version_reg::type_id::create("GPIO_VERSION");
       GPIO_VERSION.configure(this);
       GPIO_VERSION.build();

       GPIO_DATA_IN = gpio_data_in_reg::type_id::create("GPIO_DATA_IN");
       GPIO_DATA_IN.configure(this);
       GPIO_DATA_IN.build();
 
       GPIO_DATA_OUT = gpio_data_out_reg::type_id::create("GPIO_DATA_OUT");
       GPIO_DATA_OUT.configure(this);
       GPIO_DATA_OUT.build();

       GPIO_DIRECTION = gpio_direction_reg::type_id::create("GPIO_DIRECTION");
       GPIO_DIRECTION.configure(this);
       GPIO_DIRECTION.build();
   
       GPIO_OUTPUT_EN = gpio_output_en_reg::type_id::create("GPIO_OUTPUT_EN");
       GPIO_OUTPUT_EN.configure(this);
       GPIO_OUTPUT_EN.build();

       GPIO_STATUS = gpio_status_reg::type_id::create("GPIO_STATUS");
       GPIO_STATUS.configure(this);
       GPIO_STATUS.build();

       GPIO_INT_ENABLE =  gpio_int_enable_reg::type_id::create("GPIO_INT_ENABLE");
       GPIO_INT_ENABLE.configure(this);
       GPIO_INT_ENABLE.build();

       GPIO_INT_STATUS = gpio_int_status_reg::type_id::create("GPIO_INT_STATUS");
       GPIO_INT_STATUS.configure(this);
       GPIO_INT_STATUS.build();

       GPIO_INT_CLEAR = gpio_int_clear_reg::type_id::create("GPIO_INT_CLEAR");
       GPIO_INT_CLEAR.configure(this);
       GPIO_INT_CLEAR.build();

       default_map = create_map("default_map",'h4000_1000,4,UVM_LITTLE_ENDIAN);
       default_map.add_reg(GPIO_ID,'h0,"RW");
       default_map.add_reg(GPIO_VERSION,'h4,"RW");
       default_map.add_reg(GPIO_DATA_IN,'h8,"RW");
       default_map.add_reg(GPIO_DATA_OUT,'hC,"RW");
       default_map.add_reg(GPIO_DIRECTION,'h10,"RW");
       default_map.add_reg(GPIO_OUTPUT_EN,'h14,"RW");
       default_map.add_reg(GPIO_STATUS,'h18,"RW");
       default_map.add_reg(GPIO_INT_ENABLE,'h1C,"RW");
       default_map.add_reg(GPIO_INT_STATUS,'h20,"RW");
       default_map.add_reg(GPIO_INT_CLEAR,'h24,"RW");

       lock_model();
    endfunction

 endclass

`endif //GPIO_REG_BLOCK_SV
