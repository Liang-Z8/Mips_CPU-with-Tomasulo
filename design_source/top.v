`include "head.v"
`timescale 1ns/1ps
module top(
    input clk,
    input nRST
);
    //insControl
    wire [5:0] op; 
    wire pcWrite = op == `opHALT ? 0 : 1;
    wire [1:0]sel;//PC来源选择信号d
    wire labelEN;
    wire [31:0] pc;
    wire [31:0] newpc;
    wire [31:0] ins;
    wire [5:0] func;
    wire [4:0] sftamt;
    wire [4:0] rs;
    wire [4:0] rt;
    wire [4:0] rd;
    wire [15:0] immd16;
    wire [25:0] immd26;

    wire [31:0] newpcw;
    wire insStall;
    
    wire [31:0] rsData;
    wire [31:0] rtData;
    wire [4:0] rsLabel;
    wire [4:0] rtLabel;
    wire [15:0]immd;
    wire [3:0] ST_op;
    //instruction
    PC pc_instance(
        .clk(clk),
        .nRST(nRST),
        .insStall(insStall),
        .newpc(newpcw),
        .pcWrite(pcWrite),
        .pc(pc)
    );
    PCControl pc_Control(
        .pc(pc),
        .immd16(immd16),
        .immd26(immd26),
        .sel(sel),
        .rs(rsData), // rs here is data
        .newpc(newpcw)
    );
    ROM rom(
        .nrd(1'b0),
        .dataOut(ins),
        .addr(pc)
    );
    Decoder decoder(
        .ins(ins),
        .op(op),
        .func(func),
        .sftamt(sftamt),
        .rs(rs),
        .rt(rt),
        .rd(rd),
        .immd16(immd16),
        .immd26(immd26)
    );
    //CU
    //控制发射，stCU
    wire issuable;
    wire [4:0]stnum;//stCU
    wire [2:0]stType;
    wire [4:0]ST_Num;//issue
    wire issue;

    wire[2:0] Add_Busy;
    wire[2:0] Mul_Busy;
    wire [1:0]Mem_Busy;
    wire dst_W;
    wire [4:0]dst_addr;
    wire [4:0]opRFA1;
    wire [4:0]opRFA2;

    wire [4:0]BClabel;
    wire [31:0]BCdata;
    wire BCEN;
    wire [2:0]BC_Req;
    wire [2:0]BC_ReqAC;
    wire [4:0]Add_BClabel;
    wire [31:0]Add_BCdata;
    wire [4:0]Mul_BClabel;
    wire [31:0]Mul_BCdata;
    wire [4:0]Mem_BCLabel;
    wire [31:0]Mem_BCData;
    CU  CU (
        .clk(clk),
        .op(op),
        .func(func),
        .sftamt(sftamt[4:0]),
        .rs(rs),
        .rt(rt),
        .rd(rd),
        .immd16(immd16),
        .immd26(immd26),
        .issuable(issuable),
        .stnum(stnum),
        .sel(sel),
        // .labelRF1(labelRF1),
        // .dataRF1(dataRF1),
        // .labelRF2(labelRF2),
        // .dataRF2(dataRF2),
        .destEN(dst_W),
        .stType(stType),
        .stnumOut(ST_Num),
        // .issue(issue),
        .opnumRF1(opRFA1),
        .opnumRF2(opRFA2),
        .immd(immd),
        .destRF(dst_addr),
        .ST_op(ST_op)
    );

    wire WAW;

    stCU  stCU (
        .nRST(nRST),
        .Add_Busy(Add_Busy),
        .Mul_Busy(Mul_Busy),
        .Mem_Busy( Mem_Busy),
        .WAW(WAW),

        .stType(stType),
        .issuable(issuable),
        .stnum(stnum),
        .insStall(insStall)
    );
    RegFile regfile(
        .clk(clk),
        .nRST(nRST),
        .ReadAddr1(opRFA1), 
        .ReadAddr2(opRFA2),
        .RegWr(dst_W),
        .WriteAddr(dst_addr),
        .WriteLabel(ST_Num),
        .WAW(WAW), 
        .DataOut1(rsData),
        .DataOut2(rtData),
        .LabelOut1(rsLabel),
        .LabelOut2(rtLabel),
        .BCEN(BCEN),
        .BClabel(BClabel),
        .BCdata(BCdata)
    );

    ADD_st  add_st (
        .clk(clk),
        .nRST(nRST),
        .stnum(ST_Num),
        .ALUop(ST_op),
        .data1(rsData),
        .data2(rtData),
        .label1(rsLabel),
        .label2(rtLabel),
        .immd(immd),
        .Busy(Add_Busy),

        .BCEN(BCEN),
        .BreqAC(BC_ReqAC[2]),
        .BCdata(BCdata),
        .BClabel(BClabel),
        .Breq(BC_Req[2]),
        .BCLabelOut(Add_BClabel),
        .BCDataOut(Add_BCdata)
    );
    Mul_st  mul_st (
        .clk(clk),
        .nRST(nRST),
        .stnum(ST_Num),
        .ALUop(ST_op),
        .data1(rsData),
        .data2(rtData),
        .label1(rsLabel),
        .label2(rtLabel),
        .Busy(Mul_Busy),

        .BCEN(BCEN),
        .BreqAC(BC_ReqAC[1]),
        .BCdata(BCdata),
        .BClabel(BClabel),
        .Breq(BC_Req[1]),
        .BCLabelOut(Mul_BClabel),
        .BCDataOut(Mul_BCdata)
    );
    Mem_st  mem_st (
        .clk(clk),
        .nRST(nRST),
        .stnum(ST_Num),
        .op(ST_op),
        .data1(rsData),
        .data2(rtData),
        .label1(rsLabel),
        .label2(rtLabel),
        .immd(immd),
        .Busy(Mem_Busy),

        .BCEN(BCEN),
        .BreqAC(BC_ReqAC[0]),
        .BCdata(BCdata),
        .BClabel(BClabel),
        .Breq(BC_Req[0]),
        .BCLabelOut(Mem_BCLabel),
        .BCDataOut(Mem_BCData)
    );
    
    CDB cdb(
        .data0(Mem_BCData),
        .data1(Mul_BCdata),
        .data2(Add_BCdata),
        .label0(Mem_BCLabel),
        .label1(Mul_BClabel),
        .label2(Add_BClabel),
        .sel(BC_ReqAC),
        .dataOut(BCdata),
        .labelOut(BClabel),
        .EN(BCEN)
    );
    CDBHelper cdbhelper(
        .requires(BC_Req),
        .accepts(BC_ReqAC)
    );

endmodule