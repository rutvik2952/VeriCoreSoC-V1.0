
module cpu_interrupt
(
    //------------------------------------------------------------
    // Global Signals
    //------------------------------------------------------------

    input  logic        clk,
    input  logic        rst_n,

    //------------------------------------------------------------
    // Interrupt Requests
    //------------------------------------------------------------

    input  logic        irq,

    input  logic [7:0]  irq_id,

    //------------------------------------------------------------
    // CPU Status
    //------------------------------------------------------------

    input  logic        interrupt_enable,

    input  logic        reti,

    //------------------------------------------------------------
    // Outputs
    //------------------------------------------------------------

    output logic        interrupt_taken,

    output logic [31:0] interrupt_vector
);

    //------------------------------------------------------------
    // Interrupt Vector Table
    //------------------------------------------------------------

    localparam logic [31:0] VECTOR_BASE = 32'h0000_0100;

    //------------------------------------------------------------
    // Interrupt State
    //------------------------------------------------------------

    logic interrupt_active;

    //------------------------------------------------------------
    // Interrupt FSM
    //------------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin

            interrupt_active <= 1'b0;

        end
        else
        begin

            //----------------------------------------
            // Return From Interrupt
            //----------------------------------------

            if(reti)

                interrupt_active <= 1'b0;

            //----------------------------------------
            // Accept Interrupt
            //----------------------------------------

            else if(irq &&
                    interrupt_enable &&
                    !interrupt_active)

                interrupt_active <= 1'b1;

        end

    end

    //------------------------------------------------------------
    // Interrupt Outputs
    //------------------------------------------------------------

    assign interrupt_taken =
            irq &&
            interrupt_enable &&
            !interrupt_active;

    assign interrupt_vector =
            VECTOR_BASE + {20'd0, irq_id, 2'b00};
			
			    //------------------------------------------------------------
    // Performance Counters
    //------------------------------------------------------------

    logic [31:0] irq_count;
    logic [31:0] reti_count;
    logic [31:0] ignored_irq_count;

    //------------------------------------------------------------
    // Statistics
    //------------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin

            irq_count         <= '0;
            reti_count        <= '0;
            ignored_irq_count <= '0;

        end
        else
        begin

            //----------------------------------------
            // Accepted Interrupt
            //----------------------------------------

            if(interrupt_taken)
                irq_count <= irq_count + 1'b1;

            //----------------------------------------
            // RETI
            //----------------------------------------

            if(reti)
                reti_count <= reti_count + 1'b1;

            //----------------------------------------
            // Ignored Interrupt
            //----------------------------------------

            if(irq && (!interrupt_enable || interrupt_active))
                ignored_irq_count <= ignored_irq_count + 1'b1;

        end

    end

`ifndef SYNTHESIS

    //------------------------------------------------------------
    // Debug Task
    //------------------------------------------------------------

    task automatic display_interrupt_status();

        begin

            $display("------------------------------------------");
            $display("CPU INTERRUPT STATUS");
            $display("------------------------------------------");
            $display("IRQ              : %0b", irq);
            $display("IRQ ID           : %0d", irq_id);
            $display("INT ENABLE       : %0b", interrupt_enable);
            $display("INT ACTIVE       : %0b", interrupt_active);
            $display("INT TAKEN        : %0b", interrupt_taken);
            $display("VECTOR           : %08h", interrupt_vector);
            $display("------------------------------------------");

        end

    endtask

    //------------------------------------------------------------
    // Assertions
    //------------------------------------------------------------

    // Interrupt vector must be word aligned

    property p_vector_alignment;

        @(posedge clk)
        disable iff(!rst_n)

        interrupt_taken |-> (interrupt_vector[1:0] == 2'b00);

    endproperty

    assert property(p_vector_alignment)
        else
            $error("CPU_INTERRUPT : Interrupt vector is not word aligned.");

    //------------------------------------------------------------

    // Interrupt should not be taken while disabled

    property p_interrupt_enable;

        @(posedge clk)
        disable iff(!rst_n)

        !interrupt_enable |-> !interrupt_taken;

    endproperty

    assert property(p_interrupt_enable)
        else
            $error("CPU_INTERRUPT : Interrupt accepted while disabled.");

    //------------------------------------------------------------

    // RETI clears interrupt active state

    property p_reti_clear;

        @(posedge clk)
        disable iff(!rst_n)

        reti |=> !interrupt_active;

    endproperty

    assert property(p_reti_clear)
        else
            $error("CPU_INTERRUPT : RETI failed to clear interrupt state.");

`endif

endmodule
