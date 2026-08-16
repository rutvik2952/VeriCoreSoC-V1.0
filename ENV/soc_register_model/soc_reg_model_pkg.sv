`ifndef SOC_REG_MODEL_PKG_SV
`define SOC_REG_MODEL_PKG_SV

 package soc_reg_model_pkg;
   `include"uvm_macros.svh"
    import uvm_pkg::*;
    `include"SPI_Regs/spi_register.sv"
    `include"UART_Regs/urat_register.sv"
    `include"SYSCTRL_Regs/sysctrl_register.sv"
    `include"INTC_Regs/intc_register.sv"
    `include"TIMER_Regs/timer_register.sv"
    `include"BOOTROM_Regs/bootrom_register.sv"
    `include"DMA_Regs/dma_register.sv"
    `include"GPIO_Regs/gpio_register.sv"
    `include"I2C_Regs/i2c_register.sv"

 endpackage

`endif //SOC_REG_MODEL_PKG_SV
