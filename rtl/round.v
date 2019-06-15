/*
 * Copyright 2013, Homer Hsing <homer.hsing@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

`define low_pos(x,y)        `high_pos(x,y) - 63
`define high_pos(x,y)       1599 - 64*(5*y+x)
`define add_1(x)            (x == 4 ? 0 : x + 1)
`define add_2(x)            (x == 3 ? 0 : x == 4 ? 1 : x + 2)
`define sub_1(x)            (x == 0 ? 4 : x - 1)
`define rot_up(in, n)       {in[63-n:0], in[63:63-n+1]}
`define rot_up_1(in)        {in[62:0], in[63]}

module round(in, round_const, out);
    input  [1599:0] in;
    input  [63:0]   round_const;
    output [1599:0] out;

    wire   [63:0]   a[24:0];
    wire   [63:0]   b[4:0];
    wire   [63:0]   c[24:0], d[24:0], e[24:0], f[24:0], g[24:0];

    genvar x, y;

    /* assign "a[x][y][z] == in[w(5y+x)+z]" */
    generate
      for(y=0; y<5; y=y+1)
        begin : L0
          for(x=0; x<5; x=x+1)
            begin : L1
              assign a[x*5+y] = in[`high_pos(x,y) : `low_pos(x,y)];
            end
        end
    endgenerate

    /* calc "b[x] == a[x][0] ^ a[x][1] ^ ... ^ a[x][4]" */
    generate
      for(x=0; x<5; x=x+1)
        begin : L2
          assign b[x] = a[5*x] ^ a[5*x+1] ^ a[5*x+2] ^ a[5*x+3] ^ a[5*x+4];
        end
    endgenerate

    /* calc "c == theta(a)" */
    generate
      for(y=0; y<5; y=y+1)
        begin : L3
          for(x=0; x<5; x=x+1)
            begin : L4
              assign c[5*x+y] = a[5*x+y] ^ b[`sub_1(x)] ^ `rot_up_1(b[`add_1(x)]);
            end
        end
    endgenerate

    /* calc "d == rho(c)" */
    assign d[0] = c[0];
    assign d[5] = `rot_up_1(c[5]);
    assign d[10] = `rot_up(c[10], 62);
    assign d[15] = `rot_up(c[15], 28);
    assign d[20] = `rot_up(c[20], 27);
    assign d[1] = `rot_up(c[1], 36);
    assign d[6] = `rot_up(c[6], 44);
    assign d[11] = `rot_up(c[11], 6);
    assign d[16] = `rot_up(c[16], 55);
    assign d[21] = `rot_up(c[21], 20);
    assign d[2] = `rot_up(c[2], 3);
    assign d[7] = `rot_up(c[7], 10);
    assign d[12] = `rot_up(c[12], 43);
    assign d[17] = `rot_up(c[17], 25);
    assign d[22] = `rot_up(c[22], 39);
    assign d[3] = `rot_up(c[3], 41);
    assign d[8] = `rot_up(c[8], 45);
    assign d[13] = `rot_up(c[13], 15);
    assign d[18] = `rot_up(c[18], 21);
    assign d[23] = `rot_up(c[23], 8);
    assign d[4] = `rot_up(c[4], 18);
    assign d[9] = `rot_up(c[9], 2);
    assign d[14] = `rot_up(c[14], 61);
    assign d[19] = `rot_up(c[19], 56);
    assign d[24] = `rot_up(c[24], 14);

    /* calc "e == pi(d)" */
    assign e[0] = d[0];
    assign e[2] = d[5];
    assign e[4] = d[10];
    assign e[1] = d[15];
    assign e[3] = d[20];
    assign e[8] = d[1];
    assign e[5] = d[6];
    assign e[7] = d[11];
    assign e[9] = d[16];
    assign e[6] = d[21];
    assign e[11] = d[2];
    assign e[13] = d[7];
    assign e[10] = d[12];
    assign e[12] = d[17];
    assign e[14] = d[22];
    assign e[19] = d[3];
    assign e[16] = d[8];
    assign e[18] = d[13];
    assign e[15] = d[18];
    assign e[17] = d[23];
    assign e[22] = d[4];
    assign e[24] = d[9];
    assign e[21] = d[14];
    assign e[23] = d[19];
    assign e[20] = d[24];

    /* calc "f = chi(e)" */
    generate
      for(y=0; y<5; y=y+1)
        begin : L5
          for(x=0; x<5; x=x+1)
            begin : L6
              assign f[5*x+y] = e[5*x+y] ^ ((~ e[5*`add_1(x)+y]) & e[5*`add_2(x)+y]);
            end
        end
    endgenerate

    /* calc "g = iota(f)" */
    generate
      for(x=0; x<64; x=x+1)
        begin : L60
          if(x==0 || x==1 || x==3 || x==7 || x==15 || x==31 || x==63)
            assign g[0][x] = f[0][x] ^ round_const[x];
          else
            assign g[0][x] = f[0][x];
        end
    endgenerate
    
    generate
      for(y=0; y<5; y=y+1)
        begin : L7
          for(x=0; x<5; x=x+1)
            begin : L8
              if(x!=0 || y!=0)
                assign g[5*x+y] = f[5*x+y];
            end
        end
    endgenerate

    /* assign "out[w(5y+x)+z] == out_var[x][y][z]" */
    generate
      for(y=0; y<5; y=y+1)
        begin : L99
          for(x=0; x<5; x=x+1)
            begin : L100
              assign out[`high_pos(x,y) : `low_pos(x,y)] = g[5*x+y];
            end
        end
    endgenerate
endmodule

`undef low_pos
`undef high_pos
`undef add_1
`undef add_2
`undef sub_1
`undef rot_up
`undef rot_up_1
