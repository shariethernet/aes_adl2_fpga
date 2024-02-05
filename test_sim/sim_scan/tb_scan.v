`include "timescale.v"
`define MYKEY 128'h000102030405060708090a0b0c0d0e0f
`define MYIN1 128'hB9D1C48E348FE771FA464A77A178FB07
`define MYOUT1 128'h95F8847369A8573D76AF987AB30A5DE2

`define MYIN2 128'hDCFEAD50D1D9FD08B386EFB08B142F74
`define MYOUT2 128'h85E5F163C857B0AC1162E07DD3432B66

module tb_aes;

//  reg  [127:0] Kin;  // Key input
//  reg  [127:0] Din;  // Data input
  wire [127:0] Dout; // Data output
  reg  Krdy;         // Key input ready
  reg  Drdy;         // Data input ready
  reg  EncDec;       // 0:Encryption 1:Decryption
  reg  RSTn;         // Reset (Low active)
  reg  EN;           // AES circuit enable
  reg  CLK;          // System clock
  wire BSY;          // Busy signal
  wire Kvld;         // Data output valid
  wire Dvld;         // Data output valid
//scanin
  reg[259:0] SCAN_IN_REG;
  reg  scanin_in;
  wire scanin_out;
  reg  scan_clk;
  reg  scanin_update_clk;
  reg  scanin_se;
  wire[127:0] key_in;
  wire[127:0] data_in;
  wire [3:0] U;
//scanout
reg scanout_in,scanout_update_clk,scanout_se;
reg [127:0] data_out;
wire scanout_out;
reg [131:0] SCAN_OUT_REG;

integer i;

initial
   begin
	$dumpfile ("example1_scanin.vpd");
	$dumpvars(0,tb_aes);

   end

initial begin
	CLK = 0;
	scan_clk = 0;
	scanin_update_clk = 0;
	scanout_update_clk = 0;

	SCAN_IN_REG = {`MYKEY,`MYIN1,4'b0};
	scanin_in = 0;
	scanin_se = 1;
	scanout_se = 0;

//	Kin = 128'h0;
//	Din = 128'h0;
	Krdy = 1'b0;
	Drdy = 1'b0;
	EncDec = 1'b0;
	RSTn = 1'b0;
	EN = 1'b0;
#10
RSTn = 1;

end

initial begin
 for (i=0; i<260; i=i+1) begin
   @(posedge scan_clk) begin
     scanin_in <= SCAN_IN_REG[i];
   end
 end
#10
  @(posedge scan_clk)
   scanin_update_clk <= 1;
   scanin_se <= 0;

#10
  @(posedge scan_clk)
   scanin_update_clk <= 0;
  #10
// finish updating Kin Din to AES

	@(posedge CLK);
	#2.5
	//#1
	Krdy = 1;
//	Drdy = 1;
	EncDec = 0;
	EN = 1;

	@(posedge CLK);
	#2.5
	//#1
	Krdy = 0;
#0.5
Drdy = 1;
	@(posedge CLK);
	#2.5
	//#1
	Drdy = 0;
//	@(posedge CLK);
//	#2.5

# 200
//save data to scanout DFF
 scanout_se = 1;
//start shifting
 
 for (i=0; i<132; i=i+1) begin
   @(posedge scan_clk) begin
     SCAN_OUT_REG[i] <= scanout_out;
   end
 end

end

initial begin
 #20000
 $finish;
end

always #5  CLK = ~CLK;
always #20 scan_clk = ~scan_clk;

AES_Comp aes0 (
	.Kin(key_in),
	.Din(data_in),
	.Dout(Dout),
	.Krdy(Krdy),
	.Drdy(Drdy),
	.RSTn(RSTn),
	.EN(EN),
	.CLK(CLK),
	.BSY(BSY)
);

scanout scanout( 
	.scan_in(scanout_in), 
	.scan_out(scanout_out), 
	.scan_clk(scan_clk), 
	.update_clk(scanout_update_clk), 
	.se(scanout_se), 
	.Data_out(Dout),
	.U(U) 
);

scanin scanin(
	.scan_in(scanin_in), 
	.scan_out(scanin_out), 
	.scan_clk(scan_clk), 
	.update_clk(scanin_update_clk), 
	.se(scanin_se), 
	.Key_in(key_in), 
	.Data_in(data_in),
	.U(U)
);
endmodule


