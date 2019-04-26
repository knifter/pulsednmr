`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2016 03:47:51 PM
// Design Name: 
// Module Name: nmrpulsesequencer
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


module NMRPulseSequencer #(
    parameter US_DIVIDER = 125,
    parameter US_DIVIDER_WIDTH = 8
    )(
    input wire clk,
    input wire rst,
    input wire pulse_on_in,
    
    input wire [31:0] Alen, 
    input wire [31:0] Blen, 
    input wire [31:0] ABdly, 
    input wire [31:0] BBdly, 
    input wire [15:0] BBcnt,
    
    output reg      start_seq,
    output wire     pulse_on_out,
    output wire     pulse_on_outn
    );
    
    // uS divider
    reg [US_DIVIDER_WIDTH-1:0] us_counter;
    wire us_zero = ~|us_counter;
    reg us_zero_prv;
    always @(posedge clk)
        if(rst) begin
            us_counter <= US_DIVIDER - 1;
            us_zero_prv <= 0;
        end else begin
            us_counter <= us_counter - 1;
            us_zero_prv <= us_zero;
            if (us_zero)
                us_counter <= US_DIVIDER - 1;
        end
     wire us_trigger = us_zero;
        
     // at every uS handle the state machine
     localparam  STATE_AH = 1;
     localparam  STATE_AL = 2;
     localparam  STATE_BH = 3;
     localparam  STATE_BNEXT = 4;
     localparam  STATE_BL = 5;
     localparam  STATE_STOP = 6;
     reg  [4:0]  state;
     reg  [31:0] t;
     reg  [15:0] b_cnt;
     //wire [16:0] b_start = ABdly;
     //wire [16:0] b_stop =  ABdly + Blen;
     //wire [16:0] b_step = BBdly;
     reg  [31:0] bn_start;
     reg  [31:0] bn_stop;
     reg         pulse_on;
     always @ (posedge clk)
        if(rst) begin
            state <= STATE_AH;
            t <= 0;
            pulse_on <= 0;
            
            b_cnt <= BBcnt - 1;
            bn_start <= ABdly;
            bn_stop <= ABdly + Blen; 
        end else begin
            if(us_trigger)
                t <= t + 1;
            case(state)
                STATE_AH: begin // A-pulse starting
                        pulse_on <= 1;
                        start_seq <= 1;
                        if( t == Alen )
                            state <= STATE_AL;
                    end
                STATE_AL: begin // A-pulse finished, waiting for bn_start
                        pulse_on <= 0;
                        start_seq <= 0;
                        if( t == bn_start )
                        begin
                            if(|BBcnt)
                                state <= STATE_BH;
                            else
                                state <= STATE_STOP;
                        end
                    end
                STATE_BH: begin // B-pulse starting, waiting for bn_stop
                        pulse_on <= 1;
                        if( t == bn_stop )
                            state <= STATE_BNEXT;
                    end
                STATE_BNEXT: begin // B-pulse finished, initialize next b-pulse
                        pulse_on <= 0;
                        bn_start <= bn_start + BBdly;
                        bn_stop <= bn_stop + BBdly;
                        b_cnt <= b_cnt - 1;
                        if( |b_cnt)
                            state <= STATE_BL;
                        else
                            state <= STATE_STOP;
                    end
                STATE_BL: begin // B-pulse finihsed, waiting for next bn_start
                        pulse_on <= 0;
                        if( t == bn_start)
                            state <= STATE_BH;
                    end
                STATE_STOP: begin // finished all pulses
                        pulse_on <= 0;
                        state <= STATE_STOP;
                    end
            endcase                         
        end
        
        assign pulse_on_out = pulse_on | pulse_on_in;
        assign pulse_on_outn = ~pulse_on_out;
endmodule
