//wrap AES_Comp with the input and outputs split as 32 bit chunks to use in the axi interface

module harness_axi(
    input [31:0] IN_DATA0,
    input [31:0] IN_DATA1,
    input [31:0] IN_DATA2, 
    input [31:0] IN_DATA3,
    
    input [31:0] IN_KEY0,
    input [31:0] IN_KEY1,
    input [31:0] IN_KEY2,
    input [31:0] IN_KEY3,
    
    output [31:0] OUT_DATA0, 
    output [31:0] OUT_DATA1,
    output [31:0] OUT_DATA2,
    output [31:0] OUT_DATA3,
    input  Krdy,         // Key input ready
    input  Drdy,         // Data input ready
    input  RSTn,         // Reset (Low active)
    input  EN  ,        // AES circuit enable
    input  CLK ,        // System clock
    output BSY         // Busy signal
);
wire [127:0] IN_DATA, IN_KEY, OUT_DATA;

assign IN_DATA = {IN_DATA3, IN_DATA2, IN_DATA1, IN_DATA0};
assign IN_KEY = {IN_KEY3, IN_KEY2, IN_KEY1, IN_KEY0};
assign {OUT_DATA3, OUT_DATA2, OUT_DATA1, OUT_DATA0} = OUT_DATA;

AES_Comp dut(.Kin(IN_KEY), .Din(IN_DATA), .Dout(OUT_DATA), .Krdy(Krdy), .Drdy(Drdy), .RSTn(RSTn), .EN(EN), .CLK(CLK), .BSY(BSY));

endmodule