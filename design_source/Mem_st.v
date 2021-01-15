`timescale 1ns/1ps
`include "head.v"
//只有一个保留站，待完善
module Mem_st(
    input clk,
    input nRST,
    //CU
    input [4:0]stnum,
    input [3:0]op,
    input [31:0]data1,
    input [4:0]label1,
    input [31:0]data2,
    input [4:0]label2,
    input [15:0]immd,
    output reg [1:0]Busy,
    //CBD
    input BCEN,
    output reg Breq,
    input BreqAC,
    input [31:0]BCdata,
    input [4:0]BClabel,
    output reg[4:0]BCLabelOut,
    output reg[31:0]BCDataOut
    );

    // 设置了三个保留站
    
    reg [3:0]Op[1:0];
    reg [4:0]Qj[1:0];
    reg [31:0]Vj[1:0];
    reg [4:0]Qk[1:0];
    reg [31:0]Vk[1:0];
    reg [31:0]offset[1:0];
    //MEM
    reg [31:0]result;
    reg finish;
    wire finishw;
    wire [31:0]resultw;
    always@(*)begin
        result=resultw;
        finish=finishw;
    end
    reg BCready;
    reg[31:0]MemAddrL;
    reg[31:0]MemAddrS;
    reg[31:0]MemData;
    reg WEN;
    // 当前可写地址
    initial Busy= 2'b00;

    //下降沿接受数据接收数据，stnum信号对应为准
    always@(posedge clk) begin
        case (stnum)
            `Mem0:begin
                Op[0]<=op;
                Qj[0]<=label1;
                Vj[0]<=data1;
                Qk[0]<=label2;
                Vk[0]<=data2;
                Busy[0]<=1;
                offset[0]<={16'h0000,immd};
            end
            `Mem1:begin
                Op[1]<=op;
                Qj[1]<=label1;
                Vj[1]<=data1;
                Qk[1]<=label2;
                Vk[1]<=data2;
                Busy[1]<=1;
                offset[1]<={16'h0000,immd};
            end
        endcase
    end

    //给Mem传送数据0读1写
    always@(*) begin
        if(Busy[0]&& Qj[0]== 0&& Qk[0]== 0) begin
            MemData=Vk[0];
            MemAddrL=Vj[0]+offset[0];
        end
    end
    always@(*) begin
        if(Busy[1]&& Qj[1]== 0&& Qk[1]== 0) begin
            MemData=Vk[1];
            MemAddrS=Vj[1]+offset[1];
            WEN=op[3];
        end
    end


    //接收广播的数据
    always@(posedge clk or negedge nRST) begin
        if (nRST == 0) begin 
            Busy<= 0;
        end
        else begin 
            if (BCEN == 1 ) begin 
                if (Busy[0] == 1 && Qj[0]== BClabel) begin
                    Vj[0] = BCdata;
                    Qj[0] = 0;
                end
                else if(Busy[0] == 1 && Qk[0]== BClabel)begin
                    Vk[0] = BCdata;
                    Qk[0] = 0;
                end
                if (Busy[1] == 1 && Qj[1]== BClabel) begin
                    Vj[1] = BCdata;
                    Qj[1] = 0;
                end
                else if(Busy[1] == 1 && Qk[1]== BClabel)begin
                    Vk[1] = BCdata;
                    Qk[1] = 0;
                end
            end
        end
    end    
    
    always@(negedge clk) begin
        if (result!=0) begin
            Breq=1;
            BCLabelOut=`Mem0;
            BCDataOut=result;
            BCready=1;
        end
    end

    always@(posedge clk) begin
        if (BCready&&BreqAC) begin
            BCLabelOut<=0;
            BCDataOut<=0;
            BCready<=0;
            Busy[0]<=0;
            Op[0]<=0;
            Qj[0]<=0;
            Vj[0]<=0;
            Qk[0]<=0;
            Vk[0]<=0;
            result<=0;
            finish<=0;
            Breq=0;
            MemAddrL<=0;
        end
        
    end
Mem  u_Mem (
    .wena(WEN),
    .addrS(MemAddrS[8:0]),
    .addrL(MemAddrL[8:0]),
    .data_in(MemData),

    .data_out(resultw),
    .fns(finishw)
);
endmodule