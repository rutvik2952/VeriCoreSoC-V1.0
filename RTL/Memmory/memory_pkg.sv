`ifndef MEMORY_PKG_SV
`define MEMORY_PKG_SV

package memory_pkg;

    //------------------------------------------------------------
    // Global Memory Parameters
    //------------------------------------------------------------

    parameter int MEM_DATA_WIDTH = 32;
    parameter int MEM_ADDR_WIDTH = 32;

    parameter int BYTE_WIDTH = 8;
    parameter int STRB_WIDTH = MEM_DATA_WIDTH/8;

    //------------------------------------------------------------
    // Default Memory Sizes
    //------------------------------------------------------------

    parameter int IMEM_DEPTH = 4096;
    parameter int DMEM_DEPTH = 4096;

    parameter int FIFO_DEPTH = 256;
    parameter int DMA_DEPTH  = 8192;

    //------------------------------------------------------------
    // Address Widths
    //------------------------------------------------------------

    parameter int IMEM_AWIDTH = $clog2(IMEM_DEPTH);
    parameter int DMEM_AWIDTH = $clog2(DMEM_DEPTH);
    parameter int FIFO_AWIDTH = $clog2(FIFO_DEPTH);
    parameter int DMA_AWIDTH  = $clog2(DMA_DEPTH);

    //------------------------------------------------------------
    // Memory Type
    //------------------------------------------------------------

    typedef enum logic [2:0]
    {
        MEM_ROM,
        MEM_RAM,
        MEM_FIFO,
        MEM_DMA,
        MEM_RESERVED
    } mem_type_e;

    //------------------------------------------------------------
    // Read Policy
    //------------------------------------------------------------

    typedef enum logic [1:0]
    {
        READ_ASYNC,
        READ_SYNC,
        READ_PIPELINE
    } mem_read_policy_e;

    //------------------------------------------------------------
    // Write Policy
    //------------------------------------------------------------

    typedef enum logic [1:0]
    {
        WRITE_FIRST,
        READ_FIRST,
        NO_CHANGE
    } mem_write_policy_e;

    //------------------------------------------------------------
    // Byte Enable Type
    //------------------------------------------------------------

    typedef logic [STRB_WIDTH-1:0] byte_enable_t;

    //------------------------------------------------------------
    // Memory Request
    //------------------------------------------------------------

    typedef struct packed
    {
        logic                         valid;
        logic                         write;

        logic [MEM_ADDR_WIDTH-1:0]    addr;
        logic [MEM_DATA_WIDTH-1:0]    wdata;

        byte_enable_t                 be;

    } mem_req_t;

    //------------------------------------------------------------
    // Memory Response
    //------------------------------------------------------------

    typedef struct packed
    {
        logic                         ready;
        logic                         error;

        logic [MEM_DATA_WIDTH-1:0]    rdata;

    } mem_rsp_t;
	
	    //------------------------------------------------------------
    // Helper Functions
    //------------------------------------------------------------

    function automatic logic word_aligned
    (
        input logic [MEM_ADDR_WIDTH-1:0] addr
    );

        word_aligned = (addr[1:0] == 2'b00);

    endfunction

    //------------------------------------------------------------

    function automatic logic halfword_aligned
    (
        input logic [MEM_ADDR_WIDTH-1:0] addr
    );

        halfword_aligned = (addr[0] == 1'b0);

    endfunction

    //------------------------------------------------------------

    function automatic logic [MEM_ADDR_WIDTH-1:0] next_word_addr
    (
        input logic [MEM_ADDR_WIDTH-1:0] addr
    );

        next_word_addr = addr + 32'd4;

    endfunction

    //------------------------------------------------------------

    function automatic logic [MEM_ADDR_WIDTH-1:0] previous_word_addr
    (
        input logic [MEM_ADDR_WIDTH-1:0] addr
    );

        previous_word_addr = addr - 32'd4;

    endfunction

    //------------------------------------------------------------
    // Byte Enable Helpers
    //------------------------------------------------------------

    function automatic logic [31:0] byte_enable_mask
    (
        input byte_enable_t be
    );

        byte_enable_mask =
        {
            {8{be[3]}},
            {8{be[2]}},
            {8{be[1]}},
            {8{be[0]}}
        };

    endfunction

    //------------------------------------------------------------

    function automatic logic [31:0] merge_write_data
    (
        input logic [31:0] old_data,
        input logic [31:0] new_data,
        input byte_enable_t be
    );

        logic [31:0] mask;

        begin

            mask = byte_enable_mask(be);

            merge_write_data =
                    (old_data & ~mask)
                  | (new_data &  mask);

        end

    endfunction

    //------------------------------------------------------------
    // Memory Reset Values
    //------------------------------------------------------------

    parameter logic [31:0] MEM_RESET_VALUE = 32'h0000_0000;

    parameter logic [31:0] MEM_ERROR_VALUE = 32'hDEAD_BEEF;

    //------------------------------------------------------------
    // Future ECC Support
    //------------------------------------------------------------

    parameter bit ECC_ENABLE = 1'b0;

    parameter int ECC_WIDTH  = 7;

    //------------------------------------------------------------
    // Memory Latency
    //------------------------------------------------------------

    parameter int DEFAULT_READ_LATENCY  = 1;
    parameter int DEFAULT_WRITE_LATENCY = 1;

    //------------------------------------------------------------
    // Maximum Outstanding Requests
    //------------------------------------------------------------

    parameter int MAX_OUTSTANDING_REQ = 1;

    //------------------------------------------------------------
    // Memory Attributes
    //------------------------------------------------------------

    typedef struct packed
    {
        mem_type_e          mem_type;
        mem_read_policy_e   read_policy;
        mem_write_policy_e  write_policy;

        logic               cacheable;
        logic               bufferable;
        logic               executable;

    } mem_attribute_t;

    //------------------------------------------------------------
    // Default Memory Attributes
    //------------------------------------------------------------

    function automatic mem_attribute_t default_mem_attr();

        mem_attribute_t attr;

        attr.mem_type      = MEM_RAM;
        attr.read_policy   = READ_SYNC;
        attr.write_policy  = WRITE_FIRST;

        attr.cacheable     = 1'b0;
        attr.bufferable    = 1'b0;
        attr.executable    = 1'b0;

        return attr;

    endfunction

endpackage

`endif
