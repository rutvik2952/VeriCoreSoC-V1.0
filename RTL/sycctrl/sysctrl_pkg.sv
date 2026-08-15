`timescale 1ns/1ps

package sysctrl_pkg;

    import soc_pkg::*;
    //------------------------------------------------------------
    // System Identification
    //------------------------------------------------------------

    parameter logic [31:0] SYS_ID       = 32'h5449_4E59; // "TINY"

    parameter logic [31:0] SYS_VERSION  = 32'h0001_0000; // v1.0

    //------------------------------------------------------------
    // Register Address Map
    //------------------------------------------------------------
    parameter logic [31:0] SYSCTRL_BASE_ADDR    = 32'h4000_0000;
 
    parameter logic [31:0] SYS_ID_ADDR          = SYSCTRL_BASE_ADDR + 32'h0000_0000;

    parameter logic [31:0] SYS_VERSION_ADDR     = SYSCTRL_BASE_ADDR + 32'h0000_0004;

    parameter logic [31:0] SYS_STATUS_ADDR      = SYSCTRL_BASE_ADDR + 32'h0000_0008;

    parameter logic [31:0] SYS_CONTROL_ADDR     = SYSCTRL_BASE_ADDR + 32'h0000_000C;

    parameter logic [31:0] RESET_CONTROL_ADDR   = SYSCTRL_BASE_ADDR + 32'h0000_0010;

    parameter logic [31:0] CLOCK_ENABLE_ADDR    = SYSCTRL_BASE_ADDR + 32'h0000_0014;

    parameter logic [31:0] BOOT_CONFIG_ADDR     = SYSCTRL_BASE_ADDR + 32'h0000_0018;

    parameter logic [31:0] SCRATCH0_ADDR        = SYSCTRL_BASE_ADDR + 32'h0000_001C;

    parameter logic [31:0] SCRATCH1_ADDR        = SYSCTRL_BASE_ADDR + 32'h0000_0020;

    parameter logic [31:0] SCRATCH2_ADDR        = SYSCTRL_BASE_ADDR + 32'h0000_0024;

    parameter logic [31:0] SCRATCH3_ADDR        = SYSCTRL_BASE_ADDR + 32'h0000_0028;

    //------------------------------------------------------------
    // Reset Values
    //------------------------------------------------------------

    parameter logic [31:0] RESET_SYS_CONTROL   = 32'h0000_0000;

    parameter logic [31:0] RESET_CLOCK_ENABLE  = 32'h0000_0000;

    parameter logic [31:0] RESET_RESET_CONTROL = 32'h0000_0000;

    parameter logic [31:0] RESET_BOOT_CONFIG   = 32'h0000_0000;

    parameter logic [31:0] RESET_SCRATCH       = 32'h0000_0000;

    //------------------------------------------------------------
    // Bit Definitions
    //------------------------------------------------------------

    parameter int SYSCTRL_SW_RESET_BIT = 0;

    parameter int SYSCTRL_SLEEP_BIT    = 1;

    parameter int SYSCTRL_DEBUG_BIT    = 2;

    parameter int SYSCTRL_BOOT_BIT     = 3;
	
	    //------------------------------------------------------------
    // Clock Enable Register Bit Definitions
    //------------------------------------------------------------

    parameter int CLK_EN_CPU_BIT      = 0;
    parameter int CLK_EN_GPIO_BIT     = 1;
    parameter int CLK_EN_TIMER_BIT    = 2;
    parameter int CLK_EN_UART_BIT     = 3;
    parameter int CLK_EN_SPI_BIT      = 4;
    parameter int CLK_EN_I2C_BIT      = 5;
    parameter int CLK_EN_DMA_BIT      = 6;

    //------------------------------------------------------------
    // Peripheral Reset Register Bit Definitions
    //------------------------------------------------------------

    parameter int RST_CPU_BIT         = 0;
    parameter int RST_GPIO_BIT        = 1;
    parameter int RST_TIMER_BIT       = 2;
    parameter int RST_UART_BIT        = 3;
    parameter int RST_SPI_BIT         = 4;
    parameter int RST_I2C_BIT         = 5;
    parameter int RST_DMA_BIT         = 6;

    //------------------------------------------------------------
    // Register Types
    //------------------------------------------------------------

    typedef logic [31:0] sysctrl_reg_t;

    //------------------------------------------------------------
    // Boot Mode
    //------------------------------------------------------------

    typedef enum logic [1:0]
    {
        BOOT_ROM    = 2'd0,
        BOOT_FLASH  = 2'd1,
        BOOT_SRAM   = 2'd2,
        BOOT_DEBUG  = 2'd3

    } boot_mode_e;

    //------------------------------------------------------------
    // System Status Structure
    //------------------------------------------------------------

    typedef struct packed
    {
        logic cpu_running;
        logic irq_pending;
        logic sleep_mode;
        logic debug_mode;

        logic [27:0] reserved;

    } sys_status_t;

    //------------------------------------------------------------
    // Helper Functions
    //------------------------------------------------------------

    function automatic logic is_valid_address
    (
        input logic [31:0] addr
    );

        case(addr)

            SYS_ID_ADDR,
            SYS_VERSION_ADDR,
            SYS_STATUS_ADDR,
            SYS_CONTROL_ADDR,
            RESET_CONTROL_ADDR,
            CLOCK_ENABLE_ADDR,
            BOOT_CONFIG_ADDR,
            SCRATCH0_ADDR,
            SCRATCH1_ADDR,
            SCRATCH2_ADDR,
            SCRATCH3_ADDR :

                is_valid_address = 1'b1;

            default :

                is_valid_address = 1'b0;

        endcase

    endfunction

    //------------------------------------------------------------

    function automatic logic is_read_only
    (
        input logic [31:0] addr
    );

        case(addr)

            SYS_ID_ADDR,
            SYS_VERSION_ADDR,
            SYS_STATUS_ADDR :

                is_read_only = 1'b1;

            default :

                is_read_only = 1'b0;

        endcase

    endfunction

endpackage
