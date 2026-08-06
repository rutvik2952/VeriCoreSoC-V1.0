  import timer_pkg::*;

module timer_regs
(
    //------------------------------------------------------------
    // Global Signals
    //------------------------------------------------------------
    input  logic                    clk,
    input  logic                    rst_n,

    //------------------------------------------------------------
    // APB Register Interface
    //------------------------------------------------------------
    input  logic                    wr_en,
    input  logic                    rd_en,

    input  logic [31:0]             addr,
    input  logic [31:0]             wr_data,

    output logic [31:0]             rd_data,

    //------------------------------------------------------------
    // Hardware Inputs
    //------------------------------------------------------------
    input  logic [TIMER_WIDTH-1:0]  timer_count,

    input  logic                    timer_running,

    input  logic                    timer_timeout,

    input  logic                    timer_irq_pending,

    //------------------------------------------------------------
    // Register Outputs
    //------------------------------------------------------------
    output logic [31:0]             timer_control,

    output logic [31:0]             timer_load,

    output logic                    timer_int_clear
);

  
    //------------------------------------------------------------
    // Internal Registers
    //------------------------------------------------------------

    logic [31:0] control_reg;

    logic [31:0] load_reg;

    logic [31:0] status_reg;

    logic        int_clear_reg;

    //------------------------------------------------------------
    // Register Write Logic
    //------------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin

            control_reg   <= RESET_TIMER_CONTROL;

            load_reg      <= RESET_TIMER_LOAD;

            int_clear_reg <= 1'b0;

        end
        else
        begin

            //----------------------------------------------------
            // Default (Pulse Register)
            //----------------------------------------------------

            int_clear_reg <= 1'b0;

            //----------------------------------------------------
            // APB Write
            //----------------------------------------------------

            if(wr_en)
            begin

                unique case(addr)

                    TIMER_CONTROL_ADDR :
                        control_reg <= wr_data;

                    TIMER_LOAD_ADDR :
                        load_reg <= wr_data;

                    TIMER_INT_CLEAR_ADDR :
                    begin

                        if(wr_data[0])

                            int_clear_reg <= 1'b1;

                    end

                    default :
                        ;

                endcase

            end

        end

    end
	
	    //------------------------------------------------------------
    // Status Register Generation
    //------------------------------------------------------------

    always_comb
    begin

        status_reg = 32'd0;

        status_reg[TIMER_RUNNING_BIT] = timer_running;

        status_reg[TIMER_TIMEOUT_BIT] = timer_timeout;

    end

    //------------------------------------------------------------
    // Register Read Logic
    //------------------------------------------------------------

    always_comb
    begin

        rd_data = 32'd0;

        if(rd_en)
        begin

            unique case(addr)

                //------------------------------------------------
                // Read Only Registers
                //------------------------------------------------

                TIMER_ID_ADDR :
                    rd_data = TIMER_ID;

                TIMER_VERSION_ADDR :
                    rd_data = TIMER_VERSION;

                TIMER_COUNT_ADDR :
                    rd_data = timer_count;

                TIMER_STATUS_ADDR :
                    rd_data = status_reg;

                TIMER_INT_STATUS_ADDR :
                    rd_data = {{31{1'b0}}, timer_irq_pending};

                //------------------------------------------------
                // Read / Write Registers
                //------------------------------------------------

                TIMER_CONTROL_ADDR :
                    rd_data = control_reg;

                TIMER_LOAD_ADDR :
                    rd_data = load_reg;

                default :
                    rd_data = 32'hDEAD_BEEF;

            endcase

        end

    end

    //------------------------------------------------------------
    // Register Outputs
    //------------------------------------------------------------

    assign timer_control   = control_reg;

    assign timer_load      = load_reg;

    assign timer_int_clear = int_clear_reg;

`ifndef SYNTHESIS

    //------------------------------------------------------------
    // Assertions
    //------------------------------------------------------------

    // Valid Register Access

    property p_valid_access;

        @(posedge clk)

        disable iff(!rst_n)

        (wr_en || rd_en)
            |->
        is_valid_address(addr);

    endproperty

    assert property(p_valid_access)
    else
        $error("TIMER_REGS : Invalid register address.");

    //------------------------------------------------------------

    // Address Alignment

    property p_addr_alignment;

        @(posedge clk)

        disable iff(!rst_n)

        (wr_en || rd_en)
            |->
        (addr[1:0] == 2'b00);

    endproperty

    assert property(p_addr_alignment)
    else
        $error("TIMER_REGS : Address alignment error.");

    //------------------------------------------------------------

    // Read Only Register Protection

    property p_ro_write;

        @(posedge clk)

        disable iff(!rst_n)

        wr_en
            |->
        !is_read_only(addr);

    endproperty

    assert property(p_ro_write)
    else
        $error("TIMER_REGS : Write to Read-Only register.");

`endif

endmodule
