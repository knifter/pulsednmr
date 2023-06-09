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
    reg force_on;
    reg amp_on;
    
    reg [31:0]  Alen;
    reg [31:0]  Blen;
    reg [31:0]  ABdly;
    reg [31:0]  BBdly;
    reg [15:0]  BBcnt;
    reg [31:0]  BlankLen;
    wire sync_ext;
    wire pulse_ext;
    wire blank_ext;
    
    NMRPulseSequencer #(
        .US_DIVIDER(5)
    ) DUT ( 
        .clk(clk),
        .rst(rst),
        .force_on(force_on),
        .amp_on(amp_on),
        .Alen_in(Alen),
        .Blen_in(Blen),
        .ABdly_in(ABdly),
        .BBdly_in(BBdly),
        .BBcnt_in(BBcnt),
        .BlankLen_in(BlankLen),
        
        .sync_out(sync_ext),
        .pulse_out(pulse_ext),
        .blank_out(blank_ext)
        );
        
    initial begin
        clk = 0;
        force_on = 0;
        amp_on = 0;
        rst = 1;
        
        Alen = 15;
        Blen = 8;
        ABdly = 500;
        BBdly = 500;
        BBcnt = 1;
        BlankLen = 5;
        
        #50 amp_on = 1;
        #100 rst = 0;
        
        #21250 rst = 1;
        #50 rst = 0;
        
        #21250 amp_on = 0;
        
        #100 rst = 1;
        
    end
    
    always begin
        #4 clk = ~clk;
    end
    
endmodule

