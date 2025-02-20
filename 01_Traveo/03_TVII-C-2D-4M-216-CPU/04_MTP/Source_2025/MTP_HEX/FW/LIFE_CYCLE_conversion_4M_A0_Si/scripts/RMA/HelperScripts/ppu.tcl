# Add PPU and MPU protection checks in Normal and above START          

proc ReadPpuSmpuChecks {} {

                # First, read values to see if they have been modified

                # List of globals to be checked

                # 1.

                global PERI_MS_PPU_FX18_SL_ADDR_ADDR PERI_MS_PPU_FX18_SL_SIZE_ADDR PERI_MS_PPU_FX18_SL_ATT0_ADDR PERI_MS_PPU_FX18_SL_ATT1_ADDR PERI_MS_PPU_FX18_SL_ATT2_ADDR PERI_MS_PPU_FX18_SL_ATT3_ADDR;

                global PERI_MS_PPU_FX18_MS_ADDR_ADDR PERI_MS_PPU_FX18_MS_SIZE_ADDR PERI_MS_PPU_FX18_MS_ATT0_ADDR PERI_MS_PPU_FX18_MS_ATT1_ADDR PERI_MS_PPU_FX18_MS_ATT2_ADDR PERI_MS_PPU_FX18_MS_ATT3_ADDR;

                               

                # 2.

                global PERI_MS_PPU_FX150_SL_ADDR_ADDR PERI_MS_PPU_FX150_SL_SIZE_ADDR PERI_MS_PPU_FX150_SL_ATT0_ADDR PERI_MS_PPU_FX150_SL_ATT1_ADDR PERI_MS_PPU_FX150_SL_ATT2_ADDR PERI_MS_PPU_FX150_SL_ATT3_ADDR;

                global PERI_MS_PPU_FX150_MS_ADDR_ADDR PERI_MS_PPU_FX150_MS_SIZE_ADDR PERI_MS_PPU_FX150_MS_ATT0_ADDR PERI_MS_PPU_FX150_MS_ATT1_ADDR PERI_MS_PPU_FX150_MS_ATT2_ADDR PERI_MS_PPU_FX150_MS_ATT3_ADDR;

               

                # 3.

                global PERI_MS_PPU_FX72_SL_ADDR_ADDR PERI_MS_PPU_FX72_SL_SIZE_ADDR PERI_MS_PPU_FX72_SL_ATT0_ADDR PERI_MS_PPU_FX72_SL_ATT1_ADDR PERI_MS_PPU_FX72_SL_ATT2_ADDR PERI_MS_PPU_FX72_SL_ATT3_ADDR;

                global PERI_MS_PPU_FX72_MS_ADDR_ADDR PERI_MS_PPU_FX72_MS_SIZE_ADDR PERI_MS_PPU_FX72_MS_ATT0_ADDR PERI_MS_PPU_FX72_MS_ATT1_ADDR PERI_MS_PPU_FX72_MS_ATT2_ADDR PERI_MS_PPU_FX72_MS_ATT3_ADDR; 

               

                # 4.

                global PROT_SMPU_SMPU_STRUCT15_ADDR0_ADDR PROT_SMPU_SMPU_STRUCT15_ATT0_ADDR PROT_SMPU_SMPU_STRUCT15_ADDR1_ADDR PROT_SMPU_SMPU_STRUCT15_ATT1_ADDR;

               

                # 5.

                global PROT_SMPU_SMPU_STRUCT14_ADDR0_ADDR PROT_SMPU_SMPU_STRUCT14_ATT0_ADDR PROT_SMPU_SMPU_STRUCT14_ADDR1_ADDR PROT_SMPU_SMPU_STRUCT14_ATT1_ADDR;

                               

                # 6.

                global PERI_MS_PPU_PR0_SL_ADDR_ADDR PERI_MS_PPU_PR0_SL_SIZE_ADDR PERI_MS_PPU_PR0_SL_ATT0_ADDR PERI_MS_PPU_PR0_SL_ATT1_ADDR PERI_MS_PPU_PR0_SL_ATT2_ADDR PERI_MS_PPU_PR0_SL_ATT3_ADDR;

                global PERI_MS_PPU_PR0_MS_ADDR_ADDR PERI_MS_PPU_PR0_MS_SIZE_ADDR PERI_MS_PPU_PR0_MS_ATT0_ADDR PERI_MS_PPU_PR0_MS_ATT1_ADDR PERI_MS_PPU_PR0_MS_ATT2_ADDR PERI_MS_PPU_PR0_MS_ATT3_ADDR;

 

                # 7.

                global PERI_MS_PPU_PR1_SL_ADDR_ADDR PERI_MS_PPU_PR1_SL_SIZE_ADDR PERI_MS_PPU_PR1_SL_ATT0_ADDR PERI_MS_PPU_PR1_SL_ATT1_ADDR PERI_MS_PPU_PR1_SL_ATT2_ADDR PERI_MS_PPU_PR1_SL_ATT3_ADDR;

                global PERI_MS_PPU_PR1_MS_ADDR_ADDR PERI_MS_PPU_PR1_MS_SIZE_ADDR PERI_MS_PPU_PR1_MS_ATT0_ADDR PERI_MS_PPU_PR1_MS_ATT1_ADDR PERI_MS_PPU_PR1_MS_ATT2_ADDR PERI_MS_PPU_PR1_MS_ATT3_ADDR;   

                               

                # 8.

                global PERI_MS_PPU_FX60_SL_ADDR_ADDR PERI_MS_PPU_FX60_SL_SIZE_ADDR PERI_MS_PPU_FX60_SL_ATT0_ADDR PERI_MS_PPU_FX60_SL_ATT1_ADDR PERI_MS_PPU_FX60_SL_ATT2_ADDR PERI_MS_PPU_FX60_SL_ATT3_ADDR;

                global PERI_MS_PPU_FX60_MS_ADDR_ADDR PERI_MS_PPU_FX60_MS_SIZE_ADDR PERI_MS_PPU_FX60_MS_ATT0_ADDR PERI_MS_PPU_FX60_MS_ATT1_ADDR PERI_MS_PPU_FX60_MS_ATT2_ADDR PERI_MS_PPU_FX60_MS_ATT3_ADDR;                 

               

                # Later, add failure check codes for the same

                puts "\n\nRunning PPU SMPU checks START!\n\n";

               

                # 1. Configure CPUSS_BOOT region using fixed PPU such that it is readable by all PC’s but writable by PC0 only.

                puts "\n1. Configure CPUSS_BOOT region using fixed PPU such that it is readable by all PC’s but writable by PC0 only.";

                IOR $PERI_MS_PPU_FX18_SL_ADDR_ADDR  0x40202000;

                IOR $PERI_MS_PPU_FX18_SL_SIZE_ADDR  0x88000000;

                IOR $PERI_MS_PPU_FX18_SL_ATT0_ADDR  0x1515151f;# Problem: allow write in PC3, privileged write in PC2 expect 0x1515151f

                # ANKU added for CDT debug START

                puts "ANKU: Added for debug START";

                IOW $PERI_MS_PPU_FX18_SL_ATT0_ADDR  0x1515151f;

                IOR $PERI_MS_PPU_FX18_SL_ATT0_ADDR  0x1515151f;

                puts "ANKU: Added for debug END";

                # ANKU added for CDT debug END           

                IOR $PERI_MS_PPU_FX18_SL_ATT1_ADDR  0x15151515;

                IOR $PERI_MS_PPU_FX18_SL_ATT2_ADDR  0x00000000;

                IOR $PERI_MS_PPU_FX18_SL_ATT3_ADDR  0x00000000;

                IOR $PERI_MS_PPU_FX18_MS_ADDR_ADDR  0x40010c80;

                IOR $PERI_MS_PPU_FX18_MS_SIZE_ADDR  0x85000000;

                IOR $PERI_MS_PPU_FX18_MS_ATT0_ADDR  0x1515151f;# Problem: allow write in PC3, privileged write in PC2 expect 0x1515151f

                # ANKU added for CDT debug START

                puts "ANKU: Added for debug START";

                IOW $PERI_MS_PPU_FX18_MS_ATT0_ADDR  0x1515151f;

                IOR $PERI_MS_PPU_FX18_MS_ATT0_ADDR  0x1515151f;

                puts "ANKU: Added for debug END";

                # ANKU added for CDT debug END           

                IOR $PERI_MS_PPU_FX18_MS_ATT1_ADDR  0x15151515;

                IOR $PERI_MS_PPU_FX18_MS_ATT2_ADDR  0x00000000;

                IOR $PERI_MS_PPU_FX18_MS_ATT3_ADDR  0x00000000;

               

                # 2. Configure EFUSE_CTL region using fixed PPU such that only PC0 can access it.

                puts "\n2. Configure EFUSE_CTL region using fixed PPU such that only PC0 can access it.";

                IOR $PERI_MS_PPU_FX150_SL_ADDR_ADDR  0x402c0000;

                IOR $PERI_MS_PPU_FX150_SL_SIZE_ADDR  0x86000000;

                IOR $PERI_MS_PPU_FX150_SL_ATT0_ADDR  0x0000001F;

                # ANKU added for CDT debug START

                puts "ANKU: Added for debug START";

                IOW $PERI_MS_PPU_FX150_SL_ATT0_ADDR  0x00000000;

                IOR $PERI_MS_PPU_FX150_SL_ATT0_ADDR  0x00000000;

                puts "ANKU: Added for debug END";

                # ANKU added for CDT debug END                           

                IOR $PERI_MS_PPU_FX150_SL_ATT1_ADDR  0x00000000;

                # ANKU added for CDT debug START

                puts "ANKU: Added for debug START";

                IOR $PERI_MS_PPU_FX150_SL_ATT1_ADDR  0x00000000;

                IOR $PERI_MS_PPU_FX150_SL_ATT1_ADDR  0x00000000;

                puts "ANKU: Added for debug END";

                # ANKU added for CDT debug END                           

                IOR $PERI_MS_PPU_FX150_SL_ATT2_ADDR  0x00000000;

                IOR $PERI_MS_PPU_FX150_SL_ATT3_ADDR  0x00000000;

                IOR $PERI_MS_PPU_FX150_MS_ADDR_ADDR  0x40012d80;

                IOR $PERI_MS_PPU_FX150_MS_SIZE_ADDR  0x85000000;

                IOR $PERI_MS_PPU_FX150_MS_ATT0_ADDR  0x1515151F;

                # ANKU added for CDT debug START

                puts "ANKU: Added for debug START";  

                IOW $PERI_MS_PPU_FX150_MS_ATT0_ADDR  0x1515151F;

                IOR $PERI_MS_PPU_FX150_MS_ATT0_ADDR  0x1515151F;

                puts "ANKU: Added for debug END";

                # ANKU added for CDT debug END                                           

                IOR $PERI_MS_PPU_FX150_MS_ATT1_ADDR  0x15151515;

                # ANKU added for CDT debug START

                puts "ANKU: Added for debug START";  

                IOW $PERI_MS_PPU_FX150_MS_ATT1_ADDR  0x15151515;

                IOR $PERI_MS_PPU_FX150_MS_ATT1_ADDR  0x15151515;

                puts "ANKU: Added for debug END";

                # ANKU added for CDT debug END                                           

                IOR $PERI_MS_PPU_FX150_MS_ATT2_ADDR  0x00000000;

                IOR $PERI_MS_PPU_FX150_MS_ATT3_ADDR  0x00000000;           

               

                # 3. Configure FM_CTL region using fixed PPU such that only PC0 can access it.

                puts "\n3. Configure FM_CTL region using fixed PPU such that only PC0 can access it.";

                IOR $PERI_MS_PPU_FX72_SL_ADDR_ADDR  0x4024f000;

                IOR $PERI_MS_PPU_FX72_SL_SIZE_ADDR  0x8b000000;

                IOR $PERI_MS_PPU_FX72_SL_ATT0_ADDR  0x0000001F;

                IOR $PERI_MS_PPU_FX72_SL_ATT1_ADDR  0x00000000;

                IOR $PERI_MS_PPU_FX72_SL_ATT2_ADDR  0x00000000;

                IOR $PERI_MS_PPU_FX72_SL_ATT3_ADDR  0x00000000;

                IOR $PERI_MS_PPU_FX72_MS_ADDR_ADDR  0x40011a00;

                IOR $PERI_MS_PPU_FX72_MS_SIZE_ADDR  0x85000000;

                IOR $PERI_MS_PPU_FX72_MS_ATT0_ADDR  0x0000001F;

                IOR $PERI_MS_PPU_FX72_MS_ATT1_ADDR  0x00000000;

                IOR $PERI_MS_PPU_FX72_MS_ATT2_ADDR  0x00000000;

                IOR $PERI_MS_PPU_FX72_MS_ATT3_ADDR  0x00000000;             

               

                # 4. Configure SMPU15 to protect last 2KB of SRAM such that only PC0 can access it.

                # ATT0 = 0x8afffe00

                # ATT1 = 0x80fffe40

                puts "\n4. Configure SMPU15 to protect last 2KB of SRAM such that only PC0 can access it";

                IOR $PROT_SMPU_SMPU_STRUCT15_ADDR0_ADDR 0x080ff800

                IOR $PROT_SMPU_SMPU_STRUCT15_ATT0_ADDR            0x8a00ff00

                IOR $PROT_SMPU_SMPU_STRUCT15_ADDR1_ADDR 0x4023233f

                IOR $PROT_SMPU_SMPU_STRUCT15_ATT1_ADDR  0x8700ff49

               

                # 5. Configure SMPU14 to protect system partition of SROM such that it is accessible only by PC0. User partition is accessible by all PC.

                # ATT0=0x8efffe00

                # ATT1=0x80fffe40

                puts "\n5. Configure SMPU14 to protect system partition of SROM such that it is accessible only by PC0. User partition is accessible by all PC";

                IOR $PROT_SMPU_SMPU_STRUCT14_ADDR0_ADDR 0x00000081

                IOR $PROT_SMPU_SMPU_STRUCT14_ATT0_ADDR            0x8e00ff00

                IOR $PROT_SMPU_SMPU_STRUCT14_ADDR1_ADDR 0x402323cf

                IOR $PROT_SMPU_SMPU_STRUCT14_ATT1_ADDR           0x8700ff49

               

                # 6. Configure programmable PPU 0 to protect CRYPTO MMIO when system calls which use CRYPTO is running such that only PC0 can access it.

                puts "\n6. Configure programmable PPU 0 to protect CRYPTO MMIO when system calls which use CRYPTO is running such that only PC0 can access it."

                IOR $PERI_MS_PPU_PR0_SL_ADDR_ADDR  0x40100000;

                IOR $PERI_MS_PPU_PR0_SL_SIZE_ADDR  0x8f000000;

                IOR $PERI_MS_PPU_PR0_SL_ATT0_ADDR  0x1f1f1f1f;

                IOR $PERI_MS_PPU_PR0_SL_ATT1_ADDR  0x1f1f1f1f;

                IOR $PERI_MS_PPU_PR0_SL_ATT2_ADDR  0x00000000;

                IOR $PERI_MS_PPU_PR0_SL_ATT3_ADDR  0x00000000;

                IOR $PERI_MS_PPU_PR0_MS_ADDR_ADDR  0x40010000;

                IOR $PERI_MS_PPU_PR0_MS_SIZE_ADDR  0x85000000;

                IOR $PERI_MS_PPU_PR0_MS_ATT0_ADDR  0x1f1d051f;# Why not 0x1515151F?

                IOR $PERI_MS_PPU_PR0_MS_ATT1_ADDR  0x05050505;# Why not 0x15151515?

                IOR $PERI_MS_PPU_PR0_MS_ATT2_ADDR  0x00000000;

                IOR $PERI_MS_PPU_PR0_MS_ATT3_ADDR  0x00000000;               

               

                # 7. Configure programmable PPU 1 to protect IPC MMIO when system calls are running such that all PC’s can read but only PC0 can write to it.

                puts "\n7. Configure programmable PPU 1 to protect IPC MMIO when system calls are running such that all PC’s can read but only PC0 can write to it."

                IOR $PERI_MS_PPU_PR1_SL_ADDR_ADDR  0x40220040;

                IOR $PERI_MS_PPU_PR1_SL_SIZE_ADDR  0x84000000;

                IOR $PERI_MS_PPU_PR1_SL_ATT0_ADDR  0x1f1f1f1f;

                IOR $PERI_MS_PPU_PR1_SL_ATT1_ADDR  0x1f1f1f1f;

                IOR $PERI_MS_PPU_PR1_SL_ATT2_ADDR  0x00000000;

                IOR $PERI_MS_PPU_PR1_SL_ATT3_ADDR  0x00000000;

                IOR $PERI_MS_PPU_PR1_MS_ADDR_ADDR  0x40010040;

                IOR $PERI_MS_PPU_PR1_MS_SIZE_ADDR  0x85000000;

                IOR $PERI_MS_PPU_PR1_MS_ATT0_ADDR  0x1515151F;

                IOR $PERI_MS_PPU_PR1_MS_ATT1_ADDR  0x15151515;

                IOR $PERI_MS_PPU_PR1_MS_ATT2_ADDR  0x00000000;

                IOR $PERI_MS_PPU_PR1_MS_ATT3_ADDR  0x00000000;               

               

                # 8. Configure MPU15_MAIN region using fixed PPU such that all PC can read and only PC0 can write to DAP MPU.

                puts "\n8. Configure MPU15_MAIN region using fixed PPU such that all PC can read and only PC0 can write to DAP MPU.";

                IOR $PERI_MS_PPU_FX60_SL_ADDR_ADDR  0x40237c00;

                IOR $PERI_MS_PPU_FX60_SL_SIZE_ADDR  0x89000000;

                IOR $PERI_MS_PPU_FX60_SL_ATT0_ADDR  0x1515151F;

                IOR $PERI_MS_PPU_FX60_SL_ATT1_ADDR  0x15151515;

                IOR $PERI_MS_PPU_FX60_SL_ATT2_ADDR  0x00000000;

                IOR $PERI_MS_PPU_FX60_SL_ATT3_ADDR  0x00000000;

                IOR $PERI_MS_PPU_FX60_MS_ADDR_ADDR  0x40011700;

                IOR $PERI_MS_PPU_FX60_MS_SIZE_ADDR  0x85000000;

                IOR $PERI_MS_PPU_FX60_MS_ATT0_ADDR  0x1515151F;

                IOR $PERI_MS_PPU_FX60_MS_ATT1_ADDR  0x15151515;

                IOR $PERI_MS_PPU_FX60_MS_ATT2_ADDR  0x00000000;

                IOR $PERI_MS_PPU_FX60_MS_ATT3_ADDR  0x00000000;             

                puts "\n\nRunning PPU SMPU checks END!\n\n";

               

                ReadPpuSmpuChecksInFlashBoot;

}

 

proc ReadPpuSmpuChecksInFlashBoot {} {

                # Refer CDT 322652

                # 1.

                global PERI_MS_PPU_PR4_SL_ADDR_ADDR PERI_MS_PPU_PR4_SL_SIZE_ADDR PERI_MS_PPU_PR4_SL_ATT0_ADDR PERI_MS_PPU_PR4_SL_ATT1_ADDR PERI_MS_PPU_PR4_SL_ATT2_ADDR PERI_MS_PPU_PR4_SL_ATT3_ADDR;

                global PERI_MS_PPU_PR4_MS_ADDR_ADDR PERI_MS_PPU_PR4_MS_SIZE_ADDR PERI_MS_PPU_PR4_MS_ATT0_ADDR PERI_MS_PPU_PR4_MS_ATT1_ADDR PERI_MS_PPU_PR4_MS_ATT2_ADDR PERI_MS_PPU_PR4_MS_ATT3_ADDR;

 

                # 2.

                global PERI_MS_PPU_PR5_SL_ADDR_ADDR PERI_MS_PPU_PR5_SL_SIZE_ADDR PERI_MS_PPU_PR5_SL_ATT0_ADDR PERI_MS_PPU_PR5_SL_ATT1_ADDR PERI_MS_PPU_PR5_SL_ATT2_ADDR PERI_MS_PPU_PR5_SL_ATT3_ADDR;

                global PERI_MS_PPU_PR5_MS_ADDR_ADDR PERI_MS_PPU_PR5_MS_SIZE_ADDR PERI_MS_PPU_PR5_MS_ATT0_ADDR PERI_MS_PPU_PR5_MS_ATT1_ADDR PERI_MS_PPU_PR5_MS_ATT2_ADDR PERI_MS_PPU_PR5_MS_ATT3_ADDR;   

 

                # 3.

                global PERI_MS_PPU_PR6_SL_ADDR_ADDR PERI_MS_PPU_PR6_SL_SIZE_ADDR PERI_MS_PPU_PR6_SL_ATT0_ADDR PERI_MS_PPU_PR6_SL_ATT1_ADDR PERI_MS_PPU_PR6_SL_ATT2_ADDR PERI_MS_PPU_PR6_SL_ATT3_ADDR;

                global PERI_MS_PPU_PR6_MS_ADDR_ADDR PERI_MS_PPU_PR6_MS_SIZE_ADDR PERI_MS_PPU_PR6_MS_ATT0_ADDR PERI_MS_PPU_PR6_MS_ATT1_ADDR PERI_MS_PPU_PR6_MS_ATT2_ADDR PERI_MS_PPU_PR6_MS_ATT3_ADDR;                   

 

                # 4.

                global PERI_MS_PPU_FX55_SL_ADDR_ADDR PERI_MS_PPU_FX55_SL_SIZE_ADDR PERI_MS_PPU_FX55_SL_ATT0_ADDR PERI_MS_PPU_FX55_SL_ATT1_ADDR PERI_MS_PPU_FX55_SL_ATT2_ADDR PERI_MS_PPU_FX55_SL_ATT3_ADDR;

                global PERI_MS_PPU_FX55_MS_ADDR_ADDR PERI_MS_PPU_FX55_MS_SIZE_ADDR PERI_MS_PPU_FX55_MS_ATT0_ADDR PERI_MS_PPU_FX55_MS_ATT1_ADDR PERI_MS_PPU_FX55_MS_ATT2_ADDR PERI_MS_PPU_FX55_MS_ATT3_ADDR;                 

               

               

                puts "1. Configure programmable PPU 4 to protect AP_CTL"

                IOR $PERI_MS_PPU_PR4_SL_ADDR_ADDR  0x00000000;

                IOR $PERI_MS_PPU_PR4_SL_SIZE_ADDR  0x00000000;

                IOR $PERI_MS_PPU_PR4_SL_ATT0_ADDR  0x00000000;

                IOR $PERI_MS_PPU_PR4_SL_ATT1_ADDR  0x00000000;

                IOR $PERI_MS_PPU_PR4_SL_ATT2_ADDR  0x00000000;

                IOR $PERI_MS_PPU_PR4_SL_ATT3_ADDR  0x00000000;

                IOR $PERI_MS_PPU_PR4_MS_ADDR_ADDR  0x00000000;

                IOR $PERI_MS_PPU_PR4_MS_SIZE_ADDR  0x00000000;

                IOR $PERI_MS_PPU_PR4_MS_ATT0_ADDR  0x00000000;

                IOR $PERI_MS_PPU_PR4_MS_ATT1_ADDR  0x00000000;

                IOR $PERI_MS_PPU_PR4_MS_ATT2_ADDR  0x00000000;

                IOR $PERI_MS_PPU_PR4_MS_ATT3_ADDR  0x00000000;  

               

                puts "2. Configure programmable PPU 5 to protect CM0_NMI_CTL"

                IOR $PERI_MS_PPU_PR5_SL_ADDR_ADDR  0x00000000;

                IOR $PERI_MS_PPU_PR5_SL_SIZE_ADDR  0x00000000;

                IOR $PERI_MS_PPU_PR5_SL_ATT0_ADDR  0x00000000;

                IOR $PERI_MS_PPU_PR5_SL_ATT1_ADDR  0x00000000;

                IOR $PERI_MS_PPU_PR5_SL_ATT2_ADDR  0x00000000;

                IOR $PERI_MS_PPU_PR5_SL_ATT3_ADDR  0x00000000;

                IOR $PERI_MS_PPU_PR5_MS_ADDR_ADDR  0x00000000;

                IOR $PERI_MS_PPU_PR5_MS_SIZE_ADDR  0x00000000;

                IOR $PERI_MS_PPU_PR5_MS_ATT0_ADDR  0x00000000;

                IOR $PERI_MS_PPU_PR5_MS_ATT1_ADDR  0x00000000;

                IOR $PERI_MS_PPU_PR5_MS_ATT2_ADDR  0x00000000;

                IOR $PERI_MS_PPU_PR5_MS_ATT3_ADDR  0x00000000;

 

                puts "3. Configure programmable PPU 6 to protect MBIST_CTL"

                IOR $PERI_MS_PPU_PR6_SL_ADDR_ADDR  0x00000000;

                IOR $PERI_MS_PPU_PR6_SL_SIZE_ADDR  0x00000000;

                IOR $PERI_MS_PPU_PR6_SL_ATT0_ADDR  0x00000000;

                IOR $PERI_MS_PPU_PR6_SL_ATT1_ADDR  0x00000000;

                IOR $PERI_MS_PPU_PR6_SL_ATT2_ADDR  0x00000000;

                IOR $PERI_MS_PPU_PR6_SL_ATT3_ADDR  0x00000000;

                IOR $PERI_MS_PPU_PR6_MS_ADDR_ADDR  0x00000000;

                IOR $PERI_MS_PPU_PR6_MS_SIZE_ADDR  0x00000000;

                IOR $PERI_MS_PPU_PR6_MS_ATT0_ADDR  0x00000000;

                IOR $PERI_MS_PPU_PR6_MS_ATT1_ADDR  0x00000000;

                IOR $PERI_MS_PPU_PR6_MS_ATT2_ADDR  0x00000000;

                IOR $PERI_MS_PPU_PR6_MS_ATT3_ADDR  0x00000000;                               

  

                puts "4. Configure fixed PPU 6 to protect SMPU"

                IOR $PERI_MS_PPU_FX55_SL_ADDR_ADDR  0x00000000;

                IOR $PERI_MS_PPU_FX55_SL_SIZE_ADDR  0x00000000;

                IOR $PERI_MS_PPU_FX55_SL_ATT0_ADDR  0x00000000;

                IOR $PERI_MS_PPU_FX55_SL_ATT1_ADDR  0x00000000;

                IOR $PERI_MS_PPU_FX55_SL_ATT2_ADDR  0x00000000;

                IOR $PERI_MS_PPU_FX55_SL_ATT3_ADDR  0x00000000;

                IOR $PERI_MS_PPU_FX55_MS_ADDR_ADDR  0x00000000;

                IOR $PERI_MS_PPU_FX55_MS_SIZE_ADDR  0x00000000;

                IOR $PERI_MS_PPU_FX55_MS_ATT0_ADDR  0x00000000;

                IOR $PERI_MS_PPU_FX55_MS_ATT1_ADDR  0x00000000;

                IOR $PERI_MS_PPU_FX55_MS_ATT2_ADDR  0x00000000;

                IOR $PERI_MS_PPU_FX55_MS_ATT3_ADDR  0x00000000;             

}

# Add PPU and MPU protection checks in Normal and above END

               

 

 

   # 1. Configure CPUSS_BOOT region using fixed PPU such that it is readable by all PC’s but writable by PC0 only.

                set PERI_MS_PPU_FX18_SL_ADDR_ADDR 0x40010C80;

                set PERI_MS_PPU_FX18_SL_SIZE_ADDR 0x40010C84;

                set PERI_MS_PPU_FX18_SL_ATT0_ADDR 0x40010C90;

                set PERI_MS_PPU_FX18_SL_ATT1_ADDR 0x40010C94;

                set PERI_MS_PPU_FX18_SL_ATT2_ADDR 0x40010C98;

                set PERI_MS_PPU_FX18_SL_ATT3_ADDR 0x40010C9C;

                set PERI_MS_PPU_FX18_MS_ADDR_ADDR 0x40010CA0;

                set PERI_MS_PPU_FX18_MS_SIZE_ADDR 0x40010CA4;

                set PERI_MS_PPU_FX18_MS_ATT0_ADDR 0x40010CB0;

                set PERI_MS_PPU_FX18_MS_ATT1_ADDR 0x40010CB4;

                set PERI_MS_PPU_FX18_MS_ATT2_ADDR 0x40010CB8;

                set PERI_MS_PPU_FX18_MS_ATT3_ADDR 0x40010CBC;

  

   # 2. For efuse protection

                set PERI_MS_PPU_FX150_SL_ADDR_ADDR 0x40012D80;

                set PERI_MS_PPU_FX150_SL_SIZE_ADDR 0x40012D84;

                set PERI_MS_PPU_FX150_SL_ATT0_ADDR 0x40012D90;

                set PERI_MS_PPU_FX150_SL_ATT1_ADDR 0x40012D94;

                set PERI_MS_PPU_FX150_SL_ATT2_ADDR 0x40012D98;

                set PERI_MS_PPU_FX150_SL_ATT3_ADDR 0x40012D9C;

                set PERI_MS_PPU_FX150_MS_ADDR_ADDR 0x40012DA0;

                set PERI_MS_PPU_FX150_MS_SIZE_ADDR 0x40012DA4;

                set PERI_MS_PPU_FX150_MS_ATT0_ADDR 0x40012DB0;

                set PERI_MS_PPU_FX150_MS_ATT1_ADDR 0x40012DB4;

                set PERI_MS_PPU_FX150_MS_ATT2_ADDR 0x40012DB8;

                set PERI_MS_PPU_FX150_MS_ATT3_ADDR 0x40012DBC;

               

                # 3. For FM_CTL protection

                set PERI_MS_PPU_FX72_SL_ADDR_ADDR 0x40011A00;

                set PERI_MS_PPU_FX72_SL_SIZE_ADDR 0x40011A04;

                set PERI_MS_PPU_FX72_SL_ATT0_ADDR 0x40011A10;

                set PERI_MS_PPU_FX72_SL_ATT1_ADDR 0x40011A14;

                set PERI_MS_PPU_FX72_SL_ATT2_ADDR 0x40011A18;

                set PERI_MS_PPU_FX72_SL_ATT3_ADDR 0x40011A1C;

                set PERI_MS_PPU_FX72_MS_ADDR_ADDR 0x40011A20;

                set PERI_MS_PPU_FX72_MS_SIZE_ADDR 0x40011A24;

                set PERI_MS_PPU_FX72_MS_ATT0_ADDR 0x40011A30;

                set PERI_MS_PPU_FX72_MS_ATT1_ADDR 0x40011A34;

                set PERI_MS_PPU_FX72_MS_ATT2_ADDR 0x40011A38;

                set PERI_MS_PPU_FX72_MS_ATT3_ADDR 0x40011A3C;

               

                # 4. For SMPU15 to protect last 2 KB SRAM

                set PROT_SMPU_SMPU_STRUCT15_ADDR0_ADDR           0x402323C0;

                set PROT_SMPU_SMPU_STRUCT15_ATT0_ADDR               0x402323C4;

                set PROT_SMPU_SMPU_STRUCT15_ADDR1_ADDR           0x402323E0;

                set PROT_SMPU_SMPU_STRUCT15_ATT1_ADDR               0x402323E4;

               

                # 5. For SMPU14 to protect SROM system partition

                set PROT_SMPU_SMPU_STRUCT14_ADDR0_ADDR  0x40232380;

                set PROT_SMPU_SMPU_STRUCT14_ATT0_ADDR   0x40232384;

                set PROT_SMPU_SMPU_STRUCT14_ADDR1_ADDR           0x402323A0;

                set PROT_SMPU_SMPU_STRUCT14_ATT1_ADDR               0x402323A4;

               

                # 6. Configure programmable PPU 0 to protect CRYPTO MMIO when system calls which use CRYPTO is running such that only PC0 can access it.

                set PERI_MS_PPU_PR_BASE_ADDR  0x40010000;

                set PERI_MS_PPU_PR_SIZE                           0x40;

                set PERI_MS_PPU_PR_NUM                         32;

               

                set PERI_MS_PPU_PR_SL_ADDR_OFFSET  0x00;

                set PERI_MS_PPU_PR_SL_SIZE_OFFSET  0x04;

                set PERI_MS_PPU_PR_SL_ATT0_OFFSET  0x10;

                set PERI_MS_PPU_PR_SL_ATT1_OFFSET  0x14;

                set PERI_MS_PPU_PR_SL_ATT2_OFFSET  0x18;

                set PERI_MS_PPU_PR_SL_ATT3_OFFSET  0x1C;

                set PERI_MS_PPU_PR_MS_ADDR_OFFSET  0x20;

                set PERI_MS_PPU_PR_MS_SIZE_OFFSET  0x24;

                set PERI_MS_PPU_PR_MS_ATT0_OFFSET  0x30;

                set PERI_MS_PPU_PR_MS_ATT1_OFFSET  0x34;

                set PERI_MS_PPU_PR_MS_ATT2_OFFSET  0x38;

                set PERI_MS_PPU_PR_MS_ATT3_OFFSET  0x3C;

               

                set PERI_MS_PPU_PR0_SL_ADDR_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (0 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_SL_ADDR_OFFSET];

                set PERI_MS_PPU_PR0_SL_SIZE_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (0 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_SL_SIZE_OFFSET];

                set PERI_MS_PPU_PR0_SL_ATT0_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (0 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_SL_ATT0_OFFSET];

                set PERI_MS_PPU_PR0_SL_ATT1_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (0 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_SL_ATT1_OFFSET];

                set PERI_MS_PPU_PR0_SL_ATT2_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (0 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_SL_ATT2_OFFSET];

                set PERI_MS_PPU_PR0_SL_ATT3_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (0 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_SL_ATT3_OFFSET];

                set PERI_MS_PPU_PR0_MS_ADDR_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (0 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_MS_ADDR_OFFSET];

                set PERI_MS_PPU_PR0_MS_SIZE_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (0 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_MS_SIZE_OFFSET];

                set PERI_MS_PPU_PR0_MS_ATT0_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (0 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_MS_ATT0_OFFSET];

                set PERI_MS_PPU_PR0_MS_ATT1_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (0 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_MS_ATT1_OFFSET];

                set PERI_MS_PPU_PR0_MS_ATT2_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (0 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_MS_ATT2_OFFSET];

                set PERI_MS_PPU_PR0_MS_ATT3_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (0 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_MS_ATT3_OFFSET];       

               

                # 7. Configure programmable PPU 1 to protect IPC MMIO when system calls are running such that all PC’s can read but only PC0 can write to it.

                set PERI_MS_PPU_PR1_SL_ADDR_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (1 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_SL_ADDR_OFFSET];

                set PERI_MS_PPU_PR1_SL_SIZE_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (1 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_SL_SIZE_OFFSET];

                set PERI_MS_PPU_PR1_SL_ATT0_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (1 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_SL_ATT0_OFFSET];

                set PERI_MS_PPU_PR1_SL_ATT1_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (1 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_SL_ATT1_OFFSET];

                set PERI_MS_PPU_PR1_SL_ATT2_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (1 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_SL_ATT2_OFFSET];

                set PERI_MS_PPU_PR1_SL_ATT3_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (1 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_SL_ATT3_OFFSET];

                set PERI_MS_PPU_PR1_MS_ADDR_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (1 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_MS_ADDR_OFFSET];

                set PERI_MS_PPU_PR1_MS_SIZE_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (1 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_MS_SIZE_OFFSET];

                set PERI_MS_PPU_PR1_MS_ATT0_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (1 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_MS_ATT0_OFFSET];

                set PERI_MS_PPU_PR1_MS_ATT1_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (1 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_MS_ATT1_OFFSET];

                set PERI_MS_PPU_PR1_MS_ATT2_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (1 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_MS_ATT2_OFFSET];

                set PERI_MS_PPU_PR1_MS_ATT3_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (1 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_MS_ATT3_OFFSET];

               

                # 8. Configure MPU15_MAIN region using fixed PPU such that all PC can read and only PC0 can write to DAP MPU.

                set PERI_MS_PPU_FX60_SL_ADDR_ADDR  0x40011700;

                set PERI_MS_PPU_FX60_SL_SIZE_ADDR  0x40011704;

                set PERI_MS_PPU_FX60_SL_ATT0_ADDR  0x40011710;

                set PERI_MS_PPU_FX60_SL_ATT1_ADDR  0x40011714;

                set PERI_MS_PPU_FX60_SL_ATT2_ADDR  0x40011718;

                set PERI_MS_PPU_FX60_SL_ATT3_ADDR  0x4001171C;

                set PERI_MS_PPU_FX60_MS_ADDR_ADDR  0x40011720;

                set PERI_MS_PPU_FX60_MS_SIZE_ADDR  0x40011724;

                set PERI_MS_PPU_FX60_MS_ATT0_ADDR  0x40011730;

                set PERI_MS_PPU_FX60_MS_ATT1_ADDR  0x40011734;

                set PERI_MS_PPU_FX60_MS_ATT2_ADDR  0x40011738;

                set PERI_MS_PPU_FX60_MS_ATT3_ADDR  0x4001173C;

   # Add device specific checks for PPU and SMPU configuration END

  

   # Additional defines to protect AP_CTL, CM0_NMI_CTL, MBIST_CTL and SMPU.MS_CTL

   # Refer CDT 322652

                # 1. Configure programmable PPU 4 to protect AP_CTL

                set PERI_MS_PPU_PR4_SL_ADDR_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (4 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_SL_ADDR_OFFSET];

                set PERI_MS_PPU_PR4_SL_SIZE_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (4 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_SL_SIZE_OFFSET];

                set PERI_MS_PPU_PR4_SL_ATT0_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (4 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_SL_ATT0_OFFSET];

                set PERI_MS_PPU_PR4_SL_ATT1_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (4 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_SL_ATT1_OFFSET];

                set PERI_MS_PPU_PR4_SL_ATT2_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (4 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_SL_ATT2_OFFSET];

                set PERI_MS_PPU_PR4_SL_ATT3_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (4 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_SL_ATT3_OFFSET];

                set PERI_MS_PPU_PR4_MS_ADDR_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (4 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_MS_ADDR_OFFSET];

                set PERI_MS_PPU_PR4_MS_SIZE_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (4 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_MS_SIZE_OFFSET];

                set PERI_MS_PPU_PR4_MS_ATT0_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (4 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_MS_ATT0_OFFSET];

                set PERI_MS_PPU_PR4_MS_ATT1_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (4 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_MS_ATT1_OFFSET];

                set PERI_MS_PPU_PR4_MS_ATT2_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (4 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_MS_ATT2_OFFSET];

                set PERI_MS_PPU_PR4_MS_ATT3_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (4 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_MS_ATT3_OFFSET];  

               

                # 1. Configure programmable PPU 5 to protect CM0_NMI_CTL

                set PERI_MS_PPU_PR5_SL_ADDR_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (5 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_SL_ADDR_OFFSET];

                set PERI_MS_PPU_PR5_SL_SIZE_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (5 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_SL_SIZE_OFFSET];

                set PERI_MS_PPU_PR5_SL_ATT0_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (5 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_SL_ATT0_OFFSET];

                set PERI_MS_PPU_PR5_SL_ATT1_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (5 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_SL_ATT1_OFFSET];

                set PERI_MS_PPU_PR5_SL_ATT2_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (5 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_SL_ATT2_OFFSET];

                set PERI_MS_PPU_PR5_SL_ATT3_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (5 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_SL_ATT3_OFFSET];

                set PERI_MS_PPU_PR5_MS_ADDR_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (5 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_MS_ADDR_OFFSET];

                set PERI_MS_PPU_PR5_MS_SIZE_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (5 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_MS_SIZE_OFFSET];

                set PERI_MS_PPU_PR5_MS_ATT0_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (5 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_MS_ATT0_OFFSET];

                set PERI_MS_PPU_PR5_MS_ATT1_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (5 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_MS_ATT1_OFFSET];

                set PERI_MS_PPU_PR5_MS_ATT2_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (5 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_MS_ATT2_OFFSET];

                set PERI_MS_PPU_PR5_MS_ATT3_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (5 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_MS_ATT3_OFFSET];

 

                # 2. Configure programmable PPU 6 to protect MBIST_CTL

                set PERI_MS_PPU_PR6_SL_ADDR_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (6 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_SL_ADDR_OFFSET];

                set PERI_MS_PPU_PR6_SL_SIZE_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (6 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_SL_SIZE_OFFSET];

                set PERI_MS_PPU_PR6_SL_ATT0_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (6 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_SL_ATT0_OFFSET];

                set PERI_MS_PPU_PR6_SL_ATT1_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (6 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_SL_ATT1_OFFSET];

                set PERI_MS_PPU_PR6_SL_ATT2_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (6 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_SL_ATT2_OFFSET];

                set PERI_MS_PPU_PR6_SL_ATT3_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (6 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_SL_ATT3_OFFSET];

                set PERI_MS_PPU_PR6_MS_ADDR_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (6 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_MS_ADDR_OFFSET];

                set PERI_MS_PPU_PR6_MS_SIZE_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (6 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_MS_SIZE_OFFSET];

                set PERI_MS_PPU_PR6_MS_ATT0_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (6 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_MS_ATT0_OFFSET];

                set PERI_MS_PPU_PR6_MS_ATT1_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (6 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_MS_ATT1_OFFSET];

                set PERI_MS_PPU_PR6_MS_ATT2_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (6 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_MS_ATT2_OFFSET];

                set PERI_MS_PPU_PR6_MS_ATT3_ADDR  [expr $PERI_MS_PPU_PR_BASE_ADDR + (6 * $PERI_MS_PPU_PR_SIZE) + $PERI_MS_PPU_PR_MS_ATT3_OFFSET];                       

  

                # 3. Configure fixed PPU 6 to protect SMPU

                set PERI_MS_PPU_FX55_SL_ADDR_ADDR  0x400115C0;

                set PERI_MS_PPU_FX55_SL_SIZE_ADDR  0x400115C4;

                set PERI_MS_PPU_FX55_SL_ATT0_ADDR  0x400115D0;

                set PERI_MS_PPU_FX55_SL_ATT1_ADDR  0x400115D4;

                set PERI_MS_PPU_FX55_SL_ATT2_ADDR  0x400115D8;

                set PERI_MS_PPU_FX55_SL_ATT3_ADDR  0x400115DC;

                set PERI_MS_PPU_FX55_MS_ADDR_ADDR  0x400115E0;

                set PERI_MS_PPU_FX55_MS_SIZE_ADDR  0x400115E4;

                set PERI_MS_PPU_FX55_MS_ATT0_ADDR  0x400115F0;

                set PERI_MS_PPU_FX55_MS_ATT1_ADDR  0x400115F4;

                set PERI_MS_PPU_FX55_MS_ATT2_ADDR  0x400115F8;

                set PERI_MS_PPU_FX55_MS_ATT3_ADDR  0x400115FC;  