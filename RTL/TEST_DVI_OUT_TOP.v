//PULS_CTR_TOP.v
//      PLUS_CTR top
//      pulse counter 
//151228mo      :fix LVDS_TX pin num
//151226sa      :fix pin number 
// base Copyright (c) 2015 by Semillero ADT. 
//                     web: https://sites.google.com/site/semilleroadt/
//                     email: semilleroadtupb@gmail.com
// Major Functions: BE-MICRO MAX10 TOP
//

module TEST_DVI_OUT_TOP(
        //CLOCKS
          CLK_50M_i
        , CLK_USR_i

        //LED
        , LED_o

        //SW
        , PSW_i

        //FLASH
        , SFLASH_DCLK
        , SFLASH_ASDI
        , SFLASH_CSn
        , SFLASH_DATA

        //AD5681R
        , AD5681R_LDACn
        , AD5681R_RSTn
        , AD5681R_SCL
        , AD5681R_SDA
        , AD5681R_SYNCn

        //ACCELEROMETER
        , ADXL362_CSn
        , ADXL362_MISO
        , ADXL362_MOSI
        , ADXL362_SCLK
        , ADXL362_INT1
        , ADXL362_INT2

        //ADT7420 Temperature Sensor
        , ADT7420_CT
        , ADT7420_INT
        , ADT7420_SCL
        , ADT7420_SDA

        //SDRAM
        , SDRAM_A
        , SDRAM_BA
        , SDRAM_CASn
        , SDRAM_CKE
        , SDRAM_CLK
        , SDRAM_CSn
        , SDRAM_DQ
        , SDRAM_RASn
        , SDRAM_WEn
        , SDRAM_DQM


        //PMOD_[A:D]
        , PMOD_A_io
        , PMOD_B_io
        , PMOD_C_io
        , PMOD_D_io

        //GPIO_[0:2]/DIFF
//        , GPIO_0_io
//        , GPIO_1_io
//        , GPIO_2_io
        
        , LVDS_TX_o
) ;
        //CLOCKS
        input           CLK_50M_i          ;
        input           CLK_USR_i        ;

        //LED_o
        output [ 7 :0]  LED_o             ;

        //PSW_i
        input  [ 3 :0]  PSW_i              ;

        //FLASH
        output          SFLASH_DCLK     ;
        output          SFLASH_ASDI     ;
        output          SFLASH_CSn      ;
        input           SFLASH_DATA     ;

        //AD5681R
        output          AD5681R_LDACn   ;
        output          AD5681R_RSTn    ;
        output          AD5681R_SCL     ;
        output          AD5681R_SDA     ;
        output          AD5681R_SYNCn   ;

        //ACCELEROMETER
        output          ADXL362_CSn     ;
        input           ADXL362_MISO    ;
        output          ADXL362_MOSI    ;
        output          ADXL362_SCLK    ;
        input           ADXL362_INT1    ;
        input           ADXL362_INT2    ;

        //ADT7420 Temperature Sensor
        inout           ADT7420_SCL     ;
        inout           ADT7420_SDA     ;
        inout           ADT7420_CT      ;
        input           ADT7420_INT     ;


        //SDRAM
        output  [12 :0] SDRAM_A         ;
        output  [ 1 :0] SDRAM_BA        ;
        output          SDRAM_CASn      ;
        output          SDRAM_CKE       ;
        output          SDRAM_CLK       ;
        output          SDRAM_CSn       ;
        inout   [15 :0] SDRAM_DQ        ;
        output          SDRAM_RASn      ;
        output          SDRAM_WEn       ;
        output  [ 1 :0] SDRAM_DQM       ;


        //PMOD_[ A :D]
        inout   [ 3 :0] PMOD_A_io          ;
        inout   [ 3 :0] PMOD_B_io          ;
        inout   [ 3 :0] PMOD_C_io          ;
        inout   [ 3 :0] PMOD_D_io          ;

        //GPIO_[0:3]/DIFF
//        inout   [35 :0] GPIO_0_io          ;
//        inout   [25 :0] GPIO_1_io          ;
        //GPIO_2_io/EG
//        inout   [55 :0] GPIO_2_io          ;

        output  [ 3 :0] LVDS_TX_o          ;


        // start
        wire            CK_270M         ;
        wire            CK_135M         ;
        wire            CK_27M         ;
        wire            XAR             ;
        PLL u_PLL(
                  .inclk0       ( CLK_50M_i     )
                , .areset       ( 1'b0          )
                , .c0           ( CK_270M       )
                , .c1           ( CK_135M       )
                , .c2           ( CK_27M        )
                , .locked       ( XAR           )
        ) ;



        wire [ 7 :0] TMDS_SET           ;// {R,G,B,CK}
        wire [ 7 :0] TEST_DAT_R_o       ;
        wire [ 7 :0] TEST_DAT_G_o       ;
        wire [ 7 :0] TEST_DAT_B_o       ;
        wire            HD              ;
        wire            VD              ;
        wire            DEN             ;
        wire         XH_BLANK_o         ;
        wire         XV_BLANK_o         ;
        wire         CKE_27M_o          ;
        wire [ 2 :0] CK_PH_o            ;
        wire [15 :0] H_CTR_o            ;
        wire [15 :0] V_CTR_o            ;
        wire [ 7 :0] F_CTR_o            ;
        TEST_DVI_OUT TEST_DIV_OUT(
                  .CK           ( CK_135M       )
                , .XAR          ( XAR           )
                , .TMDS_SET_o   ( TMDS_SET      ) // {R,G,B,CK}
                , .TEST_DAT_R_o ( TEST_DAT_R_o  )
                , .TEST_DAT_G_o ( TEST_DAT_G_o  )
                , .TEST_DAT_B_o ( TEST_DAT_B_o  )
                , .HD_o         ( HD            )
                , .VD_o         ( VD            )
                , .DEN_o        ( DEN           )
                , .XH_BLANK_o   ( XH_BLANK_o    )
                , .XV_BLANK_o   ( XV_BLANK_o    )
                , .CKE_27M_o    ( CKE_27M_o     )
                , .CK_PH_o      ( CK_PH_o       )
                , .H_CTR_o      ( H_CTR_o       )
                , .V_CTR_o      ( V_CTR_o       )
                , .F_CTR_o      ( F_CTR_o       )
        ) ;
        // 
        wire [ 3 :0] DAT_1 ; // datain_l.datain_l
        wire [ 3 :0] DAT_0 ; // datain_h.datain_h
        generate
                genvar i ;
                for (i=0 ; i<4 ; i=i+1) begin : gen_HL_SEP
                        assign DAT_0[i] = TMDS_SET[i*2  ] ;
                        assign DAT_1[i] = TMDS_SET[i*2+1] ;
                end
        endgenerate
        // TMDS = {CK,R,G,B}
        wire    [ 3 :0] TMDS    ;
        SERIALIZER u_SERIALIZER(
                  .outclock     ( CK_135M       )
                , .datain_l     ( DAT_1         ) //later
                , .datain_h     ( DAT_0         ) //fast
                , .dataout      ( TMDS          )
        ) ;
        //        LVDS_TX_o           TMDS
        //J4-31 : TX3-          TX2-  2-      //Red
        //J4-32 : TX3+          TX2+  2       
        //J4-33 : GND           GND           
        //J4-34 : GND           GND           
        //J4-35 : TX2-          TX1-  1-      //Green
        //J4-36 : TX2+          TX1+  1       
        //J4-37 : TX1-          TX0-  0-      //Blue
        //J4-38 : TX1+          TX0+  0 
        //J4-39 : TX0-          CK-   3-      //ck
        //J4-40 : TX0+          CK+   3

        assign LVDS_TX_o[3] = TMDS[2] ;
        assign LVDS_TX_o[2] = TMDS[1] ;
        assign LVDS_TX_o[1] = TMDS[0] ;
        assign LVDS_TX_o[0] = TMDS[3] ;
        assign PMOD_A_io[0] = HD        ;
        assign PMOD_A_io[1] = VD        ;
        assign PMOD_A_io[2] = DEN        ;



endmodule // TEST_DVI_OUT_TOP
