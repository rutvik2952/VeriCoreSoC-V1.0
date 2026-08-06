module data_ram
#(
    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 12,
    parameter int DEPTH      = (1<<ADDR_WIDTH)
)
(
    //------------------------------------------------------------
    // Global Signals
    //------------------------------------------------------------

    input  logic                     clk,
    input  logic                     rst_n,

    //------------------------------------------------------------
    // CPU Interface
    //------------------------------------------------------------

    input  logic                     cs,
    input  logic                     we,
    input  logic                     re,

    input  logic [ADDR_WIDTH-1:0]    addr,

    input  logic [DATA_WIDTH-1:0]    wdata,

    input  logic [(DATA_WIDTH/8)-1:0] be,

    output logic [DATA_WIDTH-1:0]    rdata,

    output logic                     ready,

    output logic                     error
);

    //------------------------------------------------------------
    // Internal Signals
    //------------------------------------------------------------

    logic [DATA_WIDTH-1:0] ram_rdata;

    //------------------------------------------------------------
    // Generic RAM Instance
    //------------------------------------------------------------

    generic_ram
    #(
        .DATA_WIDTH     (DATA_WIDTH),
        .ADDR_WIDTH     (ADDR_WIDTH),
        .DEPTH          (DEPTH),

        .READ_ONLY      (1'b0),

        .OUTPUT_REG     (1'b1),

        .MEM_INIT_FILE  (1'b0),

        .INIT_FILE      ("")
    )
    u_dmem
    (
        .clk        (clk),
        .rst_n      (rst_n),

        .cs         (cs),

        .we         (we),

        .re         (re),

        .addr       (addr),

        .wdata      (wdata),

        .be         (be),

        .rdata      (ram_rdata),

        .ready      (ready),

        .error      (error)
    );

    //------------------------------------------------------------
    // Read Data
    //------------------------------------------------------------

    assign rdata = ram_rdata;
	
	    //------------------------------------------------------------
    // Performance Counters
    //------------------------------------------------------------

    logic [31:0] read_count;
    logic [31:0] write_count;
    logic [31:0] byte_write_count;
    logic [31:0] illegal_access_count;

    //------------------------------------------------------------
    // Internal Signals
    //------------------------------------------------------------

    logic illegal_access;

    assign illegal_access =
            (cs && (addr >= DEPTH));

    //------------------------------------------------------------
    // Statistics
    //------------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin

            read_count           <= '0;
            write_count          <= '0;
            byte_write_count     <= '0;
            illegal_access_count <= '0;

        end
        else
        begin

            //------------------------------------
            // Read Counter
            //------------------------------------

            if(cs && re && !illegal_access)
                read_count <= read_count + 1'b1;

            //------------------------------------
            // Write Counter
            //------------------------------------

            if(cs && we && !illegal_access)
            begin

                write_count <= write_count + 1'b1;

                for(int i=0;i<DATA_WIDTH/8;i++)
                begin

                    if(be[i])
                        byte_write_count <= byte_write_count + 1'b1;

                end

            end

            //------------------------------------
            // Illegal Access Counter
            //------------------------------------

            if(illegal_access)
                illegal_access_count <= illegal_access_count + 1'b1;

        end

    end

`ifndef SYNTHESIS

    //------------------------------------------------------------
    // Assertions
    //------------------------------------------------------------

    //--------------------------------------------
    // Address Range
    //--------------------------------------------

    property p_addr_valid;

        @(posedge clk)
        disable iff(!rst_n)

        cs |-> (addr < DEPTH);

    endproperty

    assert property(p_addr_valid)
        else
            $error("DATA_RAM : Address out of range.");

    //--------------------------------------------
    // Read & Write Together
    //--------------------------------------------

    property p_rw_exclusive;

        @(posedge clk)
        disable iff(!rst_n)

        !(re && we);

    endproperty

    assert property(p_rw_exclusive)
        else
            $error("DATA_RAM : Read and Write asserted together.");

    //--------------------------------------------
    // Read Data Valid
    //--------------------------------------------

    property p_rdata_known;

        @(posedge clk)
        disable iff(!rst_n)

        ready && re |-> !$isunknown(rdata);

    endproperty

    assert property(p_rdata_known)
        else
            $error("DATA_RAM : Unknown data detected.");

    //--------------------------------------------
    // Byte Enable Valid
    //--------------------------------------------

    property p_be_valid;

        @(posedge clk)
        disable iff(!rst_n)

        we |-> (be != '0);

    endproperty

    assert property(p_be_valid)
        else
            $error("DATA_RAM : Write requested with no byte enable.");

`endif

endmodule
