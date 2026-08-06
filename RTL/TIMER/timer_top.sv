
module timer_top
(
    //------------------------------------------------------------
    // Global Signals
    //------------------------------------------------------------

    input  logic         pclk,
    input  logic         presetn,

    //------------------------------------------------------------
    // APB Slave Interface
    //------------------------------------------------------------

    input  logic         psel,
    input  logic         penable,
    input  logic         pwrite,

    input  logic [31:0]  paddr,
    input  logic [31:0]  pwdata,

    output logic [31:0]  prdata,

    output logic         pready,
    output logic         pslverr,

    //------------------------------------------------------------
    // Interrupt Output
    //------------------------------------------------------------

    output logic         timer_irq
);

    import timer_pkg::*;

    //------------------------------------------------------------
    // Internal Signals
    //------------------------------------------------------------

    logic        wr_en;
    logic        rd_en;

    logic [31:0] timer_control;
    logic [31:0] timer_load;

    logic [31:0] timer_count;

    logic        timer_running;
    logic        timer_timeout;

    logic        timer_irq_pending;

    logic        timer_int_clear;

    //------------------------------------------------------------
    // APB Decode
    //------------------------------------------------------------

    assign wr_en =
            psel &
            penable &
            pwrite;

    assign rd_en =
            psel &
            penable &
           ~pwrite;

    //------------------------------------------------------------
    // Register Block
    //------------------------------------------------------------

    timer_regs
    u_timer_regs
    (
        .clk               (pclk),
        .rst_n             (presetn),

        .wr_en             (wr_en),
        .rd_en             (rd_en),

        .addr              (paddr),
        .wr_data           (pwdata),

        .rd_data           (prdata),

        .timer_count       (timer_count),

        .timer_running     (timer_running),

        .timer_timeout     (timer_timeout),

        .timer_irq_pending (timer_irq_pending),

        .timer_control     (timer_control),

        .timer_load        (timer_load),

        .timer_int_clear   (timer_int_clear)
    );

    //------------------------------------------------------------
    // Timer Logic
    //------------------------------------------------------------

    timer_logic
    u_timer_logic
    (
        .clk               (pclk),
        .rst_n             (presetn),

        .timer_control     (timer_control),

        .timer_load        (timer_load),

        .timer_int_clear   (timer_int_clear),

        .timer_count       (timer_count),

        .timer_running     (timer_running),

        .timer_timeout     (timer_timeout),

        .timer_irq_pending (timer_irq_pending),

        .timer_irq         (timer_irq)
    );
	
	    //------------------------------------------------------------
    // APB Response Generation
    //------------------------------------------------------------

    always_comb
    begin

        //--------------------------------------------------------
        // Default Response
        //--------------------------------------------------------

        pready  = 1'b1;

        pslverr = 1'b0;

        //--------------------------------------------------------
        // Invalid Address Detection
        //--------------------------------------------------------

        if((wr_en || rd_en) &&
           !is_valid_address(paddr))
        begin

            pslverr = 1'b1;

        end

    end

`ifndef SYNTHESIS

    //------------------------------------------------------------
    // Debug Task
    //------------------------------------------------------------

    task automatic display_timer_status();

        begin

            $display("--------------------------------------------");
            $display("           TIMER STATUS");
            $display("--------------------------------------------");

            $display("PADDR         : %08h", paddr);
            $display("PWDATA        : %08h", pwdata);
            $display("PRDATA        : %08h", prdata);

            $display("CONTROL       : %08h", timer_control);
            $display("LOAD          : %08h", timer_load);
            $display("COUNT         : %08h", timer_count);

            $display("RUNNING       : %0b", timer_running);
            $display("TIMEOUT       : %0b", timer_timeout);

            $display("IRQ_PENDING   : %0b", timer_irq_pending);
            $display("IRQ           : %0b", timer_irq);

            $display("--------------------------------------------");

        end

    endtask

    //------------------------------------------------------------
    // Assertions
    //------------------------------------------------------------

    // Valid Address shall not generate PSLVERR

    property p_valid_addr;

        @(posedge pclk)

        disable iff(!presetn)

        ((wr_en || rd_en) &&
          is_valid_address(paddr))
        |-> !pslverr;

    endproperty

    assert property(p_valid_addr)
    else
        $error("TIMER_TOP : PSLVERR asserted for valid address.");

    //------------------------------------------------------------

    // Invalid Address shall generate PSLVERR

    property p_invalid_addr;

        @(posedge pclk)

        disable iff(!presetn)

        ((wr_en || rd_en) &&
         !is_valid_address(paddr))
        |-> pslverr;

    endproperty

    assert property(p_invalid_addr)
    else
        $error("TIMER_TOP : Invalid address did not generate PSLVERR.");

    //------------------------------------------------------------

    // Timer IRQ shall only assert when interrupt is pending

    property p_timer_irq;

        @(posedge pclk)

        disable iff(!presetn)

        timer_irq |-> timer_irq_pending;

    endproperty

    assert property(p_timer_irq)
    else
        $error("TIMER_TOP : IRQ asserted without pending interrupt.");

`endif

endmodule
