`timescale 1ns/1ps

module cpu_decoder
(
    //------------------------------------------------------------
    // Instruction Input
    //------------------------------------------------------------

    input  cpu_pkg::fetch_packet_t     fetch_packet,

    //------------------------------------------------------------
    // Decoded Output
    //------------------------------------------------------------

    output cpu_pkg::decode_packet_t    decode_packet,

    //------------------------------------------------------------
    // Control Signals
    //------------------------------------------------------------

    output logic                       reg_write,

    output logic                       mem_read,
    output logic                       mem_write,

    output logic                       branch,
    output logic                       jump,

    output logic                       apb_access,

    output cpu_pkg::alu_opcode_e       alu_operation
);

    //------------------------------------------------------------
    // Internal Signals
    //------------------------------------------------------------

    logic [31:0] instruction;

    cpu_pkg::cpu_opcode_e opcode;

    //------------------------------------------------------------
    // Instruction Extraction
    //------------------------------------------------------------

    assign instruction = fetch_packet.instruction;

    assign opcode = cpu_pkg::cpu_opcode_e'(
                    instruction[31:24]);

    //------------------------------------------------------------
    // Decode Packet
    //------------------------------------------------------------

    always_comb
    begin

        //----------------------------------------
        // Default Values
        //----------------------------------------

        decode_packet.valid       = fetch_packet.valid;

        decode_packet.opcode      = opcode;

        decode_packet.rd          = instruction[23:20];

        decode_packet.rs1         = instruction[19:16];

        decode_packet.rs2         = instruction[15:12];

        decode_packet.immediate   = {{16{instruction[15]}},
                                      instruction[15:0]};

        //----------------------------------------
        // Default Control
        //----------------------------------------

        reg_write  = 1'b0;

        mem_read   = 1'b0;
        mem_write  = 1'b0;

        branch     = 1'b0;
        jump       = 1'b0;

        apb_access = 1'b0;

        alu_operation = cpu_pkg::ALU_NOP;

        //----------------------------------------
        // Opcode Decode
        //----------------------------------------

        unique case(opcode)

            //------------------------------------
            // Arithmetic
            //------------------------------------

            cpu_pkg::OP_ADD :
            begin
                reg_write    = 1'b1;
                alu_operation= cpu_pkg::ALU_ADD;
            end

            cpu_pkg::OP_SUB :
            begin
                reg_write    = 1'b1;
                alu_operation= cpu_pkg::ALU_SUB;
            end

            cpu_pkg::OP_AND :
            begin
                reg_write    = 1'b1;
                alu_operation= cpu_pkg::ALU_AND;
            end

            cpu_pkg::OP_OR :
            begin
                reg_write    = 1'b1;
                alu_operation= cpu_pkg::ALU_OR;
            end

            cpu_pkg::OP_XOR :
            begin
                reg_write    = 1'b1;
                alu_operation= cpu_pkg::ALU_XOR;
            end

            cpu_pkg::OP_MOV :
            begin
                reg_write    = 1'b1;
                alu_operation= cpu_pkg::ALU_PASS_B;
            end
			
			            //------------------------------------
            // Memory Instructions
            //------------------------------------

            cpu_pkg::OP_LOAD :
            begin

                reg_write     = 1'b1;
                mem_read      = 1'b1;
                alu_operation = cpu_pkg::ALU_ADD;

            end

            cpu_pkg::OP_STORE :
            begin

                mem_write     = 1'b1;
                alu_operation = cpu_pkg::ALU_ADD;

            end

            //------------------------------------
            // Branch Instructions
            //------------------------------------

            cpu_pkg::OP_JMP :
            begin

                jump          = 1'b1;
                alu_operation = cpu_pkg::ALU_PASS_A;

            end

            cpu_pkg::OP_BEQ :
            begin

                branch        = 1'b1;
                alu_operation = cpu_pkg::ALU_CMP;

            end

            cpu_pkg::OP_BNE :
            begin

                branch        = 1'b1;
                alu_operation = cpu_pkg::ALU_CMP;

            end

            cpu_pkg::OP_CALL :
            begin

                jump          = 1'b1;
                reg_write     = 1'b1;
                alu_operation = cpu_pkg::ALU_PASS_A;

            end

            cpu_pkg::OP_RET :
            begin

                jump          = 1'b1;
                alu_operation = cpu_pkg::ALU_PASS_A;

            end

            //------------------------------------
            // APB Instructions
            //------------------------------------

            cpu_pkg::OP_APB_RD :
            begin

                apb_access    = 1'b1;
                reg_write     = 1'b1;
                alu_operation = cpu_pkg::ALU_ADD;

            end

            cpu_pkg::OP_APB_WR :
            begin

                apb_access    = 1'b1;
                alu_operation = cpu_pkg::ALU_ADD;

            end

            //------------------------------------
            // Interrupt Instructions
            //------------------------------------

            cpu_pkg::OP_INT_EN,
            cpu_pkg::OP_INT_DIS,
            cpu_pkg::OP_RETI :
            begin

                alu_operation = cpu_pkg::ALU_NOP;

            end

            //------------------------------------
            // HALT
            //------------------------------------

            cpu_pkg::OP_HALT :
            begin

                alu_operation = cpu_pkg::ALU_NOP;

            end

            //------------------------------------
            // Illegal Instruction
            //------------------------------------

            default :
            begin

                decode_packet.valid = 1'b0;

            end

        endcase

    end
/*
`ifndef SYNTHESIS

    //------------------------------------------------------------
    // Assertions
    //------------------------------------------------------------

    // Valid instruction must not contain X

    property p_instruction_known;

        @(*)

        fetch_packet.valid |-> !$isunknown(fetch_packet.instruction);

    endproperty

    assert property(p_instruction_known)
        else
            $error("CPU_DECODER : Instruction contains unknown bits.");

`endif
*/
endmodule
