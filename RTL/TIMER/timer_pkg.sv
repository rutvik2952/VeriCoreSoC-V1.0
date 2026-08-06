
package timer_pkg;

    //------------------------------------------------------------
    // Timer Configuration
    //------------------------------------------------------------

    parameter int TIMER_WIDTH = 32;

    //------------------------------------------------------------
    // Peripheral Identification
    //------------------------------------------------------------

    parameter logic [31:0] TIMER_ID      = 32'h5449_4D52; // "TIMR"

    parameter logic [31:0] TIMER_VERSION = 32'h0001_0000;

    //------------------------------------------------------------
    // Register Address Map
    //------------------------------------------------------------

    parameter logic [31:0] TIMER_BASE_ADDR       = 32'h4000_2000;

    parameter logic [31:0] TIMER_ID_ADDR         = TIMER_BASE_ADDR + 32'h00;

    parameter logic [31:0] TIMER_VERSION_ADDR    = TIMER_BASE_ADDR + 32'h04;

    parameter logic [31:0] TIMER_CONTROL_ADDR    = TIMER_BASE_ADDR + 32'h08;

    parameter logic [31:0] TIMER_LOAD_ADDR       = TIMER_BASE_ADDR + 32'h0C;

    parameter logic [31:0] TIMER_COUNT_ADDR      = TIMER_BASE_ADDR + 32'h10;

    parameter logic [31:0] TIMER_STATUS_ADDR     = TIMER_BASE_ADDR + 32'h14;

    parameter logic [31:0] TIMER_INT_STATUS_ADDR = TIMER_BASE_ADDR + 32'h18;

    parameter logic [31:0] TIMER_INT_CLEAR_ADDR  = TIMER_BASE_ADDR + 32'h1C;

    //------------------------------------------------------------
    // Register Reset Values
    //------------------------------------------------------------

    parameter logic [31:0] RESET_TIMER_CONTROL   = 32'h0000_0000;

    parameter logic [31:0] RESET_TIMER_LOAD      = 32'h0000_0000;

    parameter logic [31:0] RESET_TIMER_COUNT     = 32'h0000_0000;

    parameter logic [31:0] RESET_TIMER_STATUS    = 32'h0000_0000;

    parameter logic [31:0] RESET_TIMER_INT_STAT  = 32'h0000_0000;
	
	    //------------------------------------------------------------
    // Timer Control Register Bit Definitions
    //------------------------------------------------------------

    parameter int TIMER_ENABLE_BIT     = 0;

    parameter int TIMER_MODE_BIT       = 1;

    parameter int TIMER_IRQ_ENABLE_BIT = 2;

    //------------------------------------------------------------
    // Timer Status Register Bit Definitions
    //------------------------------------------------------------

    parameter int TIMER_RUNNING_BIT    = 0;

    parameter int TIMER_TIMEOUT_BIT    = 1;

    //------------------------------------------------------------
    // Timer Mode
    //------------------------------------------------------------

    typedef enum logic
    {
        TIMER_ONE_SHOT = 1'b0,
        TIMER_PERIODIC = 1'b1

    } timer_mode_e;

    //------------------------------------------------------------
    // Timer State
    //------------------------------------------------------------

    typedef enum logic [1:0]
    {
        TIMER_IDLE,

        TIMER_RUNNING,

        TIMER_TIMEOUT

    } timer_state_e;

    //------------------------------------------------------------
    // Timer Status Structure
    //------------------------------------------------------------

    typedef struct packed
    {
        logic running;

        logic timeout;

    } timer_status_t;

    //------------------------------------------------------------
    // Register Type
    //------------------------------------------------------------

    typedef logic [31:0] timer_reg_t;

    //------------------------------------------------------------
    // Address Validation
    //------------------------------------------------------------

    function automatic logic is_valid_address
    (
        input logic [31:0] addr
    );

        case(addr)

            TIMER_ID_ADDR,
            TIMER_VERSION_ADDR,
            TIMER_CONTROL_ADDR,
            TIMER_LOAD_ADDR,
            TIMER_COUNT_ADDR,
            TIMER_STATUS_ADDR,
            TIMER_INT_STATUS_ADDR,
            TIMER_INT_CLEAR_ADDR :

                is_valid_address = 1'b1;

            default :

                is_valid_address = 1'b0;

        endcase

    endfunction

    //------------------------------------------------------------
    // Read Only Register Check
    //------------------------------------------------------------

    function automatic logic is_read_only
    (
        input logic [31:0] addr
    );

        case(addr)

            TIMER_ID_ADDR,
            TIMER_VERSION_ADDR,
            TIMER_COUNT_ADDR,
            TIMER_STATUS_ADDR,
            TIMER_INT_STATUS_ADDR :

                is_read_only = 1'b1;

            default :

                is_read_only = 1'b0;

        endcase

    endfunction

endpackage