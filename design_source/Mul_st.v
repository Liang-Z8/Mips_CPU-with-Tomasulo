`timescale 1ns/1ps
`include "head.v"

module Mul_st(
    input clk,
    input nRST,
    //CU
    input issue,
    input [4:0]stnum,
    input [3:0]ALUop,
    input [31:0]data1,
    input [31:0]data2,
    input [4:0]label1,
    input [4:0]label2,
    input [15:0]immd,
    output reg[2:0] Busy,
    //CBD
    input BCEN,
    output Breq,
    input BreqAC,
    input [31:0]BCdata,
    input [4:0]BClabel,
    output reg[4:0]BCLabelOut,
    output reg[31:0]BCDataOut
    );

    // 设置了三个保留站
    // 若使b2'11来索引，无效
    reg [3:0]Op[2:0];
    reg [4:0]Qj[2:0];
    reg [31:0]Vj[2:0];
    reg [4:0]Qk[2:0];
    reg [31:0]Vk[2:0];
    wire signed [31:0] sVj[2:0];
    wire signed [31:0] sVk[2:0];
    //转化为无符号数
    assign sVj[0]=$signed(Vj[0]);
    assign sVj[1]=$signed(Vj[1]);
    assign sVj[2]=$signed(Vj[2]);
    assign sVk[0]=$signed(Vk[0]);
    assign sVk[1]=$signed(Vk[1]);
    assign sVk[2]=$signed(Vk[2]);
    //ALU
    reg [31:0]result[2:0];
    reg [2:0]finish;
    reg [2:0]BCready;
    assign Breq=(BCready==0)?0:1;
    initial begin
        Busy[0] = 0;
        Busy[1] = 0;
        Busy[2] = 0;
    end

    //接受数据接收数据，stnum信号对应为准
    always@(posedge clk) begin
        case (stnum)
            `MUL0:begin
                Op[0]<=ALUop;
                Qj[0]<=label1;
                Vj[0]<=data1;
                Qk[0]<=label2;
                Vk[0]<=data2;
                Busy[0]<=1;
            end 
            `MUL1:begin
                Op[1]<=ALUop;
                Qj[1]<=label1;
                Vj[1]<=data1;
                Qk[1]<=label2;
                Vk[1]<=data2;
                Busy[1]<=1;
            end
            `MUL2:begin
                Op[2]<=ALUop;
                Qj[2]<=label1;
                Vj[2]<=data1;
                Qk[2]<=label2;
                Vk[2]<=data2;
                Busy[2]<=1;
            end
        endcase
    end

    //当操作数齐全时进行运算
    generate
        genvar i;
        for ( i=0 ;i<3 ; i=i+1) begin:ADD_st
            always@(*) begin
                if(Busy[i]&& Qj[i]== 0&& Qk[i]==0 ) begin
                    case(Op[i])
                        `Mulu: begin
                            result[i]=Vj[i]*Vk[i];
                        end
                        `Divu: begin
                            result[i]=Vj[i]/Vk[i];
                        end
                        `Mul: begin
                            result[i]=sVj[i]*sVk[i];
                        end
                        `Div: begin
                            result[i]=sVj[i]/sVk[i];
                        end
                        default: result[i]=Vj[i]+Vk[i];
                    endcase
                    finish[i]=1;
                end
                // else finish[i]=0;
            end
        end
    endgenerate

    //接收广播的数据
    always@(BCEN==1 or negedge nRST) begin
        if (nRST == 0) begin 
            Busy[0] <= 0;
            Busy[1] <= 0;
            Busy[2] <= 0;
        end
        else begin 
            if (BCEN == 1 ) begin 
                if (Busy[0] == 1 && Qj[0] == BClabel) begin
                    Vj[0] = BCdata;
                    Qj[0] = 0;
                end
                if (Busy[1] == 1 && Qj[1] == BClabel) begin
                    Vj[1] = BCdata;
                    Qj[1] = 0;
                end
                if (Busy[2] == 1 && Qj[2] == BClabel) begin
                    Vj[2] = BCdata;
                    Qj[2] = 0;
                end
                if (Busy[0] == 1 && Qk[0] == BClabel) begin
                    Vk[0] = BCdata;
                    Qk[0] = 0;
                end
                if (Busy[1] == 1 && Qk[1] == BClabel) begin
                    Vk[1] = BCdata;
                    Qk[1] = 0;
                end
                if (Busy[2] == 1 && Qk[2] == BClabel) begin
                    Vk[2] = BCdata;
                    Qk[2] = 0;
                end
            end
        end
    end    

    //接受ALU计算结果，并进行广播
    always@(negedge clk) begin
        if (finish[0]==1) begin
            BCLabelOut=`MUL0;
            BCDataOut=result[0];
            BCready[0]=1;
        end
        else if (finish[1]==1) begin
            BCLabelOut=`MUL1;
            BCDataOut=result[1];
            BCready[1]=1;
        end
        else if (finish[2]==1) begin
            BCLabelOut=`MUL2;
            BCDataOut=result[2];
            BCready[2]=1;
        end
    end

    always@(posedge clk) begin
        if (BCready[0]&&BreqAC) begin
            BCLabelOut<=0;
            BCDataOut<=0;
            BCready[0]<=0;
            Busy[0]<=0;
            Op[0]<=0;
            Qj[0]<=0;
            Vj[0]<=0;
            Qk[0]<=0;
            Vk[0]<=0;
            result[0]<=0;
            finish[0]<=0;
        end
        else if (BCready[1]==1&&BreqAC) begin
            BCLabelOut<=0;
            BCDataOut<=0;
            BCready[1]<=0;
            Busy[1]<=0;
            Op[1]<=0;
            Qj[1]<=0;
            Vj[1]<=0;
            Qk[1]<=0;
            Vk[1]<=0;
            result[1]<=0;
            finish[1]<=0;
        end
        else if (BCready[2]==1&&BreqAC) begin
            BCLabelOut<=0;
            BCDataOut<=0;
            BCready<=0;
            Busy[2]<=0;
            Op[2]<=0;
            Qj[2]<=0;
            Vj[2]<=0;
            Qk[2]<=0;
            Vk[2]<=0;
            result[2]<=0;
            finish[2]<=0;
        end
    end
endmodule