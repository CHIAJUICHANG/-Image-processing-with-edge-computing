`timescale 1ns / 1ps

`define CYCLE 			  20
`define RST_DEL     	2
`define IN_DEL			  1
`define MAX_CYCLE   	100000
`define SDFFILE    		"../02_SYN/sdf/core.sdf"

`define BIT_WIDTH           8
`define KERNAL_NUM 		      9
`define PIXEL_NUM 		      576   // (32*32)/2
`define X_AXIS_NUM          32
`define Y_AXIS_NUM          32
`define CHANNEL_NUM         8
`define OUT_NUM 		        256   // 16*16

`ifdef p1
  `define IN_DATA 	"../../00_TESTBED/IN_DATA.dat"
  `define GOLDEN 		"../../00_TESTBED/GOLDEN.dat"
`endif

module testbench;

// Inputs
reg 				 i_clk;
reg 				 i_rst;
reg 				 i_valid;
reg  [`BIT_WIDTH-1:0] data;
// Outputs
wire				   i_valid;
wire 				   done;
wire [`BIT_WIDTH-1:0] o_data;
// Self-define
reg  [`BIT_WIDTH-1:0] golden;

// MEM
reg  [`BIT_WIDTH-1:0] in_kernal0_mem [0:`KERNAL_NUM-1];
reg  [`BIT_WIDTH-1:0] in_kernal1_mem [0:`KERNAL_NUM-1];
reg  [`BIT_WIDTH-1:0] in_kernal2_mem [0:`KERNAL_NUM-1];
reg  [`BIT_WIDTH-1:0] in_kernal3_mem [0:`KERNAL_NUM-1];
reg  [`BIT_WIDTH-1:0] in_kernal4_mem [0:`KERNAL_NUM-1];
reg  [`BIT_WIDTH-1:0] in_kernal5_mem [0:`KERNAL_NUM-1];
reg  [`BIT_WIDTH-1:0] in_kernal6_mem [0:`KERNAL_NUM-1];
reg  [`BIT_WIDTH-1:0] in_kernal7_mem [0:`KERNAL_NUM-1];
reg  [`BIT_WIDTH-1:0] in_image0_mem [0:`PIXEL_NUM-1];
reg  [`BIT_WIDTH-1:0] in_image1_mem [0:`PIXEL_NUM-1];
reg  [`BIT_WIDTH-1:0] in_image2_mem [0:`PIXEL_NUM-1];
reg  [`BIT_WIDTH-1:0] in_image3_mem [0:`PIXEL_NUM-1];
reg  [`BIT_WIDTH-1:0] in_image4_mem [0:`PIXEL_NUM-1];
reg  [`BIT_WIDTH-1:0] in_image5_mem [0:`PIXEL_NUM-1];
reg  [`BIT_WIDTH-1:0] in_image6_mem [0:`PIXEL_NUM-1];
reg  [`BIT_WIDTH-1:0] in_image7_mem [0:`PIXEL_NUM-1];
reg  [`BIT_WIDTH-1:0] golden_mem [0:`OUTL_NUM-1];

reg over1, over2, over;
integer i, j, k, l, m, n;
integer error, correct;



// Instantiate the Design Under Test (DUT)
core core (
  .i_clk		  (i_clk),
	.i_rst  	  (i_rst),
	.i_data_0   (i_data),
	.i_valid	  (i_valid),
	.o_data		  (o_data),
  .o_valid	  (o_valid)
);	


`ifdef SDF
	initial $sdf_annotate(`SDFFILE, core);
`endif

initial begin
	$readmemh(`IN_DATA, in_data_mem);
	$readmemh(`GOLDEN, golden_mem);
end

initial begin
 	$fsdbDumpfile("architechture.fsdb");
 	$fsdbDumpvars;
end


initial begin
 	i_clk			= 1'b0;   
 	i_rst		  = 1'b1;
	i_valid		= 1'b0;
	golden		= 0;
	over		  = 0;
	over1		  = 0;
	over2		  = 0;
	error		  = 0;
	correct		= 0;
  i         = 0;
  j         = 0;
  k         = 0;
  l         = 0;
end

always begin #(`CYCLE/2)  i_clk = ~i_clk; end

initial begin
 		i_rst = 1; # (             0.25 * `CYCLE);
 		i_rst = 0; # ((`RST_DEL - 0.25) * `CYCLE);
 		i_rst = 1; # (       `MAX_CYCLE * `CYCLE);
 		$display("Error!! Runtime exceeded...");
 		$finish;
end

initial begin

	@(posedge i_clk);
	#(`CYCLE * 3);
  i_valid = 1'b1;


  while(i < `CHANNEL_NUM) begin
      while(j < 9) begin

          @(posedge i_clk);
          if(i == 1)      i_data[7:0] = in_kernal0_mem[j];
          else if(i == 2) i_data[7:0] = in_kernal1_mem[j];
          else if(i == 3) i_data[7:0] = in_kernal2_mem[j];
          else if(i == 4) i_data[7:0] = in_kernal3_mem[j];
          else if(i == 5) i_data[7:0] = in_kernal4_mem[j];
          else if(i == 6) i_data[7:0] = in_kernal5_mem[j];
          else if(i == 7) i_data[7:0] = in_kernal6_mem[j];
          else if(i == 8) i_data[7:0] = in_kernal7_mem[j];
          else            i_data[7:0] = 0;

        j = j+1;
      end
    j = 0;
    i = i+1;
  end

  i = 0;
  j = 0;
  k = 0;
  l = 0;
  for(i = 0; i < `Y_AXIS_NUM; i=i+2) begin
    for(j = 0; j < `X_AXIS_NUM; j=j+2) begin
      for(k = 0; k < `CHANNEL_NUM; k=k+1) begin
        for(l = 0; l < 4; l=l+1) begin
          if(j == 0) begin

            @(posedge i_clk);
            if(k == 0)      i_data = {in_image0_mem[((i+l)*34)+j], in_image0_mem[(i+l*34)+j+1]};
            else if(k == 1) i_data = {in_image1_mem[((i+l)*34)+j], in_image1_mem[(i+l*34)+j+1]};
            else if(k == 2) i_data = {in_image2_mem[((i+l)*34)+j], in_image2_mem[(i+l*34)+j+1]};
            else if(k == 3) i_data = {in_image3_mem[((i+l)*34)+j], in_image3_mem[(i+l*34)+j+1]};
            else if(k == 4) i_data = {in_image4_mem[((i+l)*34)+j], in_image4_mem[(i+l*34)+j+1]};
            else if(k == 5) i_data = {in_image5_mem[((i+l)*34)+j], in_image5_mem[(i+l*34)+j+1]};
            else if(k == 6) i_data = {in_image6_mem[((i+l)*34)+j], in_image6_mem[(i+l*34)+j+1]};
            else if(k == 7) i_data = {in_image7_mem[((i+l)*34)+j], in_image7_mem[(i+l*34)+j+1]};
            else            i_data = 0;
          end else begin

            @(posedge i_clk);
            if(k == 0)      i_data = {in_image0_mem[((i+l)*34)+j+2], in_image0_mem[(i+l*34)+j+1+2]};
            else if(k == 1) i_data = {in_image1_mem[((i+l)*34)+j+2], in_image1_mem[(i+l*34)+j+1+2]};
            else if(k == 2) i_data = {in_image2_mem[((i+l)*34)+j+2], in_image2_mem[(i+l*34)+j+1+2]};
            else if(k == 3) i_data = {in_image3_mem[((i+l)*34)+j+2], in_image3_mem[(i+l*34)+j+1+2]};
            else if(k == 4) i_data = {in_image4_mem[((i+l)*34)+j+2], in_image4_mem[(i+l*34)+j+1+2]};
            else if(k == 5) i_data = {in_image5_mem[((i+l)*34)+j+2], in_image5_mem[(i+l*34)+j+1+2]};
            else if(k == 6) i_data = {in_image6_mem[((i+l)*34)+j+2], in_image6_mem[(i+l*34)+j+1+2]};
            else if(k == 7) i_data = {in_image7_mem[((i+l)*34)+j+2], in_image7_mem[(i+l*34)+j+1+2]};
            else            i_data = 0;
          end
        end
      end

      if(j != 0) begin
        @(posedge i_clk);
        #(`CYCLE);
      end
	  end
  end

  @(posedge i_clk);
  i_valid = 1'b0;

	over1 = 1;
end

initial begin
  m = 0;
  n = 0;
	
	while(m < `OUT_NUM) begin
		@(posedge i_clk);
		if(i_valid) begin
			golden = golden_mem[m];
			@(negedge i_clk);
			if(o_data !== golden) begin
				$display("P%02d: Error:  yours=%h != expect=%h", m, o_data, golden); 
				error = error + 1;
			end else begin
				$display("P%02d: Correct!! %h", m, o_data);
				correct = correct + 1;
			end
			@(posedge i_clk);
			golden = 0;
			#(`CYCLE * 1);
			m = m+1;
		end
	end
	over2 = 1;
end

always @(*) begin over = over1 && over2; end

initial begin
 		@(posedge over)      
 		if(over) begin
 		   $display("\l-----------------------------------------------------\l");
 		   if ((error == 0) && (correct == `Y_AXIS_NUM    )) begin
 		      $display("Congratulations! All data have been generated successfully!\l");
 		      $display("-------------------------PASS------------------------\l");
 		   end else begin
 		      $display("Final Simulation Result as below: \l");
 		      $display("-----------------------------------------------------\l");
 		      $display("Error:  %3d \l", error);
 		      $display("-----------------------------------------------------\l");
 		   end
 		end
 		#(`CYCLE/2); $finish;
end
// initial begin
// 	@(posedge i_clk);
 	// 	#(`CYCLE * 2);
// 	i_valid = 1;
// 	i_data = 64'b10000001_00000110_00000100_10000101_00000010_00000100_00001001_00000001;
// 	data_1 = 64'b00000010_00000111_00001000_00000011_00000110_00001000_00000111_00000011;
// end
// initial begin
// 	@(posedge i_clk);
// 	#(`CYCLE * 6);
// 	golden = 32'b00000111_00001000_00001000_00001001;
// 	@(negedge i_clk);
// 	if(done) begin
// 		if(o_data !== golden) begin
  //             $display("o_hard_bit=%16b  != expect %16b", o_data, golden);
// 			$finish;
// 		end else begin
  //             $display("Correct!!");
// 			$finish;
// 		end
// 	end
	
// end



      
endmodule

