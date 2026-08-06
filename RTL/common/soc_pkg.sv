`ifndef SOC_PKG_SV
`define SOC_PKG_SV

package soc_pkg;

  //------------------------------------------------------------
  // Global Parameters
  //------------------------------------------------------------

  parameter int ADDR_WIDTH = 32;
  parameter int DATA_WIDTH = 32;
  parameter int STRB_WIDTH = DATA_WIDTH/8;

  parameter int GPIO_WIDTH  = 32;
  parameter int DMA_CHANNELS = 4;
  parameter int TIMER_COUNT  = 4;
  parameter int UART_COUNT   = 1;
  parameter int SPI_COUNT    = 1;
  parameter int I2C_COUNT    = 1;

  //------------------------------------------------------------
  // SoC Version
  //------------------------------------------------------------

  parameter logic [31:0] SOC_VERSION = 32'h0001_0000;

  //------------------------------------------------------------
  // Peripheral Base Addresses
  //------------------------------------------------------------

  parameter logic [31:0] SYSCTRL_BASE = 32'h4000_0000;
  parameter logic [31:0] INTC_BASE    = 32'h4000_7000;
  parameter logic [31:0] TIMER_BASE   = 32'h4000_2000;
  parameter logic [31:0] GPIO_BASE    = 32'h4000_1000;
  parameter logic [31:0] UART_BASE    = 32'h4000_3000;
  parameter logic [31:0] SPI_BASE     = 32'h4000_4000;
  parameter logic [31:0] I2C_BASE     = 32'h4000_5000;
  parameter logic [31:0] DMA_BASE     = 32'h4000_6000;
  parameter logic [31:0] DEBUG_BASE   = 32'h0000_8000;

  parameter logic [31:0] FIFO_BASE    = 32'h0000_9000;
  parameter logic [31:0] DMA_RAM_BASE = 32'h0000_A000;
  parameter logic [31:0] IMEM_BASE    = 32'h0001_0000;
  parameter logic [31:0] DMEM_BASE    = 32'h0002_0000;

  //------------------------------------------------------------
  // Address Space Size
  //------------------------------------------------------------

  parameter logic [31:0] PERIPHERAL_SIZE = 32'h0000_1000;

  //------------------------------------------------------------
  // Interrupt Sources
  //------------------------------------------------------------

  typedef enum logic [5:0]
  {
      IRQ_TIMER0      = 6'd0,
      IRQ_TIMER1      = 6'd1,
      IRQ_TIMER2      = 6'd2,
      IRQ_TIMER3      = 6'd3,

      IRQ_GPIO0       = 6'd4,
      IRQ_GPIO1       = 6'd5,
      IRQ_GPIO2       = 6'd6,
      IRQ_GPIO3       = 6'd7,

      IRQ_UART_TX     = 6'd8,
      IRQ_UART_RX     = 6'd9,

      IRQ_SPI         = 6'd10,

      IRQ_I2C         = 6'd11,

      IRQ_DMA_CH0     = 6'd12,
      IRQ_DMA_CH1     = 6'd13,
      IRQ_DMA_CH2     = 6'd14,
      IRQ_DMA_CH3     = 6'd15,

      IRQ_WATCHDOG    = 6'd16,

      IRQ_SOFTWARE    = 6'd17,

      IRQ_DEBUG       = 6'd18

  } irq_id_t;

  //------------------------------------------------------------
  // DMA Channel IDs
  //------------------------------------------------------------

  typedef enum logic [1:0]
  {
      DMA_CH0 = 2'd0,
      DMA_CH1 = 2'd1,
      DMA_CH2 = 2'd2,
      DMA_CH3 = 2'd3

  } dma_channel_t;

  //------------------------------------------------------------
  // Peripheral IDs
  //------------------------------------------------------------

  typedef enum logic [3:0]
  {
      PID_SYSCTRL = 4'd0,
      PID_INTC    = 4'd1,
      PID_TIMER   = 4'd2,
      PID_GPIO    = 4'd3,
      PID_UART    = 4'd4,
      PID_SPI     = 4'd5,
      PID_I2C     = 4'd6,
      PID_DMA     = 4'd7,
      PID_DEBUG   = 4'd8

  } peripheral_id_t;

  //------------------------------------------------------------
  // Timer Modes
  //------------------------------------------------------------

  typedef enum logic [2:0]
  {
      TIMER_ONE_SHOT  = 3'd0,
      TIMER_PERIODIC  = 3'd1,
      TIMER_PWM       = 3'd2,
      TIMER_CAPTURE   = 3'd3,
      TIMER_WATCHDOG  = 3'd4

  } timer_mode_t;

  //------------------------------------------------------------
  // GPIO Interrupt Type
  //------------------------------------------------------------

  typedef enum logic [1:0]
  {
      GPIO_LEVEL_LOW      = 2'd0,
      GPIO_LEVEL_HIGH     = 2'd1,
      GPIO_EDGE_FALLING   = 2'd2,
      GPIO_EDGE_RISING    = 2'd3

  } gpio_irq_mode_t;

  //------------------------------------------------------------
  // UART Parity
  //------------------------------------------------------------

  typedef enum logic [1:0]
  {
      UART_PARITY_NONE = 2'd0,
      UART_PARITY_ODD  = 2'd1,
      UART_PARITY_EVEN = 2'd2

  } uart_parity_t;

  //------------------------------------------------------------
  // APB Transfer Type
  //------------------------------------------------------------

  typedef enum logic [1:0]
  {
      APB_IDLE   = 2'd0,
      APB_SETUP  = 2'd1,
      APB_ACCESS = 2'd2

  } apb_state_t;

  //------------------------------------------------------------
  // Common Structures
  //------------------------------------------------------------

  typedef struct packed
  {
      logic                 write;
      logic [31:0]          addr;
      logic [31:0]          wdata;
      logic [3:0]           strb;

  } apb_req_t;

  typedef struct packed
  {
      logic                 ready;
      logic                 slverr;
      logic [31:0]          rdata;

  } apb_rsp_t;

endpackage

`endif