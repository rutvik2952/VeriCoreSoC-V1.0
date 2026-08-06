`timescale 1ns/1ps

module apb_slave
#(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter STRB_WIDTH = DATA_WIDTH/8
)
(
    //------------------------------------------------------------
    // Global Signals
    //------------------------------------------------------------

    input  logic                     PCLK,
    input  logic                     PRESETn,

    //------------------------------------------------------------
    // APB Bus Signals
    //------------------------------------------------------------

    input  logic                     PSEL,
    input  logic                     PENABLE,
    input  logic                     PWRITE,

    input  logic [ADDR_WIDTH-1:0]    PADDR,
    input  logic [DATA_WIDTH-1:0]    PWDATA,
    input  logic [STRB_WIDTH-1:0]    PSTRB,
    input  logic [2:0]               PPROT,

    output logic [DATA_WIDTH-1:0]    PRDATA,
    output logic                     PREADY,
    output logic                     PSLVERR,

    //------------------------------------------------------------
    // Register Bank Interface
    //------------------------------------------------------------

    output logic                     reg_write,
    output logic                     reg_read,

    output logic [ADDR_WIDTH-1:0]    reg_addr,
    output logic [DATA_WIDTH-1:0]    reg_wdata,
    output logic [STRB_WIDTH-1:0]    reg_strb,

    input  logic [DATA_WIDTH-1:0]    reg_rdata,
    input  logic                     reg_ready,
    input  logic                     reg_error
);

    //------------------------------------------------------------
    // Internal Signals
    //------------------------------------------------------------

    logic access_valid;
    logic setup_valid;

    //------------------------------------------------------------
    // APB Transaction Decode
    //------------------------------------------------------------

    assign setup_valid =
                PSEL &
               ~PENABLE;

    assign access_valid =
                PSEL &
                PENABLE;

    //------------------------------------------------------------
    // Register Access Decode
    //------------------------------------------------------------

    assign reg_write =
                access_valid &
                PWRITE;

    assign reg_read =
                access_valid &
               ~PWRITE;

    assign reg_addr =
                PADDR;

    assign reg_wdata =
                PWDATA;

    assign reg_strb =
                PSTRB;

    //------------------------------------------------------------
    // APB Response
    //------------------------------------------------------------

    always_comb
    begin

        PRDATA  = reg_rdata;
        PREADY  = reg_ready;
        PSLVERR = reg_error;

    end
	
	    //------------------------------------------------------------
    // Slave Status Signals
    //------------------------------------------------------------

    logic slave_selected;
    logic slave_enable;
    logic slave_busy;
    logic transfer_done;

    assign slave_selected = PSEL;
    assign slave_enable   = PSEL & PENABLE;
    assign slave_busy     = slave_enable & ~reg_ready;
    assign transfer_done  = slave_enable & reg_ready;

    //------------------------------------------------------------
    // Optional Access Counters (Debug)
    //------------------------------------------------------------

    logic [31:0] read_count;
    logic [31:0] write_count;

    always_ff @(posedge PCLK or negedge PRESETn)
    begin
        if(!PRESETn)
        begin
            read_count  <= '0;
            write_count <= '0;
        end
        else
        begin
            if(reg_read && reg_ready)
                read_count <= read_count + 1'b1;

            if(reg_write && reg_ready)
                write_count <= write_count + 1'b1;
        end
    end

    //------------------------------------------------------------
    // Protocol Assertions
    //------------------------------------------------------------

`ifndef SYNTHESIS

    // PENABLE requires PSEL
    property p_enable_requires_psel;
        @(posedge PCLK)
        PENABLE |-> PSEL;
    endproperty

    assert property(p_enable_requires_psel)
        else
            $error("APB Slave : PENABLE asserted without PSEL");

    // Address stable during wait states
    property p_addr_stable;
        @(posedge PCLK)
        (PSEL && PENABLE && !reg_ready)
            |=> $stable(PADDR);
    endproperty

    assert property(p_addr_stable)
        else
            $error("APB Slave : Address changed during wait state");

    // Write data stable during wait states
    property p_wdata_stable;
        @(posedge PCLK)
        (PSEL && PENABLE && PWRITE && !reg_ready)
            |=> $stable(PWDATA);
    endproperty

    assert property(p_wdata_stable)
        else
            $error("APB Slave : Write data changed during wait state");

    // Write strobes stable during wait states
    property p_strb_stable;
        @(posedge PCLK)
        (PSEL && PENABLE && !reg_ready)
            |=> $stable(PSTRB);
    endproperty

    assert property(p_strb_stable)
        else
            $error("APB Slave : Write strobes changed during wait state");

    // No simultaneous read/write
    property p_no_simultaneous_access;
        @(posedge PCLK)
        !(reg_read && reg_write);
    endproperty

    assert property(p_no_simultaneous_access)
        else
            $error("APB Slave : Read and Write asserted simultaneously");

`endif

endmodule
