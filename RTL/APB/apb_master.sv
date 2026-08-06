`timescale 1ns/1ps

module apb_master
#(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter STRB_WIDTH = DATA_WIDTH/8
)
(
    input  logic                     PCLK,
    input  logic                     PRESETn,

    //------------------------------------------------------------
    // CPU Request Interface
    //------------------------------------------------------------

    input  logic                     cpu_req,
    input  logic                     cpu_write,

    input  logic [ADDR_WIDTH-1:0]    cpu_addr,
    input  logic [DATA_WIDTH-1:0]    cpu_wdata,
    input  logic [STRB_WIDTH-1:0]    cpu_strb,

    output logic [DATA_WIDTH-1:0]    cpu_rdata,

    output logic                     cpu_ready,
    output logic                     cpu_error,

    //------------------------------------------------------------
    // APB Master Interface
    //------------------------------------------------------------

    output logic                     PSEL,
    output logic                     PENABLE,
    output logic                     PWRITE,

    output logic [ADDR_WIDTH-1:0]    PADDR,
    output logic [DATA_WIDTH-1:0]    PWDATA,
    output logic [STRB_WIDTH-1:0]    PSTRB,

    output logic [2:0]               PPROT,

    input  logic [DATA_WIDTH-1:0]    PRDATA,
    input  logic                     PREADY,
    input  logic                     PSLVERR
);

    //------------------------------------------------------------
    // APB FSM
    //------------------------------------------------------------

    typedef enum logic [1:0]
    {
        IDLE,
        SETUP,
        ACCESS
    } state_t;

    state_t state;
    state_t next_state;

    //------------------------------------------------------------
    // Internal Registers
    //------------------------------------------------------------

    logic [ADDR_WIDTH-1:0] addr_reg;
    logic [DATA_WIDTH-1:0] wdata_reg;
    logic [STRB_WIDTH-1:0] strb_reg;
    logic                  write_reg;

    //------------------------------------------------------------
    // State Register
    //------------------------------------------------------------

    always_ff @(posedge PCLK or negedge PRESETn)
    begin

        if(!PRESETn)
            state <= IDLE;
        else
            state <= next_state;

    end

    //------------------------------------------------------------
    // Latch CPU Request
    //------------------------------------------------------------

    always_ff @(posedge PCLK or negedge PRESETn)
    begin

        if(!PRESETn)
        begin
            addr_reg  <= '0;
            wdata_reg <= '0;
            strb_reg  <= '0;
            write_reg <= 1'b0;
        end
        else if(state==IDLE && cpu_req)
        begin
            addr_reg  <= cpu_addr;
            wdata_reg <= cpu_wdata;
            strb_reg  <= cpu_strb;
            write_reg <= cpu_write;
        end

    end
	    //------------------------------------------------------------
    // Next State Logic
    //------------------------------------------------------------

    always_comb
    begin

        next_state = state;

        unique case(state)

            //----------------------------------------------------
            // IDLE
            //----------------------------------------------------

            IDLE :
            begin
                if(cpu_req)
                    next_state = SETUP;
            end

            //----------------------------------------------------
            // SETUP
            //----------------------------------------------------

            SETUP :
            begin
                next_state = ACCESS;
            end

            //----------------------------------------------------
            // ACCESS
            //----------------------------------------------------

            ACCESS :
            begin

                if(PREADY)
                    next_state = IDLE;
                else
                    next_state = ACCESS;

            end

            default :
                next_state = IDLE;

        endcase

    end

    //------------------------------------------------------------
    // APB Output Logic
    //------------------------------------------------------------

    always_comb
    begin

        //-------------------------------
        // Defaults
        //-------------------------------

        PSEL      = 1'b0;
        PENABLE   = 1'b0;
        PWRITE    = write_reg;

        PADDR     = addr_reg;
        PWDATA    = wdata_reg;
        PSTRB     = strb_reg;

        PPROT     = 3'b000;

        cpu_ready = 1'b0;
        cpu_error = 1'b0;
        cpu_rdata = PRDATA;

        //-------------------------------
        // FSM Outputs
        //-------------------------------

        unique case(state)

            //------------------------------------
            // IDLE
            //------------------------------------

            IDLE :
            begin

                cpu_ready = 1'b1;

            end

            //------------------------------------
            // SETUP
            //------------------------------------

            SETUP :
            begin

                PSEL = 1'b1;

            end

            //------------------------------------
            // ACCESS
            //------------------------------------

            ACCESS :
            begin

                PSEL    = 1'b1;
                PENABLE = 1'b1;

                if(PREADY)
                begin

                    cpu_ready = 1'b1;
                    cpu_rdata = PRDATA;
                    cpu_error = PSLVERR;

                end

            end

            default :
            begin

                cpu_ready = 1'b1;

            end

        endcase

    end

    //------------------------------------------------------------
    // Optional Protocol Assertions
    //------------------------------------------------------------

`ifndef SYNTHESIS

    property p_access_requires_setup;

        @(posedge PCLK)
        (state == ACCESS) |-> PSEL;

    endproperty

    assert property(p_access_requires_setup)
        else
            $error("APB Master : ACCESS state entered without PSEL");

    property p_enable_only_in_access;

        @(posedge PCLK)
        PENABLE |-> (state == ACCESS);

    endproperty

    assert property(p_enable_only_in_access)
        else
            $error("APB Master : PENABLE asserted outside ACCESS state");

`endif

endmodule
