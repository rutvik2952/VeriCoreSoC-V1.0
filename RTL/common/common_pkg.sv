`ifndef COMMON_PKG_SV
`define COMMON_PKG_SV

package common_pkg;

    //------------------------------------------------------------
    // Common Constants
    //------------------------------------------------------------

    parameter int BYTE_WIDTH = 8;
    parameter int HALF_WORD  = 16;
    parameter int WORD_WIDTH = 32;
    parameter int DWORD_WIDTH = 64;

    parameter int MAX_IRQS      = 32;
    parameter int MAX_GPIO      = 32;
    parameter int MAX_DMA_CH    = 4;
    parameter int MAX_TIMERS    = 4;

    //------------------------------------------------------------
    // Register Access Types
    //------------------------------------------------------------

    typedef enum logic [4:0]
    {
        REG_RO      = 5'd0,
        REG_RW      = 5'd1,
        REG_WO      = 5'd2,
        REG_W1C     = 5'd3,
        REG_W1S     = 5'd4,
        REG_W0C     = 5'd5,
        REG_W0S     = 5'd6,
        REG_RC      = 5'd7,
        REG_RS      = 5'd8,
        REG_WRC     = 5'd9,
        REG_W1T     = 5'd10,
        REG_W0T     = 5'd11,
        REG_VOLATILE= 5'd12
    } reg_access_e;

    //------------------------------------------------------------
    // Peripheral State
    //------------------------------------------------------------

    typedef enum logic [2:0]
    {
        ST_IDLE,
        ST_BUSY,
        ST_DONE,
        ST_ERROR,
        ST_TIMEOUT
    } state_e;

    //------------------------------------------------------------
    // Generic Register
    //------------------------------------------------------------

    typedef struct packed
    {
        logic [31:0] value;
        logic [31:0] reset_value;
        logic [31:0] write_mask;
    } reg32_t;

    //------------------------------------------------------------
    // Timer Structure
    //------------------------------------------------------------

    typedef struct packed
    {
        logic enable;
        logic periodic;
        logic irq_en;
        logic pwm_mode;
        logic watchdog;
        logic [26:0] reserved;
    } timer_ctrl_t;

    //------------------------------------------------------------
    // GPIO Structure
    //------------------------------------------------------------

    typedef struct packed
    {
        logic [31:0] direction;
        logic [31:0] output_data;
        logic [31:0] input_data;
    } gpio_reg_t;

    //------------------------------------------------------------
    // DMA Descriptor
    //------------------------------------------------------------

    typedef struct packed
    {
        logic [31:0] src_addr;
        logic [31:0] dst_addr;
        logic [31:0] transfer_size;
        logic [31:0] control;
    } dma_descriptor_t;

    //------------------------------------------------------------
    // APB Error Codes
    //------------------------------------------------------------

    typedef enum logic [2:0]
    {
        APB_OKAY           = 3'd0,
        APB_ADDR_ERROR     = 3'd1,
        APB_TIMEOUT        = 3'd2,
        APB_PERMISSION     = 3'd3,
        APB_ALIGNMENT      = 3'd4
    } apb_error_e;

endpackage

`endif