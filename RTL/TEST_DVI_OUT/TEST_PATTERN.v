// TEST_PATTERN.v
//      TEST_PATTERN()
//
//
//151230we      :fix H post amble 50->60
//151222tu      :mod to 720x480p
//               add BLANK
//               add CKE
//151020tu      :    1st. mod coding rule
//              base  form http://sa89a.net/mp.cgi/ele/fpga_hdmi.htm


module TEST_PATTERN(
          input                 CK
        , input                 XAR
        , input                 CKE_i
        , output [ 7 :0]        QQ_R_o
        , output [ 7 :0]        QQ_G_o
        , output [ 7 :0]        QQ_B_o
        , output                DEN_o
        , output                HD_o
        , output                VD_o
        , output                XH_BLANK_o
        , output                XV_BLANK_o
        , output [15 :0]        H_CTR_o
        , output [15 :0]        V_CTR_o
        , output [ 7 :0]        F_CTR_o
);

        //720x480p (858x525)
        parameter [15 :0]    C_HSYNC_LEN     =   16'd62;
        parameter [15 :0]    C_H_POST_AMBLE  =   16'd60;
        parameter [15 :0]    C_H_SIZE        =  16'd720;
        parameter [15 :0]    C_H_PRE_AMBLE   =   16'd16;
        parameter            C_HD_POL        =        1;
        
        parameter [15 :0]    C_VSYNC_LEN     =    16'd6;
        parameter [15 :0]    C_V_POST_AMBLE  =   16'd30;
        parameter [15 :0]    C_V_SIZE        =  16'd480;
        parameter [15 :0]    C_V_PRE_AMBLE   =    16'd9;
        parameter            C_VD_POL        =     1'b1;

        //720p
//        parameter [15 :0]    C_HSYNC_LEN     =   16'd40;
//        parameter [15 :0]    C_H_POST_AMBLE  =  16'd220;
//        parameter [15 :0]    C_H_SIZE        = 16'd1280;
//        parameter [15 :0]    C_H_PRE_AMBLE   =  16'd110;
//        parameter            C_HD_POL        =        1;
//        
//        parameter [15 :0]    C_VSYNC_LEN     =    16'd5;
//        parameter [15 :0]    C_V_POST_AMBLE  =   16'd20;
//        parameter [15 :0]    C_V_SIZE        =  16'd720;
//        parameter [15 :0]    C_V_PRE_AMBLE   =    16'd5;
//        parameter            C_VD_POL        =     1'b1;

        //XGA
//        parameter [15:0] C_HSYNC_LEN = 16'd136;
//        parameter [15:0] C_H_POST_AMBLE   = 16'd160;
//        parameter [15:0] C_H_SIZE = 16'd1024;
//        parameter [15:0] C_H_PRE_AMBLE   = 16'd24;
//        parameter C_HD_POL   = 0;
//
//        parameter [15:0] C_VSYNC_LEN = 16'd6;
//        parameter [15:0] C_V_POST_AMBLE   = 16'd29;
//        parameter [15:0] C_V_SIZE = 16'd768;
//        parameter [15:0] C_V_PRE_AMBLE   = 16'd3;
//        parameter C_VD_POL   = 1'b0;

        //VGA
//        parameter [15:0] C_HSYNC_LEN = 16'd96;
//        parameter [15:0] C_H_POST_AMBLE   = 16'd48;
//        parameter [15:0] C_H_SIZE = 16'd640;
//        parameter [15:0] C_H_PRE_AMBLE   = 16'd16;
//        parameter C_HD_POL   = 0;
//
//        parameter [15:0] C_VSYNC_LEN = 16'd2;
//        parameter [15:0] C_V_POST_AMBLE   = 16'd33;
//        parameter [15:0] C_V_SIZE = 16'd480;
//        parameter [15:0] C_V_PRE_AMBLE   = 16'd10;
//        parameter C_VD_POL   = 1'b0;

        reg     [15 :0] H_CTR   ;
        reg     [15 :0] V_CTR   ;
        reg     [ 7 :0] F_CTR   ;
        reg     [ 7 :0] QQ_R    ;
        reg     [ 7 :0] QQ_G    ;
        reg     [ 7 :0] QQ_B    ;
        reg             DEN     ;

        // main part
        wire            H_DEN_a ;
        wire            V_DEN_a ;
        wire            DEN_a   ;
        assign H_DEN_a = (
                (C_HSYNC_LEN + C_H_POST_AMBLE) <= H_CTR 
                && 
                H_CTR < (C_HSYNC_LEN + C_H_POST_AMBLE + C_H_SIZE)
        ) ;
        assign V_DEN_a = (
                (C_VSYNC_LEN+C_V_POST_AMBLE) <= V_CTR 
                && 
                V_CTR < (C_VSYNC_LEN + C_V_POST_AMBLE + C_V_SIZE)
        ) ;
        reg             XH_BLANK      ;
        reg             XV_BLANK      ;
        always @ (posedge CK or negedge XAR)
                if ( ~ XAR ) begin
                        XH_BLANK <= 1'b0 ;
                        XV_BLANK <= 1'b0 ;
                end else begin
                        XH_BLANK <= H_DEN_a ;
                        XV_BLANK <= V_DEN_a ;
                end
        assign XH_BLANK_o = XH_BLANK ;
        assign XV_BLANK_o = XV_BLANK ;
        assign DEN_a = H_DEN_a & V_DEN_a ;
        always @ (posedge CK , negedge XAR)
                if ( ~ XAR ) begin
                        DEN  <= 'd0 ;
                        QQ_R <= 'd0 ;
                        QQ_R <= 'd0 ;
                        QQ_R <= 'd0 ;
                end else if ( CKE_i ) begin
                        DEN <= DEN_a ;
                        if ( DEN_a ) begin
                                QQ_R <= 8'hFF & (
                                           H_CTR 
                                        - C_HSYNC_LEN 
                                        - C_H_POST_AMBLE 
                                        + F_CTR
                                ) ;
                                QQ_G <= 8'hFF & (
                                          V_CTR 
                                        - C_VSYNC_LEN 
                                        - C_V_POST_AMBLE 
                                        + F_CTR
                                ) ;
                                QQ_B <= {8{1'b1}} & (
                                        H_CTR - C_HSYNC_LEN - C_H_POST_AMBLE
                                        + V_CTR - C_VSYNC_LEN - C_V_POST_AMBLE
                                        - F_CTR
                                ) ;
                        end else begin
                                QQ_R <= 'd0 ;
                                QQ_G <= 'd0 ;
                                QQ_B <= 'd0 ;
                        end
                end
        assign QQ_R_o = QQ_R ;
        assign QQ_G_o = QQ_G ;
        assign QQ_B_o = QQ_B ;
        assign DEN_o  = DEN  ;


        // ctl ctr
        wire            H_cy    ;
        wire            V_cy    ;
        assign H_cy = (
                H_CTR 
                >= 
                (
                          C_HSYNC_LEN 
                        + C_H_POST_AMBLE 
                        + C_H_SIZE 
                        + C_H_PRE_AMBLE 
                        - 16'd1
                )
        ) ;
        assign V_cy = (
                V_CTR 
                >=
                (
                        C_VSYNC_LEN 
                        + C_V_POST_AMBLE 
                        + C_V_SIZE 
                        + C_V_PRE_AMBLE 
                        - 16'd1
                )
        ) ;
        always @ (posedge CK or negedge XAR)
                if ( ~ XAR ) begin
                        H_CTR <= 'd0 ;
                        V_CTR <= 'd0 ;
                        F_CTR <= 'd0 ;
                end else if ( CKE_i ) begin
                        if ( ~ H_cy ) begin
                                H_CTR <= H_CTR + 1'b1 ;
                        end else begin
                                H_CTR <= 16'd0 ;
                                if ( ~ V_cy )
                                        V_CTR <= V_CTR + 1'b1 ;
                                else begin
                                        V_CTR <= 16'd0 ;
                                        F_CTR <= F_CTR + 1'b1 ;
                                end
                        end
                end
        assign H_CTR_o = H_CTR       ;
        assign V_CTR_o = V_CTR       ;
        assign F_CTR_o = F_CTR       ;


        // H/VD
        reg             HD      ;
        reg             VD      ;
        always @ (posedge CK or negedge XAR)
                if ( ~ XAR ) begin
                        HD <= C_HD_POL ;
                        VD <= C_VD_POL ;
                end else if ( CKE_i) begin
                        HD <= C_HD_POL ^ ~(H_CTR < C_HSYNC_LEN) ;
                        VD <= C_VD_POL ^ ~(V_CTR < C_VSYNC_LEN) ;
                end
        assign HD_o = HD ;
        assign VD_o = VD ;


endmodule
