module apb_default_slave
#(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32
)
(
    //----------------------------------------------------------
    // Global Signals
    //----------------------------------------------------------

    input  logic                     pclk,
    input  logic                     presetn,

    //----------------------------------------------------------
    // APB Interface
    //----------------------------------------------------------

    input  logic                     psel,
    input  logic                     penable,
    input  logic                     pwrite,

    input  logic [ADDR_WIDTH-1:0]    paddr,
    input  logic [DATA_WIDTH-1:0]    pwdata,
    input  logic [3:0]               pstrb,
    input  logic [2:0]               pprot,

    //----------------------------------------------------------
    // APB Response
    //----------------------------------------------------------

    output logic [DATA_WIDTH-1:0]    prdata,
    output logic                     pready,
    output logic                     pslverr
);

    //----------------------------------------------------------
    // Error Counters
    //----------------------------------------------------------

    logic [31:0] invalid_access_cnt;
    logic [31:0] invalid_read_cnt;
    logic [31:0] invalid_write_cnt;

    logic access_valid;

    assign access_valid =
            psel &
            penable;

    //----------------------------------------------------------
    // Statistics
    //----------------------------------------------------------

    always_ff @(posedge pclk or negedge presetn)
    begin

        if(!presetn)
        begin

            invalid_access_cnt <= '0;
            invalid_read_cnt   <= '0;
            invalid_write_cnt  <= '0;

        end
        else if(access_valid)
        begin

            invalid_access_cnt <= invalid_access_cnt + 1'b1;

            if(pwrite)
                invalid_write_cnt <= invalid_write_cnt + 1'b1;
            else
                invalid_read_cnt  <= invalid_read_cnt + 1'b1;

        end

    end

    //----------------------------------------------------------
    // Default Response
    //----------------------------------------------------------

    always_comb
    begin

        //--------------------------------------
        // Always Ready
        //--------------------------------------

        pready = 1'b1;

        //--------------------------------------
        // Generate APB Error
        //--------------------------------------

        pslverr = access_valid;

        //--------------------------------------
        // Read Data
        //--------------------------------------

        unique case(paddr[5:2])

            //----------------------------------
            // Error Signature
            //----------------------------------

            4'h0:
                prdata = 32'hDEAD_BEEF;

            //----------------------------------
            // Invalid Access Count
            //----------------------------------

            4'h1:
                prdata = invalid_access_cnt;

            //----------------------------------
            // Invalid Read Count
            //----------------------------------

            4'h2:
                prdata = invalid_read_cnt;

            //----------------------------------
            // Invalid Write Count
            //----------------------------------

            4'h3:
                prdata = invalid_write_cnt;

            //----------------------------------
            // Address
            //----------------------------------

            4'h4:
                prdata = paddr;

            //----------------------------------
            // Protection
            //----------------------------------

            4'h5:
                prdata = {29'd0,pprot};

            //----------------------------------
            // Write Data Echo
            //----------------------------------

            4'h6:
                prdata = pwdata;

            //----------------------------------
            // Write Strobes
            //----------------------------------

            4'h7:
                prdata = {28'd0,pstrb};

            default:
                prdata = 32'hBAD0_BAD0;

        endcase

    end
	`ifndef SYNTHESIS

    //----------------------------------------------------------
    // Internal Status Signals
    //----------------------------------------------------------

    logic illegal_read;
    logic illegal_write;

    assign illegal_read  = access_valid & ~pwrite;
    assign illegal_write = access_valid &  pwrite;

    //----------------------------------------------------------
    // Assertions
    //----------------------------------------------------------

    // Default slave must always respond immediately
    property p_default_ready;

        @(posedge pclk)
        disable iff(!presetn)

        access_valid |-> pready;

    endproperty

    assert property(p_default_ready)
        else
            $error("APB Default Slave : PREADY must always be asserted.");

    //----------------------------------------------------------

    // Invalid access must generate PSLVERR

    property p_default_error;

        @(posedge pclk)
        disable iff(!presetn)

        access_valid |-> pslverr;

    endproperty

    assert property(p_default_error)
        else
            $error("APB Default Slave : PSLVERR not asserted.");

    //----------------------------------------------------------

    // Read transactions return valid data

    property p_read_response;

        @(posedge pclk)
        disable iff(!presetn)

        illegal_read |-> !$isunknown(prdata);

    endproperty

    assert property(p_read_response)
        else
            $error("APB Default Slave : PRDATA contains X.");

    //----------------------------------------------------------

    // Response signals must never be X

    property p_no_unknown;

        @(posedge pclk)
        disable iff(!presetn)

        access_valid |-> (!$isunknown(pready) &&
                          !$isunknown(pslverr));

    endproperty

    assert property(p_no_unknown)
        else
            $error("APB Default Slave : Unknown response detected.");

`endif

endmodule
