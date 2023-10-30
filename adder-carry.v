/* ACM Class System (I) Fall Assignment 1 
 *
 *
 * Implement your naive adder here
 * 
 * GUIDE:
 *   1. Create a RTL project in Vivado
 *   2. Put this file into `Sources'
 *   3. Put `test_adder.v' into `Simulation Sources'
 *   4. Run Behavioral Simulation
 *   5. Make sure to run at least 100 steps during the simulation (usually 100ns)
 *   6. You can see the results in `Tcl console'
 *
 */


//要算P，G，PM，GM
module CLA(
        input [3:0] p, g,
        input cin,
        output [3:1] c,
        output cout, pm, gm
    );
    assign c[1] = g[0] | cin & p[0];
    assign c[2] = g[1] | g[0] & p[1] | cin  & (&p[1:0]);
    assign c[3] = g[2] | g[1] & p[2] | g[0] & (&p[2:1]) | cin  & (&p[2:0]);
    assign cout = g[3] | g[2] & p[3] | g[1] & (&p[3:2]) | g[0] & (&p[3:1]) | cin & (&p[3:0]);
	assign {gm,pm}={g[3] | g[2] & p[3] | g[1] & (&p[3:2]) | g[0] & (&p[3:1]),&p};
endmodule 


module CLA4(
        input [3:0] x1, x2,
        input cin,
        output [3:0] s,
        output cout, p, g
    );
    wire [3:0] P= x1 ^ x2;
    wire [3:0] G= x1 & x2;
    wire [3:1] c;
    CLA process(.p(P), .g(G), .c(c), .cin(cin), .cout(cout), .gm(g), .pm(p));
	assign s0 = {c,cin};
    assign s = P ^ s0;
endmodule //CLA4


module CLA16 (
        input [15:0] X1, X2,
        input cin,
        output [15:0] s,
        output cout, p, g
    );
    wire [3:0] G;
    wire [3:0] P;
    wire [3:1] c;
    CLA4 a0(.x1(X1[ 3: 0]), .x2(X2[ 3: 0]), .s(s[ 3: 0]), .cin(cin),  .p(P[0]), .g(G[0]));
    CLA4 a1(.x1(X1[ 7: 4]), .x2(X2[ 7: 4]), .s(s[ 7: 4]), .cin(c[1]), .p(P[1]), .g(G[1]));
    CLA4 a2(.x1(X1[11: 8]), .x2(X2[11: 8]), .s(s[11: 8]), .cin(c[2]), .p(P[2]), .g(G[2]));
    CLA4 a3(.x1(X1[15:12]), .x2(X2[15:12]), .s(s[15:12]), .cin(c[3]), .p(P[3]), .g(G[3]));
    CLA process(.p(P), .g(G), .c(c), .cin(cin), .cout(cout), .gm(g), .pm(p));
endmodule //CLA16

module adder(
        input       [15:0]          x1,
        input       [15:0]          x2,
        output      [15:0]          s,
        output                      c
    );
    CLA16 add(.X1(x1), .X2(x2), .s(s), .cin(1'b0), .cout(c));
endmodule 
//输出结果