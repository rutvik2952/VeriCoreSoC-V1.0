module cpu_top
(
    //------------------------------------------------------------
    // Global Signals
    //------------------------------------------------------------

    input  logic         clk,
    input  logic         rst_n,

    //------------------------------------------------------------
    // Interrupt Interface
    //------------------------------------------------------------

    input  logic         irq,
    input  logic [7:0]   irq_id,

    //------------------------------------------------------------
    // Instruction Memory Interface
    //------------------------------------------------------------

    output logic         imem_fetch,
    output logic [31:0]  imem_addr,

    input  logic [31:0]  imem_instr,
    input  logic         imem_ready,
    input  logic         imem_error,

    //------------------------------------------------------------
    // Data Memory Interface
    //------------------------------------------------------------

    output logic         dmem_cs,
    output logic         dmem_we,
    output logic         dmem_re,

    output logic [31:0]  dmem_addr,
    output logic [31:0]  dmem_wdata,

    input  logic [31:0]  dmem_rdata,
    input  logic         dmem_ready,

    //------------------------------------------------------------
    // APB Master Interface
    //------------------------------------------------------------

    output logic         cpu_req,

    output logic         cpu_psel,
    output logic         cpu_penable,
    output logic         cpu_pwrite,

    output logic [31:0]  cpu_paddr,
    output logic [31:0]  cpu_pwdata,

    input  logic [31:0]  cpu_prdata,
    input  logic         cpu_pready,
    input  logic         cpu_pslverr
);

    //------------------------------------------------------------
    // Program Counter
    //------------------------------------------------------------

    logic [31:0] pc;
    logic [31:0] next_pc;

    logic        stall;
    logic        flush;

    //------------------------------------------------------------
    // Fetch Stage
    //------------------------------------------------------------

    cpu_pkg::fetch_packet_t fetch_packet;

    //------------------------------------------------------------
    // Decode Stage
    //------------------------------------------------------------

    cpu_pkg::decode_packet_t decode_packet;

    logic                    reg_write;
    logic                    mem_read;
    logic                    mem_write;

    logic                    branch;
    logic                    jump;

    logic                    apb_access;

    cpu_pkg::alu_opcode_e    alu_operation;

    //------------------------------------------------------------
    // Register File
    //------------------------------------------------------------

    logic [31:0] rs1_data;
    logic [31:0] rs2_data;

    logic        wb_valid;
    logic [3:0]  wb_rd;
    logic [31:0] wb_data;

    //------------------------------------------------------------
    // Branch / Jump
    //------------------------------------------------------------

    logic        branch_taken;
    logic [31:0] branch_target;

    logic        jump_taken;
    logic [31:0] jump_addr;

    //------------------------------------------------------------
    // Interrupt
    //------------------------------------------------------------

    logic        interrupt_enable;
    logic        reti;

    logic        interrupt_taken;
    logic [31:0] interrupt_vector;

    //------------------------------------------------------------
    // APB Request Channel
    //------------------------------------------------------------

    logic        req_valid;
    logic        req_write;

    logic [31:0] req_addr;
    logic [31:0] req_wdata;

    logic [31:0] rsp_rdata;
    logic        rsp_ready;
    logic        rsp_error;

        //------------------------------------------------------------
    // Program Counter
    //------------------------------------------------------------

    cpu_pc u_cpu_pc
    (
        .clk               (clk),
        .rst_n             (rst_n),

        .stall             (stall),
        .flush             (flush),

        .branch_taken      (branch_taken),
        .jump_taken        (jump_taken),
        .interrupt_taken   (interrupt_taken),

        .branch_addr       (branch_target),
        .jump_addr         (jump_addr),
        .interrupt_vector  (interrupt_vector),

        .pc                (pc),
        .next_pc           (next_pc)
    );

    //------------------------------------------------------------
    // Fetch Stage
    //------------------------------------------------------------

    cpu_fetch u_cpu_fetch
    (
        .clk               (clk),
        .rst_n             (rst_n),

        .stall             (stall),
        .flush             (flush),

        .pc                (pc),

        //--------------------------------------------------------
        // Instruction Memory Interface
        //--------------------------------------------------------

        .imem_fetch        (imem_fetch),
        .imem_addr         (imem_addr),
        .imem_instr        (imem_instr),
        .imem_ready        (imem_ready),
        .imem_error        (imem_error),

        //--------------------------------------------------------
        // Fetch Output
        //--------------------------------------------------------

        .fetch_packet      (fetch_packet)
    );

    //------------------------------------------------------------
    // Decode Stage
    //------------------------------------------------------------

    cpu_decoder u_cpu_decoder
    (
        //--------------------------------------------------------
        // Fetch Packet
        //--------------------------------------------------------

        .fetch_packet      (fetch_packet),

        //--------------------------------------------------------
        // Decode Output
        //--------------------------------------------------------

        .decode_packet     (decode_packet),

        //--------------------------------------------------------
        // Control Signals
        //--------------------------------------------------------

        .reg_write         (reg_write),

        .mem_read          (mem_read),
        .mem_write         (mem_write),

        .branch            (branch),
        .jump              (jump),

        .apb_access        (apb_access),

        .alu_operation     (alu_operation)
    );

    //------------------------------------------------------------
    // Basic Pipeline Control
    //------------------------------------------------------------

    assign stall = 1'b0;
    assign flush = branch_taken |
                   jump_taken   |
                   interrupt_taken;

    //------------------------------------------------------------
    // Jump Logic
    //------------------------------------------------------------

    assign jump_taken = jump;

    assign jump_addr  = decode_packet.immediate;
	
	    //------------------------------------------------------------
    // Register File
    //------------------------------------------------------------

    cpu_regfile u_cpu_regfile
    (
        //--------------------------------------------------------
        // Global
        //--------------------------------------------------------

        .clk            (clk),
        .rst_n          (rst_n),

        //--------------------------------------------------------
        // Read Port-1
        //--------------------------------------------------------

        .rd1_en         (1'b1),
        .rd1_addr       (decode_packet.rs1),
        .rd1_data       (rs1_data),

        //--------------------------------------------------------
        // Read Port-2
        //--------------------------------------------------------

        .rd2_en         (1'b1),
        .rd2_addr       (decode_packet.rs2),
        .rd2_data       (rs2_data),

        //--------------------------------------------------------
        // Write Back
        //--------------------------------------------------------

        .wr_en          (wb_valid),
        .wr_addr        (wb_rd),
        .wr_data        (wb_data),

        //--------------------------------------------------------
        // Debug Port
        //--------------------------------------------------------

        .dbg_rd_en      (1'b0),
        .dbg_rd_addr    ('0),
        .dbg_rd_data    ()
    );

    //------------------------------------------------------------
    // Execute Stage
    //------------------------------------------------------------

    cpu_execute u_cpu_execute
    (
        //--------------------------------------------------------
        // Global
        //--------------------------------------------------------

        .clk                (clk),
        .rst_n              (rst_n),

        //--------------------------------------------------------
        // Decode Control
        //--------------------------------------------------------

        .decode_packet      (decode_packet),

        .reg_write          (reg_write),
        .mem_read           (mem_read),
        .mem_write          (mem_write),

        .branch             (branch),
        .jump               (jump),

        .apb_access         (apb_access),

        .alu_operation      (alu_operation),

        //--------------------------------------------------------
        // Register File Inputs
        //--------------------------------------------------------

        .rs1_data           (rs1_data),
        .rs2_data           (rs2_data),

        //--------------------------------------------------------
        // Data Memory Interface
        //--------------------------------------------------------

        .dmem_cs            (dmem_cs),
        .dmem_we            (dmem_we),
        .dmem_re            (dmem_re),

        .dmem_addr          (dmem_addr),
        .dmem_wdata         (dmem_wdata),

        .dmem_rdata         (dmem_rdata),
        .dmem_ready         (dmem_ready),

        //--------------------------------------------------------
        // Write Back
        //--------------------------------------------------------

        .wb_valid           (wb_valid),
        .wb_rd              (wb_rd),
        .wb_data            (wb_data),

        //--------------------------------------------------------
        // Branch Outputs
        //--------------------------------------------------------

        .branch_taken       (branch_taken),
        .branch_target      (branch_target)
    );

    //------------------------------------------------------------
    // Jump Control
    //------------------------------------------------------------

    //assign jump_taken = jump;

   //assign jump_addr  = decode_packet.immediate;

    //------------------------------------------------------------
    // Interrupt Enable
    //------------------------------------------------------------

    assign interrupt_enable = 1'b1;

    //------------------------------------------------------------
    // Return From Interrupt
    //------------------------------------------------------------

    assign reti = 1'b0;
	
	    //------------------------------------------------------------
    // Interrupt Controller
    //------------------------------------------------------------

    cpu_interrupt u_cpu_interrupt
    (
        //--------------------------------------------------------
        // Global
        //--------------------------------------------------------

        .clk                (clk),
        .rst_n              (rst_n),

        //--------------------------------------------------------
        // IRQ Interface
        //--------------------------------------------------------

        .irq                (irq),
        .irq_id             (irq_id),

        //--------------------------------------------------------
        // CPU Status
        //--------------------------------------------------------

        .interrupt_enable   (interrupt_enable),
        .reti               (reti),

        //--------------------------------------------------------
        // Outputs
        //--------------------------------------------------------

        .interrupt_taken    (interrupt_taken),
        .interrupt_vector   (interrupt_vector)
    );

    //------------------------------------------------------------
    // CPU APB Master
    //------------------------------------------------------------

    cpu_apb_master u_cpu_apb_master
    (
        //--------------------------------------------------------
        // Global
        //--------------------------------------------------------

        .clk            (clk),
        .rst_n          (rst_n),

        //--------------------------------------------------------
        // CPU Request Interface
        //--------------------------------------------------------

        .req_valid      (req_valid),
        .req_write      (req_write),

        .req_addr       (req_addr),
        .req_wdata      (req_wdata),

        .rsp_rdata      (rsp_rdata),
        .rsp_ready      (rsp_ready),
        .rsp_error      (rsp_error),

        //--------------------------------------------------------
        // APB Master Interface
        //--------------------------------------------------------

        .cpu_req        (cpu_req),

        .cpu_psel       (cpu_psel),
        .cpu_penable    (cpu_penable),
        .cpu_pwrite     (cpu_pwrite),

        .cpu_paddr      (cpu_paddr),
        .cpu_pwdata     (cpu_pwdata),

        .cpu_prdata     (cpu_prdata),

        .cpu_pready     (cpu_pready),
        .cpu_pslverr    (cpu_pslverr)
    );

    //------------------------------------------------------------
    // APB Request Generation
    //------------------------------------------------------------

    assign req_valid =
            apb_access;

    assign req_write =
            mem_write;

    assign req_addr  =
            dmem_addr;

    assign req_wdata =
            dmem_wdata;

    //------------------------------------------------------------
    // Future APB Read Path
    //------------------------------------------------------------

    // rsp_rdata
    // rsp_ready
    // rsp_error
    //
    // These signals are reserved for future APB load/store
    // instructions and exception handling.

    //------------------------------------------------------------
    // End of CPU_TOP
    //------------------------------------------------------------

endmodule
/*
module cpu_top
(
    //------------------------------------------------------------
    // Global Signals
    //------------------------------------------------------------

    input  logic clk,
    input  logic rst_n,

    //------------------------------------------------------------
    // Interrupt Controller Interface
    //------------------------------------------------------------

    input  logic        irq,
    input  logic [7:0]  irq_id,

    //------------------------------------------------------------
    // APB Master Interface
    //------------------------------------------------------------

    output logic        cpu_req,

    output logic        cpu_psel,
    output logic        cpu_penable,
    output logic        cpu_pwrite,

    output logic [31:0] cpu_paddr,
    output logic [31:0] cpu_pwdata,

    input  logic [31:0] cpu_prdata,

    input  logic        cpu_pready,
    input  logic        cpu_pslverr
);

    //------------------------------------------------------------
    // Program Counter
    //------------------------------------------------------------

    logic [31:0] pc;
    logic [31:0] next_pc;

    //------------------------------------------------------------
    // Fetch Stage
    //------------------------------------------------------------

    cpu_pkg::fetch_packet_t fetch_packet;

    logic        imem_fetch;
    logic [31:0] imem_addr;
    logic [31:0] imem_instr;

    logic        imem_ready;
    logic        imem_error;

    //------------------------------------------------------------
    // Decode Stage
    //------------------------------------------------------------

    cpu_pkg::decode_packet_t decode_packet;

    logic reg_write;
    logic mem_read;
    logic mem_write;

    logic branch;
    logic jump;

    logic apb_access;

    cpu_pkg::alu_opcode_e alu_operation;

    //------------------------------------------------------------
    // Register File
    //------------------------------------------------------------

    logic [31:0] rs1_data;
    logic [31:0] rs2_data;

    logic        wb_valid;
    logic [3:0]  wb_rd;
    logic [31:0] wb_data;

    //------------------------------------------------------------
    // ALU
    //------------------------------------------------------------

    logic [31:0] alu_result;

    logic zero_flag;
    logic negative_flag;
    logic carry_flag;
    logic overflow_flag;

    //------------------------------------------------------------
    // Branch
    //------------------------------------------------------------

    logic        branch_taken;
    logic [31:0] branch_target;

    //------------------------------------------------------------
    // Interrupt
    //------------------------------------------------------------

    logic        interrupt_taken;
    logic [31:0] interrupt_vector;

    //------------------------------------------------------------
    // APB Master
    //------------------------------------------------------------

    logic        req_valid;
    logic        req_write;

    logic [31:0] req_addr;
    logic [31:0] req_wdata;

    logic [31:0] rsp_rdata;
    logic        rsp_ready;
    logic        rsp_error;
	
	 //------------------------------------------------------------
    // Program Counter
    //------------------------------------------------------------

    cpu_pc u_cpu_pc
    (
        .clk               (clk),
        .rst_n             (rst_n),

        .stall             (1'b0),
        .flush             (1'b0),

        .branch_taken      (branch_taken),
        .jump_taken        (jump),

        .interrupt_taken   (interrupt_taken),

        .branch_addr       (branch_target),

        .jump_addr         (32'h0000_0000),   // Future Jump Logic

        .interrupt_vector  (interrupt_vector),

        .pc                (pc),
        .next_pc           (next_pc)
    );

    //------------------------------------------------------------
    // Instruction Fetch
    //------------------------------------------------------------

    cpu_fetch u_cpu_fetch
    (
        .clk            (clk),
        .rst_n          (rst_n),

        .stall          (1'b0),
        .flush          (1'b0),

        .pc             (pc),

        .imem_fetch     (imem_fetch),
        .imem_addr      (imem_addr),

        .imem_instr     (imem_instr),

        .imem_ready     (imem_ready),
        .imem_error     (imem_error),

        .fetch_packet   (fetch_packet)
    );
	
	//------------------------------------------------------------
    // Instruction Decoder
    //------------------------------------------------------------

    cpu_decoder u_cpu_decoder
    (
        .fetch_packet    (fetch_packet),

        .decode_packet   (decode_packet),

        .reg_write       (reg_write),

        .mem_read        (mem_read),
        .mem_write       (mem_write),

        .branch          (branch),
        .jump            (jump),

        .apb_access      (apb_access),

        .alu_operation   (alu_operation)
    );
	
	    //------------------------------------------------------------
    // Register File
    //------------------------------------------------------------

    cpu_regfile
    #(
        .REG_WIDTH (32),
        .REG_COUNT (16)
    )
    u_cpu_regfile
    (
        .clk            (clk),
        .rst_n          (rst_n),

        //-------------------------
        // Read Port-1
        //-------------------------

        .rd1_en         (1'b1),
        .rd1_addr       (decode_packet.rs1),

        .rd1_data       (rs1_data),

        //-------------------------
        // Read Port-2
        //-------------------------

        .rd2_en         (1'b1),
        .rd2_addr       (decode_packet.rs2),

        .rd2_data       (rs2_data),

        //-------------------------
        // Write Back
        //-------------------------

        .wr_en          (wb_valid),
        .wr_addr        (wb_rd),
        .wr_data        (wb_data),

        //-------------------------
        // Debug Port
        //-------------------------

        .dbg_rd_en      (1'b0),
        .dbg_rd_addr    ('0),
        .dbg_rd_data    ()
    );
	
	//------------------------------------------------------------
    // Arithmetic Logic Unit
    //------------------------------------------------------------

    cpu_alu
    u_cpu_alu
    (
        .alu_op         (alu_operation),

        .operand_a      (rs1_data),
        .operand_b      (rs2_data),

        .result         (alu_result),

        .zero_flag      (zero_flag),
        .negative_flag  (negative_flag),
        .carry_flag     (carry_flag),
        .overflow_flag  (overflow_flag)
    );
	
	    //------------------------------------------------------------
    // Execute Stage
    //------------------------------------------------------------

    cpu_execute
    u_cpu_execute
    (
        .clk                (clk),
        .rst_n              (rst_n),

        .decode_packet      (decode_packet),

        .reg_write          (reg_write),
        .mem_read           (mem_read),
        .mem_write          (mem_write),

        .branch             (branch),
        .jump               (jump),

        .apb_access         (apb_access),

        .alu_operation      (alu_operation),

        //-----------------------------
        // Register File
        //-----------------------------

        .rs1_data           (rs1_data),
        .rs2_data           (rs2_data),

        //-----------------------------
        // Data Memory Interface
        //-----------------------------

        .dmem_cs            (),
        .dmem_we            (),
        .dmem_re            (),

        .dmem_addr          (),
        .dmem_wdata         (),

        .dmem_rdata         (rsp_rdata),
        .dmem_ready         (rsp_ready),

        //-----------------------------
        // Write Back
        //-----------------------------

        .wb_valid           (wb_valid),
        .wb_rd              (wb_rd),
        .wb_data            (wb_data),

        //-----------------------------
        // Branch
        //-----------------------------

        .branch_taken       (branch_taken),
        .branch_target      (branch_target)
    );
	//------------------------------------------------------------
    // Execute -> APB Adapter
    //------------------------------------------------------------

    logic        dmem_cs;
    logic        dmem_we;
    logic        dmem_re;

    logic [31:0] dmem_addr;
    logic [31:0] dmem_wdata;

    logic [31:0] dmem_rdata;
    logic        dmem_ready;
	
	//------------------------------------------------------------
    // Execute -> APB Adapter
    //------------------------------------------------------------

    assign req_valid = dmem_cs & (dmem_re | dmem_we);

    assign req_write = dmem_we;

    assign req_addr  = dmem_addr;
    assign req_wdata = dmem_wdata;

    assign dmem_rdata = rsp_rdata;
    assign dmem_ready = rsp_ready;
	
	//------------------------------------------------------------
    // Execute Stage
    //------------------------------------------------------------

    cpu_execute
    u_cpu_execute
    (
        .clk                (clk),
        .rst_n              (rst_n),

        //--------------------------------------------------------
        // Decode Stage
        //--------------------------------------------------------

        .decode_packet      (decode_packet),

        .reg_write          (reg_write),
        .mem_read           (mem_read),
        .mem_write          (mem_write),

        .branch             (branch),
        .jump               (jump),

        .apb_access         (apb_access),

        .alu_operation      (alu_operation),

        //--------------------------------------------------------
        // Register File Inputs
        //--------------------------------------------------------

        .rs1_data           (rs1_data),
        .rs2_data           (rs2_data),

        //--------------------------------------------------------
        // Data Memory Interface
        //--------------------------------------------------------

        .dmem_cs            (dmem_cs),
        .dmem_we            (dmem_we),
        .dmem_re            (dmem_re),

        .dmem_addr          (dmem_addr),
        .dmem_wdata         (dmem_wdata),

        .dmem_rdata         (dmem_rdata),
        .dmem_ready         (dmem_ready),

        //--------------------------------------------------------
        // Write Back
        //--------------------------------------------------------

        .wb_valid           (wb_valid),
        .wb_rd              (wb_rd),
        .wb_data            (wb_data),

        //--------------------------------------------------------
        // Branch Control
        //--------------------------------------------------------

        .branch_taken       (branch_taken),
        .branch_target      (branch_target)
    );
	
	//------------------------------------------------------------
    // CPU APB Master
    //------------------------------------------------------------

    cpu_apb_master
    u_cpu_apb_master
    (
        .clk            (clk),
        .rst_n          (rst_n),

        .req_valid      (req_valid),
        .req_write      (req_write),

        .req_addr       (req_addr),
        .req_wdata      (req_wdata),

        .rsp_rdata      (rsp_rdata),
        .rsp_ready      (rsp_ready),
        .rsp_error      (rsp_error),

        .cpu_req        (cpu_req),

        .cpu_psel       (cpu_psel),
        .cpu_penable    (cpu_penable),
        .cpu_pwrite     (cpu_pwrite),

        .cpu_paddr      (cpu_paddr),
        .cpu_pwdata     (cpu_pwdata),

        .cpu_prdata     (cpu_prdata),

        .cpu_pready     (cpu_pready),
        .cpu_pslverr    (cpu_pslverr)
    );
	
	//------------------------------------------------------------
    // Interrupt Controller
    //------------------------------------------------------------

    cpu_interrupt
    u_cpu_interrupt
    (
        .clk                (clk),
        .rst_n              (rst_n),

        .irq                (irq),
        .irq_id             (irq_id),

        .interrupt_enable   (1'b1),

        .reti               (1'b0),

        .interrupt_taken    (interrupt_taken),

        .interrupt_vector   (interrupt_vector)
    );
	
endmodule

/*module cpu_top
(
    //------------------------------------------------------------
    // Global Signals
    //------------------------------------------------------------

    input  logic         clk,
    input  logic         rst_n,

    //------------------------------------------------------------
    // Interrupt Interface
    //------------------------------------------------------------

    input  logic         irq,

    input  logic [7:0]   irq_id,

    //------------------------------------------------------------
    // Instruction Memory
    //------------------------------------------------------------

    output logic         imem_fetch,

    output logic [31:0]  imem_addr,

    input  logic [31:0]  imem_instr,

    input  logic         imem_ready,

    input  logic         imem_error,

    //------------------------------------------------------------
    // Data Memory
    //------------------------------------------------------------

    output logic         dmem_cs,

    output logic         dmem_we,

    output logic         dmem_re,

    output logic [31:0]  dmem_addr,

    output logic [31:0]  dmem_wdata,

    input  logic [31:0]  dmem_rdata,

    input  logic         dmem_ready,

    //------------------------------------------------------------
    // APB Master
    //------------------------------------------------------------

    output logic [31:0]  paddr,

    output logic [31:0]  pwdata,

    input  logic [31:0]  prdata,

    output logic         psel,

    output logic         penable,

    output logic         pwrite,

    input  logic         pready,

    input  logic         pslverr
);

    //------------------------------------------------------------
    // Internal Signals
    //------------------------------------------------------------

    logic [31:0] pc;
    logic [31:0] next_pc;

    cpu_pkg::fetch_packet_t  fetch_packet;
    cpu_pkg::decode_packet_t decode_packet;

    cpu_pkg::alu_opcode_e alu_operation;

    logic reg_write;
    logic mem_read;
    logic mem_write;
    logic branch;
    logic jump;
    logic apb_access;

    logic [31:0] rs1_data;
    logic [31:0] rs2_data;

    logic wb_valid;
    logic [3:0] wb_rd;
    logic [31:0] wb_data;

    logic branch_taken;
    logic [31:0] branch_target;

    logic interrupt_taken;
    logic [31:0] interrupt_vector;

    //------------------------------------------------------------
    // Program Counter
    //------------------------------------------------------------

    cpu_pc
    u_cpu_pc
    (
        .clk               (clk),
        .rst_n             (rst_n),

        .stall             (1'b0),
        .flush             (1'b0),

        .branch_taken      (branch_taken),
        .jump_taken        (jump),

        .interrupt_taken   (interrupt_taken),

        .branch_addr       (branch_target),

        .jump_addr         (branch_target),

        .interrupt_vector  (interrupt_vector),

        .pc                (pc),

        .next_pc           (next_pc)
    );

    //------------------------------------------------------------
    // Fetch Stage
    //------------------------------------------------------------

    cpu_fetch
    u_cpu_fetch
    (
        .clk            (clk),
        .rst_n          (rst_n),

        .stall          (1'b0),

        .flush          (1'b0),

        .pc             (pc),

        .imem_fetch     (imem_fetch),

        .imem_addr      (imem_addr),

        .imem_instr     (imem_instr),

        .imem_ready     (imem_ready),

        .imem_error     (imem_error),

        .fetch_packet   (fetch_packet)
    );

    //------------------------------------------------------------
    // Decoder
    //------------------------------------------------------------

    cpu_decoder
    u_cpu_decoder
    (
        .fetch_packet   (fetch_packet),

        .decode_packet  (decode_packet),

        .reg_write      (reg_write),

        .mem_read       (mem_read),

        .mem_write      (mem_write),

        .branch         (branch),

        .jump           (jump),

        .apb_access     (apb_access),

        .alu_operation  (alu_operation)
    );
	
	    //------------------------------------------------------------
    // Register File
    //------------------------------------------------------------

    cpu_regfile
    u_cpu_regfile
    (
        .clk            (clk),
        .rst_n          (rst_n),

        .rd1_en         (1'b1),
        .rd1_addr       (decode_packet.rs1),
        .rd1_data       (rs1_data),

        .rd2_en         (1'b1),
        .rd2_addr       (decode_packet.rs2),
        .rd2_data       (rs2_data),

        .wr_en          (wb_valid),
        .wr_addr        (wb_rd),
        .wr_data        (wb_data),

        .dbg_rd_en      (1'b0),
        .dbg_rd_addr    ('0),
        .dbg_rd_data    ()
    );

    //------------------------------------------------------------
    // Execute Stage
    //------------------------------------------------------------

    cpu_execute
    u_cpu_execute
    (
        .clk            (clk),
        .rst_n          (rst_n),

        .decode_packet  (decode_packet),

        .reg_write      (reg_write),
        .mem_read       (mem_read),
        .mem_write      (mem_write),

        .branch         (branch),
        .jump           (jump),

        .apb_access     (apb_access),

        .alu_operation  (alu_operation),

        .rs1_data       (rs1_data),
        .rs2_data       (rs2_data),

        .dmem_cs        (dmem_cs),
        .dmem_we        (dmem_we),
        .dmem_re        (dmem_re),

        .dmem_addr      (dmem_addr),
        .dmem_wdata     (dmem_wdata),

        .dmem_rdata     (dmem_rdata),
        .dmem_ready     (dmem_ready),

        .wb_valid       (wb_valid),
        .wb_rd          (wb_rd),
        .wb_data        (wb_data),

        .branch_taken   (branch_taken),
        .branch_target  (branch_target)
    );

    //------------------------------------------------------------
    // Interrupt Controller
    //------------------------------------------------------------

    cpu_interrupt
    u_cpu_interrupt
    (
        .clk                (clk),
        .rst_n              (rst_n),

        .irq                (irq),
        .irq_id             (irq_id),

        .interrupt_enable   (1'b1),

        .reti               (1'b0),

        .interrupt_taken    (interrupt_taken),

        .interrupt_vector   (interrupt_vector)
    );

    //------------------------------------------------------------
    // APB Master
    //------------------------------------------------------------

    cpu_apb_master
    u_cpu_apb_master
    (
        .clk            (clk),
        .rst_n          (rst_n),

        .req_valid      (apb_access),
        .req_write      (mem_write),

        .req_addr       (dmem_addr),
        .req_wdata      (dmem_wdata),

        .req_rdata      (),
        .req_ready      (),
        .req_error      (),

        .paddr          (paddr),
        .pwdata         (pwdata),

        .prdata         (prdata),

        .psel           (psel),
        .penable        (penable),
        .pwrite         (pwrite),

        .pready         (pready),
        .pslverr        (pslverr)
    );

`ifndef SYNTHESIS

    //------------------------------------------------------------
    // Top-Level Assertions
    //------------------------------------------------------------

    property p_pc_alignment;

        @(posedge clk)
        disable iff(!rst_n)

        pc[1:0] == 2'b00;

    endproperty

    assert property(p_pc_alignment)
        else
            $error("CPU_TOP : PC alignment error.");

    //------------------------------------------------------------

    property p_writeback_valid;

        @(posedge clk)
        disable iff(!rst_n)

        wb_valid |-> !$isunknown(wb_data);

    endproperty

    assert property(p_writeback_valid)
        else
            $error("CPU_TOP : Writeback data unknown.");

`endif

endmodule
*/
