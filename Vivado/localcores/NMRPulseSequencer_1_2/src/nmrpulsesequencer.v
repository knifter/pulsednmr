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
    parameter US_DIVIDER = 125
    )(
    input wire clk,
    input wire rst,
    input wire force_on,
    input wire amp_on,
    
    input wire [31:0] Alen_in, 
    input wire [31:0] Blen_in, 
    input wire [31:0] ABdly_in, 
    input wire [31:0] BBdly_in, 
    input wire [15:0] BBcnt_in,
    input wire [31:0] BlankLen_in,
    
    output wire     sync_out,
    output wire     pulse_out,
    output wire     blank_out
    );
          
    // uS divider
    reg [$clog2(US_DIVIDER)-1:0] us_counter;
    wire us_zero = ~|us_counter;
    always @(posedge clk)
        if(rst) begin
            us_counter <= US_DIVIDER - 1;
        end else begin
            us_counter <= us_counter - 1;
            if (us_zero)
                us_counter <= US_DIVIDER - 1;
        end
      
     // at every uS handle the state machine
     localparam  STATE_A_START = 0;
     localparam  STATE_AH = 1;
     localparam  STATE_AL = 2;
     localparam  STATE_BH = 3;
     localparam  STATE_BNEXT = 4;
     localparam  STATE_BL = 5;
     localparam  STATE_STOP = 6;
     reg  [4:0]  state;
     reg  [31:0] t;
     reg  [15:0] b_cnt;
     reg  [31:0] bn_start;
     reg  [31:0] bn_stop;
     reg         pulse_reg;
     // blank regs:
     reg         pulse_reg_prv;
     wire        blank_trigger = ~pulse_reg & pulse_reg_prv;
     reg  [31:0] blank_counter;
     wire        blank_counter_zero = ~|blank_counter;
     always @ (posedge clk)
        if(rst) begin
            state <= STATE_AH;
            t <= 0;
            pulse_reg <= 0;
            pulse_reg_prv <= 0;
            blank_counter <= 0;
            
            b_cnt <= BBcnt_in - 1;
            bn_start <= ABdly_in;
            bn_stop <= ABdly_in + Blen_in;
             
        end else begin
            // Count time
            if(us_zero)
            begin
                t <= t + 1;
            end
            
            // Pulse Statemachine
            case(state)
                STATE_AH: begin // A-pulse starting
                        pulse_reg <= 1;
                        if( t == Alen_in )
                            state <= STATE_AL;
                    end
                STATE_AL: begin // A-pulse finished, waiting for bn_start
                        pulse_reg <= 0;
                        if( t == bn_start )
                        begin
                            if(|BBcnt_in)
                                state <= STATE_BH;
                            else
                                state <= STATE_STOP;
                        end
                    end
                STATE_BH: begin // B-pulse starting, waiting for bn_stop
                        pulse_reg <= 1;
                        if( t == bn_stop )
                            state <= STATE_BNEXT;
                    end
                STATE_BNEXT: begin // B-pulse finished, initialize next b-pulse
                        pulse_reg <= 0;
                        bn_start <= bn_start + BBdly_in;
                        bn_stop <= bn_stop + BBdly_in;
                        b_cnt <= b_cnt - 1;
                        if( |b_cnt)
                            state <= STATE_BL;
                        else
                            state <= STATE_STOP;
                    end
                STATE_BL: begin // B-pulse finihsed, waiting for next bn_start
                        pulse_reg <= 0;
                        if( t == bn_start)
                            state <= STATE_BH;
                    end
                STATE_STOP: begin // finished all pulses
                        pulse_reg <= 0;
                        state <= STATE_STOP;
                    end
            endcase
            
            // Blank machine
            pulse_reg_prv <= pulse_reg;
            if(blank_trigger)
            begin
                // start blank
                // start counter
                blank_counter <= BlankLen_in;
            end
            if(~blank_counter_zero & us_zero)
                blank_counter <= blank_counter -1;
        end
                
        assign pulse_out = pulse_reg | force_on;
        assign sync_out = (state==STATE_AH) & pulse_out;
        assign blank_out = (~blank_counter_zero | blank_trigger) | ~amp_on;
endmodule
