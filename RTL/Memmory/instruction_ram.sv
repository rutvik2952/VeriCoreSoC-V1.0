module instruction_ram
#(
    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 12,
    parameter int DEPTH      = (1<<ADDR_WIDTH),

    parameter string INIT_FILE = "firmware/boot.hex"
)
(
    //------------------------------------------------------------
    // Global Signals
    //------------------------------------------------------------

    input  logic                     clk,
    input  logic                     rst_n,

    //------------------------------------------------------------
    // CPU Instruction Interface
    //------------------------------------------------------------

    input  logic                     fetch,

    input  logic [ADDR_WIDTH-1:0]    addr,

    output logic [DATA_WIDTH-1:0]    instr,

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
        .DATA_WIDTH    (DATA_WIDTH),
        .ADDR_WIDTH    (ADDR_WIDTH),
        .DEPTH         (DEPTH),

        .READ_ONLY     (1'b1),

        .OUTPUT_REG    (1'b1),

        .MEM_INIT_FILE (1'b1),

        .INIT_FILE     (INIT_FILE)
    )
    u_imem
    (
        .clk        (clk),
        .rst_n      (rst_n),

        .cs         (fetch),

        .we         (1'b0),

        .re         (fetch),

        .addr       (addr),

        .wdata      ('0),

        .be         ('1),

        .rdata      (ram_rdata),

        .ready      (ready),

        .error      (error)
    );

    //------------------------------------------------------------
    // Instruction Output
    //------------------------------------------------------------

    assign instr = ram_rdata;
	
	    //------------------------------------------------------------
    // Performance Counters
    //------------------------------------------------------------

    logic [31:0] fetch_count;
    logic [31:0] illegal_fetch_count;

    //------------------------------------------------------------
    // Internal Signals
    //------------------------------------------------------------

    logic illegal_fetch;

    assign illegal_fetch =
            fetch &&
            (addr >= DEPTH);

    //------------------------------------------------------------
    // Fetch Statistics
    //------------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin

            fetch_count         <= '0;
            illegal_fetch_count <= '0;

        end
        else
        begin

            if(fetch && !illegal_fetch)
                fetch_count <= fetch_count + 1'b1;

            if(illegal_fetch)
                illegal_fetch_count <= illegal_fetch_count + 1'b1;

        end

    end

`ifndef SYNTHESIS

    //------------------------------------------------------------
    // Assertions
    //------------------------------------------------------------

    //------------------------------------------------------------
    // Fetch Address Range
    //------------------------------------------------------------

    property p_fetch_addr_valid;

        @(posedge clk)
        disable iff(!rst_n)

        fetch |-> (addr < DEPTH);

    endproperty

    assert property(p_fetch_addr_valid)
        else
            $error("INSTRUCTION_RAM : Fetch address out of range.");

    //------------------------------------------------------------
    // No Unknown Instruction
    //------------------------------------------------------------

    property p_instruction_valid;

        @(posedge clk)
        disable iff(!rst_n)

        ready |-> !$isunknown(instr);

    endproperty

    assert property(p_instruction_valid)
        else
            $error("INSTRUCTION_RAM : Instruction contains X.");

    //------------------------------------------------------------
    // Read Only Memory
    //------------------------------------------------------------

    property p_read_only;

        @(posedge clk)
        disable iff(!rst_n)

        fetch |-> !error;

    endproperty

    assert property(p_read_only)
        else
            $error("INSTRUCTION_RAM : Unexpected write/error detected.");

`endif

endmodule

