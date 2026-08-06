module cpu_apb_master
(
    //------------------------------------------------------------
    // Global Signals
    //------------------------------------------------------------

    input  logic clk,
    input  logic rst_n,

    //------------------------------------------------------------
    // CPU Request Interface
    //------------------------------------------------------------

    input  logic        req_valid,
    input  logic        req_write,

    input  logic [31:0] req_addr,
    input  logic [31:0] req_wdata,

    output logic [31:0] rsp_rdata,
    output logic        rsp_ready,
    output logic        rsp_error,

    //------------------------------------------------------------
    // APB Master Interface
    //------------------------------------------------------------

    output logic        cpu_req,

    output logic        cpu_psel,
    output logic        cpu_penable,
    output logic        cpu_pwrite,

    output logic [31:0] cpu_paddr,
    output logic [31:0] cpu_pwdata,

    input  logic [31:0] cpu_prdata,

    input  logic        cpu_pready,
    input  logic        cpu_pslverr
);

    //------------------------------------------------------------
    // Internal State
    //------------------------------------------------------------

    typedef enum logic [1:0]
    {
        IDLE,
        SETUP,
        ACCESS
    } apb_state_t;

    apb_state_t state;
	
	    //------------------------------------------------------------
    // State Register
    //------------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
            state <= IDLE;
        else
        begin

            case(state)

                //----------------------------------------------
                // IDLE
                //----------------------------------------------

                IDLE :
                begin

                    if(req_valid)
                        state <= SETUP;

                end

                //----------------------------------------------
                // SETUP
                //----------------------------------------------

                SETUP :
                begin

                    state <= ACCESS;

                end

                //----------------------------------------------
                // ACCESS
                //----------------------------------------------

                ACCESS :
                begin

                    if(cpu_pready)
                        state <= IDLE;

                end

                //----------------------------------------------

                default :
                    state <= IDLE;

            endcase

        end

    end
	            //------------------------------------------------------------
    // APB Master Output Logic
    //------------------------------------------------------------

    always_comb
    begin

        //--------------------------------------------------------
        // Defaults
        //--------------------------------------------------------

        cpu_req     = 1'b0;

        cpu_psel    = 1'b0;
        cpu_penable = 1'b0;
        cpu_pwrite  = req_write;

        cpu_paddr   = req_addr;
        cpu_pwdata  = req_wdata;

        rsp_ready   = 1'b0;
        rsp_error   = 1'b0;
        rsp_rdata   = 32'h0000_0000;

        //--------------------------------------------------------
        // State Machine
        //--------------------------------------------------------

        case(state)

            //----------------------------------------------

            IDLE :
            begin

            end

            //----------------------------------------------

            SETUP :
            begin

                cpu_req     = 1'b1;
                cpu_psel    = 1'b1;

            end

            //----------------------------------------------

            ACCESS :
            begin

                cpu_req     = 1'b1;

                cpu_psel    = 1'b1;
                cpu_penable = 1'b1;

                if(cpu_pready)
                begin

                    rsp_ready = 1'b1;
                    rsp_error = cpu_pslverr;
                    rsp_rdata = cpu_prdata;

                end

            end

        endcase

    end
endmodule


/*
module cpu_apb_master
(
    //------------------------------------------------------------
    // Global Signals
    //------------------------------------------------------------

    input  logic         clk,
    input  logic         rst_n,

    //------------------------------------------------------------
    // CPU Request Interface
    //------------------------------------------------------------

    input  logic         req_valid,
    input  logic         req_write,

    input  logic [31:0]  req_addr,
    input  logic [31:0]  req_wdata,

    output logic [31:0]  req_rdata,

    output logic         req_ready,
    output logic         req_error,

    //------------------------------------------------------------
    // APB Master Interface
    //------------------------------------------------------------

    output logic [31:0]  paddr,
    output logic [31:0]  pwdata,

    input  logic [31:0]  prdata,

    output logic         psel,
    output logic         penable,
    output logic         pwrite,

    input  logic         pready,
    input  logic         pslverr
);

    //------------------------------------------------------------
    // APB FSM
    //------------------------------------------------------------

    typedef enum logic [1:0]
    {
        IDLE,
        SETUP,
        ACCESS
    } apb_state_e;

    apb_state_e state;
    apb_state_e next_state;

    //------------------------------------------------------------
    // State Register
    //------------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
            state <= IDLE;
        else
            state <= next_state;

    end

    //------------------------------------------------------------
    // Next State Logic
    //------------------------------------------------------------

    always_comb
    begin

        next_state = state;

        unique case(state)

            //----------------------------------------
            // IDLE
            //----------------------------------------

            IDLE:
            begin

                if(req_valid)
                    next_state = SETUP;

            end

            //----------------------------------------
            // SETUP
            //----------------------------------------

            SETUP:
            begin

                next_state = ACCESS;

            end

            //----------------------------------------
            // ACCESS
            //----------------------------------------

            ACCESS:
            begin

                if(pready)
                    next_state = IDLE;

            end

            default:

                next_state = IDLE;

        endcase

    end
	
	    //------------------------------------------------------------
    // APB Output Logic
    //------------------------------------------------------------

    always_comb
    begin

        //----------------------------------------
        // Defaults
        //----------------------------------------

        psel     = 1'b0;
        penable  = 1'b0;
        pwrite   = req_write;

        paddr    = req_addr;
        pwdata   = req_wdata;

        req_rdata = prdata;

        req_ready = 1'b0;
        req_error = 1'b0;

        //----------------------------------------
        // APB FSM
        //----------------------------------------

        unique case(state)

            //------------------------------------
            // IDLE
            //------------------------------------

            IDLE:
            begin

                req_ready = 1'b1;

            end

            //------------------------------------
            // SETUP
            //------------------------------------

            SETUP:
            begin

                psel = 1'b1;

            end

            //------------------------------------
            // ACCESS
            //------------------------------------

            ACCESS:
            begin

                psel    = 1'b1;
                penable = 1'b1;

                if(pready)
                begin

                    req_ready = 1'b1;
                    req_error = pslverr;

                end

            end

        endcase

    end

    //------------------------------------------------------------
    // Performance Counters
    //------------------------------------------------------------

    logic [31:0] apb_read_count;
    logic [31:0] apb_write_count;
    logic [31:0] apb_error_count;

    always_ff @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin

            apb_read_count  <= '0;
            apb_write_count <= '0;
            apb_error_count <= '0;

        end
        else
        begin

            if(state == ACCESS && pready)
            begin

                if(req_write)
                    apb_write_count <= apb_write_count + 1'b1;
                else
                    apb_read_count <= apb_read_count + 1'b1;

                if(pslverr)
                    apb_error_count <= apb_error_count + 1'b1;

            end

        end

    end

`ifndef SYNTHESIS

    //------------------------------------------------------------
    // Assertions
    //------------------------------------------------------------

    // PENABLE must only be asserted when PSEL is active

    property p_enable_after_select;

        @(posedge clk)
        disable iff(!rst_n)

        penable |-> psel;

    endproperty

    assert property(p_enable_after_select)
        else
            $error("CPU_APB_MASTER : PENABLE asserted without PSEL.");

    //------------------------------------------------------------

    // APB address must remain stable during ACCESS

    property p_addr_stable;

        @(posedge clk)
        disable iff(!rst_n)

        (state == ACCESS && !pready) |=> $stable(paddr);

    endproperty

    assert property(p_addr_stable)
        else
            $error("CPU_APB_MASTER : PADDR changed during ACCESS.");

    //------------------------------------------------------------

    // APB write data must remain stable during ACCESS

    property p_wdata_stable;

        @(posedge clk)
        disable iff(!rst_n)

        (state == ACCESS && pwrite && !pready) |=> $stable(pwdata);

    endproperty

    assert property(p_wdata_stable)
        else
            $error("CPU_APB_MASTER : PWDATA changed during ACCESS.");

`endif

endmodule
*/