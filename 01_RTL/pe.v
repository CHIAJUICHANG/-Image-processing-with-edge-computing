`define BIT_W               8
`define PE_IMAGE_W          144     // 8*9*2
`define PE_kernel_W         144     // 8*9*2
`define PE_BIAS_W           13      // 8+5
`define EXTEN_W             16      // 8*2
`define PE_OUT_W            8      // 8+8

module pe (
    input  [`PE_IMAGE_W-1:0]    pe_image,
    input  [`PE_kernel_W-1:0]   pe_kernel,
    output [`PE_OUT_W-1:0]      pe_result
);


// Declaration
wire signed [`BIT_W-1:0] image_000, image_001, image_002, image_010, image_011, image_012, image_020, image_021, image_022,
                         image_100, image_101, image_102, image_110, image_111, image_112, image_120, image_121, image_122;

wire signed [`BIT_W-1:0] kernel_000, kernel_001, kernel_002, kernel_010, kernel_011, kernel_012, kernel_020, kernel_021, kernel_022,
                         kernel_100, kernel_101, kernel_102, kernel_110, kernel_111, kernel_112, kernel_120, kernel_121, kernel_122;

wire signed [`EXTEN_W-1:0] multi_ext_000, multi_ext_001, multi_ext_002, multi_ext_010, multi_ext_011, multi_ext_012, multi_ext_020, multi_ext_021, multi_ext_022,
                           multi_ext_100, multi_ext_101, multi_ext_102, multi_ext_110, multi_ext_111, multi_ext_112, multi_ext_120, multi_ext_121, multi_ext_122;

wire signed [`BIT_W-1:0] multi_000, multi_001, multi_002, multi_010, multi_011, multi_012, multi_020, multi_021, multi_022,
                         multi_100, multi_101, multi_102, multi_110, multi_111, multi_112, multi_120, multi_121, multi_122;

wire signed [(`BIT_W+5)-1:0] pe_result_ext;

// Assignment
assign {image_000, image_001, image_002, image_010, image_011, image_012, image_020, image_021, image_022,
        image_100, image_101, image_102, image_110, image_111, image_112, image_120, image_121, image_122} = pe_image;

assign {kernel_000, kernel_001, kernel_002, kernel_010, kernel_011, kernel_012, kernel_020, kernel_021, kernel_022,
        kernel_100, kernel_101, kernel_102, kernel_110, kernel_111, kernel_112, kernel_120, kernel_121, kernel_122} = pe_kernel;

// assign {bias_000, bias_001, bias_002, bias_010, bias_011, bias_012, bias_020, bias_021, bias_022,
//         bias_100, bias_101, bias_102, bias_110, bias_111, bias_112, bias_120, bias_121, bias_122} = i_bias;


// Multiplication
assign multi_ext_000 = image_000 * kernel_000;
assign multi_ext_001 = image_001 * kernel_001;
assign multi_ext_002 = image_002 * kernel_002;
assign multi_ext_010 = image_010 * kernel_010;
assign multi_ext_011 = image_011 * kernel_011;
assign multi_ext_012 = image_012 * kernel_012;
assign multi_ext_020 = image_020 * kernel_020;
assign multi_ext_021 = image_021 * kernel_021;
assign multi_ext_022 = image_022 * kernel_022;

assign multi_ext_100 = image_100 * kernel_100;
assign multi_ext_101 = image_101 * kernel_101;
assign multi_ext_102 = image_102 * kernel_102;
assign multi_ext_110 = image_110 * kernel_110;
assign multi_ext_111 = image_111 * kernel_111;
assign multi_ext_112 = image_112 * kernel_112;
assign multi_ext_120 = image_120 * kernel_120;
assign multi_ext_121 = image_121 * kernel_121;
assign multi_ext_122 = image_122 * kernel_122;


// Rounding
assign multi_000 = multi_ext_000[11:4];
assign multi_001 = multi_ext_001[11:4];
assign multi_002 = multi_ext_002[11:4];
assign multi_010 = multi_ext_010[11:4];
assign multi_011 = multi_ext_011[11:4];
assign multi_012 = multi_ext_012[11:4];
assign multi_020 = multi_ext_020[11:4];
assign multi_021 = multi_ext_021[11:4];
assign multi_022 = multi_ext_022[11:4];
assign multi_100 = multi_ext_100[11:4];
assign multi_101 = multi_ext_101[11:4];
assign multi_102 = multi_ext_102[11:4];
assign multi_110 = multi_ext_110[11:4];
assign multi_111 = multi_ext_111[11:4];
assign multi_112 = multi_ext_112[11:4];
assign multi_120 = multi_ext_120[11:4];
assign multi_121 = multi_ext_121[11:4];
assign multi_122 = multi_ext_122[11:4];

// Addition
assign pe_result_ext = (((multi_000 + multi_001) + (multi_002 + multi_010)) + ((multi_011 + multi_012) + (multi_020 + multi_021))) + (((multi_022 + multi_100) + (multi_101 + multi_102)) + ((multi_110 + multi_111) + (multi_112 + multi_120)))
                     + ((multi_121 + multi_122));  // + ((multi_121 + multi_122) + i_bias);


// reg [`BIT_W-1:0] o_pe_data_reg;
// always@(posedge i_clk or negedge i_rst_n) begin
//     if(~i_rst_n) begin
//         o_pe_data_reg <= 0 ;
//     end else begin
//         o_pe_data_reg <= pe_result_ext[7:0];
//     end
// end
// assign pe_result = o_pe_data_reg;

assign pe_result = pe_result_ext[7:0];

endmodule