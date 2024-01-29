//`timescale 1ns / 1ps

module AES_Comp(Kin, Din, Dout, Krdy, Drdy, RSTn, EN, CLK, BSY);
input  [127:0] Kin;  // Key input
input  [127:0] Din;  // Data input
output [127:0] Dout; // Data output
input  Krdy;         // Key input ready
input  Drdy;         // Data input ready
input  RSTn;         // Reset (Low active)
input  EN;           // AES circuit enable
input  CLK;          // System clock
output BSY;          // Busy signal

AES_Comp_ENC AES_Comp_ENC(Kin, Din, Dout, Krdy, Drdy, RSTn, EN, CLK, BSY);

endmodule


/////////////////////////////
//   GF(2^2^2^2) inverter  //
/////////////////////////////
module AES_Comp_GFinvComp(x, y);
input  [7:0] x;
output [7:0] y;

wire [8:0] da, db, dx, dy, va, tp, tn;
wire [3:0] u, v;
wire [4:0] mx;
wire [5:0] my;

assign da ={x[3], x[2]^x[3], x[2], x[1]^x[3], x[0]^x[1]^x[2]^x[3], x[0]^x[2], x[1], x[0]^x[1], x[0]};
assign db ={x[7], x[6]^x[7], x[6], x[5]^x[7], x[4]^x[5]^x[6]^x[7], x[4]^x[6], x[5], x[4]^x[5], x[4]};
assign va ={v[3], v[2]^v[3], v[2], v[1]^v[3], v[0]^v[1]^v[2]^v[3], v[0]^v[2], v[1], v[0]^v[1], v[0]};
assign dx = da ^ db;
assign dy = da & dx;
assign tp = va & dx;
assign tn = va & db;

assign u = {dy[0] ^ dy[1] ^ dy[3] ^ dy[4] ^ x[4] ^ x[5] ^ x[6],
            dy[0] ^ dy[2] ^ dy[3] ^ dy[5] ^ x[4] ^ x[7],
            dy[0] ^ dy[1] ^ dy[7] ^ dy[8] ^ x[7],
            dy[0] ^ dy[2] ^ dy[6] ^ dy[7] ^ x[6] ^ x[7]};

assign y = {tn[0] ^ tn[1] ^ tn[3] ^ tn[4], tn[0] ^ tn[2] ^ tn[3] ^ tn[5],
            tn[0] ^ tn[1] ^ tn[7] ^ tn[8], tn[0] ^ tn[2] ^ tn[6] ^ tn[7],
            tp[0] ^ tp[1] ^ tp[3] ^ tp[4], tp[0] ^ tp[2] ^ tp[3] ^ tp[5],
            tp[0] ^ tp[1] ^ tp[7] ^ tp[8], tp[0] ^ tp[2] ^ tp[6] ^ tp[7]};

////////////////////////
// GF(2^2^2) Inverter //
////////////////////////
  assign mx = {mx[0] ^ mx[1] ^ u[2],
               mx[0] ^ mx[2] ^ u[3],
               u[1] & (u[1] ^ u[3]),
               (u[0] ^ u[1]) & (u[0] ^ u[1]  ^ u[2] ^ u[3]),
               u[0] & (u[0] ^ u[2])};

  assign my = {~(mx[4] & u[3]),
               ~(mx[3] & (u[2] ^ u[3])),
               ~((mx[3] ^ mx[4]) & u[2]),
               ~(mx[4] & (u[1] ^ u[3])),
               ~(mx[3] & (u[0] ^ u[1]  ^ u[2] ^ u[3])),
               ~((mx[3] ^ mx[4]) & (u[0] ^ u[2]))};

  assign v = {my[3]^my[4], my[3]^my[5], my[0]^my[1], my[0]^my[2]};
endmodule


/////////////////////////////
//     Sbox GF(2^2^2^2)    //
/////////////////////////////
module AES_Comp_SboxComp(x, y);
input  [7:0] x;
output [7:0] y;

wire [7:0] a, b;

assign a = {x[5] ^ x[7],
            x[1] ^ x[2] ^ x[3] ^ x[4] ^ x[6] ^ x[7],
            x[2] ^ x[3] ^ x[5] ^ x[7],
            x[1] ^ x[2] ^ x[3] ^ x[5] ^ x[7],
            x[1] ^ x[2] ^ x[6] ^ x[7],
            x[1] ^ x[2] ^ x[3] ^ x[4] ^ x[7],
            x[1] ^ x[4] ^ x[6],
            x[0] ^ x[1] ^ x[6]};

AES_Comp_GFinvComp AES_Comp_GFinvComp(a, b);

assign y = { b[2] ^ b[3] ^ b[7],
            ~b[4] ^ b[5] ^ b[6] ^ b[7],
            ~b[2] ^ b[7],
             b[0] ^ b[1] ^ b[4] ^ b[7],
             b[0] ^ b[1] ^ b[2],
             b[0] ^ b[2] ^ b[3] ^ b[4] ^ b[5] ^ b[6],
            ~b[0] ^ b[7],
            ~b[0] ^ b[1] ^ b[2] ^ b[6] ^ b[7]};
endmodule


/////////////////////////////
//   SubBytes GF(2^2^2^2)  //
/////////////////////////////
module AES_Comp_SubBytesComp (x, y);
input  [31:0] x;
output [31:0] y;

AES_Comp_SboxComp Sbox3(x[31:24], y[31:24]);
AES_Comp_SboxComp Sbox2(x[23:16], y[23:16]);
AES_Comp_SboxComp Sbox1(x[15: 8], y[15: 8]);
AES_Comp_SboxComp Sbox0(x[ 7: 0], y[ 7: 0]);
endmodule



/////////////////////////////
//       MixColumns        //
/////////////////////////////
module AES_Comp_MixColumns(x, y);
input  [31:0]  x;
output [31:0]  y;

wire [7:0] a3, a2, a1, a0, b3, b2, b1, b0;

assign a3 = x[31:24]; assign a2 = x[23:16];
assign a1 = x[15: 8]; assign a0 = x[ 7: 0];

assign b3 = a3 ^ a2; assign b2 = a2 ^ a1;
assign b1 = a1 ^ a0; assign b0 = a0 ^ a3;

assign y = {a2[7] ^ b1[7] ^ b3[6],         a2[6] ^ b1[6] ^ b3[5],
            a2[5] ^ b1[5] ^ b3[4],         a2[4] ^ b1[4] ^ b3[3] ^ b3[7],
            a2[3] ^ b1[3] ^ b3[2] ^ b3[7], a2[2] ^ b1[2] ^ b3[1],
            a2[1] ^ b1[1] ^ b3[0] ^ b3[7], a2[0] ^ b1[0] ^ b3[7],
            a3[7] ^ b1[7] ^ b2[6],         a3[6] ^ b1[6] ^ b2[5],
            a3[5] ^ b1[5] ^ b2[4],         a3[4] ^ b1[4] ^ b2[3] ^ b2[7],
            a3[3] ^ b1[3] ^ b2[2] ^ b2[7], a3[2] ^ b1[2] ^ b2[1],
            a3[1] ^ b1[1] ^ b2[0] ^ b2[7], a3[0] ^ b1[0] ^ b2[7],
            a0[7] ^ b3[7] ^ b1[6],         a0[6] ^ b3[6] ^ b1[5],
            a0[5] ^ b3[5] ^ b1[4],         a0[4] ^ b3[4] ^ b1[3] ^ b1[7],
            a0[3] ^ b3[3] ^ b1[2] ^ b1[7], a0[2] ^ b3[2] ^ b1[1],
            a0[1] ^ b3[1] ^ b1[0] ^ b1[7], a0[0] ^ b3[0] ^ b1[7],
            a1[7] ^ b3[7] ^ b0[6],         a1[6] ^ b3[6] ^ b0[5],
            a1[5] ^ b3[5] ^ b0[4],         a1[4] ^ b3[4] ^ b0[3] ^ b0[7],
            a1[3] ^ b3[3] ^ b0[2] ^ b0[7], a1[2] ^ b3[2] ^ b0[1],
            a1[1] ^ b3[1] ^ b0[0] ^ b0[7], a1[0] ^ b3[0] ^ b0[7]};
endmodule



/////////////////////////////
//     Encryption Core     //
/////////////////////////////
module AES_Comp_EncCore(di, ki, Rrg, do, ko);
input  [127:0] di, ki;
input  [9:0]   Rrg;
output [127:0] do, ko;

wire   [127:0] sb, sr, mx;
wire   [31:0]  so;

AES_Comp_SubBytesComp SB3 (di[127:96], sb[127:96]);
AES_Comp_SubBytesComp SB2 (di[ 95:64], sb[ 95:64]);
AES_Comp_SubBytesComp SB1 (di[ 63:32], sb[ 63:32]);
AES_Comp_SubBytesComp SB0 (di[ 31: 0], sb[ 31: 0]);
AES_Comp_SubBytesComp SBK ({ki[23:16], ki[15:8], ki[7:0], ki[31:24]}, so);

assign sr = {sb[127:120], sb[ 87: 80], sb[ 47: 40], sb[  7:  0],
             sb[ 95: 88], sb[ 55: 48], sb[ 15:  8], sb[103: 96],
             sb[ 63: 56], sb[ 23: 16], sb[111:104], sb[ 71: 64],
             sb[ 31: 24], sb[119:112], sb[ 79: 72], sb[ 39: 32]};

AES_Comp_MixColumns MX3 (sr[127:96], mx[127:96]);
AES_Comp_MixColumns MX2 (sr[ 95:64], mx[ 95:64]);
AES_Comp_MixColumns MX1 (sr[ 63:32], mx[ 63:32]);
AES_Comp_MixColumns MX0 (sr[ 31: 0], mx[ 31: 0]);

assign do = ((Rrg[0] == 1)? sr: mx) ^ ki;

function [7:0] rcon;
input [9:0] x;
  casex (x)
    10'bxxxxxxxxx1: rcon = 8'h01;
    10'bxxxxxxxx1x: rcon = 8'h02;
    10'bxxxxxxx1xx: rcon = 8'h04;
    10'bxxxxxx1xxx: rcon = 8'h08;
    10'bxxxxx1xxxx: rcon = 8'h10;
    10'bxxxx1xxxxx: rcon = 8'h20;
    10'bxxx1xxxxxx: rcon = 8'h40;
    10'bxx1xxxxxxx: rcon = 8'h80;
    10'bx1xxxxxxxx: rcon = 8'h1b;
    10'b1xxxxxxxxx: rcon = 8'h36;
  endcase
endfunction

assign ko = {ki[127:96] ^ {so[31:24] ^ rcon(Rrg), so[23: 0]},
             ki[ 95:64] ^ ko[127:96],
             ki[ 63:32] ^ ko[ 95:64],
             ki[ 31: 0] ^ ko[ 63:32]};
endmodule



/////////////////////////////
//   AES for encryption    //
/////////////////////////////
module AES_Comp_ENC(Kin, Din, Dout, Krdy, Drdy, RSTn, EN, CLK, BSY);
input  [127:0] Kin;  // Key input
input  [127:0] Din;  // Data input
output [127:0] Dout; // Data output
input  Krdy;         // Key input ready
input  Drdy;         // Data input ready
input  RSTn;         // Reset (Low active)
input  EN;           // AES circuit enable
input  CLK;          // System clock
output BSY;          // Busy signal

reg  [127:0] Drg;    // Data register
reg  [127:0] Krg;    // Key register
reg  [127:0] KrgX;   // Temporary key Register
reg  [9:0]   Rrg;    // Round counter
reg  BSYrg;
wire [127:0] Dnext, Knext;

AES_Comp_EncCore EC (Drg, KrgX, Rrg, Dnext, Knext);

assign Dout = Drg;
assign BSY  = BSYrg;

always @(posedge CLK) begin
  if (RSTn == 0) begin
    Krg    <= 128'h0000000000000000;
    KrgX   <= 128'h0000000000000000;
    Rrg    <= 10'b0000000001;
    BSYrg  <= 0;
  end
  else if (EN == 1) begin
    if (BSYrg == 0) begin
      if (Krdy == 1) begin
        Krg    <= Kin;
        KrgX   <= Kin;
      end
      else if (Drdy == 1) begin
        Rrg    <= {Rrg[8:0], Rrg[9]};
        KrgX   <= Knext;
        Drg    <= Din ^ Krg;
        BSYrg  <= 1;
      end
    end
    else begin
      Drg <= Dnext;
      if (Rrg[0] == 1) begin
        KrgX   <= Krg;
        BSYrg  <= 0;
      end
      else begin
        Rrg    <= {Rrg[8:0], Rrg[9]};
        KrgX   <= Knext;
      end
    end
  end
end
endmodule
