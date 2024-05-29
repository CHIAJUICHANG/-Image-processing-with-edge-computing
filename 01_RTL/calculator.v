module cal (
    input  [  8-1:0] cal_x,
    input  [ 64-1:0] cal_y,
    input  [128-1:0] cal_r,
    output [ 10-1:0] cal_result
);

wire                 x4_i,  x4_r,  x3_i,  x3_r,  x2_i,  x2_r,  x1_i,  x1_r;
wire signed [ 8-1:0] y4_i,  y4_r,  y3_i,  y3_r,  y2_i,  y2_r,  y1_i,  y1_r;
wire signed [ 8-1:0] r44_r, r34_i, r34_r, r24_i, r24_r, r14_i, r14_r, r33_r, r23_i, r23_r, r13_i, r13_r, r22_r, r12_i, r12_r, r11_r;

wire signed [13-1:0] y4_tmp_i, y4_tmp_r, y3_tmp_i, y3_tmp_r, y2_tmp_i, y2_tmp_r, y1_tmp_i, y1_tmp_r;
wire signed [ 8-1:0] r44s4r_r, r44s4i_i, r33s3r_r, r33s3i_i, r34s4r_r, r34s4i_r, r34s4r_i, r34s4i_i, r22s2r_r, r22s2i_i, r23s3r_r, r23s3i_r, r23s3r_i, r23s3i_i, r24s4r_r, r24s4i_r, 
                     r24s4r_i, r24s4i_i, r11s1r_r, r11s1i_i, r12s2r_r, r12s2i_r, r12s2r_i, r12s2i_i, r13s3r_r, r13s3i_r, r13s3r_i, r13s3i_i, r14s4r_r, r14s4i_r, r14s4r_i, r14s4i_i;

wire signed [ 8-1:0] y1_ext_i, y1_ext_r, y2_ext_i, y2_ext_r, y3_ext_i, y3_ext_r, y4_ext_i, y4_ext_r;

wire signed [ 8-1:0] entry4_r, entry4_i, entry3_r, entry3_i, entry2_r, entry2_i, entry1_r, entry1_i;
wire signed [ 9-1:0] square4_r, square4_i, square3_r, square3_i, square2_r, square2_i, square1_r, square1_i;

assign {x4_i, x4_r, x3_i, x3_r, x2_i, x2_r, x1_i, x1_r} = {cal_x};
assign {y4_i, y4_r, y3_i, y3_r, y2_i, y2_r, y1_i, y1_r} = {cal_y};
assign {r44_r, r34_i, r34_r, r24_i, r24_r, r14_i, r14_r, r33_r, r23_i, r23_r, r13_i, r13_r, r22_r, r12_i, r12_r, r11_r} = cal_r;

assign y4_tmp_i = y4_i * 5'sb0001_1; 
assign y4_tmp_r = y4_r * 5'sb0001_1; 
assign y3_tmp_i = y3_i * 5'sb0001_1; 
assign y3_tmp_r = y3_r * 5'sb0001_1; 
assign y2_tmp_i = y2_i * 5'sb0001_1; 
assign y2_tmp_r = y2_r * 5'sb0001_1; 
assign y1_tmp_i = y1_i * 5'sb0001_1; 
assign y1_tmp_r = y1_r * 5'sb0001_1; 

assign r44s4r_r = (x4_r)? -r44_r: r44_r;
assign r44s4i_i = (x4_i)? -r44_r: r44_r;
assign r33s3r_r = (x3_r)? -r33_r: r33_r;
assign r33s3i_i = (x3_i)? -r33_r: r33_r;
assign r34s4r_r = (x4_r)? -r34_r: r34_r;
assign r34s4i_r = (x4_i)? -r34_i: r34_i;
assign r34s4r_i = (x4_r)? -r34_i: r34_i;
assign r34s4i_i = (x4_i)? -r34_r: r34_r;
assign r22s2r_r = (x2_r)? -r22_r: r22_r;
assign r22s2i_i = (x2_i)? -r22_r: r22_r;
assign r23s3r_r = (x3_r)? -r23_r: r23_r;
assign r23s3i_r = (x3_i)? -r23_i: r23_i;
assign r23s3r_i = (x3_r)? -r23_i: r23_i;
assign r23s3i_i = (x3_i)? -r23_r: r23_r;
assign r24s4r_r = (x4_r)? -r24_r: r24_r;
assign r24s4i_r = (x4_i)? -r24_i: r24_i;
assign r24s4r_i = (x4_r)? -r24_i: r24_i;
assign r24s4i_i = (x4_i)? -r24_r: r24_r;
assign r11s1r_r = (x1_r)? -r11_r: r11_r;
assign r11s1i_i = (x1_i)? -r11_r: r11_r;
assign r12s2r_r = (x2_r)? -r12_r: r12_r;
assign r12s2i_r = (x2_i)? -r12_i: r12_i;
assign r12s2r_i = (x2_r)? -r12_i: r12_i;
assign r12s2i_i = (x2_i)? -r12_r: r12_r;
assign r13s3r_r = (x3_r)? -r13_r: r13_r;
assign r13s3i_r = (x3_i)? -r13_i: r13_i;
assign r13s3r_i = (x3_r)? -r13_i: r13_i;
assign r13s3i_i = (x3_i)? -r13_r: r13_r;
assign r14s4r_r = (x4_r)? -r14_r: r14_r;
assign r14s4i_r = (x4_i)? -r14_i: r14_i;
assign r14s4r_i = (x4_r)? -r14_i: r14_i;
assign r14s4i_i = (x4_i)? -r14_r: r14_r;

assign y4_ext_i = y4_tmp_i[1+:8];
assign y4_ext_r = y4_tmp_r[1+:8];
assign y3_ext_i = y3_tmp_i[1+:8];
assign y3_ext_r = y3_tmp_r[1+:8];
assign y2_ext_i = y2_tmp_i[1+:8];
assign y2_ext_r = y2_tmp_r[1+:8];
assign y1_ext_i = y1_tmp_i[1+:8];
assign y1_ext_r = y1_tmp_r[1+:8];

assign entry4_r =   y4_ext_r - r44s4r_r;
assign entry4_i =   y4_ext_i - r44s4i_i;
assign entry3_r =  (y3_ext_r - r33s3r_r) + (-r34s4r_r + r34s4i_r);
assign entry3_i =  (y3_ext_i - r33s3i_i) + (-r34s4r_i - r34s4i_i);
assign entry2_r = ((y2_ext_r - r22s2r_r) + (-r23s3r_r + r23s3i_r)) +  (-r24s4r_r + r24s4i_r);
assign entry2_i = ((y2_ext_i - r22s2i_i) + (-r23s3r_i - r23s3i_i)) +  (-r24s4r_i - r24s4i_i);
assign entry1_r = ((y1_ext_r - r11s1r_r) + (-r12s2r_r + r12s2i_r)) + ((-r13s3r_r + r13s3i_r) + (-r14s4r_r + r14s4i_r));
assign entry1_i = ((y1_ext_i - r11s1i_i) + (-r12s2r_i - r12s2i_i)) + ((-r13s3r_i - r13s3i_i) + (-r14s4r_i - r14s4i_i));

assign square4_r = (entry4_r[7])? (~entry4_r)+1: entry4_r;
assign square4_i = (entry4_i[7])? (~entry4_i)+1: entry4_i;
assign square3_r = (entry3_r[7])? (~entry3_r)+1: entry3_r;
assign square3_i = (entry3_i[7])? (~entry3_i)+1: entry3_i;
assign square2_r = (entry2_r[7])? (~entry2_r)+1: entry2_r;
assign square2_i = (entry2_i[7])? (~entry2_i)+1: entry2_i;
assign square1_r = (entry1_r[7])? (~entry1_r)+1: entry1_r;
assign square1_i = (entry1_i[7])? (~entry1_i)+1: entry1_i;

assign cal_result = ((square4_r + square4_i) + (square3_r + square3_i)) + ((square2_r + square2_i) + (square1_r + square1_i));

endmodule



