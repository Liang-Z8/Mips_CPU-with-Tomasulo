`timescale 1ns / 1ps
`include "head.v"
//组合逻辑，不加时序信号，进行指令发射的判断
//写后写判断
module stCU(
    input nRST,
    //发射控制
    input [2:0]Add_Busy,//加减保留站
    input [2:0]Mul_Busy,//乘法保留站
    input [1:0]Mem_Busy,//访存保留站
    input WAW,
    input [2:0]stType, 
    output wire issuable,//cu可发射
    output [4:0]stnum,
    output insStall//pc暂停取指
    );

/*     reg [2:0]stType; //指令对应保留站类型 */
    reg issueReg;
    reg [4:0]stnumReg;
    reg full;
    initial begin
        issueReg=0;
        full=0;
    end

    assign issuable = (issueReg&&full==0);
    assign insStall=(full||WAW);
    assign stnum=stnumReg;

    always@(*) begin
      //判断保留站是否有空闲
      case (stType)
          `Addst: begin
              if (Add_Busy[2]==0) begin
                issueReg<=1;
                stnumReg<=`Add2;
                full<=0;
            end
            else if(Add_Busy[1]==0) begin
                issueReg<=1;
                stnumReg<=`Add1;
                full<=0;
            end
            else if(Add_Busy[0]==0) begin
                issueReg<=1;
                stnumReg<=`Add0;
                full<=0;
            end
            else full<=1;
          end
          `Mulst:begin 
              if (Mul_Busy[2]==0) begin
                issueReg<=1;
                stnumReg<=`MUL2;
                full<=0;
            end
            else if(Mul_Busy[1]==0) begin
                issueReg<=1;
                stnumReg<=`MUL1;
                full<=0;
            end
            else if(Mul_Busy[0]==0) begin
                issueReg<=1;
                stnumReg<=`MUL0;
                full<=0;
            end
            else full<=1;
          end
          `MemLst: begin
            if (Mem_Busy[0]==0) begin
                issueReg<=1;
                stnumReg<=`Mem0;
                full<=0;
            end
            else full<=1;
          end
          `MemSst: begin
            if (Mem_Busy[1]==0) begin
                issueReg<=1;
                stnumReg<=`Mem1;
                full<=0;
            end
            else full<=1;
          end
          default: full<=1;
        endcase
    end

endmodule
