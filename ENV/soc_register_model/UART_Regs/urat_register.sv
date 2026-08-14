`ifndef UART_REGISTER_SV
`define UART_REGISTER_SV

 class uart_id_reg extends uvm_reg;

  rand uvm_reg_field UART_ID;

   `uvm_object_utils(uart_id_reg)

    function new(string name = "uart_id_reg");
       super.new(name,32,UVM_NO_COVERAGE);
    endfunction

   function void build();
     UART_ID =  uvm_reg_field::type_id::create("UART_ID");
     UART_ID.configure(this,32,0,"RO",0,'h5541_5254,1,1,1);
   endfunction

 endclass

class uart_version_reg extends uvm_reg;

   rand uvm_reg_field UART_VERSION;

  `uvm_object_utils(uart_version_reg)

   function new(string name="uart_version_reg");
     super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   function void build();
     UART_VERSION = uvm_reg_field::type_id::create("UART_VERSION");
     UART_VERSION.configure(this,32,0,"RO",0,'h0001_0000,1,1,1); 
   endfunction

endclass

class uart_control_reg extends uvm_reg;

   rand uvm_reg_field UART_ENABLE;
   rand uvm_reg_field URAT_TX_ENABLE;
   rand uvm_reg_field UART_RX_ENABLE;
   rand uvm_reg_field UART_TX_IRQ_EN;
   rand uvm_reg_field URAT_RX_IRQ_EN;
  
  `uvm_object_utils(uart_control_reg)

   function new(string name ="uart_control_reg");
      super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   function void build();
     UART_ENABLE = uvm_reg_field::type_id::create("UART_ENABLE");
     UART_ENABLE.configure(this,1,0,"RW",0,0,1,1,1);
     
     URAT_TX_ENABLE = uvm_reg_field::type_id::create("URAT_TX_ENABLE");
     URAT_TX_ENABLE.configure(this,1,1,"RW",0,0,1,1,1);

     UART_RX_ENABLE = uvm_reg_field::type_id::create("UART_RX_ENABLE");
     UART_RX_ENABLE.configure(this,1,2,"RW",0,0,1,1,1);

     UART_TX_IRQ_EN = uvm_reg_field::type_id::create("UART_TX_IRQ_EN");
     UART_TX_IRQ_EN.configure(this,1,3,"RW",0,0,1,1,1);

     URAT_RX_IRQ_EN = uvm_reg_field::type_id::create("URAT_RX_IRQ_EN");
     URAT_RX_IRQ_EN.configure(this,1,4,"RW",0,0,1,1,1);

   endfunction
  
endclass

class urat_baud_reg extends uvm_reg;

   rand uvm_reg_field UART_BAUD;

   `uvm_object_utils(urat_baud_reg)

    function new(string name="urat_baud_reg");
      super.new(name,32,UVM_NO_COVERAGE);
    endfunction

    function void build();
      UART_BAUD = uvm_reg_field::type_id::create("UART_BAUD");
      UART_BAUD.configure(this,16,0,"RW",0,0,1,1,1);
      
    endfunction

endclass

class uart_txdata_reg extends uvm_reg;

   rand uvm_reg_field UART_TXDATA;

   `uvm_object_utils(uart_txdata_reg)

   function new(string name="uart_txdata_reg");
     super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   function void build();
     UART_TXDATA = uvm_reg_field::type_id::create("UART_TXDATA");
     UART_TXDATA.configure(this,8,0,"WO",0,0,1,1,1);
   endfunction

endclass

class uart_rxdata_reg extends uvm_reg;

   rand uvm_reg_field UART_RXDATA;

   `uvm_object_utils(uart_rxdata_reg)

    function new(string name="uart_rxdata_reg");
      super.new(name,32,UVM_NO_COVERAGE);
    endfunction

    function void build();
      UART_RXDATA = uvm_reg_field::type_id::create("UART_RXDATA");
      UART_RXDATA.configure(this,8,0,"RO",0,0,1,1,1);
    endfunction


endclass

class uart_status_reg extends uvm_reg;

   rand uvm_reg_field TX_BUSY;
   rand uvm_reg_field RX_VALID;
   rand uvm_reg_field TX_FIFO_FULL;
   rand uvm_reg_field TX_FIFO_EMPTY;
   rand uvm_reg_field RX_FIFO_FULL;
   rand uvm_reg_field RX_FIFO_EMPTY;

   `uvm_object_utils(uart_status_reg)

    function new(string name="uart_status_reg");
      super.new(name,32,UVM_NO_COVERAGE);
    endfunction

    function void build();
      TX_BUSY = uvm_reg_field::type_id::create("TX_BUSY");
      TX_BUSY.configure(this,1,0,"RO",0,0,1,1,1);
     
      RX_VALID = uvm_reg_field::type_id::create("RX_VALID");
      RX_VALID.configure(this,1,1,"RO",0,0,1,1,1);

      TX_FIFO_FULL = uvm_reg_field::type_id::create("TX_FIFO_FULL");
      TX_FIFO_FULL.configure(this,1,2,"RO",0,0,1,1,1);
    
      TX_FIFO_EMPTY = uvm_reg_field::type_id::create("TX_FIFO_EMPTY");
      TX_FIFO_EMPTY.configure(this,1,3,"RO",0,0,1,1,1);

      RX_FIFO_FULL = uvm_reg_field::type_id::create("RX_FIFO_FULL");
      RX_FIFO_FULL.configure(this,1,4,"RO",0,0,1,1,1);

      RX_FIFO_EMPTY = uvm_reg_field::type_id::create("RX_FIFO_EMPTY");
      RX_FIFO_EMPTY.configure(this,1,5,"RO",0,0,1,1,1);

    endfunction

endclass

class uart_int_status_reg extends uvm_reg;

   rand uvm_reg_field URAT_IRQ_PENDING;

   `uvm_object_utils(uart_int_status_reg)

   function new(string name="uart_int_status_reg");
     super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   function void build();
     URAT_IRQ_PENDING = uvm_reg_field::type_id::create("URAT_IRQ_PENDING");
     URAT_IRQ_PENDING.configure(this,1,0,"RO",0,0,1,1,1);
      
   endfunction 

endclass

class uart_int_clear_reg extends uvm_reg;

    rand uvm_reg_field URAT_IRQ_CLEAR;

    `uvm_object_utils(uart_int_clear_reg)

    function new(string name="uart_int_clear_reg");
      super.new(name,32,UVM_NO_COVERAGE);
    endfunction

    function void build();
      URAT_IRQ_CLEAR = uvm_reg_field::type_id::create("URAT_IRQ_CLEAR");
      URAT_IRQ_CLEAR.configure(this,1,0,"WO",0,0,1,1,1);
    endfunction

endclass

`endif //UART_REGISTER_SV
