lib:
	vlib work


common_rtl = ../RTL/common/apb_pkg.sv \
             ../RTL/common/common_pkg.sv \
             ../RTL/common/soc_pkg.sv \
             ../RTL/common/bus_arbiter.sv

apb_rtl = ../RTL/APB/apb_master.sv \
          ../RTL/APB/apb_slave.sv \
          ../RTL/APB/apb_decoder.sv \
          ../RTL/APB/apb_default_slave.sv \
          ../RTL/APB/apb_mux.sv \
          ../RTL/APB/apb_interconnect.sv

memory_rtl = ../RTL/Memmory/memory_pkg.sv \
	     ../RTL/Memmory/generic_ram.sv \
	     ../RTL/Memmory/data_ram.sv \
	     ../RTL/Memmory/dma_ram.sv \
	     ../RTL/Memmory/fifo_ram.sv \
	     ../RTL/Memmory/instruction_ram.sv \
	     ../RTL/Memmory/memeory_decoder.sv

bootrom_rtl =	../RTL/Bootrom/bootrom_pkg.sv \
		../RTL/Bootrom/bootrom_reg.sv  \
	        ../RTL/Bootrom/bootrom_logic.sv \
		../RTL/Bootrom/bootrom_top.sv

dma_rtl =	../RTL/DMA/dma_pkg.sv \
		../RTL/DMA/dma_regs.sv  \
	        ../RTL/DMA/dma_logic.sv \
		../RTL/DMA/dma_top.sv

gpio_rtl =	../RTL/GPIO/gpio_pkg.sv \
		../RTL/GPIO/gpio_reg.sv \
	        ../RTL/GPIO/gpio_logic.sv \
		../RTL/GPIO/gpio_top.sv

cpu_rtl = 	../RTL/CPU/cpu_pkg.sv \
 	        ../RTL/CPU/cpu_regfile.sv \
    	        ../RTL/CPU/cpu_pc.sv \
                ../RTL/CPU/cpu_alu.sv \
		../RTL/CPU/cpu_fetch.sv \
		../RTL/CPU/cpu_decoder.sv \
	        ../RTL/CPU/cpu_execute.sv \
                ../RTL/CPU/cpu_interrupt.sv \
		../RTL/CPU/cpu_apb_master.sv \
		../RTL/CPU/cpu_top.sv

i2c_rtl =	../RTL/I2C/i2c_pkg.sv \
		../RTL/I2C/i2c_regs.sv  \
	        ../RTL/I2C/i2c_logic.sv \
		../RTL/I2C/i2c_top.sv

intc_rtl =	../RTL/INTC/intc_pkg.sv \
		../RTL/INTC/intc_reg.sv  \
	        ../RTL/INTC/intc_logic.sv \
		../RTL/INTC/intc_top.sv

spi_rtl =	../RTL/SPI/spi_pkg.sv \
		../RTL/SPI/spi_reg.sv  \
	        ../RTL/SPI/spi_logic.sv \
		../RTL/SPI/spi_top.sv
	
sysctrl_rtl =	../RTL/sycctrl/sysctrl_pkg.sv \
		../RTL/sycctrl/sysctrl_regs.sv  \
	        ../RTL/sycctrl/sysctrl_logic.sv \
		../RTL/sycctrl/sysctrl_top.sv

timer_rtl =	../RTL/TIMER/timer_pkg.sv \
		../RTL/TIMER/timer_reg.sv  \
	        ../RTL/TIMER/timer_logic.sv \
		../RTL/TIMER/timer_top.sv

uart_rtl =	../RTL/UART/uart_pkg.sv \
		../RTL/UART/uart_regs.sv  \
	        ../RTL/UART/uart_logic.sv \
		../RTL/UART/uart_top.sv

soc_top = 	../RTL/SOC_TOP/soc_top.sv

soc_rtl =  $(common_rtl) $(apb_rtl) $(memory_rtl) $(bootrom_rtl) $(dma_rtl) $(gpio_rtl) $(cpu_rtl) $(i2c_rtl) $(intc_rtl) $(spi_rtl) $(sysctrl_rtl) $(timer_rtl) $(uart_rtl) $(soc_top)

comp:
	vlog $(soc_rtl)
