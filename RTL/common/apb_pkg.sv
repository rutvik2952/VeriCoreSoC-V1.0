`ifndef APB_PKG_SV
`define APB_PKG_SV

package apb_pkg;

    //------------------------------------------------------------
    // APB Version
    //------------------------------------------------------------

    parameter int APB_VERSION = 4;

    //------------------------------------------------------------
    // Bus Width Configuration
    //------------------------------------------------------------

    parameter int APB_ADDR_WIDTH = 32;
    parameter int APB_DATA_WIDTH = 32;
    parameter int APB_STRB_WIDTH = APB_DATA_WIDTH/8;

    parameter int APB_MAX_SLAVES = 16;
    parameter int APB_MAX_MASTERS = 1;

    //------------------------------------------------------------
    // APB State Machine
    //------------------------------------------------------------

    typedef enum logic [1:0]
    {
        APB_STATE_IDLE   = 2'b00,
        APB_STATE_SETUP  = 2'b01,
        APB_STATE_ACCESS = 2'b10
    } apb_state_e;

    //------------------------------------------------------------
    // APB Command Type
    //------------------------------------------------------------

    typedef enum logic
    {
        APB_READ  = 1'b0,
        APB_WRITE = 1'b1
    } apb_cmd_e;

    //------------------------------------------------------------
    // APB Response Type
    //------------------------------------------------------------

    typedef enum logic
    {
        APB_RESP_OKAY  = 1'b0,
        APB_RESP_ERROR = 1'b1
    } apb_resp_e;

    //------------------------------------------------------------
    // APB Master Request Structure
    //------------------------------------------------------------

    typedef struct packed
    {
        logic                             valid;
        logic                             write;

        logic [APB_ADDR_WIDTH-1:0]        addr;

        logic [APB_DATA_WIDTH-1:0]        wdata;

        logic [APB_STRB_WIDTH-1:0]        strb;

        logic [2:0]                       prot;

    } apb_req_t;

    //------------------------------------------------------------
    // APB Slave Response Structure
    //------------------------------------------------------------

    typedef struct packed
    {
        logic                             ready;

        logic                             slverr;

        logic [APB_DATA_WIDTH-1:0]        rdata;

    } apb_rsp_t;

    //------------------------------------------------------------
    // APB Master Interface Structure
    //------------------------------------------------------------

    typedef struct packed
    {
        logic                             psel;

        logic                             penable;

        logic                             pwrite;

        logic [APB_ADDR_WIDTH-1:0]        paddr;

        logic [APB_DATA_WIDTH-1:0]        pwdata;

        logic [APB_STRB_WIDTH-1:0]        pstrb;

        logic [2:0]                       pprot;

    } apb_master_t;

    //------------------------------------------------------------
    // APB Slave Interface Structure
    //------------------------------------------------------------

    typedef struct packed
    {
        logic                             pready;

        logic                             pslverr;

        logic [APB_DATA_WIDTH-1:0]        prdata;

    } apb_slave_t;

    //------------------------------------------------------------
    // Peripheral IDs
    //------------------------------------------------------------

    typedef enum logic [4:0]
    {
        APB_SYSCTRL  = 5'd0,
        APB_INTC     = 5'd1,
        APB_TIMER    = 5'd2,
        APB_GPIO     = 5'd3,
        APB_UART     = 5'd4,
        APB_SPI      = 5'd5,
        APB_I2C      = 5'd6,
        APB_DMA      = 5'd7,
        APB_DEBUG    = 5'd8,
        APB_FIFO     = 5'd9,
        APB_DMA_RAM  = 5'd10,
        APB_IMEM     = 5'd11,
        APB_DMEM     = 5'd12,
        APB_RESERVED = 5'd31

    } apb_slave_id_e;

    //------------------------------------------------------------
    // APB Transfer Status
    //------------------------------------------------------------

    typedef enum logic [2:0]
    {
        APB_IDLE_STATUS    = 3'd0,
        APB_SETUP_STATUS   = 3'd1,
        APB_ACCESS_STATUS  = 3'd2,
        APB_WAIT_STATUS    = 3'd3,
        APB_COMPLETE       = 3'd4,
        APB_ERROR_STATUS   = 3'd5

    } apb_status_e;
	
	    //------------------------------------------------------------
    // APB Timeout Configuration
    //------------------------------------------------------------

    parameter int APB_TIMEOUT_CYCLES = 1024;

    //------------------------------------------------------------
    // Address Alignment
    //------------------------------------------------------------

    parameter logic [1:0] APB_BYTE_ACCESS = 2'b00;
    parameter logic [1:0] APB_HALF_ACCESS = 2'b01;
    parameter logic [1:0] APB_WORD_ACCESS = 2'b10;

    //------------------------------------------------------------
    // APB Protection Encoding
    //------------------------------------------------------------

    parameter logic [2:0] APB_PROT_NORMAL       = 3'b000;
    parameter logic [2:0] APB_PROT_PRIVILEGED   = 3'b001;
    parameter logic [2:0] APB_PROT_SECURE       = 3'b010;
    parameter logic [2:0] APB_PROT_INSTRUCTION  = 3'b100;

    //------------------------------------------------------------
    // Byte Strobe Decode
    //------------------------------------------------------------

    typedef enum logic [3:0]
    {
        STRB_BYTE0 = 4'b0001,
        STRB_BYTE1 = 4'b0010,
        STRB_BYTE2 = 4'b0100,
        STRB_BYTE3 = 4'b1000,
        STRB_HALF0 = 4'b0011,
        STRB_HALF1 = 4'b1100,
        STRB_WORD  = 4'b1111

    } apb_strb_e;

    //------------------------------------------------------------
    // Address Decode Helper
    //------------------------------------------------------------

    function automatic logic addr_hit
    (
        input logic [31:0] addr,
        input logic [31:0] base_addr,
        input logic [31:0] size
    );

        addr_hit = ((addr >= base_addr) &&
                    (addr < (base_addr + size)));

    endfunction

    //------------------------------------------------------------
    // Word Alignment Check
    //------------------------------------------------------------

    function automatic logic is_word_aligned
    (
        input logic [31:0] addr
    );

        is_word_aligned = (addr[1:0] == 2'b00);

    endfunction

    //------------------------------------------------------------
    // Half Word Alignment Check
    //------------------------------------------------------------

    function automatic logic is_half_aligned
    (
        input logic [31:0] addr
    );

        is_half_aligned = (addr[0] == 1'b0);

    endfunction

    //------------------------------------------------------------
    // Access Size Decode
    //------------------------------------------------------------

    function automatic logic [1:0] get_access_size
    (
        input logic [3:0] strb
    );

        case(strb)

            4'b1111:
                get_access_size = APB_WORD_ACCESS;

            4'b0011,
            4'b1100:
                get_access_size = APB_HALF_ACCESS;

            default:
                get_access_size = APB_BYTE_ACCESS;

        endcase

    endfunction

    //------------------------------------------------------------
    // Byte Enable Count
    //------------------------------------------------------------

    function automatic logic [2:0] byte_count
    (
        input logic [3:0] strb
    );

        byte_count =
              strb[0]
            + strb[1]
            + strb[2]
            + strb[3];

    endfunction

    //------------------------------------------------------------
    // Address Offset
    //------------------------------------------------------------

    function automatic logic [11:0] addr_offset
    (
        input logic [31:0] addr
    );

        addr_offset = addr[11:0];

    endfunction

    //------------------------------------------------------------
    // Register Index
    //------------------------------------------------------------

    function automatic logic [9:0] reg_index
    (
        input logic [31:0] addr
    );

        reg_index = addr[11:2];

    endfunction

    //------------------------------------------------------------
    // Write Mask Generator
    //------------------------------------------------------------

    function automatic logic [31:0] write_mask
    (
        input logic [3:0] strb
    );

        write_mask = {

            {8{strb[3]}},
            {8{strb[2]}},
            {8{strb[1]}},
            {8{strb[0]}}

        };

    endfunction

    //------------------------------------------------------------
    // Merge Write Data
    //------------------------------------------------------------

    function automatic logic [31:0] merge_write_data
    (
        input logic [31:0] old_data,
        input logic [31:0] new_data,
        input logic [3:0]  strb
    );

        logic [31:0] mask;

        begin

            mask = write_mask(strb);

            merge_write_data =
                    (old_data & ~mask)
                  | (new_data &  mask);

        end

    endfunction
	
	    //------------------------------------------------------------
    // APB Address Increment
    //------------------------------------------------------------

    function automatic logic [31:0] next_word_addr
    (
        input logic [31:0] addr
    );

        next_word_addr = addr + 32'd4;

    endfunction

    //------------------------------------------------------------
    // Address Decode Utility
    //------------------------------------------------------------

    function automatic logic decode_slave
    (
        input logic [31:0] addr,
        input logic [31:0] base_addr
    );

        decode_slave = (addr[31:12] == base_addr[31:12]);

    endfunction

    //------------------------------------------------------------
    // Valid APB Write
    //------------------------------------------------------------

    function automatic logic valid_write
    (
        input logic psel,
        input logic penable,
        input logic pwrite
    );

        valid_write = psel & penable & pwrite;

    endfunction

    //------------------------------------------------------------
    // Valid APB Read
    //------------------------------------------------------------

    function automatic logic valid_read
    (
        input logic psel,
        input logic penable,
        input logic pwrite
    );

        valid_read = psel & penable & ~pwrite;

    endfunction

    //------------------------------------------------------------
    // APB Transaction Complete
    //------------------------------------------------------------

    function automatic logic transfer_done
    (
        input logic psel,
        input logic penable,
        input logic pready
    );

        transfer_done = psel & penable & pready;

    endfunction

    //------------------------------------------------------------
    // APB Transaction Error
    //------------------------------------------------------------

    function automatic logic transfer_error
    (
        input logic psel,
        input logic penable,
        input logic pready,
        input logic pslverr
    );

        transfer_error = psel &
                         penable &
                         pready &
                         pslverr;

    endfunction

    //------------------------------------------------------------
    // APB Idle Detect
    //------------------------------------------------------------

    function automatic logic bus_idle
    (
        input logic psel,
        input logic penable
    );

        bus_idle = (~psel) & (~penable);

    endfunction

    //------------------------------------------------------------
    // Default Read Data
    //------------------------------------------------------------

    function automatic logic [31:0] default_rdata();

        default_rdata = 32'h0000_0000;

    endfunction

    //------------------------------------------------------------
    // Default Error Data
    //------------------------------------------------------------

    function automatic logic [31:0] error_rdata();

        error_rdata = 32'hDEAD_BEEF;

    endfunction

    //------------------------------------------------------------
    // Peripheral Window Size
    //------------------------------------------------------------

    function automatic logic [31:0] peripheral_size();

        peripheral_size = 32'h0000_1000;

    endfunction

    //------------------------------------------------------------
    // Peripheral Window Alignment Check
    //------------------------------------------------------------

    function automatic logic aligned_4KB
    (
        input logic [31:0] addr
    );

        aligned_4KB = (addr[11:0] == 12'h000);

    endfunction

    //------------------------------------------------------------
    // Peripheral Base Address Extract
    //------------------------------------------------------------

    function automatic logic [31:0] peripheral_base
    (
        input logic [31:0] addr
    );

        peripheral_base =
        {
            addr[31:12],
            12'h000
        };

    endfunction

    //------------------------------------------------------------
    // APB Default Request
    //------------------------------------------------------------

    function automatic apb_req_t default_req();

        apb_req_t req;

        req.valid  = 1'b0;
        req.write  = 1'b0;
        req.addr   = '0;
        req.wdata  = '0;
        req.strb   = 4'b0000;
        req.prot   = 3'b000;

        return req;

    endfunction

    //------------------------------------------------------------
    // APB Default Response
    //------------------------------------------------------------

    function automatic apb_rsp_t default_rsp();

        apb_rsp_t rsp;

        rsp.ready   = 1'b1;
        rsp.slverr  = 1'b0;
        rsp.rdata   = 32'h0000_0000;

        return rsp;

    endfunction

    //------------------------------------------------------------
    // APB Write Request Constructor
    //------------------------------------------------------------

    function automatic apb_req_t create_write_req
    (
        input logic [31:0] addr,
        input logic [31:0] data,
        input logic [3:0]  strb
    );

        apb_req_t req;

        req.valid = 1'b1;
        req.write = 1'b1;
        req.addr  = addr;
        req.wdata = data;
        req.strb  = strb;
        req.prot  = APB_PROT_NORMAL;

        return req;

    endfunction

    //------------------------------------------------------------
    // APB Read Request Constructor
    //------------------------------------------------------------

    function automatic apb_req_t create_read_req
    (
        input logic [31:0] addr
    );

        apb_req_t req;

        req.valid = 1'b1;
        req.write = 1'b0;
        req.addr  = addr;
        req.wdata = '0;
        req.strb  = 4'b1111;
        req.prot  = APB_PROT_NORMAL;

        return req;

    endfunction

endpackage

`endif