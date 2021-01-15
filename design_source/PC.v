`timescale 1ns / 1ps
`include "head.v"
module PC(
    input clk,
    input nRST,
    input insStall,//指令暂停发射
    input [31:0]newpc,
    input pcWrite,
    output reg [31:0]pc
    );
    always@(posedge clk or negedge nRST) begin
        if (pcWrite && !insStall || !nRST) begin
            pc <= nRST == 0 ? 0 : newpc;
        end else begin
            pc <= pc;
        end
    end
endmodule
 
module PCControl(
    input [31:0] pc,
    input [15:0] immd16,
    input [25:0] immd26,
    input [1:0] sel,//控制跳转
    input [31:0] rs,
    output reg [31:0] newpc
    );
    initial begin
        newpc = 0;
    end
    wire [31:0]exd_immd16 = { {16{immd16[15]}}, immd16};
    always@(*) begin
        case (sel)
            `NextIns : newpc <= pc + 4;
            `RelJmp : newpc <= (pc + 4 + (exd_immd16 << 2));
            `AbsJmp : newpc <= {pc[31:26], immd26};
            `RsJmp : newpc <= rs;
        endcase
    end
endmodule
