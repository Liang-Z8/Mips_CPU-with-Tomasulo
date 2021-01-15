`timescale 1ns/1ps
`include "head.v"
module Mem(
        input clk,
        input wena,
        input [8:0] addrL,
        input [8:0] addrS,
        input [31:0] data_in,
        output fns,
        output [31:0] data_out
        );
    reg [31:0] states [0:512];
    reg finish;
    assign fns=finish;
    generate
        genvar i;
        for (i = 1; i < 512; i = i + 1) begin: regfile
            initial begin
                    states[i] <= 32'b1;
                    states[i] <= 32'b1;
            end
        end
    endgenerate

    initial begin
        states[5]<=32'h00000005;
        states[4]<=32'h00000004;
        finish=0;
    end
    
    always@(posedge clk) begin
        if(wena) begin
            if(addrS!=0) states[addrS]=data_in;
            finish=1;
        end
        else finish=0;
    end 
    assign data_out=states[addrL];
endmodule