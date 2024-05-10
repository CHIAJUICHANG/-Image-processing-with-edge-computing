module core(
            i_clk,
            i_rst,
            i_data,
            i_valid,
            o_data,
            o_valid
            );

/*========================IO declaration============================ */
input      i_clk;
input      i_rst;
input      i_valid;
output     o_valid;
input      [15:0] i_data;
output     [ 7:0] o_data;

parameter  data_size = 8;
parameter  H         = 4;
parameter  W         = 4;
parameter  idle      = 0;
parameter  kernel_in = 1;
parameter  image_in  = 2;
parameter  mul_plse  = 3;
parameter  linear    = 4;
parameter  ml_in     = 5;
parameter  ml_cal    = 6;

/* =======================REG & wire================================ */
reg         [7:0] data_o_w, data_o_r;
reg  signed [data_size-1:0] i_image1      [0:H-1][0:W-1];
reg  signed [data_size-1:0] i_image2      [0:H-1][0:W-1];
reg  signed [data_size-1:0] i_image3      [0:H-1][0:W-1];
reg  signed [data_size-1:0] i_image4      [0:H-1][0:W-1];
reg  signed [data_size-1:0] i_image5      [0:H-1][0:W-1];
reg  signed [data_size-1:0] i_image6      [0:H-1][0:W-1];
reg  signed [data_size-1:0] i_image7      [0:H-1][0:W-1];
reg  signed [data_size-1:0] i_image8      [0:H-1][0:W-1];
reg  signed [data_size-1:0] next_i_image1 [0:H-1][0:W-1];
reg  signed [data_size-1:0] next_i_image2 [0:H-1][0:W-1];
reg  signed [data_size-1:0] next_i_image3 [0:H-1][0:W-1];
reg  signed [data_size-1:0] next_i_image4 [0:H-1][0:W-1];
reg  signed [data_size-1:0] next_i_image5 [0:H-1][0:W-1];
reg  signed [data_size-1:0] next_i_image6 [0:H-1][0:W-1];
reg  signed [data_size-1:0] next_i_image7 [0:H-1][0:W-1];
reg  signed [data_size-1:0] next_i_image8 [0:H-1][0:W-1];
reg  signed [data_size-1:0] kernel1       [0:2][0:2];
reg  signed [data_size-1:0] kernel2       [0:2][0:2];
reg  signed [data_size-1:0] kernel3       [0:2][0:2];
reg  signed [data_size-1:0] kernel4       [0:2][0:2];
reg  signed [data_size-1:0] kernel5       [0:2][0:2];
reg  signed [data_size-1:0] kernel6       [0:2][0:2];
reg  signed [data_size-1:0] kernel7       [0:2][0:2];
reg  signed [data_size-1:0] kernel8       [0:2][0:2];
reg  signed [data_size-1:0] next_kernel1  [0:2][0:2];
reg  signed [data_size-1:0] next_kernel2  [0:2][0:2];
reg  signed [data_size-1:0] next_kernel3  [0:2][0:2];
reg  signed [data_size-1:0] next_kernel4  [0:2][0:2];
reg  signed [data_size-1:0] next_kernel5  [0:2][0:2];
reg  signed [data_size-1:0] next_kernel6  [0:2][0:2];
reg  signed [data_size-1:0] next_kernel7  [0:2][0:2];
reg  signed [data_size-1:0] next_kernel8  [0:2][0:2];
reg         [  3:0] channel_count, next_channel_count;
reg         [  1:0] x_axis       , next_x_axis;
reg         [  1:0] y_axis       , next_y_axis;
reg         [  5:0] x_image      , next_x_image;
reg         [  5:0] y_image      , next_y_image;
reg         [  2:0] state        , next_state;
reg  signed [ 22:0] max_out      , next_max;
reg  signed [ 22:0] conv_out;
reg         [  4:0] linear_count , next_linear_count;
reg         [  3:0] outcha_count , next_outcha_count;
reg         [  5:0] layer        , next_layer;
reg         [  3:0] max_new      , next_max_new;
reg         [  3:0] max_before   , next_max_before;
wire signed [143:0] pe_image1    , pe_image2  , pe_image3  , pe_image4 ;
wire signed [143:0] pe_kernel1   , pe_kernel2 , pe_kernel3 , pe_kernel4;
wire signed [ 20:0] pe_result1   , pe_result2 , pe_result3 , pe_result4; 
reg         o_valid_w, o_valid_r;

reg         [  2:0] next_kernel_z, kernel_z;
reg         [  1:0] next_kernel_y, kernel_y;
reg         [  1:0] next_kernel_x, kernel_x;
reg         [  3:0] next_kernel_channel = kernel_channel+1;
wire                o_trig       , o_trig_r   , o_trig_w;
wire                o_rd_rdy     , o_rd_rdy_r , o_rd_rdy_w;
wire        [159:0] o_y_hat   ;
wire signed [319:0] o_r       ;
wire                i_rd_vld  ;
wire signed [  8:0] i_llr     ;
wire                i_hard_bit;

integer     i, j;

pe PE_U1(
    .pe_image (pe_image1 ),
    .pe_kernel(pe_kernel1),
    .pe_result(pe_result1)
);
pe PE_U2(
    .pe_image (pe_image2 ),
    .pe_kernel(pe_kernel2),
    // i_bias,
    .pe_result(pe_result2)
);
pe PE_U3(
    .pe_image (pe_image3 ),
    .pe_kernel(pe_kernel3),
    // i_bias,
    .pe_result(pe_result3)
);
pe PE_U4(
    .pe_image (pe_image4 ),
    .pe_kernel(pe_kernel4),
    // i_bias,
    .pe_result(pe_result4)
);
ml_demodulator ML_U0(
    .i_clk      (i_clk     ),
    .i_reset    (i_rst     ),
    .i_trig     (o_trig    ),
    .i_y_hat    (o_y_hat   ),
    .i_r        (o_r       ),
    .i_rd_rdy   (o_rd_rdy  ),
    .o_rd_vld   (i_rd_vld  ),
    .o_llr      (i_llr     ),
    .o_hard_bit (i_hard_bit)
);

assign     pe_image1  = {i_image1[x_axis][y_axis  ], i_image1[x_axis+1][y_axis  ], i_image1[x_axis+2][y_axis  ], 
                         i_image1[x_axis][y_axis+1], i_image1[x_axis+1][y_axis+1], i_image1[x_axis+2][y_axis+1], 
                         i_image1[x_axis][y_axis+2], i_image1[x_axis+1][y_axis+2], i_image1[x_axis+2][y_axis+2],
                         i_image2[x_axis][y_axis  ], i_image2[x_axis+1][y_axis  ], i_image2[x_axis+2][y_axis  ], 
                         i_image2[x_axis][y_axis+1], i_image2[x_axis+1][y_axis+1], i_image2[x_axis+2][y_axis+1], 
                         i_image2[x_axis][y_axis+2], i_image2[x_axis+1][y_axis+2], i_image2[x_axis+2][y_axis+2]};
assign     pe_image2  = {i_image3[x_axis][y_axis  ], i_image3[x_axis+1][y_axis  ], i_image3[x_axis+2][y_axis  ], 
                         i_image3[x_axis][y_axis+1], i_image3[x_axis+1][y_axis+1], i_image3[x_axis+2][y_axis+1], 
                         i_image3[x_axis][y_axis+2], i_image3[x_axis+1][y_axis+2], i_image3[x_axis+2][y_axis+2],
                         i_image4[x_axis][y_axis  ], i_image4[x_axis+1][y_axis  ], i_image4[x_axis+2][y_axis  ], 
                         i_image4[x_axis][y_axis+1], i_image4[x_axis+1][y_axis+1], i_image4[x_axis+2][y_axis+1], 
                         i_image4[x_axis][y_axis+2], i_image4[x_axis+1][y_axis+2], i_image4[x_axis+2][y_axis+2]};
assign     pe_image3  = {i_image5[x_axis][y_axis  ], i_image5[x_axis+1][y_axis  ], i_image5[x_axis+2][y_axis  ], 
                         i_image5[x_axis][y_axis+1], i_image5[x_axis+1][y_axis+1], i_image5[x_axis+2][y_axis+1], 
                         i_image5[x_axis][y_axis+2], i_image5[x_axis+1][y_axis+2], i_image5[x_axis+2][y_axis+2],
                         i_image6[x_axis][y_axis  ], i_image6[x_axis+1][y_axis  ], i_image6[x_axis+2][y_axis  ], 
                         i_image6[x_axis][y_axis+1], i_image6[x_axis+1][y_axis+1], i_image6[x_axis+2][y_axis+1], 
                         i_image6[x_axis][y_axis+2], i_image6[x_axis+1][y_axis+2], i_image6[x_axis+2][y_axis+2]};
assign     pe_image4  = {i_image7[x_axis][y_axis  ], i_image7[x_axis+1][y_axis  ], i_image7[x_axis+2][y_axis  ], 
                         i_image7[x_axis][y_axis+1], i_image7[x_axis+1][y_axis+1], i_image7[x_axis+2][y_axis+1], 
                         i_image7[x_axis][y_axis+2], i_image7[x_axis+1][y_axis+2], i_image7[x_axis+2][y_axis+2],
                         i_image8[x_axis][y_axis  ], i_image8[x_axis+1][y_axis  ], i_image8[x_axis+2][y_axis  ], 
                         i_image8[x_axis][y_axis+1], i_image8[x_axis+1][y_axis+1], i_image8[x_axis+2][y_axis+1], 
                         i_image8[x_axis][y_axis+2], i_image8[x_axis+1][y_axis+2], i_image8[x_axis+2][y_axis+2]};
assign     pe_kernel1 = {kernel1 [0][0  ], kernel1 [0+1][0  ], kernel1 [0+2][0  ], 
                         kernel1 [0][0+1], kernel1 [0+1][0+1], kernel1 [0+2][0+1], 
                         kernel1 [0][0+2], kernel1 [0+1][0+2], kernel1 [0+2][0+2],
                         kernel2 [0][0  ], kernel2 [0+1][0  ], kernel2 [0+2][0  ], 
                         kernel2 [0][0+1], kernel2 [0+1][0+1], kernel2 [0+2][0+1], 
                         kernel2 [0][0+2], kernel2 [0+1][0+2], kernel2 [0+2][0+2]};
assign     pe_kernel2 = {kernel3 [0][0  ], kernel3 [0+1][0  ], kernel3 [0+2][0  ], 
                         kernel3 [0][0+1], kernel3 [0+1][0+1], kernel3 [0+2][0+1], 
                         kernel3 [0][0+2], kernel3 [0+1][0+2], kernel3 [0+2][0+2],
                         kernel4 [0][0  ], kernel4 [0+1][0  ], kernel4 [0+2][0  ], 
                         kernel4 [0][0+1], kernel4 [0+1][0+1], kernel4 [0+2][0+1], 
                         kernel4 [0][0+2], kernel4 [0+1][0+2], kernel4 [0+2][0+2]};
assign     pe_kernel3 = {kernel5 [0][0  ], kernel5 [0+1][0  ], kernel5 [0+2][0  ], 
                         kernel5 [0][0+1], kernel5 [0+1][0+1], kernel5 [0+2][0+1], 
                         kernel5 [0][0+2], kernel5 [0+1][0+2], kernel5 [0+2][0+2],
                         kernel6 [0][0  ], kernel6 [0+1][0  ], kernel6 [0+2][0  ], 
                         kernel6 [0][0+1], kernel6 [0+1][0+1], kernel6 [0+2][0+1], 
                         kernel6 [0][0+2], kernel6 [0+1][0+2], kernel6 [0+2][0+2]};
assign     pe_kernel4 = {kernel7 [0][0  ], kernel7 [0+1][0  ], kernel7 [0+2][0  ], 
                         kernel7 [0][0+1], kernel7 [0+1][0+1], kernel7 [0+2][0+1], 
                         kernel7 [0][0+2], kernel7 [0+1][0+2], kernel7 [0+2][0+2],
                         kernel8 [0][0  ], kernel8 [0+1][0  ], kernel8 [0+2][0  ], 
                         kernel8 [0][0+1], kernel8 [0+1][0+1], kernel8 [0+2][0+1], 
                         kernel8 [0][0+2], kernel8 [0+1][0+2], kernel8 [0+2][0+2]};
assign     o_data     = data_o_r;
assign     o_valid    = o_valid_r;

assign     o_y_hat    = {i_image1[0][0], i_image1[1][0], 
                         i_image1[0][1], i_image1[1][1],
                         i_image1[0][2], i_image1[1][2],
                         i_image1[0][3], i_image1[1][3],
                         i_image2[0][0], i_image2[1][0],
                         i_image2[0][1], i_image2[1][1],
                         i_image2[0][2], i_image2[1][2],
                         i_image2[0][3], i_image2[1][3],
                         i_image3[0][0], i_image3[1][0],
                         i_image3[0][1], i_image3[1][1]};
assign     o_r        = {i_image4[0][0], i_image4[1][0], 
                         i_image4[0][1], i_image4[1][1],
                         i_image4[0][2], i_image4[1][2],
                         i_image4[0][3], i_image4[1][3],
                         i_image5[0][0], i_image5[1][0],
                         i_image5[0][1], i_image5[1][1],
                         i_image5[0][2], i_image5[1][2],
                         i_image5[0][3], i_image5[1][3],
                         i_image6[0][0], i_image6[1][0],
                         i_image6[0][1], i_image6[1][1],
                         i_image6[0][2], i_image6[1][2],
                         i_image6[0][3], i_image6[1][3],
                         i_image7[0][0], i_image7[1][0],
                         i_image7[0][1], i_image7[1][1],
                         i_image7[0][2], i_image7[1][2],
                         i_image7[0][3], i_image7[1][3],
                         i_image8[0][0], i_image8[1][0],
                         i_image8[0][1], i_image8[1][1],
                         i_image8[0][2], i_image8[1][2],
                         i_image8[0][3], i_image8[1][3]};
assign     o_trig     = o_trig_r;
assign     o_rd_rdy   = 1;

/* ====================Combinational Part================== */
always@ (*)
begin
    next_max        = max_out;
    o_valid_w       = 0;
    data_o_w        = 0;
    next_max_new    = max_new;
    next_max_before = max_before;
    for (i = 0; i < 4; i = i + 1) 
    begin
        for (j = 0; j < 4; j = j + 1)
        begin
            next_i_image1[i][j] = i_image1[i][j];
            next_i_image2[i][j] = i_image2[i][j];
            next_i_image3[i][j] = i_image3[i][j];
            next_i_image4[i][j] = i_image4[i][j];
            next_i_image5[i][j] = i_image5[i][j];
            next_i_image6[i][j] = i_image6[i][j];
            next_i_image7[i][j] = i_image7[i][j];
            next_i_image8[i][j] = i_image8[i][j];
        end
    end
    for (i = 0; i < 3; i = i + 1) 
    begin
        for (j = 0; j < 3; j = j + 1)
        begin
            next_kernel1[i][j] = kernel1[i][j];
            next_kernel2[i][j] = kernel2[i][j];
            next_kernel3[i][j] = kernel3[i][j];
            next_kernel4[i][j] = kernel4[i][j];
            next_kernel5[i][j] = kernel5[i][j];
            next_kernel6[i][j] = kernel6[i][j];
            next_kernel7[i][j] = kernel7[i][j];
            next_kernel8[i][j] = kernel8[i][j];
        end
    end
    case(state)
        idle:
        begin
            next_max = 23'b100_0000_0000_0000_0000_0000; 
        end
        kernel_in:
        begin
            if (i_valid) 
            begin
                if (channel_count == 1)
                begin
                    next_kernel1[x_axis][y_axis] = i_data[7:0];
                end
                else if (channel_count == 2)
                begin
                    next_kernel2[x_axis][y_axis] = i_data[7:0];
                end
                else if (channel_count == 3)
                begin
                    next_kernel3[x_axis][y_axis] = i_data[7:0];
                end
                else if (channel_count == 4)
                begin
                    next_kernel4[x_axis][y_axis] = i_data[7:0];
                end
                else if (channel_count == 5)
                begin
                    next_kernel5[x_axis][y_axis] = i_data[7:0];
                end
                else if (channel_count == 6)
                begin
                    next_kernel6[x_axis][y_axis] = i_data[7:0];
                end
                else if (channel_count == 7)
                begin
                    next_kernel7[x_axis][y_axis] = i_data[7:0];
                end
                else if (channel_count == 8)
                begin
                    next_kernel8[x_axis][y_axis] = i_data[7:0];
                end
            end 
        end
        image_in:
        begin
            if (i_valid)
            begin
                if (x_image   == 0)
                begin
                    if (channel_count == 1)
                    begin
                        next_i_image1[x_axis  ][y_axis] = i_data[15:8];
                        next_i_image1[x_axis+1][y_axis] = i_data[ 7:0];
                    end
                    else if (channel_count == 2)
                    begin
                        next_i_image2[x_axis  ][y_axis] = i_data[15:8];
                        next_i_image2[x_axis+1][y_axis] = i_data[ 7:0];
                    end
                    else if (channel_count == 3)
                    begin
                        next_i_image3[x_axis  ][y_axis] = i_data[15:8];
                        next_i_image3[x_axis+1][y_axis] = i_data[ 7:0];
                    end
                    else if (channel_count == 4)
                    begin
                        next_i_image4[x_axis  ][y_axis] = i_data[15:8];
                        next_i_image4[x_axis+1][y_axis] = i_data[ 7:0];
                    end
                    else if (channel_count == 5)
                    begin
                        next_i_image5[x_axis  ][y_axis] = i_data[15:8];
                        next_i_image5[x_axis+1][y_axis] = i_data[ 7:0];
                    end
                    else if (channel_count == 6)
                    begin
                        next_i_image6[x_axis  ][y_axis] = i_data[15:8];
                        next_i_image6[x_axis+1][y_axis] = i_data[ 7:0];
                    end
                    else if (channel_count == 7)
                    begin
                        next_i_image7[x_axis  ][y_axis] = i_data[15:8];
                        next_i_image7[x_axis+1][y_axis] = i_data[ 7:0];
                    end
                    else if (channel_count == 8)
                    begin
                        next_i_image8[x_axis  ][y_axis] = i_data[15:8];
                        next_i_image8[x_axis+1][y_axis] = i_data[ 7:0];
                    end
                end 
                else
                begin
                    // for (i = 0; i < 2; i = i + 1) 
                    // begin
                    //     for (j = 0; j < 4; j = j + 1)
                    //     begin
                    //         next_i_image1[i][j] = i_image1[i+2][j];
                    //         next_i_image2[i][j] = i_image2[i+2][j];
                    //         next_i_image3[i][j] = i_image3[i+2][j];
                    //         next_i_image4[i][j] = i_image4[i+2][j];
                    //         next_i_image5[i][j] = i_image5[i+2][j];
                    //         next_i_image6[i][j] = i_image6[i+2][j];
                    //         next_i_image7[i][j] = i_image7[i+2][j];
                    //         next_i_image8[i][j] = i_image8[i+2][j];
                    //     end
                    // end
                    if (channel_count == 1)
                    begin
                        next_i_image1[x_axis  ][y_axis] = i_image1[x_axis+2][y_axis];
                        next_i_image1[x_axis+1][y_axis] = i_image1[x_axis+3][y_axis];
                        next_i_image1[x_axis+2][y_axis] = i_data[15:8];
                        next_i_image1[x_axis+3][y_axis] = i_data[ 7:0];
                    end
                    else if (channel_count == 2)
                    begin
                        next_i_image2[x_axis  ][y_axis] = i_image2[x_axis+2][y_axis];
                        next_i_image2[x_axis+1][y_axis] = i_image2[x_axis+3][y_axis];
                        next_i_image2[x_axis+2][y_axis] = i_data[15:8];
                        next_i_image2[x_axis+3][y_axis] = i_data[ 7:0];
                    end
                    else if (channel_count == 3)
                    begin
                        next_i_image3[x_axis  ][y_axis] = i_image3[x_axis+2][y_axis];
                        next_i_image3[x_axis+1][y_axis] = i_image3[x_axis+3][y_axis];
                        next_i_image3[x_axis+2][y_axis] = i_data[15:8];
                        next_i_image3[x_axis+3][y_axis] = i_data[ 7:0];
                    end
                    else if (channel_count == 4)
                    begin
                        next_i_image4[x_axis  ][y_axis] = i_image4[x_axis+2][y_axis];
                        next_i_image4[x_axis+1][y_axis] = i_image4[x_axis+3][y_axis];
                        next_i_image4[x_axis+2][y_axis] = i_data[15:8];
                        next_i_image4[x_axis+3][y_axis] = i_data[ 7:0];
                    end
                    else if (channel_count == 5)
                    begin
                        next_i_image5[x_axis  ][y_axis] = i_image5[x_axis+2][y_axis];
                        next_i_image5[x_axis+1][y_axis] = i_image5[x_axis+3][y_axis];
                        next_i_image5[x_axis+2][y_axis] = i_data[15:8];
                        next_i_image5[x_axis+3][y_axis] = i_data[ 7:0];
                    end
                    else if (channel_count == 6)
                    begin
                        next_i_image6[x_axis  ][y_axis] = i_image6[x_axis+2][y_axis];
                        next_i_image6[x_axis+1][y_axis] = i_image6[x_axis+3][y_axis];
                        next_i_image6[x_axis+2][y_axis] = i_data[15:8];
                        next_i_image6[x_axis+3][y_axis] = i_data[ 7:0];
                    end
                    else if (channel_count == 7)
                    begin
                        next_i_image7[x_axis  ][y_axis] = i_image7[x_axis+2][y_axis];
                        next_i_image7[x_axis+1][y_axis] = i_image7[x_axis+3][y_axis];
                        next_i_image7[x_axis+2][y_axis] = i_data[15:8];
                        next_i_image7[x_axis+3][y_axis] = i_data[ 7:0];
                    end
                    else if (channel_count == 8)
                    begin
                        next_i_image8[x_axis  ][y_axis] = i_image8[x_axis+2][y_axis];
                        next_i_image8[x_axis+1][y_axis] = i_image8[x_axis+3][y_axis];
                        next_i_image8[x_axis+2][y_axis] = i_data[15:8];
                        next_i_image8[x_axis+3][y_axis] = i_data[ 7:0];
                    end
                end 
                if (next_state == mul_plse ) next_max = 23'b100_0000_0000_0000_0000_0000;
                if (next_linear_count ==  1) 
                begin
                    next_max = 23'b100_0000_0000_0000_0000_0000;
                    next_max_new    = 0;
                    next_max_before = 0;
                end
                if (next_linear_count == 11)
                begin
                    next_max = 23'b100_0000_0000_0000_0000_0000;
                    next_max_new    = 0;
                    next_max_before = 0;
                end
                if (next_linear_count == 21)
                begin
                    next_max = 23'b100_0000_0000_0000_0000_0000;
                    next_max_new    = 0;
                    next_max_before = 0;
                end
                // if (next_linear_count == 30) next_max = 0;
            end
        end
        mul_plse:
        begin
            conv_out      = pe_result1 + pe_result2 + pe_result3 + pe_result4;
            if ((conv_out > max_out) && (conv_out[22] != 1)) next_max = conv_out;
            if ((conv_out > max_out) && (conv_out[22] != 1)) next_max = conv_out;
            if ((conv_out > max_out) && (conv_out[22] != 1)) next_max = conv_out;
            if ((x_axis == 1) && (y_axis == 1))
            begin
                o_valid_w = 1;
                if (layer == 30) data_o_w  = next_max[ 9:3]; 
                if (layer == 14) data_o_w  = next_max[14:7];
                if (layer ==  6) data_o_w  = next_max[14:7];
            end
        end
        linear:
        begin
            next_max_new  = max_new+1;
            conv_out      = pe_result1 + pe_result2 + pe_result3 + pe_result4;
            if (conv_out > max_out ) 
            begin
                next_max_before = max_new;
                next_max        = conv_out;
            end
            if (linear_count ==  10)
            begin
                o_valid_w = 1;
                data_o_w  = next_max_before;
            end
            if (linear_count == 20)
            begin
                o_valid_w = 1;
                data_o_w  = next_max_before;
            end
            if (linear_count == 30)
            begin
                o_valid_w = 1;
                data_o_w  = next_max_before;
            end
        end
        ml_in:
        begin
            if (i_valid)
            begin
                if (channel_count == 1)
                begin
                    next_i_image1[x_axis  ][y_axis] = i_data[15:8];
                    next_i_image1[x_axis+1][y_axis] = i_data[ 7:0];
                end
                else if (channel_count == 2)
                begin
                    next_i_image2[x_axis  ][y_axis] = i_data[15:8];
                    next_i_image2[x_axis+1][y_axis] = i_data[ 7:0];
                end
                else if (channel_count == 3)
                begin
                    next_i_image3[x_axis  ][y_axis] = i_data[15:8];
                    next_i_image3[x_axis+1][y_axis] = i_data[ 7:0];
                end
                else if (channel_count == 4)
                begin
                    next_i_image4[x_axis  ][y_axis] = i_data[15:8];
                    next_i_image4[x_axis+1][y_axis] = i_data[ 7:0];
                end
                else if (channel_count == 5)
                begin
                    next_i_image5[x_axis  ][y_axis] = i_data[15:8];
                    next_i_image5[x_axis+1][y_axis] = i_data[ 7:0];
                end
                else if (channel_count == 6)
                begin
                    next_i_image6[x_axis  ][y_axis] = i_data[15:8];
                    next_i_image6[x_axis+1][y_axis] = i_data[ 7:0];
                end
                else if (channel_count == 7)
                begin
                    next_i_image7[x_axis  ][y_axis] = i_data[15:8];
                    next_i_image7[x_axis+1][y_axis] = i_data[ 7:0];
                end
                else if (channel_count == 8)
                begin
                    next_i_image8[x_axis  ][y_axis] = i_data[15:8];
                    next_i_image8[x_axis+1][y_axis] = i_data[ 7:0];
                end
            end
        end
        ml_cal:
        begin
            if (i_rd_vld):
            begin
                if (kernel_channel == 1)
                begin
                    next_kernel1[kernel_x][kernel_y][kernel_z] = i_hard_bit;
                end
                else if (kernel_channel == 2)
                begin
                    next_kernel2[kernel_x][kernel_y][kernel_z] = i_hard_bit;
                end
                else if (kernel_channel == 3)
                begin
                    next_kernel3[kernel_x][kernel_y][kernel_z] = i_hard_bit;
                end
                else if (kernel_channel == 4)
                begin
                    next_kernel4[kernel_x][kernel_y][kernel_z] = i_hard_bit;
                end
                else if (kernel_channel == 5)
                begin
                    next_kernel5[kernel_x][kernel_y][kernel_z] = i_hard_bit;
                end
                else if (kernel_channel == 6)
                begin
                    next_kernel6[kernel_x][kernel_y][kernel_z] = i_hard_bit;
                end
                else if (kernel_channel == 7)
                begin
                    next_kernel7[kernel_x][kernel_y][kernel_z] = i_hard_bit;
                end
                else if (kernel_channel == 8)
                begin
                    next_kernel8[kernel_x][kernel_y][kernel_z] = i_hard_bit;
                end
            end
        end
    endcase
end

/* ====================Control Part================== */
always@ (*)
begin
    next_x_axis         = x_axis;
    next_y_axis         = y_axis;
    next_state          = state;
    next_x_image        = x_image;
    next_y_image        = y_image;
    next_channel_count  = channel_count;
    next_layer          = layer;
    next_linear_count   = linear_count;
    next_outcha_count   = outcha_count;
    o_trig_w            = 0;
    o_rd_rdy_r          = o_rd_rdy_w;
    next_kernel_x       = kernel_x;
    next_kernel_y       = kernel_y;
    next_kernel_z       = kernel_z;
    next_kernel_channel = kernel_channel;
    case(state)
        idle:
        begin
            next_state            = ml_in;
            next_x_axis           = 0;
            next_y_axis           = 0;
            next_x_image          = 0;
            next_y_image          = 0;
            next_channel_count    = 1;
            next_outcha_count     = outcha_count+1;
            if (layer == 0)
            begin 
                next_layer        = 30;
                next_outcha_count = 0;
            end
            if (layer == 30 && outcha_count == 3)
            begin 
                next_layer        = 14;
                next_outcha_count = 0;
            end
            if (layer == 14 && outcha_count == 7)
            begin 
                next_layer        = 6;
                next_outcha_count = 0;
            end
            if (layer ==  6 && outcha_count == 3) 
            begin
                next_layer        = 1;
                next_outcha_count = 0;
                next_linear_count = 1;
                next_state        = kernel_in;
            end
        end
        kernel_in:
        begin
            if (i_valid) 
            begin
                next_y_axis = y_axis+1;
                if (y_axis == 2)
                begin
                    next_y_axis = 0;
                    next_x_axis = x_axis+1; 
                    if (x_axis == 2)
                    begin 
                        next_x_axis        = 0;
                        next_channel_count = channel_count+1;
                        if (channel_count == 8)
                        begin
                            next_channel_count = 1;
                            next_state         = image_in;
                        end
                    end
                end  
            end 
        end
        image_in:       // image  = 4*4*8, 2 data/cycle, total need 64 or 32 cycles 
        begin
            if (i_valid)
            begin 
                if (x_image == 0)           // in first column
                begin
                    next_y_axis = y_axis+1;
                    if (y_axis == 3)    // 2 input
                    begin
                        next_x_axis = x_axis+2; 
                        next_y_axis = 0;
                        if (x_axis == 2)
                        begin 
                            next_x_axis            = 0;
                            next_channel_count     = channel_count+1;
                            if (channel_count == 8)
                            begin
                                next_channel_count = 1;
                                next_state         = mul_plse;
                                if (layer   == 1) next_state = linear;
                            end
                        end
                    end  
                end 
                else
                begin
                    next_y_axis = y_axis+1;
                    if (y_axis == 3)
                    begin
                        next_y_axis       = 0;
                        next_x_axis       = 0;
                        next_channel_count = channel_count+1;
                        if (channel_count == 8)
                        begin
                            next_channel_count    = 1;
                            next_state            = mul_plse;
                        end
                    end
                end
            end
        end
        mul_plse:       // 8 channel (1 output pixel)/cycle, 4 cycles 
        begin
            next_x_axis        = x_axis;
            next_y_axis        = y_axis;
            next_x_image       = x_image;
            next_y_image       = y_image;
            next_state         = mul_plse;
            if ((x_axis == 0) && (y_axis == 0))
            begin
                next_x_axis    = 1;
                next_y_axis    = 0;
            end
            else if ((x_axis == 1) && (y_axis == 0))
            begin
                next_x_axis    = 0;
                next_y_axis    = 1;
            end
            else if ((x_axis == 0) && (y_axis == 1))
            begin
                next_x_axis    = 1;
                next_y_axis    = 1;
            end
            else if ((x_axis == 1) && (y_axis == 1))
            begin
                next_x_axis    = 0;
                next_y_axis    = 0;
                next_state     = image_in;
                next_x_image   = x_image+2;
                if (x_image == layer)      // output shape
                begin
                    next_x_image = 0;
                    next_y_image = y_image+2;
                    if (y_image == layer)  // output shape
                    begin
                        next_y_image = 0;
                        next_state   = idle;
                    end
                end
            end
        end
        linear:
        begin
            next_state            = image_in;
            next_linear_count     = linear_count+1;
            if (linear_count == 30) 
            begin
                next_state        = idle;
                next_linear_count = 0;
            end
        end
        ml_in:          // input ml data
        begin
            if (i_valid)      
            begin
                next_y_axis = y_axis+1;
                if ((channel_count == 3) && (y_axis == 2))
                begin
                    next_y_axis        = 0;
                    next_channel_count = channel_count+1;
                end
                if (y_axis == 3)
                begin
                    next_y_axis        = 0;
                    next_channel_count = channel_count+1;
                    if (channel_count == 8) 
                    begin
                        next_channel_count = 1;
                        next_state         = ml_cal;
                        o_trig_w           = 1;
                    end
                end
            end    
        end
        ml_cal:
        begin
            if (i_rd_vld):
            begin
                next_state    = ml_in;
                next_kernel_z = kernel_z+1;
                if (kernel_z == 7)
                begin
                    next_kernel_z = 0;
                    next_kernel_y = kernel_y+1;
                    if (next_kernel_y = 2)
                    begin
                        next_kernel_y = 0;
                        next_kernel_x = kernel_x+1;
                        if (next_kernel_x = 2)
                        begin
                            next_kernel_x = 0;
                            next_kernel_channel = kernel_channel+1;
                            if (kernel_channel == 8)
                            begin
                                next_kernel_channel = 0;
                                next_y_axis         = 0;
                                next_x_axis         = 0;
                                next_channel_count  = 1;
                                next_state          = image_in;
                            end
                        end
                    end
                end
            end
        end
    endcase
end

/* ====================Seq Part================== */
always@(posedge i_clk or negedge i_rst)
begin
    if (!i_rst) 
    begin
        data_o_r       <= 0;
        o_valid_r      <= 0;
        state          <= 0;
        x_axis         <= 0;
        y_axis         <= 0;
        x_image        <= 0;
        y_image        <= 0;
        channel_count  <= 1;
        max_out        <= 0; 
        layer          <= 0;
        linear_count   <= 0;
        outcha_count   <= 0;
        max_new        <= 0;
        max_before     <= 0;
        o_rd_rdy_r     <= 0;
        o_trig_r       <= 0;
        kernel_x       <= 0;
        kernel_y       <= 0;
        kernel_z       <= 0;
        kernel_channel <= 0;
        for (i = 0; i < 3; i = i + 1) 
        begin
            for (j = 0; j < 3; j = j + 1)
            begin
                kernel1[i][j]  <= 0;
                kernel2[i][j]  <= 0;
                kernel3[i][j]  <= 0;
                kernel4[i][j]  <= 0;
                kernel5[i][j]  <= 0;
                kernel6[i][j]  <= 0;
                kernel7[i][j]  <= 0;
                kernel8[i][j]  <= 0;
            end
        end
        for (i = 0; i < 4; i = i + 1) 
        begin
            for (j = 0; j < 4; j = j + 1)
            begin           
                i_image1[i][j] <= 0;
                i_image2[i][j] <= 0;
                i_image3[i][j] <= 0;
                i_image4[i][j] <= 0;
                i_image5[i][j] <= 0;
                i_image6[i][j] <= 0;
                i_image7[i][j] <= 0;
                i_image8[i][j] <= 0;
            end
        end
    end  
    else 
    begin
        data_o_r       <= data_o_w;
        o_valid_r      <= o_valid_w;
        state          <= next_state;
        x_axis         <= next_x_axis;
        y_axis         <= next_y_axis;
        x_image        <= next_x_image;
        y_image        <= next_y_image;
        channel_count  <= next_channel_count;  
        max_out        <= next_max; 
        layer          <= next_layer;
        linear_count   <= next_linear_count;
        outcha_count   <= next_outcha_count;
        max_new        <= next_max_new;
        max_before     <= next_max_before;
        data_address   <= next_data_add;
        o_rd_rdy_r     <= o_rd_rdy_w;
        o_trig_r       <= o_trig_w;
        kernel_x       <= next_kernel_x;
        kernel_y       <= next_kernel_y;
        kernel_z       <= next_kernel_z;
        kernel_channel <= next_kernel_channel;
        for (i = 0; i < 3; i = i + 1) 
        begin
            for (j = 0; j < 3; j = j + 1)
            begin
                kernel1[i][j]  <= next_kernel1[i][j];
                kernel2[i][j]  <= next_kernel2[i][j];
                kernel3[i][j]  <= next_kernel3[i][j];
                kernel4[i][j]  <= next_kernel4[i][j];
                kernel5[i][j]  <= next_kernel5[i][j];
                kernel6[i][j]  <= next_kernel6[i][j];
                kernel7[i][j]  <= next_kernel7[i][j];
                kernel8[i][j]  <= next_kernel8[i][j];
            end
        end
        for (i = 0; i < 4; i = i + 1) 
        begin
            for (j = 0; j < 4; j = j + 1)
            begin           
                i_image1[i][j] <= next_i_image1[i][j];
                i_image2[i][j] <= next_i_image2[i][j];
                i_image3[i][j] <= next_i_image3[i][j];
                i_image4[i][j] <= next_i_image4[i][j];
                i_image5[i][j] <= next_i_image5[i][j];
                i_image6[i][j] <= next_i_image6[i][j];
                i_image7[i][j] <= next_i_image7[i][j];
                i_image8[i][j] <= next_i_image8[i][j];
            end
        end 
    end
end

endmodule