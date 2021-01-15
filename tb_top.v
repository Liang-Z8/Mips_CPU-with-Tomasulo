//~ `New testbench
`timescale  1ns / 1ps
module tb_top;
    // top Inputs
    reg   clk                                  = 0 ;
    reg   nRST                                 = 0 ;
    top  u_top (
        .clk                     ( clk    ),
        .nRST                    ( nRST   )
    );
    initial
    begin
        clk=!clk;
        nRST=0;
        #5;
            nRST = 1;
        forever #5 begin 
            clk = !clk;
        end
    end
endmodule