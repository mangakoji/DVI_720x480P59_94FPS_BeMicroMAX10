// TEST_DVI_OUT.v
//      TEST_DVI_OUT()
//
//151226sa      :fix CK bit assign on TDMS
//               add comment TDMS bit assign
// 151128sa     :mod any point 720PX
// 151128sa     :mod view face not mod logical code by JA10YL
// Written by: Holguer A Becerra


module TEST_DVI_OUT(    
          input         CK
        , input         XAR
        , output[ 7 :0] TMDS_SET_o      // {CK,R,G,B}
        , output[ 7 :0] TEST_DAT_R_o
        , output[ 7 :0] TEST_DAT_G_o
        , output[ 7 :0] TEST_DAT_B_o
        , output        HD_o
        , output        VD_o
        , output        DEN_o
        , output        XH_BLANK_o
        , output        XV_BLANK_o
        , output        CKE_27M_o
        , output[ 2 :0] CK_PH_o
        , output[15 :0] H_CTR_o
        , output[15 :0] V_CTR_o
        , output[ 7 :0] F_CTR_o
) ;
        // log2() for calc bit width from data N
        // constant function on Verilog 2001
        function integer log2 ;
                input integer value ;
        begin
                value = value - 1 ;
                for (log2=0 ; value>0 ; log2=log2+1)
                        value = value>>1 ;
        end endfunction



        reg             CKE_27M         ;
        reg     [ 2 :0] CK_PH           ;
        always @ (posedge CK or negedge XAR)
                if ( ~ XAR ) begin
                        CK_PH <= 'd0 ;
                        CKE_27M <= 1'b1 ;
                end else begin
                        if (CK_PH == (5-1))
                                CK_PH <= 'd0 ;
                        else
                                CK_PH <= CK_PH + 'd1 ;
                        CKE_27M <= (CK_PH == (5-2)) ;
                end
        assign CK_PH_o   = CK_PH   ;
        assign CKE_27M_o = CKE_27M ;

        wire [ 7 :0] TEST_DAT_R ;
        wire [ 7 :0] TEST_DAT_G ;
        wire [ 7 :0] TEST_DAT_B ;
        wire            DEN     ;
        wire            HD      ;
        wire            VD      ;
        TEST_PATTERN u_TEST_PATTERN (
                  .CK           ( CK            )
                , .XAR          ( XAR           )
                , .CKE_i        ( CKE_27M       )
                , .QQ_R_o       ( TEST_DAT_R    )
                , .QQ_G_o       ( TEST_DAT_G    )
                , .QQ_B_o       ( TEST_DAT_B    )
                , .DEN_o        ( DEN           )
                , .HD_o         ( HD            )
                , .VD_o         ( VD            )
                , .XH_BLANK_o   ( XH_BLANK_o    )
                , .XV_BLANK_o   ( XV_BLANK_o    )
                , .H_CTR_o      ( H_CTR_o       )
                , .V_CTR_o      ( V_CTR_o       )
                , .F_CTR_o      ( F_CTR_o       )
        ) ; //TEST_PATTERN
        assign HD_o = HD ;
        assign VD_o = VD ;
        assign TEST_DAT_R_o = TEST_DAT_R ;
        assign TEST_DAT_G_o = TEST_DAT_G ;
        assign TEST_DAT_B_o = TEST_DAT_B ;


        //      TMDS = {R,G,B}
        wire    [29 :0] TMDS    ;
        DVI_ENC u_DVI_ENC ( 
                  .CK           ( CK            )
                , .XAR          ( XAR           )
                , .CKE_i        ( CKE_27M       )
                , .DAT_R_i      ( TEST_DAT_R    )
                , .DAT_G_i      ( TEST_DAT_G    )
                , .DAT_B_i      ( TEST_DAT_B    )
                , .DE_i         ( DEN           )
                , .HD_i         ( HD            ) //pol positive
                , .VD_i         ( VD            ) //pol positive
                , .TMDS_o       ( TMDS          )
        ) ;
        assign DEN_o = DEN ;

        //reverse bit order
        reg     [ 7 :0] TMDS_SET ;
        localparam C_CK_PATTERN = 10'b00000_11111 ;
        always @ (posedge CK or negedge XAR)
                if ( ~ XAR )
                        TMDS_SET <= 'd0 ;
                else begin
                        TMDS_SET[1:0] <= TMDS >> (CK_PH*2) ;
                        TMDS_SET[3:2] <= TMDS >> (CK_PH*2 +10) ;
                        TMDS_SET[5:4] <= TMDS >> (CK_PH*2 +20) ;
                        TMDS_SET[7:6] <= C_CK_PATTERN >> (CK_PH*2) ;
                end
        assign TMDS_SET_o = TMDS_SET ;
endmodule // TEST_DIV_OUT.v
