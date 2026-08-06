`ifndef APB_IF_SV
`define APB_IF_SV

interface apb_if
#(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter STRB_WIDTH = DATA_WIDTH/8
)
(
    input logic PCLK,
    input logic PRESETn
);

    //------------------------------------------------------------
    // APB4 Signals
    //------------------------------------------------------------

    logic                     PSEL;
    logic                     PENABLE;
    logic                     PWRITE;

    logic [ADDR_WIDTH-1:0]    PADDR;
    logic [DATA_WIDTH-1:0]    PWDATA;

    logic [DATA_WIDTH-1:0]    PRDATA;

    logic                     PREADY;
    logic                     PSLVERR;

    logic [STRB_WIDTH-1:0]    PSTRB;

    logic [2:0]               PPROT;

    //------------------------------------------------------------
    // Optional User Signals
    //------------------------------------------------------------

    logic                     PCLK_EN;

    logic                     PREQ;

    logic                     PGNT;

    //------------------------------------------------------------
    // Clocking Blocks
    //------------------------------------------------------------

`ifndef SYNTHESIS

    clocking master_cb @(posedge PCLK);

        default input #1step output #1step;

        output  PSEL;
        output  PENABLE;
        output  PWRITE;

        output  PADDR;
        output  PWDATA;
        output  PSTRB;
        output  PPROT;

        input   PRDATA;
        input   PREADY;
        input   PSLVERR;

    endclocking

    clocking slave_cb @(posedge PCLK);

        default input #1step output #1step;

        input  PSEL;
        input  PENABLE;
        input  PWRITE;

        input  PADDR;
        input  PWDATA;
        input  PSTRB;
        input  PPROT;

        output PRDATA;
        output PREADY;
        output PSLVERR;

    endclocking

`endif

    //------------------------------------------------------------
    // Master Modport
    //------------------------------------------------------------

    modport MASTER
    (
        input   PCLK,
        input   PRESETn,

        output  PSEL,
        output  PENABLE,
        output  PWRITE,

        output  PADDR,
        output  PWDATA,

        output  PSTRB,
        output  PPROT,

        input   PRDATA,
        input   PREADY,
        input   PSLVERR
    );

    //------------------------------------------------------------
    // Slave Modport
    //------------------------------------------------------------

    modport SLAVE
    (
        input   PCLK,
        input   PRESETn,

        input   PSEL,
        input   PENABLE,
        input   PWRITE,

        input   PADDR,
        input   PWDATA,

        input   PSTRB,
        input   PPROT,

        output  PRDATA,
        output  PREADY,
        output  PSLVERR
    );
	
	    //------------------------------------------------------------
    // Monitor Modport
    //------------------------------------------------------------

    modport MONITOR
    (
        input PCLK,
        input PRESETn,

        input PSEL,
        input PENABLE,
        input PWRITE,

        input PADDR,
        input PWDATA,
        input PRDATA,

        input PSTRB,
        input PPROT,

        input PREADY,
        input PSLVERR
    );

    //------------------------------------------------------------
    // Driver Modport
    //------------------------------------------------------------

`ifndef SYNTHESIS

    modport DRIVER
    (
        clocking master_cb,

        input PCLK,
        input PRESETn
    );

`endif

    //------------------------------------------------------------
    // Interface Initialization
    //------------------------------------------------------------

    task automatic init();

        PSEL     = 1'b0;
        PENABLE  = 1'b0;
        PWRITE   = 1'b0;

        PADDR    = '0;
        PWDATA   = '0;

        PSTRB    = '0;
        PPROT    = '0;

        PRDATA   = '0;

        PREADY   = 1'b1;
        PSLVERR  = 1'b0;

        PCLK_EN  = 1'b1;
        PREQ     = 1'b0;
        PGNT     = 1'b0;

    endtask

    //------------------------------------------------------------
    // Reset Interface
    //------------------------------------------------------------

    task automatic reset_master();

        PSEL     = 1'b0;
        PENABLE  = 1'b0;
        PWRITE   = 1'b0;

        PADDR    = '0;
        PWDATA   = '0;
        PSTRB    = '0;
        PPROT    = '0;

    endtask

    //------------------------------------------------------------
    // APB Write Helper
    //------------------------------------------------------------

    task automatic apb_write
    (
        input logic [ADDR_WIDTH-1:0] addr,
        input logic [DATA_WIDTH-1:0] data,
        input logic [STRB_WIDTH-1:0] strb
    );

        @(posedge PCLK);

        PSEL    <= 1'b1;
        PENABLE <= 1'b0;
        PWRITE  <= 1'b1;

        PADDR   <= addr;
        PWDATA  <= data;
        PSTRB   <= strb;

        @(posedge PCLK);

        PENABLE <= 1'b1;

        wait(PREADY);

        @(posedge PCLK);

        PSEL    <= 1'b0;
        PENABLE <= 1'b0;

    endtask

    //------------------------------------------------------------
    // APB Read Helper
    //------------------------------------------------------------

    task automatic apb_read
    (
        input  logic [ADDR_WIDTH-1:0] addr,
        output logic [DATA_WIDTH-1:0] data
    );

        @(posedge PCLK);

        PSEL    <= 1'b1;
        PENABLE <= 1'b0;
        PWRITE  <= 1'b0;

        PADDR   <= addr;

        @(posedge PCLK);

        PENABLE <= 1'b1;

        wait(PREADY);

        data = PRDATA;

        @(posedge PCLK);

        PSEL    <= 1'b0;
        PENABLE <= 1'b0;

    endtask

    //------------------------------------------------------------
    // APB Protocol Assertions
    //------------------------------------------------------------

`ifndef SYNTHESIS

    property p_enable_requires_psel;
        @(posedge PCLK)
        PENABLE |-> PSEL;
    endproperty

    assert property(p_enable_requires_psel)
        else
            $error("APB Protocol Error : PENABLE asserted without PSEL");

    property p_addr_stable;
        @(posedge PCLK)
        (PSEL && PENABLE && !PREADY)
            |=> $stable(PADDR);
    endproperty

    assert property(p_addr_stable)
        else
            $error("APB Protocol Error : PADDR changed during wait state");

    property p_write_data_stable;
        @(posedge PCLK)
        (PSEL && PENABLE && PWRITE && !PREADY)
            |=> $stable(PWDATA);
    endproperty

    assert property(p_write_data_stable)
        else
            $error("APB Protocol Error : PWDATA changed during wait state");

    property p_strb_stable;
        @(posedge PCLK)
        (PSEL && PENABLE && !PREADY)
            |=> $stable(PSTRB);
    endproperty

    assert property(p_strb_stable)
        else
            $error("APB Protocol Error : PSTRB changed during wait state");

`endif

endinterface

`endif