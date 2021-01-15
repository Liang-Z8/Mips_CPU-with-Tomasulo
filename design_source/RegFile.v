`timescale 1ns / 1ps
`include "head.v"
module RegFile(
    input clk,
    input nRST,
    input [4:0] ReadAddr1,
    input [4:0] ReadAddr2,
    input RegWr, //labelEN
    input [4:0] WriteAddr,
    input [4:0] WriteLabel,
    output WAW,
    output [31:0] DataOut1,
    output [31:0] DataOut2,
    output [4:0] LabelOut1,
    output [4:0] LabelOut2,
    input BCEN,
    input [4:0] BClabel,
    input [31:0] BCdata
    );
    reg [31:0] regData[1:31];
    reg [4:0] regLabel[1:31];
    assign DataOut1 = (ReadAddr1 == 0) ? 0 : regData[ReadAddr1];
    assign DataOut2 = (ReadAddr2 == 0) ? 0 : regData[ReadAddr2];
    assign LabelOut1 = (ReadAddr1 == 0) ? 0 : regLabel[ReadAddr1];
    assign LabelOut2 = (ReadAddr2 == 0) ? 0 : regLabel[ReadAddr2];
    reg stall;
    assign WAW=stall;
    initial begin
        stall=0;
    end
    generate
        genvar i;
        for (i = 1; i < 32; i = i + 1) begin: regfile
            always @(negedge clk or negedge nRST) begin
                if (!nRST) begin
                    regData[i] <= 32'b0;
                    regLabel[i] <= 32'b0;
                end 
                // else begin
                    // if (RegWr && WriteAddr == i) begin
                    //     if (regLabel[i] != WriteLabel) begin 
                    //         regLabel[i] <= WriteLabel;
                    //         stall=0;
                    //         end
                    //     else if(regLabel[i] == WriteLabel&&WriteLabel!=0)stall=1;
                    // end 
                    // if (BCEN && regLabel[i] == BClabel) begin
                    //     regLabel[i] <= 5'b0;
                    //     regData[i] <= BCdata;
                    // end
                // end
            end
        end
    endgenerate

    generate
        genvar j;
        for (j = 1; j < 32; j = j + 1) begin: RegFile
            always@(*)begin
                if (RegWr && WriteAddr == j) begin
                    if (regLabel[j] != WriteLabel) begin 
                        regLabel[j] <= WriteLabel;
                        stall=0;
                        end
                    // else if(regLabel[j]== WriteLabel&&WriteLabel!=0)stall=1;
                end
                if (BCEN && regLabel[j] == BClabel) begin
                        regLabel[j] <= 5'b0;
                        regData[j] <= BCdata;
                end
            end
        end
    endgenerate    

endmodule

