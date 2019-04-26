`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2016 05:15:39 PM
// Design Name: 
// Module Name: nmrpulsesequencer_test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ns

module nmrpulsesequencer_test(

    );
    
    reg clk;
    reg rst;
    
    reg [15:0]  Alen;
    reg [15:0]  Blen;
    reg [15:0]  ABdly;
    reg [15:0]  BBdly;
    reg [15:0]  BBcnt;
    
    NMRPulseSequencer inst( 
        .clk(clk),
        .rst(rst),
        .Alen(Alen),
        .Blen(Blen),
        .ABdly(ABdly),
        .BBdly(BBdly),
        .BBcnt(BBcnt)
        );
        
    initial begin
        clk = 0;
        rst = 1;
        
        Alen = 10;
        Blen = 20;
        ABdly = 120;
        BBdly = 60;
        BBcnt = 5;
        
        #50 rst = 0;
        
            
    end
    
    always begin
        #4 clk = ~clk;
    end
    
endmodule

