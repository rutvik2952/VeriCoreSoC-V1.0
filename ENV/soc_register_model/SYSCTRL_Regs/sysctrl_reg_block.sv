`ifndef SYSCTRL_REG_BLOCK_SV
`define SYSCTRL_REG_BLOCK_SV

 class sysctrl_reg_block extends uvm_reg_block;

   sysid_reg         SYS_ID;
   sys_version_reg   SYS_VERSION;
   sys_status_reg    SYS_STATUS;
   sys_control_reg   SYS_CONTROL;
   reset_control_reg RESET_CONTROL;
   clock_enable_reg  CLOCK_ENABLE;
   boot_config_reg   BOOT_CONFIG;
   scratch0_reg      SCRATCH0;
   scratch1_reg      SCRATCH1;
   scratch2_reg      SCRATCH2;
   scratch3_reg      SCRATCH3;

   `uvm_object_utils(sysctrl_reg_block)

   function new(string name="sysctrl_reg_block");
     super.new(name,UVM_NO_COVERAGE);
   endfunction

   function void build();
     SYS_ID = sysid_reg::type_id::create("SYS_ID");
     SYS_ID.configure(this);
     SYS_ID.build();

     SYS_VERSION = sys_version_reg::type_id::create("SYS_VERSION");
     SYS_VERSION.configure(this);
     SYS_VERSION.build();

     SYS_STATUS = sys_status_reg::type_id::create("SYS_STATUS");
     SYS_STATUS.configure(this);
     SYS_STATUS.build();

     SYS_CONTROL = sys_control_reg::type_id::create("SYS_CONTROL");
     SYS_CONTROL.configure(this);
     SYS_CONTROL.build();

     RESET_CONTROL = reset_control_reg::type_id::create("RESET_CONTROL");
     RESET_CONTROL.configure(this);
     RESET_CONTROL.build();

     CLOCK_ENABLE = clock_enable_reg::type_id::create("CLOCK_ENABLE");
     CLOCK_ENABLE.configure(this);
     CLOCK_ENABLE.build();

     BOOT_CONFIG = boot_config_reg::type_id::create("BOOT_CONFIG");
     BOOT_CONFIG.configure(this);
     BOOT_CONFIG.build();

     SCRATCH0 = scratch0_reg::type_id::create("SCRATCH0");
     SCRATCH0.configure(this);
     SCRATCH0.build();

     SCRATCH1 = scratch1_reg::type_id::create("SCRATCH1");
     SCRATCH1.configure(this);
     SCRATCH1.build();
    
     SCRATCH2 = scratch2_reg::type_id::create("SCRATCH2");
     SCRATCH2.configure(this);
     SCRATCH2.build();

     SCRATCH3 = scratch3_reg::type_id::create("SCRATCH3");
     SCRATCH3.configure(this);
     SCRATCH3.build();

     default_map = create_map("default_map",'h4000_0000,4,UVM_LITTLE_ENDIAN);

     default_map.add_reg(SYS_ID,'h0,"RW");
     default_map.add_reg(SYS_VERSION,'h4,"RW");
     default_map.add_reg(SYS_STATUS,'h8,"RW");
     default_map.add_reg(SYS_CONTROL,'hC,"RW");
     default_map.add_reg(RESET_CONTROL,'h10,"RW");
     default_map.add_reg(CLOCK_ENABLE,'h14,"RW");
     default_map.add_reg(BOOT_CONFIG,'h18,"RW"); 
     default_map.add_reg(SCRATCH0,'h1C,"RW");
     default_map.add_reg(SCRATCH1,'h20,"RW");
     default_map.add_reg(SCRATCH2,'h24,"RW");
     default_map.add_reg(SCRATCH3,'h28,"RW");

     lock_model();
     
   endfunction
   
 endclass

`endif //SYSCTRL_REG_BLOCK_SV
