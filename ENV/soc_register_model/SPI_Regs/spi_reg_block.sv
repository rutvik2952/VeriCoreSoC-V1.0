`ifndef SPI_REG_BLOCK_SV
`define SPI_REG_BLOCK_SV

class spi_reg_block extends uvm_reg_block;

  spi_id_reg      SPI_ID;
  spi_version_reg SPI_VERSION;
  spi_control_reg SPI_CONTROL;
  spi_clkdiv_reg  SPI_CLKDIV;
  spi_txdata_reg  SPI_TXDATA;
  spi_rxdata_reg  SPI_RXDATA;
  spi_status_reg  SPI_STATUS;
  spi_int_status_reg SPI_INT_STATUS;
  spi_int_clear_reg  SPI_INT_CLEAR; 

  `uvm_object_utils(spi_reg_block)

  function new(string name="spi_reg_block");
    super.new(name,UVM_NO_COVERAGE);
  endfunction

  function void build();
    SPI_ID = spi_id_reg::type_id::create("SPI_ID");
    SPI_ID.configure(this);
    SPI_ID.build();

    SPI_VERSION = spi_version_reg::type_id::create("SPI_VERSION");
    SPI_VERSION.configure(this);
    SPI_VERSION.build();
 
    SPI_CONTROL = spi_control_reg::type_id::create("SPI_CONTROL");
    SPI_CONTROL.configure(this);
    SPI_CONTROL.build();

    SPI_CLKDIV = spi_clkdiv_reg::type_id::create("SPI_CLKDIV");
    SPI_CLKDIV.configure(this);
    SPI_CLKDIV.build();

    SPI_TXDATA = spi_txdata_reg::type_id::create("SPI_TXDATA");
    SPI_TXDATA.configure(this);
    SPI_TXDATA.build();

    SPI_RXDATA = spi_rxdata_reg::type_id::create("SPI_RXDATA");
    SPI_RXDATA.configure(this);
    SPI_RXDATA.build();

    SPI_STATUS = spi_status_reg::type_id::create("SPI_STATUS");
    SPI_STATUS.configure(this);
    SPI_STATUS.build();

    SPI_INT_STATUS = spi_int_status_reg::type_id::create("SPI_INT_STATUS");
    SPI_INT_STATUS.configure(this);
    SPI_INT_STATUS.build();

    SPI_INT_CLEAR = spi_int_clear_reg::type_id::create("SPI_INT_CLEAR");
    SPI_INT_CLEAR.configure(this);
    SPI_INT_CLEAR.build();

  endfunction

endclass

`endif //SPI_INT_CLEAR
