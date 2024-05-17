module ml_demodulator(
    i_clk,
    i_reset,
    i_trig,
    i_y_hat,
    i_r,
    i_rd_rdy,
    o_rd_vld,
    o_llr,
    o_hard_bit
);

input            i_clk;
input            i_reset;
input            i_trig;
input  [160-1:0] i_y_hat;
input  [320-1:0] i_r;
input            i_rd_rdy;
output           o_rd_vld;
output [  8-1:0] o_llr;
output           o_hard_bit;

localparam INF = 10'b01_1111_1111;
// ---------------------------------------------------------------------------
// Declaration
// ---------------------------------------------------------------------------
reg            i_trig_d;
reg  [160-1:0] i_y_hat_d;
reg  [320-1:0] i_r_d;

reg  [  8-1:0] w_ptr, r_ptr;
reg  [256-1:0] buffer;

wire [  8-1:0] pattern0, pattern1, pattern2, pattern3;
wire [ 10-1:0] cal_result0, cal_result1, cal_result2, cal_result3;

wire           cal_done;
reg            busy;
reg            cnt1000;
reg  [  6-1:0] cycle_cnt;

wire signed [ 10-1:0] min_x42, min_x41, min_x32, min_x31, min_x22, min_x21;
wire signed [ 10-1:0] min_x42_n, min_x41_n, min_x32_n, min_x31_n, min_x22_n, min_x21_n;
wire signed [ 10-1:0] local_min, cal_min01, cal_min23, cal_min13, cal_min02;

wire signed [ 10-1:0] min_x42_1,   min_x41_1,   min_x32_1,   min_x31_1,   min_x22_1,   min_x21_1,   min_x12_1,   min_x11_1;
wire signed [ 10-1:0] min_x42_0,   min_x41_0,   min_x32_0,   min_x31_0,   min_x22_0,   min_x21_0,   min_x12_0,   min_x11_0;
reg  signed [ 10-1:0] min_x42_1_n, min_x41_1_n, min_x32_1_n, min_x31_1_n, min_x22_1_n, min_x21_1_n, min_x12_1_n, min_x11_1_n;
reg  signed [ 10-1:0] min_x42_0_n, min_x41_0_n, min_x32_0_n, min_x31_0_n, min_x22_0_n, min_x21_0_n, min_x12_0_n, min_x11_0_n;

wire signed [ 10-1:0] llr_x11, llr_x12, llr_x21, llr_x22, llr_x31, llr_x32, llr_x41, llr_x42;
wire                  hb_x11, hb_x12, hb_x21, hb_x22, hb_x31, hb_x32, hb_x41, hb_x42;

// ---------------------------------------------------------------------------
// Instantiation
// ---------------------------------------------------------------------------
cal CAL_U0 (
    .cal_x      (pattern0),
    .cal_y      (i_y_hat_d),
    .cal_r      (i_r_d),
    .cal_result (cal_result0)
); 
cal CAL_U1 (
    .cal_x      (pattern1),
    .cal_y      (i_y_hat_d),
    .cal_r      (i_r_d),
    .cal_result (cal_result1)
); 
cal CAL_U2 (
    .cal_x      (pattern2),
    .cal_y      (i_y_hat_d),
    .cal_r      (i_r_d),
    .cal_result (cal_result2)
); 
cal CAL_U3 (
    .cal_x      (pattern3),
    .cal_y      (i_y_hat_d),
    .cal_r      (i_r_d),
    .cal_result (cal_result3)
);

// ---------------------------------------------------------------------------
// Controller
// ---------------------------------------------------------------------------
assign cal_done = (busy && (cycle_cnt == 63))? 1: 0;

always@(posedge i_clk or posedge i_reset) begin
    if(i_reset)                 cycle_cnt <= 0;
    else if(busy)               cycle_cnt <= cycle_cnt+1;
end

always@(posedge i_clk or posedge i_reset) begin
    if(i_reset)                             busy <= 0;
    else if(i_trig)                         busy <= 1;
    else if(cycle_cnt == 63)                busy <= 0;
end


always@(posedge i_clk or posedge i_reset) begin
    if(i_reset)                             cnt1000 <= 0;
    else if ((!i_trig) && cal_done && busy) cnt1000 <= 0;
end


// ---------------------------------------------------------------------------
// Input DFF
// ---------------------------------------------------------------------------
always@(posedge i_clk or posedge i_reset) begin
    if(i_reset)         i_trig_d <= 0;
    else                i_trig_d <= i_trig;
end
always@(posedge i_clk or posedge i_reset) begin
    if(i_reset)         i_y_hat_d <= 0;
    else if(i_trig)     i_y_hat_d <= i_y_hat;
end
always@(posedge i_clk or posedge i_reset) begin
    if(i_reset)         i_r_d <= 0;
    else if(i_trig)     i_r_d <= i_r;
end

// ---------------------------------------------------------------------------
// Output Buffer
// ---------------------------------------------------------------------------
assign o_rd_vld   = (w_ptr != r_ptr)? 1: 0;
assign o_llr      = (o_rd_vld)? {buffer[r_ptr], 7'b0000001}: 0;
assign o_hard_bit = (o_rd_vld)? buffer[r_ptr]: 0;

always@(posedge i_clk or posedge i_reset) begin
    if(i_reset)                       buffer <= 0;
    else if(cal_done && (!cnt1000))   buffer[w_ptr+: 8] <= {hb_x42, hb_x41, hb_x32, hb_x31, hb_x22, hb_x21, hb_x12, hb_x11};
end

always@(posedge i_clk or posedge i_reset) begin
    if(i_reset)                       w_ptr <= 0;
    else if(cal_done && (!cnt1000))   w_ptr <= w_ptr + 8;
end

always@(posedge i_clk or posedge i_reset) begin
    if(i_reset)                       r_ptr <= 0;
    else if(o_rd_vld && i_rd_rdy)     r_ptr <= r_ptr + 1;
end

// ---------------------------------------------------------------------------
// QPSK Constellation Generator
// ---------------------------------------------------------------------------
assign pattern0 = {cycle_cnt, 2'b00};
assign pattern1 = {cycle_cnt, 2'b01};
assign pattern2 = {cycle_cnt, 2'b10};
assign pattern3 = {cycle_cnt, 2'b11};

// ---------------------------------------------------------------------------
// Comparator
// ---------------------------------------------------------------------------
assign cal_min01 = (cal_result0 < cal_result1)? cal_result0: cal_result1;
assign cal_min23 = (cal_result2 < cal_result3)? cal_result2: cal_result3;
assign cal_min13 = (cal_result1 < cal_result3)? cal_result1: cal_result3;
assign cal_min02 = (cal_result0 < cal_result2)? cal_result0: cal_result2;
assign local_min = (  cal_min01 < cal_min23  )? cal_min01  : cal_min23;
// x42
assign min_x42_n = (           cycle_cnt[5])? min_x42_1_n: min_x42_0_n;
assign min_x42   = (  min_x42_n < local_min)? min_x42_n  : local_min;
// x41
assign min_x41_n = (           cycle_cnt[4])? min_x41_1_n: min_x41_0_n;
assign min_x41   = (  min_x41_n < local_min)? min_x41_n  : local_min;
// x32
assign min_x32_n = (           cycle_cnt[3])? min_x32_1_n: min_x32_0_n;
assign min_x32   = (  min_x32_n < local_min)? min_x32_n  : local_min;
// x31
assign min_x31_n = (           cycle_cnt[2])? min_x31_1_n: min_x31_0_n;
assign min_x31   = (  min_x31_n < local_min)? min_x31_n  : local_min;
// x22
assign min_x22_n = (           cycle_cnt[1])? min_x22_1_n: min_x22_0_n;
assign min_x22   = (  min_x22_n < local_min)? min_x22_n  : local_min;
// x21
assign min_x21_n = (           cycle_cnt[0])? min_x21_1_n: min_x21_0_n;
assign min_x21   = (  min_x21_n < local_min)? min_x21_n  : local_min;
// x12
assign min_x12_1 = (min_x12_1_n < cal_min23)? min_x12_1_n: cal_min23;
assign min_x12_0 = (min_x12_0_n < cal_min01)? min_x12_0_n: cal_min01;
// x11
assign min_x11_1 = (min_x11_1_n < cal_min13)? min_x11_1_n: cal_min13;
assign min_x11_0 = (min_x11_0_n < cal_min02)? min_x11_0_n: cal_min02;

always@(posedge i_clk or posedge i_reset) begin
    if(i_reset) begin
        min_x42_1_n <= INF;
        min_x42_0_n <= INF;
        min_x41_1_n <= INF;
        min_x41_0_n <= INF;
        min_x32_1_n <= INF;
        min_x32_0_n <= INF;
        min_x31_1_n <= INF;
        min_x31_0_n <= INF;
        min_x22_1_n <= INF;
        min_x22_0_n <= INF;
        min_x21_1_n <= INF;
        min_x21_0_n <= INF;
        min_x12_1_n <= INF;
        min_x12_0_n <= INF;
        min_x11_1_n <= INF;
        min_x11_0_n <= INF;
    end else if(cal_done) begin
        min_x42_1_n <= INF;
        min_x42_0_n <= INF;
        min_x41_1_n <= INF;
        min_x41_0_n <= INF;
        min_x32_1_n <= INF;
        min_x32_0_n <= INF;
        min_x31_1_n <= INF;
        min_x31_0_n <= INF;
        min_x22_1_n <= INF;
        min_x22_0_n <= INF;
        min_x21_1_n <= INF;
        min_x21_0_n <= INF;
        min_x12_1_n <= INF;
        min_x12_0_n <= INF;
        min_x11_1_n <= INF;
        min_x11_0_n <= INF;
    end else if(i_trig_d || busy) begin
        min_x42_1_n <= ( cycle_cnt[5])? min_x42: min_x42_1_n;
        min_x42_0_n <= (~cycle_cnt[5])? min_x42: min_x42_0_n;
        min_x41_1_n <= ( cycle_cnt[4])? min_x41: min_x41_1_n;
        min_x41_0_n <= (~cycle_cnt[4])? min_x41: min_x41_0_n;
        min_x32_1_n <= ( cycle_cnt[3])? min_x32: min_x32_1_n;
        min_x32_0_n <= (~cycle_cnt[3])? min_x32: min_x32_0_n;
        min_x31_1_n <= ( cycle_cnt[2])? min_x31: min_x31_1_n;
        min_x31_0_n <= (~cycle_cnt[2])? min_x31: min_x31_0_n;
        min_x22_1_n <= ( cycle_cnt[1])? min_x22: min_x22_1_n;
        min_x22_0_n <= (~cycle_cnt[1])? min_x22: min_x22_0_n;
        min_x21_1_n <= ( cycle_cnt[0])? min_x21: min_x21_1_n;
        min_x21_0_n <= (~cycle_cnt[0])? min_x21: min_x21_0_n;
        min_x12_1_n <= min_x12_1;
        min_x12_0_n <= min_x12_0;
        min_x11_1_n <= min_x11_1;
        min_x11_0_n <= min_x11_0;
    end
end

// ---------------------------------------------------------------------------
// Log Likelihood Ratio & Hard Bit
// ---------------------------------------------------------------------------
assign min_x42_1 = ( cycle_cnt[5])? min_x42: min_x42_1_n;
assign min_x42_0 = (~cycle_cnt[5])? min_x42: min_x42_0_n;
assign min_x41_1 = ( cycle_cnt[4])? min_x41: min_x41_1_n;
assign min_x41_0 = (~cycle_cnt[4])? min_x41: min_x41_0_n;
assign min_x32_1 = ( cycle_cnt[3])? min_x32: min_x32_1_n;
assign min_x32_0 = (~cycle_cnt[3])? min_x32: min_x32_0_n;
assign min_x31_1 = ( cycle_cnt[2])? min_x31: min_x31_1_n;
assign min_x31_0 = (~cycle_cnt[2])? min_x31: min_x31_0_n;
assign min_x22_1 = ( cycle_cnt[1])? min_x22: min_x22_1_n;
assign min_x22_0 = (~cycle_cnt[1])? min_x22: min_x22_0_n;
assign min_x21_1 = ( cycle_cnt[0])? min_x21: min_x21_1_n;
assign min_x21_0 = (~cycle_cnt[0])? min_x21: min_x21_0_n;

assign llr_x42 = (cal_done)? (min_x42_1 - min_x42_0): 0;
assign llr_x41 = (cal_done)? (min_x41_1 - min_x41_0): 0;
assign llr_x32 = (cal_done)? (min_x32_1 - min_x32_0): 0;
assign llr_x31 = (cal_done)? (min_x31_1 - min_x31_0): 0;
assign llr_x22 = (cal_done)? (min_x22_1 - min_x22_0): 0;
assign llr_x21 = (cal_done)? (min_x21_1 - min_x21_0): 0;
assign llr_x12 = (cal_done)? (min_x12_1 - min_x12_0): 0;
assign llr_x11 = (cal_done)? (min_x11_1 - min_x11_0): 0;

assign hb_x42 = llr_x42[9];
assign hb_x41 = llr_x41[9];
assign hb_x32 = llr_x32[9];
assign hb_x31 = llr_x31[9];
assign hb_x22 = llr_x22[9];
assign hb_x21 = llr_x21[9];
assign hb_x12 = llr_x12[9];
assign hb_x11 = llr_x11[9];

endmodule




