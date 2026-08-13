`ifndef SPI_REGISTER_SV
`define SPI_REGISTER_SV

class spi_id_reg extends uvm_reg;

  rand uvm_reg_field SPI_ID;

  //Factory Registration
  `uvm_object_utils(spi_id_reg)

  function new(string name ="spi_id_reg");
    super.new(name,32,UVM_NO_COVERAGE);
  endfunction

 function void build();
   SPI_ID = uvm_reg_field::type_id::create("SPI_ID");
   SPI_ID.configure(this,32,0,"RO",0,'h5350_4920,1,1,1);
 endfunction

endclass

class spi_version_reg extends uvm_reg;
 
  rand uvm_reg_field SPI_VERSION;

  `uvm_object_utils(spi_version_reg)

   function new(string name ="spi_version_reg");
      super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   function void build();
     SPI_VERSION = uvm_reg_field::type_id::create("SPI_VERSION");
     SPI_VERSION.configure(this,32,0,"RO",0,'h0001_0000,1,1,1);
   endfunction

endclass

class spi_control_reg extends uvm_reg;

   rand uvm_reg_field SPI_ENABLE;
   rand uvm_reg_field SPI_MASTER;
   rand uvm_reg_field SPI_CPOL;
   rand uvm_reg_field SPI_CPHA;
   rand uvm_reg_field SPI_TX_IRQ_EN;
   rand uvm_reg_field SPI_RX_IRQ_EN;
   rand uvm_reg_field SPI_DATA16;
  
   `uvm_object_utils(spi_control_reg)

    function new(string name="spi_control_reg");
      super.new(name,32,UVM_NO_COVERAGE);
    endfunction

   function void build();
     SPI_ENABLE =  uvm_reg_field::type_id::create("SPI_ENABLE");
     SPI_ENABLE.configure( this,1,0,"RW",0,0,1,1,1);

     SPI_MASTER = uvm_reg_field::type_id::create("SPI_MASTER");
     SPI_MASTER.configure(this,1,1,"RW",0,0,1,1,1);

     SPI_CPOL = uvm_reg_field::type_id::create("SPI_CPOL");
     SPI_CPOL.configure(this,1,2,"RW",0,0,1,1,1);
    
     SPI_CPHA = uvm_reg_field::type_id::create("SPI_CPHA");
     SPI_CPHA.configure(this,1,3,"RW",0,0,1,1,1);

     SPI_TX_IRQ_EN = uvm_reg_field::type_id::create("SPI_TX_IRQ_EN");
     SPI_TX_IRQ_EN.configure(this,1,4,"RW",0,0,1,1,1);

     SPI_RX_IRQ_EN = uvm_reg_field::type_id::create("SPI_RX_IRQ_EN");
     SPI_RX_IRQ_EN.configure(this,1,6,"RW",0,0,1,1,1);
   endfunction

endclass

class spi_clkdiv_reg extends uvm_reg;

  rand  uvm_reg_field SPI_CLKDIV;

  `uvm_object_utils(spi_clkdiv_reg)

  function new(string name="spi_clkdiv_reg");
    super.new(name,32,UVM_NO_COVERAGE);
  endfunction

  function void build();
    SPI_CLKDIV = uvm_reg_field::type_id::create("SPI_CLKDIV");
    SPI_CLKDIV.configure(this,16,0,"RW",0,'h4,1,1,1); 
  endfunction

endclass

class spi_txdata_reg extends uvm_reg;
   
  rand uvm_reg_field SPI_TXDATA;

  `uvm_object_utils(spi_txdata_reg)

  function new(string name="spi_txdata_reg");
    super.new(name,32,UVM_NO_COVERAGE);
  endfunction

  function void build();
     SPI_TXDATA = uvm_reg_field::type_id::create("SPI_TXDATA");
     SPI_TXDATA.configure(this,16,0,"WO",0,0,1,1,1);
  endfunction

endclass 
 
class spi_rxdata_reg extends uvm_reg;

   rand uvm_reg_field SPI_RXDATA;
   
   `uvm_object_utils(spi_rxdata_reg)

   function new(string name="spi_rxdata_reg");
     super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   function void build();
     SPI_RXDATA = uvm_reg_field::type_id::create("SPI_RXDATA");
     SPI_RXDATA.configure(this,16,0,"RO",0,0,1,1,1); 
   endfunction

endclass

class spi_status_reg extends uvm_reg;

  rand uvm_reg_field SPI_BUSY;
  rand uvm_reg_field SPI_TX_EMPTY;
  rand uvm_reg_field SPI_TX_FULL;
  rand uvm_reg_field SPI_RX_EMPTY;
  rand uvm_reg_field SPI_RX_FULL;
  rand uvm_reg_field SPI_TX_DONE;
  rand uvm_reg_field SPI_RX_DONE;

  `uvm_object_utils(spi_status_reg)

   function new(string name ="spi_status_reg");
     super.new(name,32,UVM_NO_COVERAGE);
   endfunction
   
   function void build();
     SPI_BUSY = uvm_reg_field::type_id::create("SPI_BUSY");
     SPI_BUSY.configure(this,1,0,"RO",0,0,1,1,1);

     SPI_TX_EMPTY = uvm_reg_field::type_id::create("SPI_TX_EMPTY");
     SPI_TX_EMPTY.configure(this,1,1,"RO",0,0,1,1,1);

     SPI_TX_FULL = uvm_reg_field::type_id::create("SPI_TX_FULL");
     SPI_TX_FULL.configure(this,1,2,"RO",0,0,1,1,1);

     SPI_RX_EMPTY = uvm_reg_field::type_id::create("SPI_RX_EMPTY");
     SPI_RX_EMPTY.configure(this,1,3,"RO",0,0,1,1,1);

     SPI_RX_FULL = uvm_reg_field::type_id::create("SPI_RX_FULL");
     SPI_RX_FULL.configure(this,1,4,"RO",0,0,1,1,1);
    
     SPI_TX_DONE = uvm_reg_field::type_id::create("SPI_TX_DONE");
     SPI_TX_DONE.configure(this,1,5,"RO",0,0,1,1,1);

     SPI_RX_DONE = uvm_reg_field::type_id::create("SPI_RX_DONE");
     SPI_RX_DONE.configure(this,1,6,"RO",0,0,1,1,1); 
   endfunction 

endclass

class spi_int_status_reg extends uvm_reg;

  rand uvm_reg_field SPI_IRQ_PENDING;

  `uvm_object_utils(spi_int_status_reg)

  function new(string name="spi_int_status_reg");
     super.new(name,32,UVM_NO_COVERAGE);
  endfunction

  function void build();
     SPI_IRQ_PENDING = uvm_reg_field::type_id::create("SPI_IRQ_PENDING");
     SPI_IRQ_PENDING.configure(this,1,0,"RO",0,0,1,1,1);
  endfunction

endclass

class spi_int_clear_reg extends uvm_reg;

   rand uvm_reg_field SPI_IRQ_CLEAR;

   `uvm_object_utils(spi_int_clear_reg)

    function new(string name="spi_int_clear_reg");
      super.new(name,32,UVM_NO_COVERAGE);
    endfunction

    function void build();
      SPI_IRQ_CLEAR = uvm_reg_field::type_id::create("SPI_IRQ_CLEAR");
      SPI_IRQ_CLEAR.configure(this,1,0,"WO",0,0,1,1,1);
    endfunction

endclass

`endif //SPI_REGISTER_SV
