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




/* =======================REG & wire================================ */
reg  signed [data_size-1:0] data_o_w, data_o_r;
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
reg         [3:0] channel_count, next_channel_count;
reg  signed [3:0] x_axis       , next_x_axis;
reg  signed [3:0] y_axis       , next_y_axis;
reg  signed [6:0] x_image      , next_x_image;
reg  signed [6:0] y_image      , next_y_image;
reg         [3:0] state        , next_state;
reg  signed [7:0] max_out      , next_max;
reg  signed [9:0] conv_out;
wire signed [143:0] pe_image1  , pe_image2  , pe_image3  , pe_image4 ;
wire signed [143:0] pe_kernel1 , pe_kernel2 , pe_kernel3 , pe_kernel4;
wire signed [7:0]   pe_result1 , pe_result2 , pe_result3 , pe_result4; 

reg        o_valid_w, o_valid_r;
integer    i, j;


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
                         i_image6[x_axis][y_axis  ], i_image6[x_axis+1][y_axis  ], i_image2[x_axis+2][y_axis  ], 
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

/* ====================Combinational Part================== */
always@ (*)
begin
    next_max   = 0;
    o_valid_w  = 0;
    data_o_w   = 0;
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
                if (x_image == 0)
                begin
                    if (channel_count == 1)
                    begin
                        next_i_image1[x_axis][y_axis] = i_data[ 7:0];
                        next_i_image1[x_axis+1][y_axis] = i_data[15:8];
                    end
                    else if (channel_count == 2)
                    begin
                        next_i_image2[x_axis][y_axis] = i_data[ 7:0];
                        next_i_image2[x_axis+1][y_axis] = i_data[15:8];
                    end
                    else if (channel_count == 3)
                    begin
                        next_i_image3[x_axis][y_axis] = i_data[ 7:0];
                        next_i_image3[x_axis+1][y_axis] = i_data[15:8];
                    end
                    else if (channel_count == 4)
                    begin
                        next_i_image4[x_axis][y_axis] = i_data[ 7:0];
                        next_i_image4[x_axis+1][y_axis] = i_data[15:8];
                    end
                    else if (channel_count == 5)
                    begin
                        next_i_image5[x_axis][y_axis] = i_data[ 7:0];
                        next_i_image5[x_axis+1][y_axis] = i_data[15:8];
                    end
                    else if (channel_count == 6)
                    begin
                        next_i_image6[x_axis][y_axis] = i_data[ 7:0];
                        next_i_image6[x_axis+1][y_axis] = i_data[15:8];
                    end
                    else if (channel_count == 7)
                    begin
                        next_i_image7[x_axis][y_axis] = i_data[ 7:0];
                        next_i_image7[x_axis+1][y_axis] = i_data[15:8];
                    end
                    else if (channel_count == 8)
                    begin
                        next_i_image8[x_axis][y_axis] = i_data[ 7:0];
                        next_i_image8[x_axis+1][y_axis] = i_data[15:8];
                    end
                end 
                else
                begin
                    for (i = 0; i < 2; i = i + 1) 
                    begin
                        for (j = 0; j < 4; j = j + 1)
                        begin
                            next_i_image1[i][j] = i_image1[i+2][j];
                            next_i_image2[i][j] = i_image2[i+2][j];
                            next_i_image3[i][j] = i_image3[i+2][j];
                            next_i_image4[i][j] = i_image4[i+2][j];
                            next_i_image5[i][j] = i_image5[i+2][j];
                            next_i_image6[i][j] = i_image6[i+2][j];
                            next_i_image7[i][j] = i_image7[i+2][j];
                            next_i_image8[i][j] = i_image8[i+2][j];
                        end
                    end
                    if (channel_count == 1)
                    begin
                        next_i_image1[x_axis+2][y_axis] = i_data;
                    end
                    else if (channel_count == 2)
                    begin
                        next_i_image2[x_axis+2][y_axis] = i_data;
                    end
                    else if (channel_count == 3)
                    begin
                        next_i_image3[x_axis+2][y_axis] = i_data;
                    end
                    else if (channel_count == 4)
                    begin
                        next_i_image4[x_axis+2][y_axis] = i_data;
                    end
                    else if (channel_count == 5)
                    begin
                        next_i_image5[x_axis+2][y_axis] = i_data;
                    end
                    else if (channel_count == 6)
                    begin
                        next_i_image6[x_axis+2][y_axis] = i_data;
                    end
                    else if (channel_count == 7)
                    begin
                        next_i_image7[x_axis+2][y_axis] = i_data;
                    end
                    else if (channel_count == 8)
                    begin
                        next_i_image8[x_axis+2][y_axis] = i_data;
                    end
                end 
            end
        end
        mul_plse:
        begin
            next_max      = max_out;
            conv_out      = pe_result1 + pe_result2 + pe_result3 + pe_result4;
            // conv_out      = kernel1[1][0] + i_image1[1][0];
            if (conv_out > max_out ) next_max = conv_out[9:2];
            if ((x_axis == 1) && (y_axis == 1))
            begin
                o_valid_w = 1;
                data_o_w   = next_max; 
            end
        end
    endcase
end

/* ====================Control Part================== */
always@ (*)
begin
    next_x_axis        = x_axis;
    next_y_axis        = y_axis;
    next_state         = state;
    next_x_image       = x_image;
    next_y_image       = y_image;
    next_channel_count = channel_count;
    case(state)
        idle:
        begin
            next_state         = kernel_in;
            next_channel_count = 1;
        end
        kernel_in:      // kernel = 3*3*8, 1 data/cycle, total need 72 cycles 
        begin
            if (i_valid) 
            begin
                if (channel_count != 8)     // channel = 1~7
                begin
                    next_x_axis = x_axis+1;
                    if (x_axis == 2)        // x_size = 3, bound = 2
                    begin
                        next_x_axis = 0;
                        if (y_axis == 2)    // y_size = 3, bound = 2
                        begin 
                            next_y_axis        = 0;
                            next_channel_count = channel_count+1;
                        end
                        else
                            next_y_axis = y_axis+1;  
                    end  
                end
                else 
                begin
                    next_x_axis = x_axis+1;
                    if (x_axis == 2)        // x_size = 3, bound = 2
                    begin
                        next_x_axis = 0;
                        if (y_axis == 2)    // y_size = 3, bound = 2, last channel
                        begin 
                            next_y_axis        = 0;
                            next_channel_count = 1;
                            next_state         = image_in;
                        end
                        else
                            next_y_axis = y_axis+1;  
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
                    if (channel_count != 8)
                    begin
                        next_x_axis = x_axis+2;
                        if (x_axis == 2)    // 2 input
                        begin
                            next_x_axis = 0;
                            if (y_axis == 3)
                            begin 
                                next_y_axis        = 0;
                                next_channel_count = channel_count+1;
                            end
                            else
                                next_y_axis = y_axis+1;  
                        end  
                    end
                    else
                    begin
                        next_x_axis = x_axis+2;
                        if (x_axis == 2)    // 2 input
                        begin
                            next_x_axis = 0;
                            if (y_axis == 3)
                            begin 
                                next_y_axis        = 0;
                                next_channel_count = 1;
                                next_state         = mul_plse;
                            end
                            else
                                next_y_axis = y_axis+1;  
                        end
                    end
                end 
                else
                begin
                    if (channel_count != 8)
                    begin
                        next_x_axis = x_axis+2;
                        if (x_axis == 2)
                        begin
                            next_x_axis = 0;
                            if (y_axis == 3)
                            begin 
                                next_y_axis        = 0;
                                next_channel_count = channel_count+1;
                            end
                            else
                                next_y_axis = y_axis+1;  
                        end  
                    end
                    else
                    begin
                        next_x_axis = x_axis+2;
                        if (x_axis == 2)
                        begin
                            next_x_axis = 0;
                            if (y_axis == 3)
                            begin 
                                next_y_axis        = 0;
                                next_channel_count = 1;
                                next_state         = mul_plse;
                            end
                            else
                                next_y_axis = y_axis+1;  
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
                if (x_image == 32)      // output shape
                begin
                    next_x_image = 0;
                    next_y_image = y_image+2;
                    if (y_image == 32)  // output shape
                    begin
                        next_y_image = 0;
                        next_state   = idle;
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
        data_o_r      <= 0;
        o_valid_r     <= 0;
        state         <= 1;
        x_axis        <= 0;
        y_axis        <= 0;
        x_image       <= 0;
        y_image       <= 0;
        channel_count <= 1;
        max_out       <= 0; 
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
        data_o_r      <= data_o_w;
        o_valid_r     <= o_valid_w;
        state         <= next_state;
        x_axis        <= next_x_axis;
        y_axis        <= next_y_axis;
        x_image       <= next_x_image;
        y_image       <= next_y_image;
        channel_count <= next_channel_count;  
        max_out       <= next_max; 
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