
module gpio_regs
(
    //------------------------------------------------------------
    // Global Signals
    //------------------------------------------------------------

    input  logic                             clk,
    input  logic                             rst_n,

    //------------------------------------------------------------
    // APB Register Interface
    //------------------------------------------------------------

    input  logic                             wr_en,
    input  logic                             rd_en,

    input  logic [31:0]                      addr,
    input  logic [31:0]                      wr_data,

    output logic [31:0]                      rd_data,

    //------------------------------------------------------------
    // GPIO Pin Inputs
    //------------------------------------------------------------

    input  logic [gpio_pkg::GPIO_WIDTH-1:0]  gpio_in,

    //------------------------------------------------------------
    // Register Outputs
    //------------------------------------------------------------

    output logic [gpio_pkg::GPIO_WIDTH-1:0]  gpio_data_out,

    output logic [gpio_pkg::GPIO_WIDTH-1:0]  gpio_direction,

    output logic [gpio_pkg::GPIO_WIDTH-1:0]  gpio_output_enable,

    output logic [gpio_pkg::GPIO_WIDTH-1:0]  gpio_int_enable
);

    import gpio_pkg::*;

    //------------------------------------------------------------
    // Internal Registers
    //------------------------------------------------------------

    logic [GPIO_WIDTH-1:0] data_out_reg;

    logic [GPIO_WIDTH-1:0] direction_reg;

    logic [GPIO_WIDTH-1:0] output_enable_reg;

    logic [GPIO_WIDTH-1:0] int_enable_reg;

    logic [GPIO_WIDTH-1:0] int_status_reg;

    logic [31:0] status_reg;

    //------------------------------------------------------------
    // Register Write Logic
    //------------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin

            data_out_reg      <= RESET_DATA_OUT;

            direction_reg     <= RESET_DIRECTION;

            output_enable_reg <= RESET_OUTPUT_EN;

            int_enable_reg    <= RESET_INT_ENABLE;

            int_status_reg    <= RESET_INT_STATUS;

        end
        else if(wr_en)
        begin

            unique case(addr)

                GPIO_DATA_OUT_ADDR :
                    data_out_reg <= wr_data[GPIO_WIDTH-1:0];

                GPIO_DIRECTION_ADDR :
                    direction_reg <= wr_data[GPIO_WIDTH-1:0];

                GPIO_OUTPUT_EN_ADDR :
                    output_enable_reg <= wr_data[GPIO_WIDTH-1:0];

                GPIO_INT_ENABLE_ADDR :
                    int_enable_reg <= wr_data[GPIO_WIDTH-1:0];

                GPIO_INT_CLEAR_ADDR :
                    int_status_reg <=
                        int_status_reg &
                        ~wr_data[GPIO_WIDTH-1:0];

                default :
                    ;

            endcase

        end

    end
	
    //------------------------------------------------------------
    // GPIO Status Register Generation
    //------------------------------------------------------------

    always_comb
    begin

        status_reg = 32'd0;

        status_reg[0] = |gpio_in;         // Any GPIO input active
        status_reg[1] = |int_status_reg;  // Any interrupt pending

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

                GPIO_ID_ADDR :
                    rd_data = GPIO_ID;

                GPIO_VERSION_ADDR :
                    rd_data = GPIO_VERSION;

                GPIO_DATA_IN_ADDR :
                    rd_data = gpio_in;

                GPIO_STATUS_ADDR :
                    rd_data = status_reg;

                GPIO_INT_STATUS_ADDR :
                    rd_data = int_status_reg;

                //------------------------------------------------
                // Read / Write Registers
                //------------------------------------------------

                GPIO_DATA_OUT_ADDR :
                    rd_data = data_out_reg;

                GPIO_DIRECTION_ADDR :
                    rd_data = direction_reg;

                GPIO_OUTPUT_EN_ADDR :
                    rd_data = output_enable_reg;

                GPIO_INT_ENABLE_ADDR :
                    rd_data = int_enable_reg;

                default :
                    rd_data = 32'hDEAD_BEEF;

            endcase

        end

    end

    //------------------------------------------------------------
    // Register Outputs
    //------------------------------------------------------------

    assign gpio_data_out      = data_out_reg;

    assign gpio_direction     = direction_reg;

    assign gpio_output_enable = output_enable_reg;

    assign gpio_int_enable    = int_enable_reg;

`ifndef SYNTHESIS

    //------------------------------------------------------------
    // Assertions
    //------------------------------------------------------------

    // Invalid GPIO register write

    property p_valid_gpio_write;

        @(posedge clk)
        disable iff(!rst_n)

        wr_en |-> is_valid_address(addr);

    endproperty

    assert property(p_valid_gpio_write)
        else
            $error("GPIO_REGS : Invalid register write.");

    //------------------------------------------------------------

    // Address alignment

    property p_addr_alignment;

        @(posedge clk)
        disable iff(!rst_n)

        (wr_en || rd_en) |-> (addr[1:0] == 2'b00);

    endproperty

    assert property(p_addr_alignment)
        else
            $error("GPIO_REGS : Unaligned register access.");

    //------------------------------------------------------------

    // Read-only register protection

    property p_ro_write;

        @(posedge clk)
        disable iff(!rst_n)

        wr_en |->
        !is_read_only(addr);

    endproperty

    assert property(p_ro_write)
        else
            $error("GPIO_REGS : Attempt to write Read-Only register.");

`endif

endmodule
	