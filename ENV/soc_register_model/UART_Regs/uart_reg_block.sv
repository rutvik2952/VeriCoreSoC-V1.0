`ifndef UART_REG_BLOCK_SV
`define UART_REG_BLOCK_SV

 class uart_reg_block extends uvm_reg_block;

   uart_id_reg         UART_ID;
   uart_version_reg    UART_VERSION;
   uart_control_reg    UART_CONTROL;
   urat_baud_reg       UART_BAUD;
   uart_txdata_reg     UART_TXDATA;
   uart_rxdata_reg     UART_RXDATA;
   uart_status_reg     UART_STATUS;
   uart_int_status_reg UART_INT_STATUS;
   uart_int_clear_reg  UART_INT_CLEAR;

   `uvm_object_utils(uart_reg_block)

  function new(string name="uart_reg_block");
     super.new(name,UVM_NO_COVERAGE);
  endfunction

  function void build();
     UART_ID =  uart_id_reg::type_id::create("UART_ID");
     UART_ID.configure(this);
     UART_ID.build();

     UART_VERSION = uart_version_reg::type_id::create("UART_VERSION");
     UART_VERSION.configure(this);
     UART_VERSION.build();

     UART_CONTROL = uart_control_reg::type_id::create("UART_CONTROL");
     UART_CONTROL.configure(this);
     UART_CONTROL.build();

     UART_BAUD = urat_baud_reg::type_id::create("UART_BAUD");
     UART_BAUD.configure(this);
     UART_BAUD.build();

     UART_TXDATA = uart_txdata_reg::type_id::create("UART_TXDATA");
     UART_TXDATA.configure(this);
     UART_TXDATA.build();
   
     UART_RXDATA = uart_rxdata_reg::type_id::create("UART_RXDATA");
     UART_RXDATA.configure(this);
     UART_RXDATA.build();

     UART_STATUS = uart_status_reg::type_id::create("UART_STATUS");
     UART_STATUS.configure(this);
     UART_STATUS.build();

     UART_INT_STATUS = uart_int_status_reg::type_id::create("UART_INT_STATUS");
     UART_INT_STATUS.configure(this);
     UART_INT_STATUS.build();

     UART_INT_CLEAR = uart_int_clear_reg::type_id::create("UART_INT_CLEAR");
     UART_INT_CLEAR.configure(this);
     UART_INT_CLEAR.build();

     default_map = create_map("default_map",'h4000_3000,4,UVM_LITTLE_ENDIAN);
     default_map.add_reg(UART_ID,'h00,"RW");
     default_map.add_reg(UART_VERSION,'h04,"RW");
     default_map.add_reg(UART_CONTROL,'h08,"RW");
     default_map.add_reg(UART_BAUD,'h0C,"RW");
     default_map.add_reg(UART_TXDATA,'h10,"RW");
     default_map.add_reg(UART_RXDATA,'h14,"RW");
     default_map.add_reg(UART_STATUS,'h18,"RW");
     default_map.add_reg(UART_INT_STATUS,'h1C,"RW");
     default_map.add_reg(UART_INT_CLEAR,'h20,"RW");

     lock_model();   

  endfunction

endclass

`endif //UART_REG_BLOCK_SV
