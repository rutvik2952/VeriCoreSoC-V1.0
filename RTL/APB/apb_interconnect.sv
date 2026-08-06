
module apb_interconnect
#(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32,
    parameter int NUM_SLAVES = 16
)
(
    //------------------------------------------------------------
    // APB Master Interface
    //------------------------------------------------------------

    input  logic                         pclk,
    input  logic                         presetn,

    input  logic                         psel,
    input  logic                         penable,
    input  logic                         pwrite,

    input  logic [ADDR_WIDTH-1:0]        paddr,
    input  logic [DATA_WIDTH-1:0]        pwdata,
    input  logic [3:0]                   pstrb,
    input  logic [2:0]                   pprot,

    output logic [DATA_WIDTH-1:0]        prdata,
    output logic                         pready,
    output logic                         pslverr,

    //------------------------------------------------------------
    // Peripheral Select Outputs
    //------------------------------------------------------------

    output logic [NUM_SLAVES-1:0]        slave_psel,

    //------------------------------------------------------------
    // Peripheral Response Inputs
    //------------------------------------------------------------

    input logic [NUM_SLAVES-1:0][DATA_WIDTH-1:0] slave_prdata,
    input logic [NUM_SLAVES-1:0]                 slave_pready,
    input logic [NUM_SLAVES-1:0]                 slave_pslverr
);

    //------------------------------------------------------------
    // Internal Signals
    //------------------------------------------------------------

    logic decode_error;

    logic [DATA_WIDTH-1:0] default_prdata;
    logic                  default_pready;
    logic                  default_pslverr;

    //------------------------------------------------------------
    // Address Decoder
    //------------------------------------------------------------

    apb_decoder
    #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .NUM_SLAVES (NUM_SLAVES)
    )
    u_decoder
    (
        .psel           (psel),
        .paddr          (paddr),

        .slave_sel      (slave_psel),
        .decode_error   (decode_error)
    );

    //------------------------------------------------------------
    // Default Slave
    //------------------------------------------------------------

    apb_default_slave
    #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH)
    )
    u_default_slave
    (
        .pclk       (pclk),
        .presetn    (presetn),

        .psel       (decode_error & psel),
        .penable    (penable),
        .pwrite     (pwrite),

        .paddr      (paddr),
        .pwdata     (pwdata),
        .pstrb      (pstrb),
        .pprot      (pprot),

        .prdata     (default_prdata),
        .pready     (default_pready),
        .pslverr    (default_pslverr)
    );

    //------------------------------------------------------------
    // Response Multiplexer
    //------------------------------------------------------------

    apb_mux
    #(
        .DATA_WIDTH (DATA_WIDTH),
        .NUM_SLAVES (NUM_SLAVES)
    )
    u_mux
    (
        .slave_sel      (slave_psel),

        .slave_prdata   (slave_prdata),
        .slave_pready   (slave_pready),
        .slave_pslverr  (slave_pslverr),

        .default_prdata (default_prdata),
        .default_pready (default_pready),
        .default_pslverr(default_pslverr),

        .decode_error   (decode_error),

        .prdata         (prdata),
        .pready         (pready),
        .pslverr        (pslverr)
    );
	
	    //------------------------------------------------------------
    // Performance Counters
    //------------------------------------------------------------

    logic [31:0] total_transactions;
    logic [31:0] read_transactions;
    logic [31:0] write_transactions;
    logic [31:0] decode_error_count;

    wire access_complete;

    assign access_complete =
            psel &
            penable &
            pready;

    always_ff @(posedge pclk or negedge presetn)
    begin

        if(!presetn)
        begin
            total_transactions <= '0;
            read_transactions  <= '0;
            write_transactions <= '0;
            decode_error_count <= '0;
        end
        else
        begin

            if(access_complete)
            begin

                total_transactions <= total_transactions + 1'b1;

                if(pwrite)
                    write_transactions <= write_transactions + 1'b1;
                else
                    read_transactions  <= read_transactions + 1'b1;

            end

            if(psel && decode_error)
                decode_error_count <= decode_error_count + 1'b1;

        end

    end

`ifndef SYNTHESIS

    //------------------------------------------------------------
    // Assertions
    //------------------------------------------------------------

    // Only one slave can be selected
    property p_onehot_slave;

        @(posedge pclk)
        disable iff(!presetn)

        psel |-> $onehot0(slave_psel);

    endproperty

    assert property(p_onehot_slave)
        else
            $error("APB_INTERCONNECT : Multiple slaves selected.");

    //------------------------------------------------------------

    // Decode error implies no slave selected

    property p_decode_error;

        @(posedge pclk)
        disable iff(!presetn)

        decode_error |-> (slave_psel == '0);

    endproperty

    assert property(p_decode_error)
        else
            $error("APB_INTERCONNECT : Decode error with valid slave.");

    //------------------------------------------------------------

    // PRDATA must never contain X when transaction completes

    property p_prdata_valid;

        @(posedge pclk)
        disable iff(!presetn)

        access_complete && !pwrite
            |->
        !$isunknown(prdata);

    endproperty

    assert property(p_prdata_valid)
        else
            $error("APB_INTERCONNECT : PRDATA contains unknown.");

    //------------------------------------------------------------

    // PREADY must never be X

    property p_pready_valid;

        @(posedge pclk)
        disable iff(!presetn)

        psel |-> !$isunknown(pready);

    endproperty

    assert property(p_pready_valid)
        else
            $error("APB_INTERCONNECT : PREADY unknown.");

    //------------------------------------------------------------

    // PSLVERR must never be X

    property p_pslverr_valid;

        @(posedge pclk)
        disable iff(!presetn)

        psel |-> !$isunknown(pslverr);

    endproperty

    assert property(p_pslverr_valid)
        else
            $error("APB_INTERCONNECT : PSLVERR unknown.");

`endif

endmodule