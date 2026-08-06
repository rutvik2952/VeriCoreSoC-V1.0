
module gpio_top
(
    //------------------------------------------------------------
    // Global Signals
    //------------------------------------------------------------

    input  logic                             pclk,
    input  logic                             presetn,

    //------------------------------------------------------------
    // APB Slave Interface
    //------------------------------------------------------------

    input  logic                             psel,
    input  logic                             penable,
    input  logic                             pwrite,

    input  logic [31:0]                      paddr,
    input  logic [31:0]                      pwdata,

    output logic [31:0]                      prdata,

    output logic                             pready,
    output logic                             pslverr,

    //------------------------------------------------------------
    // GPIO Physical Interface
    //------------------------------------------------------------

    input  logic [gpio_pkg::GPIO_WIDTH-1:0]  gpio_in,

    output logic [gpio_pkg::GPIO_WIDTH-1:0]  gpio_out,

    output logic [gpio_pkg::GPIO_WIDTH-1:0]  gpio_oe
);

    import gpio_pkg::*;

    //------------------------------------------------------------
    // Internal Signals
    //------------------------------------------------------------

    logic wr_en;
    logic rd_en;

    logic [GPIO_WIDTH-1:0] gpio_data_out;
    logic [GPIO_WIDTH-1:0] gpio_direction;
    logic [GPIO_WIDTH-1:0] gpio_output_enable;
    logic [GPIO_WIDTH-1:0] gpio_int_enable;

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

    gpio_regs
    u_gpio_regs
    (
        .clk                (pclk),
        .rst_n              (presetn),

        .wr_en              (wr_en),
        .rd_en              (rd_en),

        .addr               (paddr),
        .wr_data            (pwdata),

        .rd_data            (prdata),

        .gpio_in            (gpio_in),

        .gpio_data_out      (gpio_data_out),

        .gpio_direction     (gpio_direction),

        .gpio_output_enable (gpio_output_enable),

        .gpio_int_enable    (gpio_int_enable)
    );

    //------------------------------------------------------------
    // GPIO Logic
    //------------------------------------------------------------

    gpio_logic
    u_gpio_logic
    (
        .gpio_data_out      (gpio_data_out),

        .gpio_direction     (gpio_direction),

        .gpio_output_enable (gpio_output_enable),

        .gpio_in            (gpio_in),

        .gpio_out           (gpio_out),

        .gpio_oe            (gpio_oe)
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

    task automatic display_gpio();

        begin

            $display("------------------------------------------");
            $display("GPIO TOP STATUS");
            $display("------------------------------------------");

            $display("PSEL      : %0b", psel);
            $display("PENABLE   : %0b", penable);
            $display("PWRITE    : %0b", pwrite);

            $display("PADDR     : %08h", paddr);
            $display("PWDATA    : %08h", pwdata);
            $display("PRDATA    : %08h", prdata);

            $display("PREADY    : %0b", pready);
            $display("PSLVERR   : %0b", pslverr);

            $display("GPIO_IN   : %08h", gpio_in);
            $display("GPIO_OUT  : %08h", gpio_out);
            $display("GPIO_OE   : %08h", gpio_oe);

            $display("------------------------------------------");

        end

    endtask

    //------------------------------------------------------------
    // Assertions
    //------------------------------------------------------------

    // Valid address shall not generate PSLVERR

    property p_valid_addr;

        @(posedge pclk)
        disable iff(!presetn)

        ((wr_en || rd_en) &&
         is_valid_address(paddr))
        |-> !pslverr;

    endproperty

    assert property(p_valid_addr)
        else
            $error("GPIO_TOP : PSLVERR asserted for valid address.");

    //------------------------------------------------------------

    // Invalid address shall generate PSLVERR

    property p_invalid_addr;

        @(posedge pclk)
        disable iff(!presetn)

        ((wr_en || rd_en) &&
         !is_valid_address(paddr))
        |-> pslverr;

    endproperty

    assert property(p_invalid_addr)
        else
            $error("GPIO_TOP : Invalid address did not generate PSLVERR.");

    //------------------------------------------------------------

    // GPIO Output Enable shall always follow the architecture

    property p_gpio_oe;

        @(posedge pclk)
        disable iff(!presetn)

        (gpio_oe == (gpio_direction & gpio_output_enable));

    endproperty

    assert property(p_gpio_oe)
        else
            $error("GPIO_TOP : GPIO Output Enable mismatch.");

`endif

endmodule

