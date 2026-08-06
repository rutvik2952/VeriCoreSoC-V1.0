`ifndef CPU_PKG_SV
`define CPU_PKG_SV

package cpu_pkg;

    //------------------------------------------------------------
    // CPU Parameters
    //------------------------------------------------------------

    parameter int CPU_DATA_WIDTH = 32;
    parameter int CPU_ADDR_WIDTH = 32;

    parameter int REG_COUNT = 16;
    parameter int REG_WIDTH = 32;

    parameter int REG_ADDR_WIDTH = $clog2(REG_COUNT);
	
	parameter int OPCODE_MSB = 31;
    parameter int OPCODE_LSB = 24;

    parameter int RD_MSB = 23;
    parameter int RD_LSB = 20;

    parameter int RS1_MSB = 19;
    parameter int RS1_LSB = 16;

    parameter int RS2_MSB = 15;
    parameter int RS2_LSB = 12;

    parameter int IMM_MSB = 15;
    parameter int IMM_LSB = 0;
	
	parameter int JUMP_MSB = 23;
    parameter int JUMP_LSB = 0;

    //------------------------------------------------------------
    // Program Counter
    //------------------------------------------------------------

    parameter logic [31:0] RESET_VECTOR = 32'h0000_0000;

    //------------------------------------------------------------
    // Instruction Width
    //------------------------------------------------------------

    parameter int INSTR_WIDTH = 32;

    //------------------------------------------------------------
    // Opcode Width
    //------------------------------------------------------------

    parameter int OPCODE_WIDTH = 8;

    //------------------------------------------------------------
    // Register Index
    //------------------------------------------------------------

    typedef logic [REG_ADDR_WIDTH-1:0] reg_idx_t;

    //------------------------------------------------------------
    // ALU Data
    //------------------------------------------------------------

    typedef logic [REG_WIDTH-1:0] reg_data_t;

    //------------------------------------------------------------
    // Instruction
    //------------------------------------------------------------

    typedef logic [31:0] instruction_t;

    //------------------------------------------------------------
    // CPU State Machine
    //------------------------------------------------------------

    typedef enum logic[2:0]
    {
        CPU_RESET,

        CPU_FETCH,

        CPU_DECODE,

        CPU_EXECUTE,

        CPU_MEMORY,

        CPU_WRITEBACK,

        CPU_HALT

    } cpu_state_e;

    //------------------------------------------------------------
    // ALU Operations
    //------------------------------------------------------------

    typedef enum logic[4:0]
    {
        ALU_NOP,

        ALU_ADD,

        ALU_SUB,

        ALU_AND,

        ALU_OR,

        ALU_XOR,

        ALU_NOT,

        ALU_SLL,

        ALU_SRL,

        ALU_SRA,

        ALU_CMP,

        ALU_PASS_A,

        ALU_PASS_B

    } alu_opcode_e;
	
	    //------------------------------------------------------------
    // CPU Instruction Opcodes
    //------------------------------------------------------------

    typedef enum logic [7:0]
    {
        OP_NOP      = 8'h00,
        OP_ADD      = 8'h01,
        OP_SUB      = 8'h02,
        OP_AND      = 8'h03,
        OP_OR       = 8'h04,
        OP_XOR      = 8'h05,
        OP_MOV      = 8'h06,

        OP_LOAD     = 8'h10,
        OP_STORE    = 8'h11,

        OP_JMP      = 8'h20,
        OP_BEQ      = 8'h21,
        OP_BNE      = 8'h22,
        OP_CALL     = 8'h23,
        OP_RET      = 8'h24,

        OP_APB_RD   = 8'h30,
        OP_APB_WR   = 8'h31,

        OP_INT_EN   = 8'h40,
        OP_INT_DIS  = 8'h41,
        OP_RETI     = 8'h42,

        OP_HALT     = 8'hFF

    } cpu_opcode_e;

    //------------------------------------------------------------
    // Branch Types
    //------------------------------------------------------------

    typedef enum logic [2:0]
    {
        BR_NONE,
        BR_JUMP,
        BR_BEQ,
        BR_BNE,
        BR_CALL,
        BR_RETURN

    } branch_type_e;

    //------------------------------------------------------------
    // Memory Access Type
    //------------------------------------------------------------

    typedef enum logic [2:0]
    {
        MEM_NONE,
        MEM_BYTE,
        MEM_HALFWORD,
        MEM_WORD

    } mem_access_e;

    //------------------------------------------------------------
    // Interrupt Type
    //------------------------------------------------------------

    typedef enum logic [1:0]
    {
        INT_NONE,
        INT_EXTERNAL,
        INT_SOFTWARE,
        INT_TIMER

    } interrupt_type_e;

    //------------------------------------------------------------
    // Pipeline Information
    //------------------------------------------------------------

    typedef struct packed
    {
        logic           valid;

        instruction_t   instruction;

        logic [31:0]    pc;

    } fetch_packet_t;

    //------------------------------------------------------------

    typedef struct packed
    {
        logic           valid;

        cpu_opcode_e    opcode;

        reg_idx_t       rs1;
        reg_idx_t       rs2;
        reg_idx_t       rd;

        logic [31:0]    immediate;

    } decode_packet_t;

    //------------------------------------------------------------

    typedef struct packed
    {
        logic           valid;

        cpu_opcode_e    opcode;

        logic [31:0]    result;

        logic           zero;

        logic           carry;

        logic           overflow;

    } execute_packet_t;

    //------------------------------------------------------------
    // APB Request
    //------------------------------------------------------------

    typedef struct packed
    {
        logic           valid;
        logic           write;

        logic [31:0]    addr;
        logic [31:0]    data;

    } apb_request_t;

    //------------------------------------------------------------
    // APB Response
    //------------------------------------------------------------

    typedef struct packed
    {
        logic           ready;
        logic           error;

        logic [31:0]    data;

    } apb_response_t;

    //------------------------------------------------------------
    // Helper Functions
    //------------------------------------------------------------

    function automatic logic is_branch
    (
        input cpu_opcode_e opcode
    );

        case(opcode)

            OP_JMP,
            OP_BEQ,
            OP_BNE,
            OP_CALL,
            OP_RET :

                is_branch = 1'b1;

            default :

                is_branch = 1'b0;

        endcase

    endfunction

    //------------------------------------------------------------

    function automatic logic is_memory
    (
        input cpu_opcode_e opcode
    );

        case(opcode)

            OP_LOAD,
            OP_STORE :

                is_memory = 1'b1;

            default :

                is_memory = 1'b0;

        endcase

    endfunction

    //------------------------------------------------------------

    function automatic logic is_apb
    (
        input cpu_opcode_e opcode
    );

        case(opcode)

            OP_APB_RD,
            OP_APB_WR :

                is_apb = 1'b1;

            default :

                is_apb = 1'b0;

        endcase

    endfunction
	
	    //------------------------------------------------------------
    // Instruction Decode Helper Functions
    //------------------------------------------------------------

    function automatic cpu_opcode_e get_opcode
    (
        input instruction_t instruction
    );

        get_opcode = cpu_opcode_e'(
            instruction[OPCODE_MSB:OPCODE_LSB]
        );

    endfunction

    //------------------------------------------------------------

    function automatic reg_idx_t get_rd
    (
        input instruction_t instruction
    );

        get_rd = instruction[RD_MSB:RD_LSB];

    endfunction

    //------------------------------------------------------------

    function automatic reg_idx_t get_rs1
    (
        input instruction_t instruction
    );

        get_rs1 = instruction[RS1_MSB:RS1_LSB];

    endfunction

    //------------------------------------------------------------

    function automatic reg_idx_t get_rs2
    (
        input instruction_t instruction
    );

        get_rs2 = instruction[RS2_MSB:RS2_LSB];

    endfunction

    //------------------------------------------------------------

    function automatic logic [15:0] get_immediate
    (
        input instruction_t instruction
    );

        get_immediate = instruction[IMM_MSB:IMM_LSB];

    endfunction

    //------------------------------------------------------------

    function automatic logic [23:0] get_jump_address
    (
        input instruction_t instruction
    );

        get_jump_address = instruction[JUMP_MSB:JUMP_LSB];

    endfunction

endpackage

`endif