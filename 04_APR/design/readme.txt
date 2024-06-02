module CHIP ( i_clk, i_rst, i_data, i_valid, o_data, o_valid );
  input [15:0] i_data;
  input        i_valid;
  output [7:0] o_data;
  output       o_valid;
  input i_clk, i_rst;

  
  wire [15:0] in_i_data;
  wire        in_i_valid;
  wire [ 7:0] in_o_data;
  wire        in_o_valid;
  wire in_i_clk, in_i_rst;
  wire n_logic0,n_logic1;
  core core_in( .i_clk(in_i_clk), .i_rst(in_i_rst), .i_data(in_i_data), .i_valid(in_i_valid), .o_data(in_o_data), .o_valid(in_o_valid) );
  
  TIE0 ipad_n_logic0(.O(n_logic0));
  TIE1 ipad_n_logic1(.O(n_logic1));
  XMD ipad_i_clk (.O(in_i_clk), .I(i_clk), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
  XMD ipad_i_rst (.O(in_i_rst), .I(i_rst), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
  XMD ipad_i_data_0 (.O(in_i_data[0]), .I(i_data[0]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
  XMD ipad_i_data_1 (.O(in_i_data[1]), .I(i_data[1]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
  XMD ipad_i_data_2 (.O(in_i_data[2]), .I(i_data[2]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
  XMD ipad_i_data_3 (.O(in_i_data[3]), .I(i_data[3]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
  XMD ipad_i_data_4 (.O(in_i_data[4]), .I(i_data[4]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
  XMD ipad_i_data_5 (.O(in_i_data[5]), .I(i_data[5]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
  XMD ipad_i_data_6 (.O(in_i_data[6]), .I(i_data[6]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
  XMD ipad_i_data_7 (.O(in_i_data[7]), .I(i_data[7]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
  XMD ipad_i_data_8 (.O(in_i_data[8]), .I(i_data[8]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
  XMD ipad_i_data_9 (.O(in_i_data[9]), .I(i_data[9]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
  XMD ipad_i_data_10 (.O(in_i_data[10]), .I(i_data[10]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
  XMD ipad_i_data_11 (.O(in_i_data[11]), .I(i_data[11]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
  XMD ipad_i_data_12 (.O(in_i_data[12]), .I(i_data[12]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
  XMD ipad_i_data_13 (.O(in_i_data[13]), .I(i_data[13]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
  XMD ipad_i_data_14 (.O(in_i_data[14]), .I(i_data[14]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
  XMD ipad_i_data_15 (.O(in_i_data[15]), .I(i_data[15]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
  XMD ipad_i_valid_0  (.O(in_i_valid), .I(i_valid), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));

  YA2GSD ipad_o_data_0 (.O(o_data[0]), .I(in_o_data[0]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0));
  YA2GSD ipad_o_data_1 (.O(o_data[1]), .I(in_o_data[1]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0));
  YA2GSD ipad_o_data_2 (.O(o_data[2]), .I(in_o_data[2]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0));
  YA2GSD ipad_o_data_3 (.O(o_data[3]), .I(in_o_data[3]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0));
  YA2GSD ipad_o_data_4 (.O(o_data[4]), .I(in_o_data[4]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0));
  YA2GSD ipad_o_data_5 (.O(o_data[5]), .I(in_o_data[5]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0));
  YA2GSD ipad_o_data_6 (.O(o_data[6]), .I(in_o_data[6]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0));
  YA2GSD ipad_o_data_7 (.O(o_data[7]), .I(in_o_data[7]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0));
  YA2GSD ipad_o_valid_0 (.O(o_valid), .I(in_o_valid), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0));
endmodule