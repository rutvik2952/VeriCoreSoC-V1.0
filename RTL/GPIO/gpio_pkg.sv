`timescale 1ns/1ps

package gpio_pkg;

    //------------------------------------------------------------
    // GPIO Configuration
    //------------------------------------------------------------

    parameter int GPIO_WIDTH = 32;

    //------------------------------------------------------------
    // Peripheral Identification
    //------------------------------------------------------------

    parameter logic [31:0] GPIO_ID      = 32'h4750_494F; // "GPIO"

    parameter logic [31:0] GPIO_VERSION = 32'h0001_0000;

    //------------------------------------------------------------
    // Register Address Map
    //------------------------------------------------------------

    parameter logic [31:0] GPIO_BASE_ADDR      = 32'h4000_1000;

    parameter logic [31:0] GPIO_ID_ADDR        = GPIO_BASE_ADDR + 32'h00;

    parameter logic [31:0] GPIO_VERSION_ADDR   = GPIO_BASE_ADDR + 32'h04;

    parameter logic [31:0] GPIO_DATA_IN_ADDR   = GPIO_BASE_ADDR + 32'h08;

    parameter logic [31:0] GPIO_DATA_OUT_ADDR  = GPIO_BASE_ADDR + 32'h0C;

    parameter logic [31:0] GPIO_DIRECTION_ADDR = GPIO_BASE_ADDR + 32'h10;

    parameter logic [31:0] GPIO_OUTPUT_EN_ADDR = GPIO_BASE_ADDR + 32'h14;

    parameter logic [31:0] GPIO_STATUS_ADDR    = GPIO_BASE_ADDR + 32'h18;

    parameter logic [31:0] GPIO_INT_ENABLE_ADDR= GPIO_BASE_ADDR + 32'h1C;

    parameter logic [31:0] GPIO_INT_STATUS_ADDR= GPIO_BASE_ADDR + 32'h20;

    parameter logic [31:0] GPIO_INT_CLEAR_ADDR = GPIO_BASE_ADDR + 32'h24;

    //------------------------------------------------------------
    // Register Reset Values
    //------------------------------------------------------------

    parameter logic [31:0] RESET_DATA_OUT   = 32'h0000_0000;

    parameter logic [31:0] RESET_DIRECTION  = 32'h0000_0000;

    parameter logic [31:0] RESET_OUTPUT_EN  = 32'h0000_0000;

    parameter logic [31:0] RESET_INT_ENABLE = 32'h0000_0000;

    parameter logic [31:0] RESET_INT_STATUS = 32'h0000_0000;
	
	    //------------------------------------------------------------
    // GPIO Direction
    //------------------------------------------------------------

    typedef enum logic
    {
        GPIO_INPUT  = 1'b0,
        GPIO_OUTPUT = 1'b1

    } gpio_direction_e;

    //------------------------------------------------------------
    // GPIO Status Structure
    //------------------------------------------------------------

    typedef struct packed
    {
        logic [GPIO_WIDTH-1:0] gpio_input;
        logic [GPIO_WIDTH-1:0] gpio_output;
        logic [GPIO_WIDTH-1:0] gpio_direction;

    } gpio_status_t;

    //------------------------------------------------------------
    // Register Type
    //------------------------------------------------------------

    typedef logic [31:0] gpio_reg_t;

    //------------------------------------------------------------
    // Helper Function
    //------------------------------------------------------------

    function automatic logic is_valid_address
    (
        input logic [31:0] addr
    );

        case(addr)

            GPIO_ID_ADDR,
            GPIO_VERSION_ADDR,
            GPIO_DATA_IN_ADDR,
            GPIO_DATA_OUT_ADDR,
            GPIO_DIRECTION_ADDR,
            GPIO_OUTPUT_EN_ADDR,
            GPIO_STATUS_ADDR,
            GPIO_INT_ENABLE_ADDR,
            GPIO_INT_STATUS_ADDR,
            GPIO_INT_CLEAR_ADDR :

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

            GPIO_ID_ADDR,
            GPIO_VERSION_ADDR,
            GPIO_DATA_IN_ADDR,
            GPIO_STATUS_ADDR,
            GPIO_INT_STATUS_ADDR :

                is_read_only = 1'b1;

            default :

                is_read_only = 1'b0;

        endcase

    endfunction

endpackage