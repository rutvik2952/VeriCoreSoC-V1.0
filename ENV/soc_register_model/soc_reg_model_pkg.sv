`ifndef SOC_REG_MODEL_PKG_SV
`define SOC_REG_MODEL_PKG_SV

 package soc_reg_model_pkg;
   `include"uvm_macros.svh"
    import uvm_pkg::*;
    //import spi_reg_pkg::*;
    //import uart_reg_pkg::*;
    `include"SPI_Regs/spi_register.sv"
    `include"UART_Regs/urat_register.sv"
 endpackage

`endif //SOC_REG_MODEL_PKG_SV
