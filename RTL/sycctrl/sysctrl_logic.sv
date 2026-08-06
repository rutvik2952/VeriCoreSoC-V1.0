
module sysctrl_logic
(
    //------------------------------------------------------------
    // Global Signals
    //------------------------------------------------------------

    input  logic         clk,
    input  logic         rst_n,

    //------------------------------------------------------------
    // Register Inputs
    //------------------------------------------------------------

    input  logic         sw_reset,

    input  logic [31:0]  clock_enable,

    input  logic [31:0]  reset_control,

    input  logic [31:0]  boot_config,

    //------------------------------------------------------------
    // System Control Outputs
    //------------------------------------------------------------

    output logic         cpu_reset,

    output logic         gpio_reset,

    output logic         timer_reset,

    output logic         uart_reset,

    output logic         spi_reset,

    output logic         i2c_reset,

    output logic         dma_reset,

    //------------------------------------------------------------
    // Clock Enable Outputs
    //------------------------------------------------------------

    output logic         cpu_clk_en,

    output logic         gpio_clk_en,

    output logic         timer_clk_en,

    output logic         uart_clk_en,

    output logic         spi_clk_en,

    output logic         i2c_clk_en,

    output logic         dma_clk_en,

    //------------------------------------------------------------
    // Boot Mode
    //------------------------------------------------------------

    output sysctrl_pkg::boot_mode_e boot_mode
);

    import sysctrl_pkg::*;

    //------------------------------------------------------------
    // Peripheral Reset Generation
    //------------------------------------------------------------

    assign cpu_reset   =
            sw_reset |
            reset_control[RST_CPU_BIT];

    assign gpio_reset =
            sw_reset |
            reset_control[RST_GPIO_BIT];

    assign timer_reset =
            sw_reset |
            reset_control[RST_TIMER_BIT];

    assign uart_reset =
            sw_reset |
            reset_control[RST_UART_BIT];

    assign spi_reset =
            sw_reset |
            reset_control[RST_SPI_BIT];

    assign i2c_reset =
            sw_reset |
            reset_control[RST_I2C_BIT];

    assign dma_reset =
            sw_reset |
            reset_control[RST_DMA_BIT];

    //------------------------------------------------------------
    // Clock Enable Generation
    //------------------------------------------------------------

    assign cpu_clk_en =
            clock_enable[CLK_EN_CPU_BIT];

    assign gpio_clk_en =
            clock_enable[CLK_EN_GPIO_BIT];

    assign timer_clk_en =
            clock_enable[CLK_EN_TIMER_BIT];

    assign uart_clk_en =
            clock_enable[CLK_EN_UART_BIT];

    assign spi_clk_en =
            clock_enable[CLK_EN_SPI_BIT];

    assign i2c_clk_en =
            clock_enable[CLK_EN_I2C_BIT];

    assign dma_clk_en =
            clock_enable[CLK_EN_DMA_BIT];
			
	 
        //------------------------------------------------------------
    // Boot Mode Decode
    //------------------------------------------------------------

    always_comb
    begin

        unique case(boot_config[1:0])

            2'b00 :
                boot_mode = BOOT_ROM;

            2'b01 :
                boot_mode = BOOT_FLASH;

            2'b10 :
                boot_mode = BOOT_SRAM;

            2'b11 :
                boot_mode = BOOT_DEBUG;

            default :
                boot_mode = BOOT_ROM;

        endcase

    end

`ifndef SYNTHESIS

    //------------------------------------------------------------
    // Debug Task
    //------------------------------------------------------------

    task automatic display_sysctrl_status();

        begin

            $display("------------------------------------------");
            $display("SYSCTRL STATUS");
            $display("------------------------------------------");

            $display("SW Reset        : %0b", sw_reset);

            $display("CPU Clock       : %0b", cpu_clk_en);
            $display("GPIO Clock      : %0b", gpio_clk_en);
            $display("TIMER Clock     : %0b", timer_clk_en);
            $display("UART Clock      : %0b", uart_clk_en);
            $display("SPI Clock       : %0b", spi_clk_en);
            $display("I2C Clock       : %0b", i2c_clk_en);
            $display("DMA Clock       : %0b", dma_clk_en);

            $display("CPU Reset       : %0b", cpu_reset);
            $display("GPIO Reset      : %0b", gpio_reset);
            $display("TIMER Reset     : %0b", timer_reset);
            $display("UART Reset      : %0b", uart_reset);
            $display("SPI Reset       : %0b", spi_reset);
            $display("I2C Reset       : %0b", i2c_reset);
            $display("DMA Reset       : %0b", dma_reset);

            $display("Boot Mode       : %0d", boot_mode);

            $display("------------------------------------------");

        end

    endtask

    //------------------------------------------------------------
    // Assertions
    //------------------------------------------------------------

    // Software reset shall reset CPU

    property p_sw_reset;

        @(posedge clk)
        disable iff(!rst_n)

        sw_reset |-> cpu_reset;

    endproperty

    assert property(p_sw_reset)
        else
            $error("SYSCTRL_LOGIC : CPU reset not asserted during software reset.");

    //------------------------------------------------------------

    // Boot mode must never be unknown

    property p_boot_mode;

        @(posedge clk)
        disable iff(!rst_n)

        !$isunknown(boot_mode);

    endproperty

    assert property(p_boot_mode)
        else
            $error("SYSCTRL_LOGIC : Boot mode unknown.");

    //------------------------------------------------------------

    // Clock enable outputs must never contain X

    property p_clock_enable;

        @(posedge clk)
        disable iff(!rst_n)

        !$isunknown({
            cpu_clk_en,
            gpio_clk_en,
            timer_clk_en,
            uart_clk_en,
            spi_clk_en,
            i2c_clk_en,
            dma_clk_en
        });

    endproperty

    assert property(p_clock_enable)
        else
            $error("SYSCTRL_LOGIC : Clock enable contains unknown.");

`endif

endmodule
