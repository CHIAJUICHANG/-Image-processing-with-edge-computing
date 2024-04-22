`define BIT_W           8
`define IN_IMAGE_W      576     // 8bits*9*2*4
`define IN_KERNAL_W     576     // 8*9*2*4
`define IN_BIAS_W       15      // 8+7  
`define OUT_DATA_W      32      // 8*4   

`define PE_IMAGE_W      144     // 8bits*(3*3*2)
`define PE_KERNAL_W     144     // 8bits*(3*3*2)*
`define PE_BIAS_W       16      // 8bits*(2) 
`define PE_OUT_W        16      // 8+7 

`define REG_IMAGE_W     576     // 8bits*(3*3*2)*(2*2)
`define REG_KERNAL_W    576     // 8bits*(3*3)*(8)
`define REG_BIAS_W      16      // 8bits*(2)
`define REG_OUT_W       16      // 8bits*(2) 

`define PTR_IMAGE_W     10
`define PTR_KERNAL_W    10
`define PTR_BIAS_W      4
`define PTR_OUT_W       4



`define CONV_2x48x48        0
`define CONV_4x24x24        1
`define CONV_1x12x12        2
`define BN_2x48x48          3
`define BN_4x24x24          4
`define BN_1x12x12          5
`define POOL_2x24x24        6
`define POOL_4x12x12        7
`define POOL_1x6x6          8
`define LINEAR              9

module core (
    input                   i_clk,
    input                   i_rst_n,
    input                   i_trig,
    input  [4-1:0]          i_opcode,
    input  [`BIT_W-1:0]     i_image,
    input  [`BIT_W-1:0]     i_kernal,
    input  [`BIT_W-1:0]     i_bias,
    output                  o_valid,
    output                  o_data
);

// ---------------------------------------------------------------------------
// Parameter
// ---------------------------------------------------------------------------
localparam IDLE     = 3'd0;     // Initialization
localparam IF       = 3'd1;     // Instruction Fetch
localparam ID       = 3'd2;     // Instruction Decoder
localparam EX       = 3'd3;     // Execution
localparam WB       = 3'd4;     // Write Back
localparam DONE     = 3'd5;     // Finish

localparam INIT_MAX = 8'b1000_0000;


// ---------------------------------------------------------------------------
// Declaration
// ---------------------------------------------------------------------------
reg  [3-1:0] state;
reg  [3-1:0] state_nxt;

wire         image_wd_en, kernal_wd_en, bias_wd_en;
wire         image_wd_en_2, kernal_wd_en_2, bias_wd_en_2;
wire         out_wd_en, out_rd_en;


wire [`PE_IMAGE_W-1:0 ] pe_image_0, pe_image_1, pe_image_2, pe_image_3, pe_image_4, pe_image_5, pe_image_6, pe_image_7;
wire [`PE_KERNAL_W-1:0] pe_kernal_0,  pe_kernal_1,  pe_kernal_2,  pe_kernal_3, pe_kernal_4,  pe_kernal_5,  pe_kernal_6,  pe_kernal_7;
wire [`PE_BIAS_W-1:0  ] pe_bias_0, pe_bias_1, pe_bias_2, pe_bias_3, pe_bias_4, pe_bias_5, pe_bias_6, pe_bias_7;
wire [`PE_OUT_W-1:0   ] pe_result_0, pe_result_1, pe_result_2, pe_result_3, pe_result_4, pe_result_5, pe_result_6, pe_result_7;

wire [`BIT_WIDTH-1:0] kernal_00;
wire [`BIT_WIDTH-1:0] kernal_01;
wire [`BIT_WIDTH-1:0] kernal_10;
wire [`BIT_WIDTH-1:0] kernal_11;
reg  [`BIT_WIDTH-1:0] kernal_max;
reg  [`BIT_WIDTH-1:0] local_max0;
reg  [`BIT_WIDTH-1:0] local_max1;



// ---------------------------------------------------------------------------
// Instantiation
// ---------------------------------------------------------------------------
// assign pe_clk =(pe_counter == 7) ~pe_clk;

// always@(posedge i_clk or negedge i_rst_n) begin
//     if(~i_rst_n) begin
//         pe_counter <= 0;
//     end else begin
//         pe_counter <= pe_counter+1;
//     end
// end

pe pe_u0 (
    .i_clk      (i_clk      ),
    .i_rst_n    (i_rst_n    ),
    .pe_image   (pe_image_0 ),
    .pe_kernal  (pe_kernal_0),
    // .pe_bias      (pe_bias_0   ),
    .pe_result  (pe_result_0)
);

pe pe_u1 (
    .i_clk      (i_clk      ),
    .i_rst_n    (i_rst_n    ),
    .pe_image   (pe_image_1 ),
    .pe_kernal  (pe_kernal_1),
    // .pe_bias      (pe_bias_1   ),
    .pe_result  (pe_result_1)
);

pe pe_u2 (
    .i_clk      (i_clk      ),
    .i_rst_n    (i_rst_n    ),
    .pe_image   (pe_image_2 ),
    .pe_kernal  (pe_kernal_2),
    // .pe_bias      (pe_bias_2   ),
    .pe_result  (pe_result_2)
);

pe pe_u3 (
    .i_clk      (i_clk      ),
    .i_rst_n    (i_rst_n    ),
    .pe_image   (pe_image_3  ),
    .pe_kernal  (pe_kernal_3 ),
    // .i_bias      (pe_bias_3   ),
    .pe_result  (pe_result_3)
);

pool pool_u0 (
	.kernal_00      (pe_result_0),
    .kernal_01      (pe_result_1),
    .kernal_10      (pe_result_2),
    .kernal_11      (pe_result_3),
	.pool_result    (pool_result_0)
);

pool pool_u1 (
	.kernal_00      (pe_result_4),
    .kernal_01      (pe_result_5),
    .kernal_10      (pe_result_6),
    .kernal_11      (pe_result_7),
	.pool_result    (pool_result_1)
);

// pool pool_u2 (
// 	.kernal_00      (kernal_00),
//     .kernal_01      (kernal_01),
//     .kernal_10      (kernal_10),
//     .kernal_11      (kernal_11),
// 	.pool_result    (pool_result_2)
// );

// pool pool_u3 (
// 	.kernal_00      (kernal_00),
//     .kernal_01      (kernal_01),
//     .kernal_10      (kernal_10),
//     .kernal_11      (kernal_11),
// 	.pool_result    (pool_result_3)
// );

// pe pe_u4 (
//     .i_clk      (i_clk      ),
//     .i_rst_n    (i_rst_n    ),
//     .pe_image   (pe_image_4 ),
//     .pe_kernal  (pe_kernal_4),
//     // .pe_bias      (pe_bias_4   ),
//     .pe_result  (pe_result_4)
// );

// pe pe_u5 (
//     .i_clk      (i_clk      ),
//     .i_rst_n    (i_rst_n    ),
//     .pe_image   (pe_image_5 ),
//     .pe_kernal  (pe_kernal_5),
//     // .pe_bias      (pe_bias_5   ),
//     .pe_result  (pe_result_5)
// );

// pe pe_u6 (
//     .i_clk      (i_clk      ),
//     .i_rst_n    (i_rst_n    ),
//     .pe_image   (pe_image_6 ),
//     .pe_kernal  (pe_kernal_6),
//     // .pe_bias      (pe_bias_6   ),
//     .pe_result  (pe_result_6)
// );

// pe pe_u7 (
//     .i_clk      (i_clk      ),
//     .i_rst_n    (i_rst_n    ),
//     .pe_image   (pe_image_7  ),
//     .pe_kernal  (pe_kernal_7 ),
//     // .i_bias      (pe_bias_7   ),
//     .pe_result  (pe_result_7)
// );


// ---------------------------------------------------------------------------
// Finite State Machine
// ---------------------------------------------------------------------------
always@(*) begin
    case(state)
        IDLE: state_nxt = IF;

        IF: state_nxt = ID;

        ID: state_nxt = EX;

        EX: state_nxt = WB;

        WB: state_nxt = DONE;

        DONE: state_nxt  = IDLE;
    endcase
end

always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)    state <= IDLE;
    else            state <= state_nxt;
end


// ---------------------------------------------------------------------------
// Controller
// ---------------------------------------------------------------------------
reg        state, state_nxt;
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        state <= 0;
    end if else begin
        state <= state_nxt;
    end
end

reg        busy;
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        busy <= 0;
    end if else(i_trig) begin
        busy <= 1;
    end
end


reg [7:0] wd_cnt;
reg        wd_cnt_en;
reg        wd_cnt_rst;
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        wd_cnt <= 0;
    end else if(wd_cnt_en) begin
        wd_cnt <= wd_cnt + 1;
    end else if(wd_cnt_rst) begin
        wd_cnt <= 1;
    end else begin
        wd_cnt <= 0;
    end
end


reg [7:0] ex_cnt;
reg        ex_cnt_en;
reg        ex_cnt_rst;
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        ex_cnt <= 0;
    end else if(ex_cnt_en) begin
        ex_cnt <= wd_cnt + 1;
    end else if(ex_cnt_rst) begin
        ex_cnt <= 1;
    end else begin
        ex_cnt <= 0;
    end
end


reg [10:0] rd_cnt;
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        rd_cnt <= 0;
    end else begin
        rd_cnt <= rd_cnt + 1;
    end
end

reg [] pix_cnt;

always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        pix_cnt <= 0;
    end else begin
        pix_cnt <= pix_cnt + 1;
    end
end

reg [] change_line_cnt;
always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        change_line_cnt <= 0;
    end else begin
        change_line_cnt <= change_line_cnt + 1;
    end
end


// ---------------------------------------------------------------------------
// Input DFF
// ---------------------------------------------------------------------------
// Image Data Register
reg  [`PTR_IMAGE_W-1:0]     image_addr;
reg  [`REG_IMAGE_W-1:0]     image_reg;

always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)            image_reg <= 0;
    else if(image_wd_en)    image_reg[image_addr+:8] <= i_image; 
end

always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)            image_addr <= 0;
    else if(image_wd_en)    image_addr <= image_addr + 8;
end

// Kernal Data Register
reg  [`PTR_KERNAL_W-1:0]    kernal_addr;
reg  [`REG_KERNAL_W-1:0]    kernal_reg;

always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)            kernal_reg <= 0;
    else if(kernal_wd_en)   kernal_reg[image_addr+:8] <= i_kernal; 
end

always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)            kernal_addr <= 0;
    else if(kernal_wd_en)   kernal_addr <= kernal_addr + 8;
end

// Bias Data Register
reg  [`PTR_BIAS_W-1:0]      bias_addr;
reg  [`REG_BIAS_W-1:0]      bias_reg;

always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)            bias_reg <= 0;
    else if(bias_wd_en)     bias_reg[image_addr+:8] <= i_bias; 
end

always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)            bias_addr <= 0;
    else if(bias_wd_en)     bias_addr <= bias_addr + 8;
end

// ---------------------------------------------------------------------------
// Input Buffer
// ---------------------------------------------------------------------------
// Image Data Register
// reg  [`PTR_IMAGE_W-1:0]         image_addr_2;
reg  [`REG_IMAGE_W-1:0]         image_reg_2;

always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)                image_reg_2 <= 0;
    else if(image_wd_en_2)      image_reg_2 <= image_reg; 
end

// always@(posedge i_clk or negedge i_rst_n) begin
//     if(~i_rst_n)                image_addr_2 <= 0;
//     else if(image_wd_en_2)      image_addr_2 <= image_addr_2 + 8;
// end

// Kernal Data Register
// reg  [`PTR_KERNAL_W-1:0]        kernal_addr_2;
reg  [`REG_KERNAL_W-1:0]        kernal_reg_2;

always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)                kernal_reg_2 <= 0;
    else if(kernal_wd_en_2)     kernal_reg_2 <= kernal_reg; 
end

// always@(posedge i_clk or negedge i_rst_n) begin
//     if(~i_rst_n)                kernal_addr_2 <= 0;
//     else if(kernal_wd_en_2)     kernal_addr_2 <= kernal_addr_2 + 8;
// end

// Bias Data Register
// reg  [`PTR_BIAS_W-1:0]          bias_addr_2;
reg  [`REG_BIAS_W-1:0]          bias_reg_2;

always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)                bias_reg_2 <= 0;
    else if(bias_wd_en_2)       bias_reg_2 <= bias_reg; 
end

// always@(posedge i_clk or negedge i_rst_n) begin
//     if(~i_rst_n)                bias_addr_2 <= 0;
//     else if(bias_wd_en_2)       bias_addr_2 <= bias_addr_2 + 8;
// end


// ---------------------------------------------------------------------------
// Instuction Decoder
// ---------------------------------------------------------------------------
assign kernal_wd_en = (state == 3'd1)? 1: 0;
assign image_wd_en = (state == 3'd2)? 1: 0;
assign bias_wd_en = (state == 3'd3)? 1: 0;

always@(*) begin
    case(i_opcode)
        `CONV_1x32x32: begin
            case(state)
                3'd0: state_nxt = (i_trig)? 3'd1: 3'd0;

                3'd1: begin
                    state_nxt = (wd_cnt < 9)? 3'd1: 3'd2;
                    wd_cnt_en =  1;
                    wd_cnt_rst = (wd_cnt == 9)? 1: 0;

                    image_wd_en = 1;

                    ex_cnt_en = (image_wd_en_2)? 1: 0;
                end

                3'd2: begin
                    state_nxt = (  wd_cnt < 72)? 3'd2:

                    wd_cnt_en = 1;
                    wd_cnt_rst = (wd_cnt == 72)? 1: 0;

                    image_wd_en = 1;


                end

                3'd3: begin
                    state_nxt = (  wd_cnt < 2)? 3'd3;
                                (line_cnt < 16)? 3'd1:
                                                 3'd4;
                    wd_cnt_en = 1;
                    wd_cnt_rst = (wd_cnt == 2)? 1: 0;

                    image_wd_en_2 = (wd_cnt == 2)? 1: 0;
                    kernal_wd_en_2 = (wd_cnt == 2)? 1: 0;
                    bias_wd_en_2 = (wd_cnt == 2)? 1: 0;

                    ex_cnt_rst = (image_wd_en_2)? 1: 0;
                end

                3'd4: begin
                    state_nxt = 3'd0;
                end
            endcase
            

        end

        `CONV_4x16x16: begin

        end

        `CONV_8x8x8: begin

        end

        `LIEANR: begin

        end

        // `BN_2x48x48: begin

        // end

        // `BN_4x24x24: begin

        // end

        // `BN_1x12x12: begin

        // end

        // `POOL_2x24x24: begin

        // end

        // `POOL_4x12x12: begin

        // end

        // `POOL_1x6x6: begin

        // end

        // `LINEAR: begin

        // end

    endcase
end


// ---------------------------------------------------------------------------
// Execution
// ---------------------------------------------------------------------------

// Convolution
assign {pe_image_0, pe_image_1, pe_image_2, pe_image_3, pe_image_4, pe_image_5, pe_image_6, pe_image_7} = image_reg_2;
assign {pe_kernal_0,  pe_kernal_1,  pe_kernal_2,  pe_kernal_3, pe_kernal_4,  pe_kernal_5,  pe_kernal_6,  pe_kernal_7} = kernal_reg_2;
assign {pe_bias_0, pe_bias_1, pe_bias_2, pe_bias_3, pe_bias_4, pe_bias_5, pe_bias_6, pe_bias_7} = {bias_reg_2[31:16], bias_reg_2[31:16], bias_reg_2[31:16], bias_reg_2[31:16], bias_reg_2[15:0], bias_reg_2[15:0], bias_reg_2[15:0], bias_reg_2[15:0]} 

// Max Pooling

// ---------------------------------------------------------------------------
// Write Back
// ---------------------------------------------------------------------------
// Output Buffer
reg  [`PTR_OUT_W-1:0]           out_addr;
reg  [`REG_OUT_W-1:0]           out_reg;

assign o_data = (out_rd_en_2)? out_reg[out_addr+:8]: 0;

always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)                out_reg <= 0;
    else if(out_wd_en)        out_reg <= {pool_result_0, pool_result_1}; 
end

always@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)                out_addr <= 0;
    else if(out_rd_en)        out_addr <= out_addr + 8;
end

endmodule