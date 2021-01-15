`include "head.v"
`timescale 1ns/1ps
//controlunit负责发射前的换名，读操作数，并通过stCU进行发射控制，将保留站需要的操作码发射
//用组合逻辑实现
module CU(
    input clk,
    input [5:0] op,
    input [5:0] func,
    input [4:0] sftamt,
    input [4:0] rs,
    input [4:0] rt,
    input [4:0] rd,
    input [15:0] immd16,
    input [25:0] immd26,

    //是否发射控制
    input issuable,//cu可发射
    input [4:0]stnum,//
    //output [5:0]opCode,
    //output [5:0]functCode, 
    output [2:0]stType,
    output reg[4:0]stnumOut,
    output reg [1:0]sel,
    output reg[15:0]immd,
    output reg[4:0] opnumRF1,
    output reg[4:0] opnumRF2,
    output reg[4:0] destRF,
    output destEN,
    output [3:0]ST_op
);
    reg [2:0]Type;
    reg dstn;
    reg [3:0]STop;
    reg issue;
    assign ST_op=STop;
    assign destEN=(dstn&&issue);
    assign stType=Type;
    reg [4:0]dest;
    initial begin
        opnumRF2=0;
        opnumRF1=0;
        immd=0;
        issue=0;
        sel=0;
    end
    //判断指令类型,分配数据类型
    always@(*) begin
        case(op)
            `opRR: begin
                if(func==`funcSRA)begin
                  STop= `Sra;
                  Type=`Addst;
                end
                case(func)
                    `funcADD: begin
                      STop<=`Add;
                      Type<=`Addst;
                    end
                    `funcADDU: begin
                      STop=`Addu;
                      Type=`Addst;
                    end 
                    `funcSUB: begin
                      STop= `Sub;
                      Type=`Addst;
                    end
                    `funcSUBU: begin
                      STop= `Subu;
                      Type=`Addst;
                    end 
                    `funcAND: begin
                      STop= `And;
                      Type=`Addst;
                    end 
                    `funcOR: begin
                      STop= `Or;
                      Type=`Addst;
                    end 
                    `funcXOR: begin
                      STop= `Xor;
                      Type=`Addst;
                    end
                    `funcNOR: begin
                      STop= `Nor;
                      Type=`Addst;
                    end
                    `funcSLT: begin
                      STop= `Slt;
                      Type=`Addst;
                    end
                    `funcSLTU: begin
                      STop= `Sltu;
                      Type=`Addst;
                    end
                    `funcSLL: begin
                      STop= `Sll;
                      Type=`Addst;
                    end
                    `funcSRL: begin
                      STop= `Srl;
                      Type=`Addst;
                    end
                    `funcMULU: begin
                      STop=`Mulu;
                      Type=`Mulst;
                    end 
                    `funcDIVU: begin
                      STop=`Divu;
                      Type=`Mulst;
                    end
                    `funcSRA: begin
                      STop= `Sra;
                      Type=`Addst;
                    end 
                    `funcMUL: begin
                      STop=`Mul;
                      Type=`Mulst;
                    end
                    `funcDIV: begin
                      STop=`Div;
                      Type=`Mulst;
                    end 
                    default:begin
                      STop=0;
                      Type=0;
                    end
                endcase
                opnumRF1=rs;
                opnumRF2=rt;
                dest=rd;
                dstn=1;
                immd=0;
                sel=0;
            end
            `opADDI: begin
                STop=`Add;
                opnumRF1=rs;
                immd=immd16;
                dest=rt;
                dstn=1;
                Type=`Addst;
                sel=0;
            end
            `opADDIU: begin
                STop=`Addu;
                opnumRF1=rs;
                immd=immd16;
                dest=rt;
                dstn=1;
                Type=`Addst;
                sel=0;
            end
            `opORI: begin
                STop=`Or;
                opnumRF1=rs;
                immd=immd16;
                dest=rt;
                dstn=1;
                Type=`Addst;
                sel=0;
            end
            `opSLTI: begin
                STop=`Slt;
                opnumRF1=rs;
                immd=immd16;
                dest=rt;
                dstn=1;
                Type=`Addst;
                sel=0;
            end
            `opSLTIU: begin
                STop=`Sltu;
                opnumRF1=rs;
                immd=immd16;
                dest=rt;
                dstn=1;
                Type=`Addst;
                sel=0;
            end
            `opLUI: begin
                STop=`Lui1;
                opnumRF1=rs;
                immd=immd16;
                dest=rt;
                dstn=1;
                Type=`Addst;
                sel=0;
            end
            `opXORI: begin
                STop=`Xor;
                opnumRF1=rs;
                immd=immd16;
                dest=rt;
                dstn=1;
                Type=`Addst;
                sel=0;
            end
            `opLW: begin
                STop = `LW;
                opnumRF1=rs;
                dest=rt;
                dstn=1;
                immd=immd16;
                Type=`MemLst;
                sel=0;
            end
            `opSW: begin
                STop <= `SW;
                opnumRF1<=rs;
                immd<=immd16;
                Type<=`MemSst;
                sel=0;
            end
            `opJ:begin
                sel=`AbsJmp;
            end
            default:begin
                STop = 1;
                Type=0;
                immd=0;
                opnumRF1=0;
                opnumRF2=0;
                dstn=0;
                sel=0;
            end
        endcase
    end
    
    //发射
    always@(negedge clk) begin
      if(issuable&&sel==0) begin
        issue<=1;
        stnumOut<=stnum;
        destRF<=dest;
      end
      else begin
        issue<=0;
        stnumOut<=5'b00000;
      end
    end
endmodule