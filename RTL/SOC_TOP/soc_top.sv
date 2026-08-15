module soc_top
(
    //------------------------------------------------------------
    // Global Signals
    //------------------------------------------------------------

    input  logic         clk,
    input  logic         rst_n,

    //------------------------------------------------------------
    // Verification / External APB Master
    //------------------------------------------------------------

    input  logic         cpu_master_enable,
    input  logic         apb_master_enable,

    //input  logic         apb_req,
    input  logic         apb_psel,
    input  logic         apb_penable,
    input  logic         apb_pwrite,

    input  logic [31:0]  apb_paddr,
    input  logic [31:0]  apb_pwdata,

    output logic [31:0]  apb_prdata,
    output logic         apb_pready,
    output logic         apb_pslverr,

    //------------------------------------------------------------
    // UART
    //------------------------------------------------------------

    input  logic         uart_rx,
    output logic         uart_tx,

    //------------------------------------------------------------
    // SPI
    //------------------------------------------------------------

    input  logic         spi_miso,
    output logic         spi_mosi,
    output logic         spi_sclk,
    output logic         spi_cs_n,

    //------------------------------------------------------------
    // I2C
    //------------------------------------------------------------

    inout  wire          i2c_scl,
    inout  wire          i2c_sda,

    //------------------------------------------------------------
    // GPIO
    //------------------------------------------------------------

    input  logic [31:0]  gpio_in,
    output logic [31:0]  gpio_out,
    output logic [31:0]  gpio_oe,

    //------------------------------------------------------------
    // Boot Configuration
    //------------------------------------------------------------
    input sysctrl_pkg::boot_mode_e boot_mode_sel,

    //------------------------------------------------------------
    // External Interrupts
    //------------------------------------------------------------

    input  logic [7:0]   ext_irq
);
 
//------------------------------------------------------------
// CPU Interrupt Interface
//------------------------------------------------------------

logic        irq;
logic [7:0]  irq_id;
logic        cpu_irq;


//------------------------------------------------------------
// CPU Instruction Memory Interface
//------------------------------------------------------------

logic        imem_fetch;
logic [31:0] imem_addr;

logic [31:0] imem_instr;
logic        imem_ready;
logic        imem_error;


//------------------------------------------------------------
// CPU Data Memory Interface
//------------------------------------------------------------

logic        dmem_cs;
logic        dmem_we;
logic        dmem_re;

logic [31:0] dmem_addr;
logic [31:0] dmem_wdata;

logic [31:0] dmem_rdata;
logic        dmem_ready;


//------------------------------------------------------------
// CPU APB Master Interface
//------------------------------------------------------------

logic        cpu_req;

logic        cpu_psel;
logic        cpu_penable;
logic        cpu_pwrite;

logic [31:0] cpu_paddr;
logic [31:0] cpu_pwdata;

logic [31:0] cpu_prdata;
logic        cpu_pready;
logic        cpu_pslverr;

logic [31:0] sysctrl_prdata;
logic        sysctrl_pready;
logic        sysctrl_pslverr;

//------------------------------------------------------------------------------
// CPU Status Signals
//------------------------------------------------------------------------------
logic cpu_running;
logic irq_pending;
logic sleep_mode;
logic debug_mode;

//------------------------------------------------------------------------------
// Peripheral Reset Signals
// Active Low Reset for Individual IP Blocks
//------------------------------------------------------------------------------
logic cpu_reset;
logic gpio_reset;
logic timer_reset;
logic uart_reset;
logic spi_reset;
logic i2c_reset;
logic dma_reset;

//------------------------------------------------------------------------------
// Peripheral Clock Enable Signals
// Used for Clock Gating / Power Management
//------------------------------------------------------------------------------
logic cpu_clk_en;
logic gpio_clk_en;
logic timer_clk_en;
logic uart_clk_en;
logic spi_clk_en;
logic i2c_clk_en;
logic dma_clk_en;
logic cpu_clk;
logic gpio_clk;
logic timer_clk;
logic uart_clk;
logic spi_clk;
logic i2c_clk;
logic dma_clk;


//------------------------------------------------------------------------------
// GPIO APB Slave Response Signals
//------------------------------------------------------------------------------
logic [31:0] gpio_prdata;
logic        gpio_pready;
logic        gpio_pslverr;

//------------------------------------------------------------------------------
// UART APB Slave Response Signals
//------------------------------------------------------------------------------
logic [31:0] timer_prdata;
logic        timer_pready;
logic        timer_pslverr;

//------------------------------------------------------------------------------
// UART APB Slave Response Signals
//------------------------------------------------------------------------------
logic [31:0] uart_prdata;
logic        uart_pready;
logic        uart_pslverr;

//------------------------------------------------------------------------------
// SPI APB Slave Response Signals
//------------------------------------------------------------------------------
logic [31:0] spi_prdata;
logic        spi_pready;
logic        spi_pslverr;

//------------------------------------------------------------------------------
// I2C APB Slave Response Signals
//------------------------------------------------------------------------------
logic [31:0] i2c_prdata;
logic        i2c_pready;
logic        i2c_pslverr;

//------------------------------------------------------------------------------
// DMA APB Slave Response Signals
//------------------------------------------------------------------------------
logic [31:0] dma_prdata;
logic        dma_pready;
logic        dma_pslverr;

//------------------------------------------------------------------------------
// Interrupt Controller (INTC) APB Slave Response Signals
//-----------------------------------------------------------------------------
logic [31:0] intc_prdata;
logic        intc_pready;
logic        intc_pslverr;

//------------------------------------------------------------------------------
// Peripheral Interrupt Request Signals
// Generated by Peripheral IPs and Routed to Interrupt Controller
//------------------------------------------------------------------------------
logic timer_irq;
logic uart_irq;
logic spi_irq;
logic i2c_irq;
logic dma_irq;
logic intc_irq;

//------------------------------------------------------------------------------
// DMA Internal Signals
//------------------------------------------------------------------------------
logic [31:0] dma_addr;

//------------------------------------------------------------------------------
// RAM Interface Signals
// Interface Between CPU/DMA and Internal Data Memory
//------------------------------------------------------------------------------
logic        ram_cs;
logic        ram_we;
logic        ram_re;
logic [31:0] ram_addr;
logic [31:0] ram_wdata;
logic [31:0] ram_rdata;

//------------------------------------------------------------
// Shared System Bus
//------------------------------------------------------------

logic        sys_psel;
logic        sys_penable;
logic        sys_pwrite;

logic [31:0] sys_paddr;
logic [31:0] sys_pwdata;

logic [31:0] sys_prdata;
logic        sys_pready;
logic        sys_pslverr;

//------------------------------------------------------------
// APB Peripheral Selects
//------------------------------------------------------------

logic sysctrl_sel;
logic gpio_sel;
logic timer_sel;
logic uart_sel;
logic spi_sel;
logic i2c_sel;
logic dma_sel;
logic intc_sel;

logic apb_decode_error;


//------------------------------------------------------------
// SYSCTRL
//------------------------------------------------------------

sysctrl_top
u_sysctrl
(
    //--------------------------------------------------------
    // Global Signals
    //--------------------------------------------------------

    .pclk           (clk),

    .presetn        (rst_n),


    //--------------------------------------------------------
    // APB Slave Interface
    //--------------------------------------------------------

    .psel           (sysctrl_sel),

    .penable        (sys_penable),

    .pwrite         (sys_pwrite),

    .paddr          (sys_paddr),

    .pwdata         (sys_pwdata),

    .prdata         (sysctrl_prdata),

    .pready         (sysctrl_pready),

    .pslverr        (sysctrl_pslverr),


    //--------------------------------------------------------
    // System Status Inputs
    //--------------------------------------------------------

    .cpu_running    (cpu_running),

    .irq_pending    (irq_pending),

    .sleep_mode     (sleep_mode),

    .debug_mode     (debug_mode),


    //--------------------------------------------------------
    // System Outputs
    //--------------------------------------------------------

    .cpu_reset      (cpu_reset),

    .gpio_reset     (gpio_reset),

    .timer_reset    (timer_reset),

    .uart_reset     (uart_reset),

    .spi_reset      (spi_reset),

    .i2c_reset      (i2c_reset),

    .dma_reset      (dma_reset),


    //--------------------------------------------------------
    // Clock Enables
    //--------------------------------------------------------

    .cpu_clk_en     (cpu_clk_en),

    .gpio_clk_en    (gpio_clk_en),

    .timer_clk_en   (timer_clk_en),

    .uart_clk_en    (uart_clk_en),

    .spi_clk_en     (spi_clk_en),

    .i2c_clk_en     (i2c_clk_en),

    .dma_clk_en     (dma_clk_en),


    //--------------------------------------------------------
    // Boot Mode
    //--------------------------------------------------------

    .boot_mode      (boot_mode_sel)

);
//------------------------------------------------------------
// This cpu_clk, gpio_clk , timer_clk , uart_clk , spi_clk , i2c_clk
// and dma_clk connect with each peripheral
//------------------------------------------------------------
assign cpu_clk     = clk & cpu_clk_en;
assign gpio_clk    = clk & gpio_clk_en;
assign timer_clk   = clk & timer_clk_en;
assign uart_clk    = clk & uart_clk_en;
assign spi_clk     = clk & spi_clk_en;
assign i2c_clk     = clk & i2c_clk_en;
assign dma_clk     = clk & dma_clk_en; 


cpu_top
u_cpu
(
    //--------------------------------------------------------
    // Global Signals
    //--------------------------------------------------------

    .clk            (clk),
    .rst_n          (~cpu_reset),

    //--------------------------------------------------------
    // Interrupt Interface
    //--------------------------------------------------------

    .irq            (cpu_irq),
    .irq_id         (irq_id),

    //--------------------------------------------------------
    // Instruction Memory Interface
    //--------------------------------------------------------

    .imem_fetch     (imem_fetch),
    .imem_addr      (imem_addr),

    .imem_instr     (imem_instr),
    .imem_ready     (imem_ready),
    .imem_error     (imem_error),

    //--------------------------------------------------------
    // Data Memory Interface
    //--------------------------------------------------------

    .dmem_cs        (dmem_cs),
    .dmem_we        (dmem_we),
    .dmem_re        (dmem_re),

    .dmem_addr      (dmem_addr),
    .dmem_wdata     (dmem_wdata),

    .dmem_rdata     (dmem_rdata),
    .dmem_ready     (dmem_ready),

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
// Instruction RAM
//------------------------------------------------------------
logic [31:0] instr_ram_data;
logic        instr_ram_ready;
logic        instr_ram_error;

instruction_ram
u_instruction_ram
(
    //--------------------------------------------------------
    // Global Signals
    //--------------------------------------------------------

    .clk        (clk),
    .rst_n      (rst_n),

    //--------------------------------------------------------
    // CPU Instruction Interface
    //--------------------------------------------------------

    .fetch      (imem_fetch),

    .addr       (imem_addr[11:0]),

    .instr      (instr_ram_data),

    .ready      (instr_ram_ready),

    .error      (instr_ram_error)
);

//------------------------------------------------------------
// Data RAM
//------------------------------------------------------------

logic [3:0] dmem_be;
logic       dmem_error;

assign dmem_be = 4'b1111;

data_ram
u_data_ram
(
    //--------------------------------------------------------
    // Global Signals
    //--------------------------------------------------------

    .clk        (clk),
    .rst_n      (rst_n),

    //--------------------------------------------------------
    // CPU Interface
    //--------------------------------------------------------

    .cs         (ram_cs),
    .we         (ram_we),
    .re         (ram_re),

    .addr       (ram_addr),

    .wdata      (ram_wdata),

    .be         (dmem_be),

    .rdata      (ram_rdata),

    .ready      (dmem_ready),

    .error      (dmem_error)
);

//------------------------------------------------------------
// BootROM
//------------------------------------------------------------

bootrom_top
u_bootrom
(
    //--------------------------------------------------------
    // Global Signals
    //--------------------------------------------------------

    .clk        (clk),
    .rst_n      (rst_n),

    //--------------------------------------------------------
    // Read Interface
    //--------------------------------------------------------

    .rd_en      (bootrom_rd_en),

    .addr       (imem_addr),

    .rd_data    (bootrom_rdata)
);

//------------------------------------------------------------
// Memory Decoder
//------------------------------------------------------------

logic bootrom_sel;
logic imem_sel;
logic dmem_sel;
logic dma_ram_sel;

logic mem_decode_error;

memory_decoder
u_memory_decoder
(
    .psel           (imem_fetch),

    .paddr          (imem_addr),

    .bootrom_sel    (bootrom_sel),

    .imem_sel       (imem_sel),

    .dmem_sel       (dmem_sel),

    .dma_ram_sel    (dma_ram_sel),

    .decode_error   (mem_decode_error)
);

//------------------------------------------------------------
// Instruction Read MUX
//------------------------------------------------------------
always_comb begin
    imem_instr = '0;
    imem_ready = 1'b0;
    imem_error = 1'b0;

    if (bootrom_sel) begin
        imem_instr = bootrom_rdata;
        // bootrom has no ready/error outputs in the frozen RTL
        imem_ready = 1'b1;
    end
    else if (imem_sel) begin
        imem_instr = instr_ram_data;
        imem_ready = instr_ram_ready;
        imem_error = instr_ram_error;
    end
end


//------------------------------------------------------------
// Arbitration Status
//------------------------------------------------------------

logic cpu_grant;
logic apb_grant;
logic arb_error;
logic cpu_req_arb;
logic apb_req_arb;

//assign cpu_req_arb = cpu_master_enable & cpu_req;
assign cpu_req_arb = cpu_master_enable;
assign apb_req_arb = apb_master_enable;
//assign apb_req_arb = apb_master_enable & apb_req;

//------------------------------------------------------------
// Bus Arbiter
//------------------------------------------------------------

bus_arbiter
u_bus_arbiter
(
    //--------------------------------------------------------
    // CPU APB Master
    //--------------------------------------------------------

    .cpu_req       (cpu_req_arb),

    .cpu_psel      (cpu_psel),
    .cpu_penable   (cpu_penable),
    .cpu_pwrite    (cpu_pwrite),

    .cpu_paddr     (cpu_paddr),
    .cpu_pwdata    (cpu_pwdata),

    .cpu_prdata    (cpu_prdata),
    .cpu_pready    (cpu_pready),
    .cpu_pslverr   (cpu_pslverr),

    //--------------------------------------------------------
    // External APB Master
    //--------------------------------------------------------

    .apb_req       (apb_req_arb),

    .apb_psel      (apb_psel),
    .apb_penable   (apb_penable),
    .apb_pwrite    (apb_pwrite),

    .apb_paddr     (apb_paddr),
    .apb_pwdata    (apb_pwdata),

    .apb_prdata    (apb_prdata),
    .apb_pready    (apb_pready),
    .apb_pslverr   (apb_pslverr),

    //--------------------------------------------------------
    // Shared System Bus
    //--------------------------------------------------------

    .sys_psel      (sys_psel),
    .sys_penable   (sys_penable),
    .sys_pwrite    (sys_pwrite),

    .sys_paddr     (sys_paddr),
    .sys_pwdata    (sys_pwdata),

    .sys_prdata    (sys_prdata),
    .sys_pready    (sys_pready),
    .sys_pslverr   (sys_pslverr),

    //--------------------------------------------------------
    // Arbitration Status
    //--------------------------------------------------------

    .cpu_grant     (cpu_grant),
    .apb_grant     (apb_grant),
    .arb_error     (arb_error)
);




//------------------------------------------------------------
// APB Address Decoder
//------------------------------------------------------------

apb_decoder_logic
u_apb_decoder
(
    .paddr          (sys_paddr),
    .psel           (sys_psel),

    .sysctrl_sel    (sysctrl_sel),
    .gpio_sel       (gpio_sel),
    .timer_sel      (timer_sel),
    .uart_sel       (uart_sel),
    .spi_sel        (spi_sel),
    .i2c_sel        (i2c_sel),
    .dma_sel        (dma_sel),
    .intc_sel       (intc_sel),

    .decode_error   (apb_decode_error)
);


//------------------------------------------------------------
// APB Slave Select Bus
//------------------------------------------------------------

logic [15:0] slave_sel;


always_comb
begin

    slave_sel = '0;

    slave_sel[0] = sysctrl_sel;
    slave_sel[1] = gpio_sel;
    slave_sel[2] = timer_sel;
    slave_sel[3] = uart_sel;
    slave_sel[4] = spi_sel;
    slave_sel[5] = i2c_sel;
    slave_sel[6] = dma_sel;
    slave_sel[7] = intc_sel;
    slave_sel[15:8] = 0;

end

//------------------------------------------------------------
// APB Slave Response Bus
//------------------------------------------------------------

logic [15:0][31:0] slave_prdata;

logic [15:0]       slave_pready;

logic [15:0]       slave_pslverr;


//------------------------------------------------------------
// APB Slave Response Mapping
//------------------------------------------------------------

always_comb
begin

    slave_prdata  = '0;

    slave_pready  = '0;

    slave_pslverr = '0;


    //--------------------------------------------------------
    // SYSCTRL
    //--------------------------------------------------------

    slave_prdata[0]  = sysctrl_prdata;
    slave_pready[0]  = sysctrl_pready;
    slave_pslverr[0] = sysctrl_pslverr;


    //--------------------------------------------------------
    // GPIO
    //--------------------------------------------------------

    slave_prdata[1]  = gpio_prdata;
    slave_pready[1]  = gpio_pready;
    slave_pslverr[1] = gpio_pslverr;


    //--------------------------------------------------------
    // TIMER
    //--------------------------------------------------------

    slave_prdata[2]  = timer_prdata;
    slave_pready[2]  = timer_pready;
    slave_pslverr[2] = timer_pslverr;


    //--------------------------------------------------------
    // UART
    //--------------------------------------------------------

    slave_prdata[3]  = uart_prdata;
    slave_pready[3]  = uart_pready;
    slave_pslverr[3] = uart_pslverr;


    //--------------------------------------------------------
    // SPI
    //--------------------------------------------------------

    slave_prdata[4]  = spi_prdata;
    slave_pready[4]  = spi_pready;
    slave_pslverr[4] = spi_pslverr;


    //--------------------------------------------------------
    // I2C
    //--------------------------------------------------------

    slave_prdata[5]  = i2c_prdata;
    slave_pready[5]  = i2c_pready;
    slave_pslverr[5] = i2c_pslverr;


    //--------------------------------------------------------
    // DMA
    //--------------------------------------------------------

    slave_prdata[6]  = dma_prdata;
    slave_pready[6]  = dma_pready;
    slave_pslverr[6] = dma_pslverr;


    //--------------------------------------------------------
    // INTC
    //--------------------------------------------------------

    slave_prdata[7]  = intc_prdata;
    slave_pready[7]  = intc_pready;
    slave_pslverr[7] = intc_pslverr;

end

//------------------------------------------------------------
// Default APB Slave
//------------------------------------------------------------

logic [31:0] default_prdata;
logic        default_pready;
logic        default_pslverr;


assign default_prdata  = 32'h0000_0000;

assign default_pready  = 1'b1;

assign default_pslverr = apb_decode_error;

//------------------------------------------------------------
// APB Response MUX
//------------------------------------------------------------

apb_mux
#(
    .DATA_WIDTH (32),
    .NUM_SLAVES (16)
)
u_apb_mux
(
    //--------------------------------------------------------
    // Slave Select
    //--------------------------------------------------------

    .slave_sel          (slave_sel),


    //--------------------------------------------------------
    // Slave Responses
    //--------------------------------------------------------

    .slave_prdata       (slave_prdata),

    .slave_pready       (slave_pready),

    .slave_pslverr      (slave_pslverr),


    //--------------------------------------------------------
    // Default Response
    //--------------------------------------------------------

    .default_prdata     (default_prdata),

    .default_pready     (default_pready),

    .default_pslverr    (default_pslverr),

    .decode_error       (apb_decode_error),


    //--------------------------------------------------------
    // Master Response
    //--------------------------------------------------------

    .prdata             (sys_prdata),

    .pready             (sys_pready),

    .pslverr            (sys_pslverr)

);



//------------------------------------------------------------
// INTC APB Interface
//------------------------------------------------------------

logic intc_wr_en;
logic intc_rd_en;

logic [31:0] intc_addr;
logic [31:0] intc_wr_data;



//------------------------------------------------------------
// External Interrupt Inputs
//------------------------------------------------------------

logic [7:0] irq_in;

//------------------------------------------------------------
// INTC APB Access Conversion
//------------------------------------------------------------

always_comb
begin

    //--------------------------------------------------------
    // Default Values
    //--------------------------------------------------------

    intc_wr_en   = 1'b0;

    intc_rd_en   = 1'b0;

    intc_addr    = 32'h0;

    intc_wr_data = 32'h0;


    //--------------------------------------------------------
    // INTC Write Access
    //--------------------------------------------------------

    if(intc_sel &&
       sys_psel &&
       sys_penable &&
       sys_pwrite)
    begin

        intc_wr_en = 1'b1;

        intc_addr  = sys_paddr;

        intc_wr_data = sys_pwdata;

    end


    //--------------------------------------------------------
    // INTC Read Access
    //--------------------------------------------------------

    else if(intc_sel &&
            sys_psel &&
            sys_penable &&
            !sys_pwrite)
    begin

        intc_rd_en = 1'b1;

        intc_addr  = sys_paddr;

    end

end

//------------------------------------------------------------
// CPU Interrupt ID
//------------------------------------------------------------

assign irq_id = 8'h00;


//------------------------------------------------------------
// Final Interrupt Mapping
//------------------------------------------------------------

always_comb
begin

    irq_in = '0;


    // Internal interrupts

    irq_in[0] = timer_irq;

    irq_in[1] = uart_irq;

    irq_in[2] = spi_irq;

    irq_in[3] = i2c_irq;

    irq_in[4] = dma_irq;


    // External interrupts

    irq_in[5] = ext_irq[0];

    irq_in[6] = ext_irq[1];

    irq_in[7] = ext_irq[2];

end


//------------------------------------------------------------
// Interrupt Controller
//------------------------------------------------------------

intc_top
u_intc
(
    //--------------------------------------------------------
    // Global Signals
    //--------------------------------------------------------

    .clk        (clk),

    .rst_n      (rst_n),


    //--------------------------------------------------------
    // APB Converted Interface
    //--------------------------------------------------------

    .wr_en      (intc_wr_en),

    .rd_en      (intc_rd_en),

    .addr       (intc_addr),

    .wr_data    (intc_wr_data),

    .rd_data    (intc_prdata),


    //--------------------------------------------------------
    // Interrupt Inputs
    //--------------------------------------------------------

    .irq_in     (irq_in),


    //--------------------------------------------------------
    // CPU Interrupt Output
    //--------------------------------------------------------

    .cpu_irq    (cpu_irq)

);


//------------------------------------------------------------
// GPIO Controller
//------------------------------------------------------------

gpio_top
u_gpio
(
    //--------------------------------------------------------
    // Global Signals
    //--------------------------------------------------------

    .pclk       (clk),

    .presetn    (~gpio_reset),


    //--------------------------------------------------------
    // APB Slave Interface
    //--------------------------------------------------------

    .psel       (gpio_sel),

    .penable    (sys_penable),

    .pwrite     (sys_pwrite),

    .paddr      (sys_paddr),

    .pwdata     (sys_pwdata),

    .prdata     (gpio_prdata),

    .pready     (gpio_pready),

    .pslverr    (gpio_pslverr),


    //--------------------------------------------------------
    // GPIO Physical Interface
    //--------------------------------------------------------

    .gpio_in    (gpio_in),

    .gpio_out   (gpio_out),

    .gpio_oe    (gpio_oe)

);


//------------------------------------------------------------
// TIMER Controller
//------------------------------------------------------------

timer_top
u_timer
(
    //--------------------------------------------------------
    // Global Signals
    //--------------------------------------------------------

    .pclk       (clk),

    .presetn    (~timer_reset),


    //--------------------------------------------------------
    // APB Slave Interface
    //--------------------------------------------------------

    .psel       (timer_sel),

    .penable    (sys_penable),

    .pwrite     (sys_pwrite),

    .paddr      (sys_paddr),

    .pwdata     (sys_pwdata),

    .prdata     (timer_prdata),

    .pready     (timer_pready),

    .pslverr    (timer_pslverr),


    //--------------------------------------------------------
    // Interrupt Output
    //--------------------------------------------------------

    .timer_irq  (timer_irq)

);

//------------------------------------------------------------
// UART Internal APB Interface
//------------------------------------------------------------

logic uart_wr_en;
logic uart_rd_en;

logic [31:0] uart_addr;
logic [31:0] uart_wr_data;

logic [31:0] uart_rd_data;



//------------------------------------------------------------
// UART APB Access Conversion
//------------------------------------------------------------

always_comb
begin

    //--------------------------------------------------------
    // Default
    //--------------------------------------------------------

    uart_wr_en   = 1'b0;

    uart_rd_en   = 1'b0;

    uart_addr    = 32'h0;

    uart_wr_data = 32'h0;


    //--------------------------------------------------------
    // UART Write
    //--------------------------------------------------------

    if(uart_sel &&
       sys_psel &&
       sys_penable &&
       sys_pwrite)
    begin

        uart_wr_en = 1'b1;

        uart_addr  = sys_paddr;

        uart_wr_data = sys_pwdata;

    end


    //--------------------------------------------------------
    // UART Read
    //--------------------------------------------------------

    else if(uart_sel &&
            sys_psel &&
            sys_penable &&
            !sys_pwrite)
    begin

        uart_rd_en = 1'b1;

        uart_addr  = sys_paddr;

    end

end

//------------------------------------------------------------
// UART Controller
//------------------------------------------------------------

uart_top
u_uart
(
    //--------------------------------------------------------
    // Global Signals
    //--------------------------------------------------------

    .clk        (clk),

    .rst_n      (~uart_reset),


    //--------------------------------------------------------
    // APB Converted Interface
    //--------------------------------------------------------

    .wr_en      (uart_wr_en),

    .rd_en      (uart_rd_en),

    .addr       (uart_addr),

    .wr_data    (uart_wr_data),

    .rd_data    (uart_rd_data),


    //--------------------------------------------------------
    // UART Pins
    //--------------------------------------------------------

    .uart_tx    (uart_tx),

    .uart_rx    (uart_rx),


    //--------------------------------------------------------
    // Interrupt
    //--------------------------------------------------------

    .uart_irq   (uart_irq)

);

//------------------------------------------------------------
// SPI Internal APB Interface
//------------------------------------------------------------

logic spi_wr_en;
logic spi_rd_en;

logic [31:0] spi_addr;
logic [31:0] spi_wr_data;

logic [31:0] spi_rd_data;



//------------------------------------------------------------
// SPI APB Access Conversion
//------------------------------------------------------------

always_comb
begin

    //--------------------------------------------------------
    // Default
    //--------------------------------------------------------

    spi_wr_en   = 1'b0;

    spi_rd_en   = 1'b0;

    spi_addr    = 32'h0;

    spi_wr_data = 32'h0;


    //--------------------------------------------------------
    // SPI Write Access
    //--------------------------------------------------------

    if(spi_sel &&
       sys_psel &&
       sys_penable &&
       sys_pwrite)
    begin

        spi_wr_en = 1'b1;

        spi_addr  = sys_paddr;

        spi_wr_data = sys_pwdata;

    end


    //--------------------------------------------------------
    // SPI Read Access
    //--------------------------------------------------------

    else if(spi_sel &&
            sys_psel &&
            sys_penable &&
            !sys_pwrite)
    begin

        spi_rd_en = 1'b1;

        spi_addr  = sys_paddr;

    end

end

//------------------------------------------------------------
// SPI Controller
//------------------------------------------------------------

spi_top
u_spi
(
    //--------------------------------------------------------
    // Global Signals
    //--------------------------------------------------------

    .clk        (clk),

    .rst_n      (~spi_reset),


    //--------------------------------------------------------
    // APB Converted Interface
    //--------------------------------------------------------

    .wr_en      (spi_wr_en),

    .rd_en      (spi_rd_en),

    .addr       (spi_addr),

    .wr_data    (spi_wr_data),

    .rd_data    (spi_rd_data),


    //--------------------------------------------------------
    // SPI Interface
    //--------------------------------------------------------

    .spi_sclk   (spi_sclk),

    .spi_mosi   (spi_mosi),

    .spi_miso   (spi_miso),

    .spi_cs_n   (spi_cs_n),


    //--------------------------------------------------------
    // Interrupt
    //--------------------------------------------------------

    .spi_irq    (spi_irq)

);

//------------------------------------------------------------
// I2C Internal APB Interface
//------------------------------------------------------------

logic i2c_wr_en;
logic i2c_rd_en;

logic [31:0] i2c_addr;
logic [31:0] i2c_wr_data;

logic [31:0] i2c_rd_data;


//------------------------------------------------------------
// I2C APB Access Conversion
//------------------------------------------------------------

always_comb
begin

    //--------------------------------------------------------
    // Default
    //--------------------------------------------------------

    i2c_wr_en   = 1'b0;

    i2c_rd_en   = 1'b0;

    i2c_addr    = 32'h0;

    i2c_wr_data = 32'h0;


    //--------------------------------------------------------
    // I2C Write Access
    //--------------------------------------------------------

    if(i2c_sel &&
       sys_psel &&
       sys_penable &&
       sys_pwrite)
    begin

        i2c_wr_en = 1'b1;

        i2c_addr  = sys_paddr;

        i2c_wr_data = sys_pwdata;

    end


    //--------------------------------------------------------
    // I2C Read Access
    //--------------------------------------------------------

    else if(i2c_sel &&
            sys_psel &&
            sys_penable &&
            !sys_pwrite)
    begin

        i2c_rd_en = 1'b1;

        i2c_addr  = sys_paddr;

    end

end

//------------------------------------------------------------
// I2C Controller
//------------------------------------------------------------

i2c_top
u_i2c
(
    //--------------------------------------------------------
    // Global Signals
    //--------------------------------------------------------

    .clk        (clk),

    .rst_n      (~i2c_reset),


    //--------------------------------------------------------
    // APB Converted Interface
    //--------------------------------------------------------

    .wr_en      (i2c_wr_en),

    .rd_en      (i2c_rd_en),

    .addr       (i2c_addr),

    .wr_data    (i2c_wr_data),

    .rd_data    (i2c_rd_data),


    //--------------------------------------------------------
    // I2C Pins
    //--------------------------------------------------------

    .scl        (i2c_scl),

    .sda        (i2c_sda),


    //--------------------------------------------------------
    // Interrupt
    //--------------------------------------------------------

    .i2c_irq    (i2c_irq)

);

//------------------------------------------------------------
// DMA APB Interface
//------------------------------------------------------------

logic dma_wr_en;
logic dma_rd_en;
logic [31:0] dma_wr_data;
logic [31:0] dma_rd_data;


//------------------------------------------------------------
// DMA Memory Interface
//------------------------------------------------------------

logic [31:0] dma_mem_rd_addr;
logic [31:0] dma_mem_rd_data;

logic [31:0] dma_mem_wr_addr;
logic [31:0] dma_mem_wr_data;
logic        dma_mem_wr_en;



//------------------------------------------------------------
// DMA APB Access Conversion
//------------------------------------------------------------

always_comb
begin

    //--------------------------------------------------------
    // Default
    //--------------------------------------------------------

    dma_wr_en   = 1'b0;

    dma_rd_en   = 1'b0;

    dma_addr    = 32'h0;

    dma_wr_data = 32'h0;


    //--------------------------------------------------------
    // DMA Write Access
    //--------------------------------------------------------

    if(dma_sel &&
       sys_psel &&
       sys_penable &&
       sys_pwrite)
    begin

        dma_wr_en = 1'b1;

        dma_addr  = sys_paddr;

        dma_wr_data = sys_pwdata;

    end


    //--------------------------------------------------------
    // DMA Read Access
    //--------------------------------------------------------

    else if(dma_sel &&
            sys_psel &&
            sys_penable &&
            !sys_pwrite)
    begin

        dma_rd_en = 1'b1;

        dma_addr  = sys_paddr;

    end

end

//------------------------------------------------------------
// DMA Memory Signals
//------------------------------------------------------------

logic [31:0] dma_wdata;
logic        dma_we;
logic [31:0] dma_rdata;

//------------------------------------------------------------
// DMA Controller
//------------------------------------------------------------

dma_top
u_dma
(
    //--------------------------------------------------------
    // Global Signals
    //--------------------------------------------------------

    .clk        (clk),

    .rst_n      (~dma_reset),


    //--------------------------------------------------------
    // APB Converted Interface
    //--------------------------------------------------------

    .wr_en      (dma_wr_en),

    .rd_en      (dma_rd_en),

    .addr       (dma_addr),

    .wr_data    (dma_wr_data),

    .rd_data    (dma_rd_data),


    //--------------------------------------------------------
    // Memory Interface
    //--------------------------------------------------------

    .mem_rd_addr (dma_mem_rd_addr),

    .mem_rd_data (dma_rdata),


    .mem_wr_addr (dma_mem_wr_addr),

    .mem_wr_data (dma_wdata),

    .mem_wr_en   (dma_we),


    //--------------------------------------------------------
    // Interrupt
    //--------------------------------------------------------

    .dma_irq    (dma_irq)

);


//------------------------------------------------------------
// DMA has priority over CPU
//------------------------------------------------------------

always_comb
begin

    // Default CPU access

    ram_cs    = dmem_cs;

    ram_we    = dmem_we;

    ram_re    = dmem_re;

    ram_addr  = dmem_addr;

    ram_wdata = dmem_wdata;


    // DMA access

    if(dma_we)
    begin

        ram_cs    = 1'b1;

        ram_we    = 1'b1;

        ram_re    = 1'b0;

        ram_addr  = dma_mem_wr_addr;

        ram_wdata = dma_wdata;

    end

end
assign dmem_rdata = ram_rdata;

assign dma_rdata  = ram_rdata;

endmodule 

