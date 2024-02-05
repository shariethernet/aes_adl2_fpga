//`include "timescale.v"
//`timescale 1ns / 10ps
`define MYKEY 128'h000102030405060708090a0b0c0d0e0f
`define MYIN  128'hB9D1C48E348FE771FA464A77A178FB07
`define MYOUT 128'h95F8847369A8573D76AF987AB30A5DE2
`define MYIN2 128'hDCFEAD50D1D9FD08B386EFB08B142F74
`define MYOUT2 128'h85E5F163C857B0AC1162E07DD3432B66
`define MYIN3 128'h4CFDA4C3076157F581B71E46E8CB5675
`define MYOUT3 128'h5AE6F0344CEBA2511D6376C89AC33DDC
`define MYINtvla  128'h00000000000000000000000000000000
//`define MYKEYtvla 128'h0123456789abcdef123456789abcdef0
`define MYIN5 128'h16D62BA4D338FF7BA6B8CF19BAB720E7
`define MYOUT5 128'h19D727FE2431C2113BFEF100C3C6D1CE

module tb_aes;

  reg  [127:0] Kin;  // Key input
  reg  [127:0] Din;  // Data input
  wire [127:0] Dout; // Data output
  reg  Krdy;         // Key input ready
  reg  Drdy;         // Data input ready
  reg  RSTn;         // Reset (Low active)
  reg  EN;           // AES circuit enable
  reg  CLK;          // System clock
  wire BSY;          // Busy signal


integer		n, error_cnt,i;
reg	[127:0]	plain, ciph;
integer file;
initial
   begin
	$dumpfile ("AES_Comp_ENC.vcd");
	$dumpvars(0,aes0);

   end

initial
   begin
	$display("\n\n");
	$display("*****************************************************");
	$display("* AES Test bench ...");
	$display("*****************************************************");
	$display("\n");

	
	error_cnt = 0;
	
	Kin = 128'h0;
	Din = 128'h0;
	Krdy = 1'b0;
	Drdy = 1'b0;
	RSTn = 1'b0;
	EN = 1'b0;
	CLK = 1'b1;
	

	@(posedge CLK);
	#9.5
	RSTn = 1;

	$display("");
	$display("");
	$display("Din 1");

  
	Kin     = `MYKEY;
	Din 	= `MYIN;
	plain   = `MYIN;
	ciph	= `MYOUT;
	Kin     = `MYKEY;


	@(posedge CLK);
	#2.5
	EN   = 1;
	Krdy = 1;
	Drdy = 1;
	
	@(posedge CLK);
	#2.5
	Krdy = 0;
	@(posedge CLK);
	#2.5
	Drdy = 0;
	@(posedge CLK);
	#2.5

	while(BSY) begin
		@(posedge CLK);
	end
	if(Dout != ciph | (|Dout)==1'bx)
	   begin
		$display("ERROR: (a) Vector mismatch. Expected %x, Got %x",ciph, Dout);
		error_cnt = error_cnt + 1;
	   end
	else
	$display("INFO: (a) Vector xpected %x, Got %x", ciph, Dout);




	@(posedge CLK); 
	

	$display("");
	$display("");
	$display("Test Done. ");
	$display("");
	$display("");
	//repeat(10)	@(posedge CLK);
	#10;
	$finish;
end


//always #20 CLK = ~CLK;
always #5 CLK = ~CLK;


AES_Comp aes0 (
	.Kin(Kin),
	.Din(Din),
	.Dout(Dout),
	.Krdy(Krdy),
	.Drdy(Drdy),
	.RSTn(RSTn),
	.EN(EN),
	.CLK(CLK),
	.BSY(BSY)
);

endmodule
