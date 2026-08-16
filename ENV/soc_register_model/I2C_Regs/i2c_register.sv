`ifndef I2C_REGISTER_SV
`define I2C_REGISTER_SV

 class i2c_id_reg extends uvm_reg;

   rand uvm_reg_field I2C_ID;
   
   `uvm_object_utils(i2c_id_reg)

   function new(string name="i2c_id_reg");
      super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   function void build();
     I2C_ID = uvm_reg_field::type_id::create("I2C_ID");
     I2C_ID.configure(this,32,0,"RO",0,'h4932_4320,1,1,1);
   endfunction

 endclass

 class i2c_version_reg extends uvm_reg;

   rand uvm_reg_field I2C_VERSION;

   `uvm_object_utils(i2c_version_reg)

   function new(string name="i2c_version_reg");
     super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   function void build();
     I2C_VERSION = uvm_reg_field::type_id::create("I2C_VERSION");
     I2C_VERSION.configure(this,32,0,"RO",0,'h0001_0000,1,1,1);
    
   endfunction 

 endclass

 class i2c_control_reg extends uvm_reg;

   rand uvm_reg_field I2C_ENABLE;
   rand uvm_reg_field I2C_START;
   rand uvm_reg_field I2C_STOP;
   rand uvm_reg_field I2C_RW;
   rand uvm_reg_field I2C_IRQ_EN;

   `uvm_object_utils(i2c_control_reg)

   function new(string name="i2c_control_reg");
     super.new(name,32,UVM_NO_COVERAGE);
   endfunction

  function void build();
    I2C_ENABLE = uvm_reg_field::type_id::create("I2C_ENABLE");
    I2C_ENABLE.configure(this,1,0,"RW",0,0,1,1,1);

    I2C_START = uvm_reg_field::type_id::create("I2C_START");
    I2C_START.configure(this,1,1,"RW",0,0,1,1,1);

    I2C_STOP = uvm_reg_field::type_id::create("I2C_STOP");
    I2C_STOP.configure(this,1,2,"RW",0,0,1,1,1);
   
    I2C_RW = uvm_reg_field::type_id::create("I2C_RW");
    I2C_RW.configure(this,1,3,"RW",0,0,1,1,1);

    I2C_IRQ_EN = uvm_reg_field::type_id::create("I2C_IRQ_EN");
    I2C_IRQ_EN.configure(this,1,4,"RW",0,0,1,1,1);
    
  endfunction 

 endclass

 class i2c_clkdiv_reg extends uvm_reg;
   
   rand uvm_reg_field I2C_CLKDIV;

   `uvm_object_utils(i2c_clkdiv_reg)
  
    function new (string name="i2c_clkdiv_reg");
      super.new(name,32,UVM_NO_COVERAGE);
    endfunction

    function void build();
      I2C_CLKDIV = uvm_reg_field::type_id::create("I2C_CLKDIV");
      I2C_CLKDIV.configure(this,32,0,"RW",0,'h0000_0064,1,1,1);
    endfunction

 endclass

 class i2c_address_reg extends uvm_reg;
    
   rand uvm_reg_field I2C_SLAVE_ADDR;
   
   `uvm_object_utils(i2c_address_reg)

   function new(string name="i2c_address_reg");
     super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   function void build();
     I2C_SLAVE_ADDR = uvm_reg_field::type_id::create("I2C_SLAVE_ADDR");
     I2C_SLAVE_ADDR.configure(this,7,0,"RW",0,0,1,1,1);

   endfunction

 endclass

 class i2c_txdata_reg extends uvm_reg;

   rand uvm_reg_field I2C_TXDATA;

   `uvm_object_utils(i2c_txdata_reg)

    function new(string name="i2c_txdata_reg");
      super.new(name,32,UVM_NO_COVERAGE);
    endfunction
    
    function void build();
      I2C_TXDATA = uvm_reg_field::type_id::create("I2C_TXDATA");
      I2C_TXDATA.configure(this,8,0,"WO",0,0,1,1,1);
    endfunction

 endclass

 class i2c_rxdata_reg extends uvm_reg;
   
   rand uvm_reg_field I2C_RXDATA;

   `uvm_object_utils(i2c_rxdata_reg)

   function new(string name="i2c_rxdata_reg");
     super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   function void build();
     I2C_RXDATA = uvm_reg_field::type_id::create("I2C_RXDATA");
     I2C_RXDATA.configure(this,8,0,"RO",0,0,1,1,1);
   endfunction

 endclass

 class i2c_status extends uvm_reg;

   rand uvm_reg_field I2C_BUSY;
   rand uvm_reg_field I2C_ACK;
   rand uvm_reg_field I2C_DONE;
   
   `uvm_object_utils(i2c_status)

   function new(string name="i2c_status");
     super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   function void build();
     I2C_BUSY = uvm_reg_field::type_id::create("I2C_BUSY");
     I2C_BUSY.configure(this,1,0,"RO",0,0,1,1,1);

     I2C_ACK = uvm_reg_field::type_id::create("I2C_ACK");
     I2C_ACK.configure(this,1,1,"RO",0,0,1,1,1);

     I2C_DONE = uvm_reg_field::type_id::create("I2C_DONE");
     I2C_DONE.configure(this,1,2,"RO",0,0,1,1,1);
   endfunction

 endclass

class i2c_int_status_reg extends uvm_reg;

   rand uvm_reg_field I2C_IRQ_PENDING;
   
   `uvm_object_utils(i2c_int_status_reg)

   function new(string name ="i2c_int_status_reg");
     super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   function void build();
      I2C_IRQ_PENDING = uvm_reg_field::type_id::create("I2C_IRQ_PENDING");
      I2C_IRQ_PENDING.configure(this,1,0,"RO",0,0,1,1,1);
   endfunction

endclass

class i2c_int_clear extends uvm_reg;

   rand uvm_reg_field I2C_IRQ_CLEAR;

   `uvm_object_utils(i2c_int_clear)

   function new(string name="i2c_int_clear");
     super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   function void build();
     I2C_IRQ_CLEAR = uvm_reg_field::type_id::create("I2C_IRQ_CLEAR");
     I2C_IRQ_CLEAR.configure(this,32,0,"WO",0,0,1,1,1);
   endfunction

endclass

`endif //I2C_REGISTER_SV
