module generic_ram
#(
    parameter int DATA_WIDTH      = 32,
    parameter int ADDR_WIDTH      = 12,
    parameter int DEPTH           = (1<<ADDR_WIDTH),

    parameter bit READ_ONLY       = 0,
    parameter bit OUTPUT_REG      = 0,
    parameter bit MEM_INIT_FILE   = 0,

    parameter string INIT_FILE    = ""
)
(
    //------------------------------------------------------------
    // Global Signals
    //------------------------------------------------------------

    input  logic                     clk,
    input  logic                     rst_n,

    //------------------------------------------------------------
    // Control
    //------------------------------------------------------------

    input  logic                     cs,
    input  logic                     we,
    input  logic                     re,

    //------------------------------------------------------------
    // Address
    //------------------------------------------------------------

    input  logic [ADDR_WIDTH-1:0]    addr,

    //------------------------------------------------------------
    // Write Data
    //------------------------------------------------------------

    input  logic [DATA_WIDTH-1:0]    wdata,

    input  logic [(DATA_WIDTH/8)-1:0] be,

    //------------------------------------------------------------
    // Read Data
    //------------------------------------------------------------

    output logic [DATA_WIDTH-1:0]    rdata,

    output logic                     ready,

    output logic                     error
);

    //------------------------------------------------------------
    // Memory Declaration
    //------------------------------------------------------------

    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    //------------------------------------------------------------
    // Internal Signals
    //------------------------------------------------------------

    logic [DATA_WIDTH-1:0] read_data;

    logic                  addr_error;

    integer i;

    //------------------------------------------------------------
    // Optional Memory Initialization
    //------------------------------------------------------------

    generate

        if(MEM_INIT_FILE)
        begin

            initial
            begin

                if(INIT_FILE != "")
                    $readmemh(INIT_FILE, mem);

            end

        end

    endgenerate

    //------------------------------------------------------------
    // Ready/Error
    //------------------------------------------------------------

    assign ready = cs;

    assign addr_error = (addr >= DEPTH);

    assign error = addr_error;

    //------------------------------------------------------------
    // Reset
    //------------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin

            for(i=0;i<DEPTH;i++)
                mem[i] <= '0;

        end
        else
        begin

            //----------------------------------------------------
            // Byte Enable Write
            //----------------------------------------------------

            if(cs && we && !READ_ONLY && !addr_error)
            begin

                for(int b=0;b<DATA_WIDTH/8;b++)
                begin

                    if(be[b])
                        mem[addr][(8*b)+:8] <= wdata[(8*b)+:8];

                end

            end

        end

    end

    //------------------------------------------------------------
    // Read Logic
    //------------------------------------------------------------

    always_comb
    begin

        if(cs && re && !addr_error)
            read_data = mem[addr];
        else
            read_data = '0;

    end

    //------------------------------------------------------------
    // Optional Output Register
    //------------------------------------------------------------

    generate

        if(OUTPUT_REG)
        begin

            always_ff @(posedge clk or negedge rst_n)
            begin

                if(!rst_n)
                    rdata <= '0;
                else if(cs && re)
                    rdata <= read_data;

            end

        end
        else
        begin

            always_comb
            begin
                rdata = read_data;
            end

        end

    endgenerate

    //------------------------------------------------------------
    // Performance Counters
    //------------------------------------------------------------

    logic [31:0] read_count;
    logic [31:0] write_count;

    always_ff @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin
            read_count  <= '0;
            write_count <= '0;
        end
        else
        begin

            if(cs && re && !addr_error)
                read_count <= read_count + 1'b1;

            if(cs && we && !addr_error && !READ_ONLY)
                write_count <= write_count + 1'b1;

        end

    end

`ifndef SYNTHESIS

    //------------------------------------------------------------
    // Assertions
    //------------------------------------------------------------

    property p_no_read_write_same_cycle;

        @(posedge clk)
        disable iff(!rst_n)

        !(re && we);

    endproperty

    assert property(p_no_read_write_same_cycle)
        else
            $error("GENERIC_RAM : Read and Write asserted together.");

    //------------------------------------------------------------

    property p_address_valid;

        @(posedge clk)
        disable iff(!rst_n)

        cs |-> !addr_error;

    endproperty

    assert property(p_address_valid)
        else
            $error("GENERIC_RAM : Address out of range.");

    //------------------------------------------------------------

    property p_read_only_write;

        @(posedge clk)
        disable iff(!rst_n)

        READ_ONLY |-> !we;

    endproperty

    assert property(p_read_only_write)
        else
            $error("GENERIC_RAM : Write attempted to read-only memory.");

`endif

endmodule
