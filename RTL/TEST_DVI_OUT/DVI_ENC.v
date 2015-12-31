//DIV_ENC.v
//      DIV_ENC()
//
//
// base from vvvvvv
// http://sa89a.net/mp.cgi/ele/fpga_hdmi.htm
//
//151228mo      :retruct TMDS encoder  base sa89a mod
//151019mo      :add CKE
//                1st.


//             TDMS = {R,G,B}
module DVI_ENC( 
          input          CK
        , input         XAR
        , input         CKE_i
        , input [ 7 :0] DAT_R_i
        , input [ 7 :0] DAT_G_i
        , input [ 7 :0] DAT_B_i
        , input         DE_i
        , input         HD_i
        , input         VD_i
        , output [29 :0] TMDS_o
);

        wire [9 :0] QQA_R ;
        wire [9 :0] QQA_G ;
        wire [9 :0] QQA_B ;
        TMDS_ENC ENC_R(
                  CK
                , XAR
                , CKE_i
                , DAT_R_i
                , 1'b0
                , 1'b0
                , DE_i
                , QQA_R
        ) ;
        TMDS_ENC ENC_G(
                  CK
                , XAR
                , CKE_i
                , DAT_G_i
                , 1'b0 
                , 1'b0 
                , DE_i
                , QQA_G
        ) ;
        TMDS_ENC ENC_B(
                  CK
                , XAR
                , CKE_i
                , DAT_B_i
                , HD_i          //C0
                , VD_i          //C1
                , DE_i
                , QQA_B
        ) ;

        assign TMDS_o = {QQA_R , QQA_G , QQA_B} ;

endmodule // DVI_ENC()

module TMDS_ENC(
          input         CK 
        , input         XAR
        , input         CKE_i
        , input [ 7 :0] D_i
        , input         C0_i    //HD
        , input         C1_i    //VD
        , input         DE_i
        , output[ 9 :0] QQ_o
) ;
        function [ 4 :0] f_num_1_count ;
                input   [ 7 :0] NUM     ;
                integer         i       ;
        begin
                f_num_1_count = 0 ;
                for (i=0 ; i<8 ; i=i+1)
                        f_num_1_count = f_num_1_count + NUM[ i ] ;
        end endfunction 


        wire    [ 3 :0] n1_d ;
//        assign n1_d = 4'd0 +D_i[7]+D_i[6]+D_i[5]+D_i[4]+D_i[3]+D_i[2]+D_i[1]+D_i[0] ;
        assign n1_d = f_num_1_count( D_i ) ;
  

        wire    [ 4 :0] n1_qm   ;
        reg     [ 8 :0] Q_M     ;
//        assign n1_qm = 5'd0 + Q_M[7] + Q_M[6] + Q_M[5] + Q_M[4] + Q_M[3] + Q_M[2] + Q_M[1] + Q_M[0] ;
        assign n1_qm = f_num_1_count( Q_M ) ;


        //stage1
        reg                     DE_D    ;
        reg                     C0_D    ;
        reg                     C1_D    ;
        always @ (posedge CK or negedge XAR)
                if ( ~ XAR ) begin
                        Q_M <= 'd0 ;
                        DE_D <= 'd0 ;
                        C0_D <= 1'b0 ;
                        C1_D <= 1'b0 ;
                end else if ( CKE_i ) begin
                        if(
                                (n1_d > 4'd4)
                                ||
                                (
                                        (n1_d == 4'd4)
                                        &&
                                        ( ! D_i[0])
                                )
                        ) begin
                                Q_M[0] <= D_i[0];
                                Q_M[1] <= D_i[0]~^D_i[1];
                                Q_M[2] <= D_i[0]~^D_i[1]~^D_i[2];
                                Q_M[3] <= D_i[0]~^D_i[1]~^D_i[2]~^D_i[3];
                                Q_M[4] <= D_i[0]~^D_i[1]~^D_i[2]~^D_i[3]~^D_i[4];
                                Q_M[5] <= D_i[0]~^D_i[1]~^D_i[2]~^D_i[3]~^D_i[4]~^D_i[5];
                                Q_M[6] <= D_i[0]~^D_i[1]~^D_i[2]~^D_i[3]~^D_i[4]~^D_i[5]~^D_i[6];
                                Q_M[7] <= D_i[0]~^D_i[1]~^D_i[2]~^D_i[3]~^D_i[4]~^D_i[5]~^D_i[6]~^D_i[7];
                                Q_M[8] <= 1'b0;
                        end else begin
                                Q_M[0] <= D_i[0];
                                Q_M[1] <= D_i[0]^D_i[1];
                                Q_M[2] <= D_i[0]^D_i[1]^D_i[2];
                                Q_M[3] <= D_i[0]^D_i[1]^D_i[2]^D_i[3];
                                Q_M[4] <= D_i[0]^D_i[1]^D_i[2]^D_i[3]^D_i[4];
                                Q_M[5] <= D_i[0]^D_i[1]^D_i[2]^D_i[3]^D_i[4]^D_i[5];
                                Q_M[6] <= D_i[0]^D_i[1]^D_i[2]^D_i[3]^D_i[4]^D_i[5]^D_i[6];
                                Q_M[7] <= D_i[0]^D_i[1]^D_i[2]^D_i[3]^D_i[4]^D_i[5]^D_i[6]^D_i[7];
                                Q_M[8] <= 1'b1;
                        end //if
                        DE_D <= DE_i ;
                        C0_D <= C0_i ;
                        C1_D <= C1_i ;
                end //CKE_i


        //stage2
        reg             [ 9 :0] QQ              ;
        reg signed      [ 4 :0] CNT             ;
        always @ (posedge CK or negedge XAR)
                if ( ~ XAR ) begin
                        CNT <= 'd0 ;
                        QQ <=  'd0 ;
                end else if ( CKE_i) begin
                        if ( ~ DE_D) begin
                                CNT <= 5'sd0 ;
                                case( {C1_D , C0_D} )
                                        2'b00 : QQ <= 10'b11_01_01_01_00 ;
                                        2'b01 : QQ <= 10'b00_10_10_10_11 ;
                                        2'b10 : QQ <= 10'b01_01_01_01_00 ;
                                        2'b11 : QQ <= 10'b10_10_10_10_11 ;
                                endcase
                        end else begin
                                if((CNT == 5'sd0) || (n1_qm == 5'd4)) begin
                                        QQ <= { 
                                                  ~ Q_M[8]
                                                , Q_M[8]
                                                , (
                                                        Q_M[8] ? 
                                                                Q_M[ 7 :0] 
                                                        : 
                                                                ~ Q_M[ 7 :0]
                                                )
                                        } ;
                                        if ( Q_M[ 8 ])
                                                CNT <= CNT + (n1_qm + n1_qm - 5'd8);
                                        else
                                                CNT <= CNT + (5'd8 - n1_qm - n1_qm);
                                end else if (
                                        (
                                                (CNT > 5'sd0)
                                                &
                                                (n1_qm > 5'd4)
                                        )|(
                                                (CNT < 5'sd0)
                                                &
                                                (n1_qm < 5'd4)
                                        )
                                ) begin
                                        QQ <= {1'b1 , Q_M[8] , ~ Q_M[7:0]} ;
                                        CNT <= 
                                                  CNT 
                                                + {3'b0 , Q_M[8] , 1'b0} 
                                                + (5'd8 - n1_qm - n1_qm)
                                        ;
                                end else begin
                                        QQ <= {1'b0 , Q_M[8] , Q_M[7:0]} ;
                                        CNT <= 
                                                  CNT 
                                                - {3'b0 , ~Q_M[8] , 1'b0} 
                                                + (n1_qm + n1_qm - 5'd8)
                                        ;
                                end
                        end
                end
        assign QQ_o = QQ ;

endmodule // TMDS_ENC()

