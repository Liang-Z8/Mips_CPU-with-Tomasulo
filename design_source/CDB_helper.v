`timescale 1ns/1ps
`include "head.v"
module CDBHelper(
    input [2:0]requires,
    output reg [2:0] accepts
);
    always@(*) begin
        if (requires[2])
            accepts = 3'b100;
        else if (requires[1])
            accepts = 3'b010;
        else if (requires[0])
            accepts = 3'b001;
        else
            accepts = 3'b000;
    end
endmodule