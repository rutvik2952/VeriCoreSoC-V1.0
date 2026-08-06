
module apb_decoder_logic
(
    input  logic [31:0] paddr,
    input  logic        psel,

    output logic sysctrl_sel,
    output logic gpio_sel,
    output logic timer_sel,
    output logic uart_sel,
    output logic spi_sel,
    output logic i2c_sel,
    output logic dma_sel,
    output logic intc_sel,

    output logic decode_error
);

always_comb begin

    sysctrl_sel = 0;
    gpio_sel    = 0;
    timer_sel   = 0;
    uart_sel    = 0;
    spi_sel     = 0;
    i2c_sel     = 0;
    dma_sel     = 0;
    intc_sel    = 0;
    decode_error = 0;

    if (psel) begin
        case (paddr[31:12])

            20'h40000: sysctrl_sel = 1;
            20'h40001: gpio_sel    = 1;
            20'h40002: timer_sel   = 1;
            20'h40003: uart_sel    = 1;
            20'h40004: spi_sel     = 1;
            20'h40005: i2c_sel     = 1;
            20'h40006: dma_sel     = 1;
            20'h40007: intc_sel    = 1;

            default: decode_error = 1;

        endcase
    end

end

endmodule

/*
module apb_addr_decoder
#(
    parameter int ADDR_WIDTH = 32,
    parameter int NUM_SLAVES = 16,

    parameter logic [ADDR_WIDTH-1:0] BASE_ADDR [NUM_SLAVES] =
    '{
        32'h0000_0000,   // SYSCTRL
        32'h0000_1000,   // INTC
        32'h0000_2000,   // TIMER
        32'h0000_3000,   // GPIO
        32'h0000_4000,   // UART
        32'h0000_5000,   // SPI
        32'h0000_6000,   // I2C
        32'h0000_7000,   // DMA
        32'h0000_8000,   // DEBUG
        32'h0000_9000,   // FIFO
        32'h0000_A000,   // DMA RAM
        32'h0001_0000,   // IMEM
        32'h0002_0000,   // DMEM
        32'h0003_0000,
        32'h0004_0000,
        32'hFFFF_FFFF
    },

    parameter logic [ADDR_WIDTH-1:0] ADDR_SIZE [NUM_SLAVES] =
    '{
        32'h0000_1000,
        32'h0000_1000,
        32'h0000_1000,
        32'h0000_1000,
        32'h0000_1000,
        32'h0000_1000,
        32'h0000_1000,
        32'h0000_1000,
        32'h0000_1000,
        32'h0000_1000,
        32'h0000_1000,
        32'h0001_0000,
        32'h0001_0000,
        32'h0000_1000,
        32'h0000_1000,
        32'h0000_1000
    }
)
(
    input  logic                     psel,
    input  logic [ADDR_WIDTH-1:0]    paddr,

    output logic [NUM_SLAVES-1:0]    slave_sel,
    output logic                     decode_error
);

    //----------------------------------------------------------
    // Internal Variables
    //----------------------------------------------------------

    integer i;

    logic hit;

    //----------------------------------------------------------
    // Address Decoder
    //----------------------------------------------------------

    always_comb
    begin

        slave_sel    = '0;
        decode_error = 1'b0;

        if(psel)
        begin

            hit = 1'b0;

            for(i=0;i<NUM_SLAVES;i++)
            begin

                if((paddr >= BASE_ADDR[i]) &&
                   (paddr < (BASE_ADDR[i] + ADDR_SIZE[i])))
                begin

                    slave_sel[i] = 1'b1;
                    hit          = 1'b1;

                end

            end

            decode_error = ~hit;

        end

    end
	
	    //----------------------------------------------------------
    // Optional Decode Function
    //----------------------------------------------------------

    function automatic logic addr_hit
    (
        input logic [ADDR_WIDTH-1:0] addr,
        input logic [ADDR_WIDTH-1:0] base,
        input logic [ADDR_WIDTH-1:0] size
    );

        addr_hit = ((addr >= base) &&
                    (addr < (base + size)));

    endfunction

    //----------------------------------------------------------
    // Number of Selected Slaves
    //----------------------------------------------------------

    logic [$clog2(NUM_SLAVES+1)-1:0] sel_count;

    always_comb
    begin

        sel_count = '0;

        for(int j=0;j<NUM_SLAVES;j++)
            sel_count += slave_sel[j];

    end

    //----------------------------------------------------------
    // Optional Slave Index
    //----------------------------------------------------------

    logic [$clog2(NUM_SLAVES)-1:0] slave_index;

    always_comb
    begin

        slave_index = '0;

        for(int j=0;j<NUM_SLAVES;j++)
        begin
            if(slave_sel[j])
                slave_index = j[$clog2(NUM_SLAVES)-1:0];
        end

    end

`ifndef SYNTHESIS

    //----------------------------------------------------------
    // Assertions
    //----------------------------------------------------------

    // Decoder must generate one-hot output
    property p_onehot_decode;

        @(posedge psel)
        $onehot0(slave_sel);

    endproperty

    assert property(p_onehot_decode)
        else
            $error("APB Decoder : Multiple slaves selected.");

    // Decode error only when no slave selected
    property p_decode_error;

        @(posedge psel)

        decode_error |-> (sel_count == 0);

    endproperty

    assert property(p_decode_error)
        else
            $error("APB Decoder : Decode error asserted incorrectly.");

    // Decode error must never occur with valid selection
    property p_valid_decode;

        @(posedge psel)

        (sel_count > 0) |-> !decode_error;

    endproperty

    assert property(p_valid_decode)
        else
            $error("APB Decoder : Valid decode generated error.");

`endif

endmodule

*/