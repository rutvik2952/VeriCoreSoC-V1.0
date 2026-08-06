
module sysctrl_top
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
    // System Status Inputs
    //------------------------------------------------------------

    input  logic         cpu_running,
    input  logic         irq_pending,
    input  logic         sleep_mode,
    input  logic         debug_mode,

    //------------------------------------------------------------
    // System Outputs
    //------------------------------------------------------------

    output logic         cpu_reset,

    output logic         gpio_reset,

    output logic         timer_reset,

    output logic         uart_reset,

    output logic         spi_reset,

    output logic         i2c_reset,

    output logic         dma_reset,

    output logic         cpu_clk_en,

    output logic         gpio_clk_en,

    output logic         timer_clk_en,

    output logic         uart_clk_en,

    output logic         spi_clk_en,

    output logic         i2c_clk_en,

    output logic         dma_clk_en,

    output sysctrl_pkg::boot_mode_e boot_mode
);

    import sysctrl_pkg::*;

    //------------------------------------------------------------
    // Internal Signals
    //------------------------------------------------------------

    logic        wr_en;
    logic        rd_en;

    logic        sw_reset;

    logic [31:0] clock_enable;
    logic [31:0] reset_control;
    logic [31:0] boot_config;

    //------------------------------------------------------------
    // APB Decode
    //------------------------------------------------------------

    assign wr_en = psel &
                   penable &
                   pwrite;

    assign rd_en = psel &
                   penable &
                  ~pwrite;

    //------------------------------------------------------------
    // Register Block
    //------------------------------------------------------------

    sysctrl_regs
    u_sysctrl_regs
    (
        .clk            (pclk),
        .rst_n          (presetn),

        .wr_en          (wr_en),
        .rd_en          (rd_en),

        .addr           (paddr),
        .wr_data        (pwdata),

        .rd_data        (prdata),

        .cpu_running    (cpu_running),
        .irq_pending    (irq_pending),
        .sleep_mode     (sleep_mode),
        .debug_mode     (debug_mode),

        .sw_reset       (sw_reset),

        .clock_enable   (clock_enable),

        .reset_control  (reset_control),

        .boot_config    (boot_config)
    );

    //------------------------------------------------------------
    // Control Logic
    //------------------------------------------------------------

    sysctrl_logic
    u_sysctrl_logic
    (
        .clk            (pclk),
        .rst_n          (presetn),

        .sw_reset       (sw_reset),

        .clock_enable   (clock_enable),

        .reset_control  (reset_control),

        .boot_config    (boot_config),

        .cpu_reset      (cpu_reset),

        .gpio_reset     (gpio_reset),

        .timer_reset    (timer_reset),

        .uart_reset     (uart_reset),

        .spi_reset      (spi_reset),

        .i2c_reset      (i2c_reset),

        .dma_reset      (dma_reset),

        .cpu_clk_en     (cpu_clk_en),

        .gpio_clk_en    (gpio_clk_en),

        .timer_clk_en   (timer_clk_en),

        .uart_clk_en    (uart_clk_en),

        .spi_clk_en     (spi_clk_en),

        .i2c_clk_en     (i2c_clk_en),

        .dma_clk_en     (dma_clk_en),

        .boot_mode      (boot_mode)
    );
	
	    //------------------------------------------------------------
    // APB Response Generation
    //------------------------------------------------------------

    always_comb
    begin

        //----------------------------------------
        // Default Response
        //----------------------------------------

        pready  = 1'b1;

        pslverr = 1'b0;

        //----------------------------------------
        // Invalid Address Detection
        //----------------------------------------

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

    task automatic display_sysctrl();

        begin

            $display("------------------------------------------");
            $display("SYSCTRL TOP STATUS");
            $display("------------------------------------------");

            $display("PSEL           : %0b", psel);
            $display("PENABLE        : %0b", penable);
            $display("PWRITE         : %0b", pwrite);

            $display("PADDR          : %08h", paddr);
            $display("PWDATA         : %08h", pwdata);
            $display("PRDATA         : %08h", prdata);

            $display("PREADY         : %0b", pready);
            $display("PSLVERR        : %0b", pslverr);

            $display("------------------------------------------");

        end

    endtask

    //------------------------------------------------------------
    // Assertions
    //------------------------------------------------------------

    // PREADY shall always be asserted
    // (No wait-state implementation in v1.0)

    property p_ready;

        @(posedge pclk)
        disable iff(!presetn)

        pready;

    endproperty

    assert property(p_ready)
        else
            $error("SYSCTRL_TOP : PREADY deasserted.");

    //------------------------------------------------------------

    // Invalid address must generate PSLVERR

    property p_invalid_addr;

        @(posedge pclk)
        disable iff(!presetn)

        ((wr_en || rd_en) &&
        !is_valid_address(paddr))
        |-> pslverr;

    endproperty

    assert property(p_invalid_addr)
        else
            $error("SYSCTRL_TOP : Invalid address did not generate PSLVERR.");

    //------------------------------------------------------------

    // Valid address must not generate PSLVERR

    property p_valid_addr;

        @(posedge pclk)
        disable iff(!presetn)

        ((wr_en || rd_en) &&
         is_valid_address(paddr))
        |-> !pslverr;

    endproperty

    assert property(p_valid_addr)
        else
            $error("SYSCTRL_TOP : PSLVERR asserted for valid address.");

`endif

endmodule

