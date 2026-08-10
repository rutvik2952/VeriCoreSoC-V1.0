`ifndef APB_INTERFACE_SV
`define APB_INTERFACE_SV

 `include"apb_common.sv"

 interface apb_vif(input logic PCLK ,logic PRESETn);

  logic[ADDR_WIDTH-1:0] PADDR;
  logic PSLEx;
  logic PENABLE;
  logic[DATA_WIDTH-1:0] PWDATA;
  logic PWRITE;
  logic PREADY;
  logic[DATA_WIDTH-1:0] PRDATA;
  logic PSLVERR;

 endinterface

`endif //APB_INTERFACE_SV
