
module sysctrl_regs
(
    //------------------------------------------------------------
    // Global Signals
    //------------------------------------------------------------

    input  logic         clk,
    input  logic         rst_n,

    //------------------------------------------------------------
    // APB Register Interface
    //------------------------------------------------------------

    input  logic         wr_en,
    input  logic         rd_en,

    input  logic [31:0]  addr,
    input  logic [31:0]  wr_data,

    output logic [31:0]  rd_data,

    //------------------------------------------------------------
    // System Status Inputs
    //------------------------------------------------------------

    input  logic         cpu_running,
    input  logic         irq_pending,
    input  logic         sleep_mode,
    input  logic         debug_mode,

    //------------------------------------------------------------
    // Register Outputs
    //------------------------------------------------------------

    output logic         sw_reset,

    output logic [31:0]  clock_enable,

    output logic [31:0]  reset_control,

    output logic [31:0]  boot_config
);

    import sysctrl_pkg::*;

    //------------------------------------------------------------
    // Internal Registers
    //------------------------------------------------------------

    logic [31:0] sys_control_reg;

    logic [31:0] clock_enable_reg;

    logic [31:0] reset_control_reg;

    logic [31:0] boot_config_reg;

    logic [31:0] scratch0_reg;
    logic [31:0] scratch1_reg;
    logic [31:0] scratch2_reg;
    logic [31:0] scratch3_reg;

    //------------------------------------------------------------
    // System Status Register
    //------------------------------------------------------------

    sys_status_t status_reg;

    always_comb
    begin

        status_reg.cpu_running = cpu_running;

        status_reg.irq_pending = irq_pending;

        status_reg.sleep_mode  = sleep_mode;

        status_reg.debug_mode  = debug_mode;

        status_reg.reserved    = '0;

    end

    //------------------------------------------------------------
    // Register Write Logic
    //------------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin

            sys_control_reg   <= RESET_SYS_CONTROL;

            clock_enable_reg  <= RESET_CLOCK_ENABLE;

            reset_control_reg <= RESET_RESET_CONTROL;

            boot_config_reg   <= RESET_BOOT_CONFIG;

            scratch0_reg      <= RESET_SCRATCH;
            scratch1_reg      <= RESET_SCRATCH;
            scratch2_reg      <= RESET_SCRATCH;
            scratch3_reg      <= RESET_SCRATCH;

        end
        else if(wr_en)
        begin

            unique case(addr)

                SYS_CONTROL_ADDR:
                    sys_control_reg <= wr_data;

                CLOCK_ENABLE_ADDR:
                    clock_enable_reg <= wr_data;

                RESET_CONTROL_ADDR:
                    reset_control_reg <= wr_data;

                BOOT_CONFIG_ADDR:
                    boot_config_reg <= wr_data;

                SCRATCH0_ADDR:
                    scratch0_reg <= wr_data;

                SCRATCH1_ADDR:
                    scratch1_reg <= wr_data;

                SCRATCH2_ADDR:
                    scratch2_reg <= wr_data;

                SCRATCH3_ADDR:
                    scratch3_reg <= wr_data;

                default: ;

            endcase

        end

    end
	
	    //------------------------------------------------------------
    // Register Read Logic
    //------------------------------------------------------------

    always_comb
    begin

        rd_data = 32'd0;

        if(rd_en)
        begin

            unique case(addr)

                //------------------------------------------------
                // Read-Only Registers
                //------------------------------------------------

                SYS_ID_ADDR:
                    rd_data = SYS_ID;

                SYS_VERSION_ADDR:
                    rd_data = SYS_VERSION;

                SYS_STATUS_ADDR:
                    rd_data = status_reg;

                //------------------------------------------------
                // Read/Write Registers
                //------------------------------------------------

                SYS_CONTROL_ADDR:
                    rd_data = sys_control_reg;

                RESET_CONTROL_ADDR:
                    rd_data = reset_control_reg;

                CLOCK_ENABLE_ADDR:
                    rd_data = clock_enable_reg;

                BOOT_CONFIG_ADDR:
                    rd_data = boot_config_reg;

                SCRATCH0_ADDR:
                    rd_data = scratch0_reg;

                SCRATCH1_ADDR:
                    rd_data = scratch1_reg;

                SCRATCH2_ADDR:
                    rd_data = scratch2_reg;

                SCRATCH3_ADDR:
                    rd_data = scratch3_reg;

                default:
                    rd_data = 32'hDEAD_BEEF;

            endcase

        end

    end

    //------------------------------------------------------------
    // Register Outputs
    //------------------------------------------------------------

    assign sw_reset       =
           sys_control_reg[SYSCTRL_SW_RESET_BIT];

    assign clock_enable   =
           clock_enable_reg;

    assign reset_control  =
           reset_control_reg;

    assign boot_config    =
           boot_config_reg;

`ifndef SYNTHESIS

    //------------------------------------------------------------
    // Assertions
    //------------------------------------------------------------

    // Read-only registers shall never be written

    property p_ro_register_write;

        @(posedge clk)
        disable iff(!rst_n)

        wr_en |->
        !(addr == SYS_ID_ADDR ||
          addr == SYS_VERSION_ADDR ||
          addr == SYS_STATUS_ADDR);

    endproperty

    assert property(p_ro_register_write)
        else
            $error("SYSCTRL_REGS : Attempt to write read-only register.");

    //------------------------------------------------------------

    // Address must be word aligned

    property p_addr_alignment;

        @(posedge clk)
        disable iff(!rst_n)

        (wr_en || rd_en) |-> (addr[1:0] == 2'b00);

    endproperty

    assert property(p_addr_alignment)
        else
            $error("SYSCTRL_REGS : Unaligned register access.");

`endif

endmodule

`default_nettype wire