
module timer_logic
(
    //------------------------------------------------------------
    // Global Signals
    //------------------------------------------------------------
    input  logic                    clk,
    input  logic                    rst_n,

    //------------------------------------------------------------
    // Register Interface
    //------------------------------------------------------------
    input  logic [31:0]             timer_control,

    input  logic [31:0]             timer_load,

    input  logic                    timer_int_clear,

    //------------------------------------------------------------
    // Hardware Outputs
    //------------------------------------------------------------
    output logic [31:0]             timer_count,

    output logic                    timer_running,

    output logic                    timer_timeout,

    output logic                    timer_irq_pending,

    output logic                    timer_irq
);

    import timer_pkg::*;

    //------------------------------------------------------------
    // Internal Registers
    //------------------------------------------------------------

    logic [31:0] counter_reg;

    logic        running_reg;

    logic        timeout_reg;

    logic        irq_pending_reg;

    //------------------------------------------------------------
    // Timer Counter Logic
    //------------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin

            counter_reg      <= RESET_TIMER_COUNT;

            running_reg      <= 1'b0;

            timeout_reg      <= 1'b0;

            irq_pending_reg  <= 1'b0;

        end
        else
        begin

            //----------------------------------------------------
            // Clear timeout pulse every cycle
            //----------------------------------------------------

            timeout_reg <= 1'b0;

            //----------------------------------------------------
            // Clear interrupt
            //----------------------------------------------------

            if(timer_int_clear)

                irq_pending_reg <= 1'b0;

            //----------------------------------------------------
            // Timer Enable
            //----------------------------------------------------

            if(timer_control[TIMER_ENABLE_BIT])
            begin

                //------------------------------------------------
                // Start Timer
                //------------------------------------------------

                if(!running_reg)
                begin

                    // Ignore zero load value
                  if(timer_load != 32'd0)
                    begin

                     counter_reg <= timer_load;
                     running_reg <= 1'b1;

    end

                end
				
	                //------------------------------------------------
                // Timer Running
                //------------------------------------------------

                else
                begin

                    if(counter_reg != 32'd0)
                    begin

                        counter_reg <= counter_reg - 32'd1;

                    end
                    else
                    begin

                        //----------------------------------------
                        // Timeout Event
                        //----------------------------------------

                        timeout_reg <= 1'b1;

                        if(timer_control[TIMER_IRQ_ENABLE_BIT])

                            irq_pending_reg <= 1'b1;

                        //----------------------------------------
                        // Timer Mode
                        //----------------------------------------

                        if(timer_control[TIMER_MODE_BIT] ==
                           TIMER_PERIODIC)
                        begin

                            counter_reg <= timer_load;

                            running_reg <= 1'b1;

                        end
                        else
                        begin

                            running_reg <= 1'b0;

                        end

                    end

                end

            end
            else
            begin

                //--------------------------------------------
                // Timer Disabled
                //--------------------------------------------

                running_reg <= 1'b0;

            end

        end

    end

    //------------------------------------------------------------
    // Output Assignments
    //------------------------------------------------------------

    assign timer_count       = counter_reg;

    assign timer_running     = running_reg;

    assign timer_timeout     = timeout_reg;

    assign timer_irq_pending = irq_pending_reg;

    assign timer_irq =
            irq_pending_reg &
            timer_control[TIMER_IRQ_ENABLE_BIT];

`ifndef SYNTHESIS

    //------------------------------------------------------------
    // Assertions
    //------------------------------------------------------------

    // Counter shall never underflow

    property p_counter_underflow;

        @(posedge clk)
        disable iff(!rst_n)

        counter_reg == 32'hFFFF_FFFF
        |->
        0;

    endproperty

    assert property(p_counter_underflow)
    else
        $error("TIMER_LOGIC : Counter underflow detected.");

    //------------------------------------------------------------

    // Timeout implies counter is zero

    property p_timeout;

        @(posedge clk)
        disable iff(!rst_n)

        timeout_reg
        |->
        (counter_reg == 32'd0);

    endproperty

    assert property(p_timeout)
    else
        $error("TIMER_LOGIC : Timeout generated before counter reached zero.");

    //------------------------------------------------------------

    // IRQ requires pending status

    property p_irq;

        @(posedge clk)
        disable iff(!rst_n)

        timer_irq
        |->
        irq_pending_reg;

    endproperty

    assert property(p_irq)
    else
        $error("TIMER_LOGIC : IRQ asserted without pending interrupt.");

`endif

endmodule
	