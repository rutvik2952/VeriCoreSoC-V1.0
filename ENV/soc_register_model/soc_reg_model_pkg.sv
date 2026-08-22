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

    `include"SYSCTRL_Regs/sysctrl_reg_block.sv"
    `include"INTC_Regs/intc_reg_block.sv"
    `include"TIMER_Regs/timer_reg_block.sv"
    `include"GPIO_Regs/gpio_reg_block.sv"
    `include"UART_Regs/uart_reg_block.sv"
    `include"SPI_Regs/spi_reg_block.sv"
    `include"soc_reg_block_model.sv"

 endpackage

`endif //SOC_REG_MODEL_PKG_SV
