`timescale 1ns / 1ps

`define CYCLE 			        20
`define RST_DEL     	      2
`define IN_DEL			        1
`define OUT_DEL			        0.5
`define MAX_CYCLE   	      1000000
`define SDFFILE    		      "../02_SYN/core.sdf"

`define BIT_WIDTH           8
`define BIT2_WIDTH          16

`define IN_IMAGE_NUM        1024  // 32*32
`define COVNV0_IMAGE_NUM 		1156  // 34*34
`define COVNV1_IMAGE_NUM 		324   // 18*18
`define COVNV2_IMAGE_NUM 		100   // 10*10
`define LINEAR_WEIGHT_NUM   1920   // 64*10*3

`define IN_CHANNEL_NUM      1
`define PE_KERNEL_NUM       72

`define CONV0_CHANNEL_NUM   4
`define CONV0_KERNEL_NUM    288   // 72*4
`define CONV0_X_AXIS_NUM    32
`define CONV0_Y_AXIS_NUM    32

`define CONV1_CHANNEL_NUM   8
`define CONV1_KERNEL_NUM    576   // 72*8
`define CONV1_X_AXIS_NUM    16
`define CONV1_Y_AXIS_NUM    16

`define CONV2_CHANNEL_NUM   4
`define CONV2_KERNEL_NUM    288   // 72*4  
`define CONV2_X_AXIS_NUM    8
`define CONV2_Y_AXIS_NUM    8

`define OUT_NUM             3


`ifdef p1
  `define IN_IMAGE 	      "../00_TESTBED/PATTERN/IN_IMAGE.dat"
  `define CONV0_KERNEL 	  "../00_TESTBED/PATTERN/CONV0_KERNEL.dat"
  `define CONV1_KERNEL 	  "../00_TESTBED/PATTERN/CONV1_KERNEL.dat"
  `define CONV2_KERNEL 	  "../00_TESTBED/PATTERN/CONV2_KERNEL.dat"
  `define LINEAR_WEIGHT 	"../00_TESTBED/PATTERN/LINEAR_WEIGHT.dat"
  `define GOLDEN 		      "../00_TESTBED/PATTERN/GOLDEN.dat"
`endif

module testbench;

// Declaration //
// I/O
reg 				          i_clk;
reg 				          i_rst;
reg 				          i_valid;
reg  [`BIT2_WIDTH-1:0] i_data;
wire				          o_valid;
wire [`BIT_WIDTH-1:0] o_data;
// Self-Define 
reg  [`BIT_WIDTH-1:0] golden;
reg  [`BIT_WIDTH-1:0] output_tmp;
// Memory
reg  [`BIT_WIDTH-1:0]      in_image_mem [0:`IN_IMAGE_NUM-1];
reg  [`BIT_WIDTH-1:0]  conv0_kernel_mem [0:`CONV0_KERNEL_NUM-1];
reg  [`BIT_WIDTH-1:0]  conv1_kernel_mem [0:`CONV1_KERNEL_NUM-1];
reg  [`BIT_WIDTH-1:0]  conv2_kernel_mem [0:`CONV2_KERNEL_NUM-1];
reg  [`BIT_WIDTH-1:0] linear_weight_mem [0:`LINEAR_WEIGHT_NUM-1];
reg  [`BIT_WIDTH-1:0]        golden_mem [0:`OUT_NUM-1];
// Register File
reg  [`BIT_WIDTH-1:0]     in_image_reg [0:34-1][0:34-1];
reg  [`BIT_WIDTH-1:0] conv0_image0_reg [0:18-1][0:18-1];
reg  [`BIT_WIDTH-1:0] conv0_image1_reg [0:18-1][0:18-1];
reg  [`BIT_WIDTH-1:0] conv0_image2_reg [0:18-1][0:18-1];
reg  [`BIT_WIDTH-1:0] conv0_image3_reg [0:18-1][0:18-1];
reg  [`BIT_WIDTH-1:0] conv0_image4_reg [0:18-1][0:18-1];
reg  [`BIT_WIDTH-1:0] conv0_image5_reg [0:18-1][0:18-1];
reg  [`BIT_WIDTH-1:0] conv0_image6_reg [0:18-1][0:18-1];
reg  [`BIT_WIDTH-1:0] conv0_image7_reg [0:18-1][0:18-1];
reg  [`BIT_WIDTH-1:0] conv1_image0_reg [0:10-1][0:10-1];
reg  [`BIT_WIDTH-1:0] conv1_image1_reg [0:10-1][0:10-1];
reg  [`BIT_WIDTH-1:0] conv1_image2_reg [0:10-1][0:10-1];
reg  [`BIT_WIDTH-1:0] conv1_image3_reg [0:10-1][0:10-1];
reg  [`BIT_WIDTH-1:0] conv1_image4_reg [0:10-1][0:10-1];
reg  [`BIT_WIDTH-1:0] conv1_image5_reg [0:10-1][0:10-1];
reg  [`BIT_WIDTH-1:0] conv1_image6_reg [0:10-1][0:10-1];
reg  [`BIT_WIDTH-1:0] conv1_image7_reg [0:10-1][0:10-1];
reg  [`BIT_WIDTH-1:0] conv2_image0_reg [0:6-1][0:6-1];
reg  [`BIT_WIDTH-1:0] conv2_image1_reg [0:6-1][0:6-1];
reg  [`BIT_WIDTH-1:0] conv2_image2_reg [0:6-1][0:6-1];
reg  [`BIT_WIDTH-1:0] conv2_image3_reg [0:6-1][0:6-1];
reg  [`BIT_WIDTH-1:0] linear_weight0_reg [0:10-1][0:64-1];
reg  [`BIT_WIDTH-1:0] linear_weight1_reg [0:10-1][0:64-1];
reg  [`BIT_WIDTH-1:0] linear_weight2_reg [0:10-1][0:64-1];
reg  [4-1:0]       output_reg [0:3-1];
// Flag
reg over1, over2, over;
integer i, j, k, l, m, n, o, p, q, r, s, t, i_mode, pad;
integer ii, jj, kk, o_mode;
integer error, correct;



// For gate-level simulation only //
`ifdef SDF
	initial $sdf_annotate(`SDFFILE, CORE_U0);
`endif


// Read in test pattern and golden pattern //
initial begin
  $readmemh(`IN_IMAGE, in_image_mem);
	$readmemh(`CONV0_KERNEL, conv0_kernel_mem);
	$readmemh(`CONV1_KERNEL, conv1_kernel_mem);
  $readmemh(`CONV2_KERNEL, conv2_kernel_mem);
  $readmemh(`LINEAR_WEIGHT, linear_weight_mem);
	$readmemh(`GOLDEN, golden_mem);
end


// Write out waveform file //
initial begin
 	$fsdbDumpfile("core.fsdb");
 	$fsdbDumpvars;
end


// Instantiate the Design Under Test (DUT) //
core CORE_U0 (
  .i_clk		  (i_clk),
	.i_rst  	  (i_rst),
	.i_data     (i_data),
	.i_valid	  (i_valid),
	.o_data		  (o_data),
  .o_valid	  (o_valid)
);	

// Initialization //
initial begin
  for(i=0;i<34;i=i+1) begin
    for(j=0;j<34;j=j+1) begin
      in_image_reg[j][i] = 0;
    end
  end
  for(i=0;i<32;i=i+1) begin
    for(j=0;j<32;j=j+1) begin
      in_image_reg[j+1][i+1] = in_image_mem[i*32+j];
    end
  end

  for(i=0;i<18;i=i+1) begin
    for(j=0;j<18;j=j+1) begin
      conv0_image0_reg[j][i] = 0;
      conv0_image1_reg[j][i] = 0;
      conv0_image2_reg[j][i] = 0;
      conv0_image3_reg[j][i] = 0;
      conv0_image4_reg[j][i] = 0;
      conv0_image5_reg[j][i] = 0;
      conv0_image6_reg[j][i] = 0;
      conv0_image7_reg[j][i] = 0;
    end
  end

  for(i=0;i<10;i=i+1) begin
    for(j=0;j<10;j=j+1) begin
      conv1_image0_reg[j][i] = 0;
      conv1_image1_reg[j][i] = 0;
      conv1_image2_reg[j][i] = 0;
      conv1_image3_reg[j][i] = 0;
      conv1_image4_reg[j][i] = 0;
      conv1_image5_reg[j][i] = 0;
      conv1_image6_reg[j][i] = 0;
      conv1_image7_reg[j][i] = 0;
    end
  end

  for(i=0;i<6;i=i+1) begin
    for(j=0;j<6;j=j+1) begin
      conv2_image0_reg[j][i] = 0;
      conv2_image1_reg[j][i] = 0;
      conv2_image2_reg[j][i] = 0;
      conv2_image3_reg[j][i] = 0;
    end
  end

  for(i=0;i<10;i=i+1) begin
    for(j=0;j<64;j=j+1) begin
      linear_weight0_reg[i][j] = 0;
      linear_weight1_reg[i][j] = 0;
      linear_weight2_reg[i][j] = 0;
    end
  end
  for(k=0;k<3;k=k+1) begin
    for(i=0;i<10;i=i+1) begin
      for(j=0;j<64;j=j+1) begin
        linear_weight0_reg[i][j] = linear_weight_mem[k*640+i*64+j];
        linear_weight1_reg[i][j] = linear_weight_mem[k*640+i*64+j];
        linear_weight2_reg[i][j] = linear_weight_mem[k*640+i*64+j];
      end
    end
  end
  

  i_clk			  = 1'b0;   
 	i_rst		    = 1'b1;
	i_valid		  = 1'b0;
  i_data      = 16'b0;
  output_tmp  = 8'b0;
	golden		  = 8'b0;
	over		    = 0;
	over1		    = 0;
	over2		    = 0;
	error		    = 0;
	correct		  = 0;
  i_mode      = 0;
  i           = 0;
  j           = 0;
  k           = 0;
  l           = 0;
  m           = 0;
  n           = 0;
  o           = 0;
  p           = 0;
  q           = 0;
  t           = 0;
  pad         = 0;
  o_mode      = 0;
  ii          = 0;
  jj          = 0;
  kk          = 0;
end


// Clock & Reset Generation //
always begin #(`CYCLE/2)  i_clk = ~i_clk; end
initial begin
 		i_rst = 1; # (             0.25 * `CYCLE);
 		i_rst = 0; # ((`RST_DEL - 0.25) * `CYCLE);
 		i_rst = 1; # (       `MAX_CYCLE * `CYCLE);
 		$display("Error!! Runtime exceeded...");
 		$finish;
end

// Input Data Control //
initial begin
  @(posedge i_clk);
	#(`CYCLE * 3);
  for(i_mode=0;i_mode<4;i_mode=i_mode+1) begin
    case(i_mode)
    0: begin
      for(i=0;i<`CONV0_CHANNEL_NUM;i=i+1) begin
        for(j=0;j<72;j=j+1) begin
          @(posedge i_clk);
          #(`IN_DEL);
          i_valid = 1'b1;
          if((j >= 0) && (j< 9)) i_data = {8'b0000_0000, conv0_kernel_mem[i*9+j]};
          else                   i_data = {16'b0000_0000_0000_0000};
        end
        for(k=0;k<`CONV0_Y_AXIS_NUM;k=k+2) begin
          for(l=0;l<`CONV0_X_AXIS_NUM;l=l+2) begin
            for(m=0;m<8;m=m+1) begin
              if(l == 0) begin
                for(n=0;n<4;n=n+1) begin
                    @(posedge i_clk);
                    #(`IN_DEL);
                    i_valid = 1'b1;
                    if(m == 0)      i_data = {in_image_reg[k+n][l], in_image_reg[k+n][l+1]};
                    else if(m == 1) i_data = {16'b0000_0000_0000_0000};
                    else if(m == 2) i_data = {16'b0000_0000_0000_0000};
                    else if(m == 3) i_data = {16'b0000_0000_0000_0000};
                    else if(m == 4) i_data = {16'b0000_0000_0000_0000};
                    else if(m == 5) i_data = {16'b0000_0000_0000_0000};
                    else if(m == 6) i_data = {16'b0000_0000_0000_0000};
                    else if(m == 7) i_data = {16'b0000_0000_0000_0000};
                    else            i_data = 0;
                end
                for(o=0;o<4;o=o+1) begin
                    @(posedge i_clk);
                    #(`IN_DEL);
                    i_valid = 1'b1;
                    if(m == 0)      i_data = {in_image_reg[k+o][l+2], in_image_reg[k+o][l+3]};
                    else if(m == 1) i_data = {16'b0000_0000_0000_0000};
                    else if(m == 2) i_data = {16'b0000_0000_0000_0000};
                    else if(m == 3) i_data = {16'b0000_0000_0000_0000};
                    else if(m == 4) i_data = {16'b0000_0000_0000_0000};
                    else if(m == 5) i_data = {16'b0000_0000_0000_0000};
                    else if(m == 6) i_data = {16'b0000_0000_0000_0000};
                    else if(m == 7) i_data = {16'b0000_0000_0000_0000};
                    else            i_data = 0;
                end 
              end else begin
                for(n=0;n<4;n=n+1) begin 
                    @(posedge i_clk);
                    #(`IN_DEL);
                    i_valid = 1'b1;
                    if(m == 0)      i_data = {in_image_reg[k+n][l+2], in_image_reg[k+n][l+3]};
                    else if(m == 1) i_data = {16'b0000_0000_0000_0000};
                    else if(m == 2) i_data = {16'b0000_0000_0000_0000};
                    else if(m == 3) i_data = {16'b0000_0000_0000_0000};
                    else if(m == 4) i_data = {16'b0000_0000_0000_0000};
                    else if(m == 5) i_data = {16'b0000_0000_0000_0000};
                    else if(m == 6) i_data = {16'b0000_0000_0000_0000};
                    else if(m == 7) i_data = {16'b0000_0000_0000_0000};
                    else            i_data = 0;
                end
              end
            end
            @(posedge i_clk);
            #(`CYCLE*4);
	        end
        end

        @(posedge i_clk);
        #(`CYCLE);
      end
    end

    1: begin
      for(i=0;i<`CONV1_CHANNEL_NUM;i=i+1) begin
        for(j=0;j<72;j=j+1) begin
          @(posedge i_clk);
          #(`IN_DEL);
          i_valid = 1'b1;
          if((j >= 0) && (j< 36)) i_data = {8'b0000_0000, conv1_kernel_mem[i*36+j]};
          else                    i_data = {16'b0000_0000_0000_0000};
        end
        for(k=0;k<`CONV1_Y_AXIS_NUM;k=k+2) begin
          for(l=0;l<`CONV1_X_AXIS_NUM;l=l+2) begin
            for(m=0;m<8;m=m+1) begin
              if(l == 0) begin
                for(n=0;n<4;n=n+1) begin
                    @(posedge i_clk);
                    #(`IN_DEL);
                    i_valid = 1'b1;
                    if(m == 0)      i_data = {conv0_image0_reg[k+n][l], conv0_image0_reg[k+n][l+1]};
                    else if(m == 1) i_data = {conv0_image1_reg[k+n][l], conv0_image1_reg[k+n][l+1]};
                    else if(m == 2) i_data = {conv0_image2_reg[k+n][l], conv0_image2_reg[k+n][l+1]};
                    else if(m == 3) i_data = {conv0_image3_reg[k+n][l], conv0_image3_reg[k+n][l+1]};
                    else if(m == 4) i_data = {16'b0000_0000_0000_0000};
                    else if(m == 5) i_data = {16'b0000_0000_0000_0000};
                    else if(m == 6) i_data = {16'b0000_0000_0000_0000};
                    else if(m == 7) i_data = {16'b0000_0000_0000_0000};
                    else            i_data = 0;
                end
                for(o=0;o<4;o=o+1) begin
                    @(posedge i_clk);
                    #(`IN_DEL);
                    i_valid = 1'b1;
                    if(m == 0)      i_data = {conv0_image0_reg[k+o][l+2], conv0_image0_reg[k+o][l+3]};
                    else if(m == 1) i_data = {conv0_image1_reg[k+o][l+2], conv0_image1_reg[k+o][l+3]};
                    else if(m == 2) i_data = {conv0_image2_reg[k+o][l+2], conv0_image2_reg[k+o][l+3]};
                    else if(m == 3) i_data = {conv0_image3_reg[k+o][l+2], conv0_image3_reg[k+o][l+3]};
                    else if(m == 4) i_data = {16'b0000_0000_0000_0000};
                    else if(m == 5) i_data = {16'b0000_0000_0000_0000};
                    else if(m == 6) i_data = {16'b0000_0000_0000_0000};
                    else if(m == 7) i_data = {16'b0000_0000_0000_0000};
                    else            i_data = 0;
                end
              end else begin
                for(n=0;n<4;n=n+1) begin 
                    @(posedge i_clk);
                    #(`IN_DEL);
                    i_valid = 1'b1;
                    if(m == 0)      i_data = {conv0_image0_reg[k+n][l+2], conv0_image0_reg[k+n][l+3]};
                    else if(m == 1) i_data = {conv0_image1_reg[k+n][l+2], conv0_image1_reg[k+n][l+3]};
                    else if(m == 2) i_data = {conv0_image2_reg[k+n][l+2], conv0_image2_reg[k+n][l+3]};
                    else if(m == 3) i_data = {conv0_image3_reg[k+n][l+2], conv0_image3_reg[k+n][l+3]};
                    else if(m == 4) i_data = {16'b0000_0000_0000_0000};
                    else if(m == 5) i_data = {16'b0000_0000_0000_0000};
                    else if(m == 6) i_data = {16'b0000_0000_0000_0000};
                    else if(m == 7) i_data = {16'b0000_0000_0000_0000};
                    else            i_data = 0;
                end
              end
            end
            @(posedge i_clk);
            #(`CYCLE*4);
	        end
        end
        @(posedge i_clk);
        #(`CYCLE);
      end
    end

    2: begin
      for(i=0;i<`CONV2_CHANNEL_NUM;i=i+1) begin
        for(j=0;j<`PE_KERNEL_NUM;j=j+1) begin
          @(posedge i_clk);
          #(`IN_DEL);
          i_valid = 1'b1;
          i_data = {8'b0000_0000, conv2_kernel_mem[i*72+j]};
        end
        for(k=0;k<`CONV2_Y_AXIS_NUM;k=k+2) begin
          for(l=0;l<`CONV2_X_AXIS_NUM;l=l+2) begin
            for(m=0;m<8;m=m+1) begin
              if(l == 0) begin
                for(n=0;n<4;n=n+1) begin
                    @(posedge i_clk);
                    #(`IN_DEL);
                    i_valid = 1'b1;
                    if(m == 0)      i_data = {conv1_image0_reg[k+n][l], conv1_image0_reg[k+n][l+1]};
                    else if(m == 1) i_data = {conv1_image1_reg[k+n][l], conv1_image1_reg[k+n][l+1]};
                    else if(m == 2) i_data = {conv1_image2_reg[k+n][l], conv1_image2_reg[k+n][l+1]};
                    else if(m == 3) i_data = {conv1_image3_reg[k+n][l], conv1_image3_reg[k+n][l+1]};
                    else if(m == 4) i_data = {conv1_image4_reg[k+n][l], conv1_image4_reg[k+n][l+1]};
                    else if(m == 5) i_data = {conv1_image5_reg[k+n][l], conv1_image5_reg[k+n][l+1]};
                    else if(m == 6) i_data = {conv1_image6_reg[k+n][l], conv1_image6_reg[k+n][l+1]};
                    else if(m == 7) i_data = {conv1_image7_reg[k+n][l], conv1_image7_reg[k+n][l+1]};
                    else            i_data = 0;
     
                end
                for(o=0;o<4;o=o+1) begin
                    @(posedge i_clk);
                    #(`IN_DEL);
                    i_valid = 1'b1;
                    if(m == 0)      i_data = {conv1_image0_reg[k+o][l+2], conv1_image0_reg[k+o][l+3]};
                    else if(m == 1) i_data = {conv1_image1_reg[k+o][l+2], conv1_image1_reg[k+o][l+3]};
                    else if(m == 2) i_data = {conv1_image2_reg[k+o][l+2], conv1_image2_reg[k+o][l+3]};
                    else if(m == 3) i_data = {conv1_image3_reg[k+o][l+2], conv1_image3_reg[k+o][l+3]};
                    else if(m == 4) i_data = {conv1_image4_reg[k+o][l+2], conv1_image4_reg[k+o][l+3]};
                    else if(m == 5) i_data = {conv1_image5_reg[k+o][l+2], conv1_image5_reg[k+o][l+3]};
                    else if(m == 6) i_data = {conv1_image6_reg[k+o][l+2], conv1_image6_reg[k+o][l+3]};
                    else if(m == 7) i_data = {conv1_image7_reg[k+o][l+2], conv1_image7_reg[k+o][l+3]};
                    else            i_data = 0;
     
                end

              end else begin
                for(n=0;n<4;n=n+1) begin 
                    @(posedge i_clk);
                    #(`IN_DEL);
                    i_valid = 1'b1;
                    if(m == 0)      i_data = {conv1_image0_reg[k+n][l+2], conv1_image0_reg[k+n][l+3]};
                    else if(m == 1) i_data = {conv1_image1_reg[k+n][l+2], conv1_image1_reg[k+n][l+3]};
                    else if(m == 2) i_data = {conv1_image2_reg[k+n][l+2], conv1_image2_reg[k+n][l+3]};
                    else if(m == 3) i_data = {conv1_image3_reg[k+n][l+2], conv1_image3_reg[k+n][l+3]};
                    else if(m == 4) i_data = {conv1_image4_reg[k+n][l+2], conv1_image4_reg[k+n][l+3]};
                    else if(m == 5) i_data = {conv1_image5_reg[k+n][l+2], conv1_image5_reg[k+n][l+3]};
                    else if(m == 6) i_data = {conv1_image6_reg[k+n][l+2], conv1_image6_reg[k+n][l+3]};
                    else if(m == 7) i_data = {conv1_image7_reg[k+n][l+2], conv1_image7_reg[k+n][l+3]};
                    else            i_data = 0;
                end
              end
            end
            @(posedge i_clk);
            #(`CYCLE*4);
	        end
        end
        @(posedge i_clk);
        #(`CYCLE);
      end
    end

    3: begin
      for(i=0;i<4;i=i+1)begin
        for(j=0;j<4;j=j+1) begin
          for(k=0;k<4;k=k+1) begin
            @(posedge i_clk);
            #(`IN_DEL);
            i_valid = 1'b1;
            if(i == 0)      i_data = {8'b0000_0000, conv2_image0_reg[j+1][k+1]};
            else if(i == 1) i_data = {8'b0000_0000, conv2_image1_reg[j+1][k+1]};
            else if(i == 2) i_data = {8'b0000_0000, conv2_image2_reg[j+1][k+1]};
            else if(i == 3) i_data = {8'b0000_0000, conv2_image3_reg[j+1][k+1]};
          end
        end
      end
      for(pad=0;pad<8;pad=pad+1) begin
        @(posedge i_clk);
        #(`IN_DEL);
        i_valid = 1'b1;
        i_data = 8'b0;
      end
      for(l=0;l<3;l=l+1) begin
        for(m=0;m<10;m=m+1) begin
          for(n=0;n<8;n=n+1) begin
            for(o=0;o<4;o=o+2) begin
              for(p=0;p<4;p=p+1) begin

                  @(posedge i_clk);
                  #(`IN_DEL);
                  i_valid = 1'b1;
                  if((n < 7)&&(o == 0)&&(p < 3))        i_data = {linear_weight_mem[l*640+m*64+n*9+p+q-t], linear_weight_mem[l*640+m*64+n*9+p+q+3-t]};
                  else if((n < 7)&&(o == 2)&&(p < 3))   i_data = {linear_weight_mem[l*640+m*64+n*9+o*3+p+q-t], 8'b0000_0000};
                  else if((n < 7)&&(p == 3))            i_data = {16'b0000_0000_0000_0000};
                  else if((n == 7)&&(o == 0)&&(p == 0)) i_data = {linear_weight_mem[l*640+m*64+63], 8'b0000_0000};
                  else                                  i_data = {16'b0000_0000_0000_0000};
                  
                  if((n == 7)&&(o == 0)&&(p == 0)) q = 1;


                // if(m == 0) begin
                //   for(r=0;r<4;r=r+1) begin
                //     @(posedge i_clk);
                //     i_valid = 1'b1;
                //     if((n < 7)&&(o == 0)&&(p < 3))        i_data = {linear_weight_mem[l*640+m*64+n*9+o*6+p*2+q], linear_weight_mem[l*640+m*64+n*9+o*6+p*2+q+1]};
                //     else if((n < 7)&&(o == 2)&&(p < 3))   i_data = {linear_weight_mem[l*640+m*64+n*9+o*6+p+q], 8'b0000_0000};
                //     else if((n < 7)&&(p == 3))            i_data = {16'b0000_0000_0000_0000};
                //     else if((n == 7)&&(o == 0)&&(p == 0)) i_data = {linear_weight_mem[l*640+m*64+63], 8'b0000_0000};
                //     if(n == 7) q = q+1;
                //   end
                //   for(s=0;s<4;s=+1) begin
                //     @(posedge i_clk);
                //     i_valid = 1'b1;
                //     if((n < 7)&&(o == 0)&&(p < 3))        i_data = {linear_weight_mem[l*640+m*64+n*9+o*6+p*2+q], linear_weight_mem[l*640+m*64+n*9+o*6+p*2+q+1]};
                //     else if((n < 7)&&(o == 2)&&(p < 3))   i_data = {linear_weight_mem[l*640+m*64+n*9+o*6+p+q], 8'b0000_0000};
                //     else if((n < 7)&&(p == 3))            i_data = {16'b0000_0000_0000_0000};
                //     else if((n == 7)&&(o == 0)&&(p == 0)) i_data = {linear_weight_mem[l*640+m*64+63], 8'b0000_0000};
                //     if(n == 7) q = q+1;
                //   end
                // end else begin
                //   @(posedge i_clk);
                //   i_valid = 1'b1;
                //   if((n < 7)&&(o == 0)&&(p < 3))        i_data = {linear_weight_mem[l*640+m*64+n*9+o*6+p*2+q], linear_weight_mem[l*640+m*64+n*9+o*6+p*2+q+1]};
                //   else if((n < 7)&&(o == 2)&&(p < 3))   i_data = {linear_weight_mem[l*640+m*64+n*9+o*6+p+q], 8'b0000_0000};
                //   else if((n < 7)&&(p == 3))            i_data = {16'b0000_0000_0000_0000};
                //   else if((n == 7)&&(o == 0)&&(p == 0)) i_data = {linear_weight_mem[l*640+m*64+63], 8'b0000_0000};

                //   if(n == 7) q = q+1;
                // end

              end
            end
          end
          t = 1;
          @(posedge i_clk);
          #(`CYCLE);
        end
      end
    end

    endcase
  end

  over1 = 1;
end



// Output Data Control //
initial begin
  while(o_mode<4) begin
    case(o_mode)
    0: begin
      while(ii<`CONV0_CHANNEL_NUM) begin
        while(jj<16) begin
          while(kk<16) begin
            @(posedge i_clk);
            if(o_valid) begin
              if(ii == 0)       conv0_image0_reg[jj+1][kk+1] = o_data;
              else if(ii == 1)  conv0_image1_reg[jj+1][kk+1] = o_data;
              else if(ii == 2)  conv0_image2_reg[jj+1][kk+1] = o_data;
              else if(ii == 3)  conv0_image3_reg[jj+1][kk+1] = o_data;
              output_tmp = o_data;
              @(negedge i_clk);
              if(ii == 0)       $display("Mode%1d Channel[%01d]P[%03d]: yours=%d", o_mode, ii, jj*16+kk, output_tmp);
              else if(ii == 1)  $display("Mode%1d Channel[%01d]P[%03d]: yours=%d", o_mode, ii, jj*16+kk, output_tmp);
              else if(ii == 2)  $display("Mode%1d Channel[%01d]P[%03d]: yours=%d", o_mode, ii, jj*16+kk, output_tmp);
              else if(ii == 3)  $display("Mode%1d Channel[%01d]P[%03d]: yours=%d", o_mode, ii, jj*16+kk, output_tmp);
              @(posedge i_clk);
              kk = kk+1;
            end
          end

          kk = 0;
          jj = jj+1;
        end

        jj = 0;
        ii = ii+1;
      end

      ii = 0;
      o_mode = o_mode+1;
    end
    1: begin
      while(ii<`CONV1_CHANNEL_NUM) begin
        while(jj<8) begin
          while(kk<8) begin
            @(posedge i_clk);
            if(o_valid) begin
              if(ii == 0)       conv1_image0_reg[jj+1][kk+1] = o_data;
              else if(ii == 1)  conv1_image1_reg[jj+1][kk+1] = o_data;
              else if(ii == 2)  conv1_image2_reg[jj+1][kk+1] = o_data;
              else if(ii == 3)  conv1_image3_reg[jj+1][kk+1] = o_data;
              else if(ii == 4)  conv1_image4_reg[jj+1][kk+1] = o_data;
              else if(ii == 5)  conv1_image5_reg[jj+1][kk+1] = o_data;
              else if(ii == 6)  conv1_image6_reg[jj+1][kk+1] = o_data;
              else if(ii == 7)  conv1_image7_reg[jj+1][kk+1] = o_data;
              output_tmp = o_data;
              @(negedge i_clk);
              if(ii == 0)       $display("Mode%1d Channel[%01d]P[%03d]: yours=%d", o_mode, ii, jj*8+kk, output_tmp);
              else if(ii == 1)  $display("Mode%1d Channel[%01d]P[%03d]: yours=%d", o_mode, ii, jj*8+kk, output_tmp);
              else if(ii == 2)  $display("Mode%1d Channel[%01d]P[%03d]: yours=%d", o_mode, ii, jj*8+kk, output_tmp);
              else if(ii == 3)  $display("Mode%1d Channel[%01d]P[%03d]: yours=%d", o_mode, ii, jj*8+kk, output_tmp);
              else if(ii == 4)  $display("Mode%1d Channel[%01d]P[%03d]: yours=%d", o_mode, ii, jj*8+kk, output_tmp);
              else if(ii == 5)  $display("Mode%1d Channel[%01d]P[%03d]: yours=%d", o_mode, ii, jj*8+kk, output_tmp);
              else if(ii == 6)  $display("Mode%1d Channel[%01d]P[%03d]: yours=%d", o_mode, ii, jj*8+kk, output_tmp);
              else if(ii == 7)  $display("Mode%1d Channel[%01d]P[%03d]: yours=%d", o_mode, ii, jj*8+kk, output_tmp);
              @(posedge i_clk);
              kk = kk+1;
            end
          end

          kk = 0;
          jj = jj+1;
        end

        jj = 0;
        ii = ii+1;
      end

      ii = 0;
      o_mode = o_mode+1;
    end
    2: begin
      while(ii<`CONV2_CHANNEL_NUM) begin
        while(jj<4) begin
          while(kk<4) begin
            @(posedge i_clk);
            if(o_valid) begin
              if(ii == 0)       conv2_image0_reg[jj+1][kk+1] = o_data;
              else if(ii == 1)  conv2_image1_reg[jj+1][kk+1] = o_data;
              else if(ii == 2)  conv2_image2_reg[jj+1][kk+1] = o_data;
              else if(ii == 3)  conv2_image3_reg[jj+1][kk+1] = o_data;
              output_tmp = o_data;
              @(negedge i_clk);
              if(ii == 0)       $display("Mode%1d Channel[%01d]P[%03d]: yours=%d", o_mode, ii, jj*4+kk, output_tmp);
              else if(ii == 1)  $display("Mode%1d Channel[%01d]P[%03d]: yours=%d", o_mode, ii, jj*4+kk, output_tmp);
              else if(ii == 2)  $display("Mode%1d Channel[%01d]P[%03d]: yours=%d", o_mode, ii, jj*4+kk, output_tmp);
              else if(ii == 3)  $display("Mode%1d Channel[%01d]P[%03d]: yours=%d", o_mode, ii, jj*4+kk, output_tmp);
              @(posedge i_clk);
              kk = kk+1;
            end
          end

          kk = 0;
          jj = jj+1;
        end

        jj = 0;
        ii = ii+1;
      end

      ii = 0;
      o_mode = o_mode+1;
    end
    3: begin
      while(ii<3) begin
        @(posedge i_clk);
        if(o_valid) begin
          output_reg[ii] = o_data;
          output_tmp = o_data;
          golden = golden_mem[ii];
          @(negedge i_clk);
	  		    if(output_tmp !== golden) begin
	  		    	$display("P[%01d]: Error:  yours=%d != expect=%d", ii, output_reg[ii], golden); 
	  		    	error = error + 1;
	  		    end else begin
	  		    	$display("P[%01d]: Correct!! yours=%d == expect=%d", ii, output_reg[ii], golden);
	  		    	correct = correct + 1;
	  		    end
            @(posedge i_clk);
            ii = ii+1;
        end
      end

      ii = 0;
      o_mode = o_mode+1;
    end
    endcase
  end

  over2 = 1;
end


always @(*) begin over = over1 && over2; end
initial begin
 		@(posedge over)      
 		if(over) begin
 		   $display("-----------------------------------------------------");
 		   if ((error == 0)) begin
 		      $display("Congratulations! All data have been generated successfully!");
 		      $display("-------------------------PASS------------------------");
 		   end else begin
 		      $display("Final Simulation Result as below: ");
 		      $display("-----------------------------------------------------");
 		      $display("Error:  %3d ", error);
 		      $display("-----------------------------------------------------");
 		   end
 		end
 		#(`CYCLE/2); $finish;
end


endmodule