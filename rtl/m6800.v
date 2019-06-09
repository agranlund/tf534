`timescale 1ns / 1ps
/*	
	Copyright (C) 2016-2019, Stephen J. Leary
	All rights reserved.
	
	This file is part of  TF53x (Terrible Fire Accelerator).

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; version 2 only.
	
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/


module m6800(

           input                CLK7M,
           input                        AS20,
           input [2:0]  FC,
           input                        VPA,
           output               VMA,
           output reg   E,

           // emulation signal.
           output   DSACK1

       );

wire CPUSPACE = &FC;

// 6800 bus signal emulation.
reg [3:0] Q = 'h4;
reg VMA_SYNC = 1'b1;
reg DSACK1_SYNC = 1'b1;


initial begin

    E = 'b0;

end


/* This block produces the E clock.
 * The E clock is 1/10th of the 68000
 * clock speed. e.g 709Khz on a PAL amiga.
 * 
 * 
 * Q    |9|0|1|2|3|4|5|6|7|8|9|0|1|2|3|4|5|6|7|8|9|0|
 *                   ________            ________
 * E    ____________|        |__________|        |___
 *      ____________________                 ________         
 * VMA                      |_______________|          
 *      ________________________________     ________
 * DTACKS                               |___|        
 *
 * DTACKS will disassert when AS20 goes high. 
 */
always @(posedge CLK7M) begin

    // Q counts from 0 to 9
    // in the 7Mz clock domain
    if (Q == 'd9) begin

        Q <= 'd0;

    end else begin

        Q <= Q + 'd1;

        if (Q == 'd4) begin

            E <= 'b1;

        end

        if (Q == 'd8) begin

            E <= 'b0;

        end

    end

end

/* This block takes care of the VMA signal
 * which is used to acknowledge to old 6800
 * style hardware that a bus transfer has 
 * happened. Resets when the CPU AS is disasserted */
always @(posedge CLK7M or posedge VPA) begin

    if (VPA == 1'b1) begin

        VMA_SYNC <= 1'b1;

    end else begin

        if (Q == 'd9) begin

            VMA_SYNC <= 1'b1;

        end

        if (Q == 'd2) begin

            VMA_SYNC <= VPA | CPUSPACE;

        end

    end

end

always @(posedge CLK7M or posedge AS20) begin

    if (AS20 == 1'b1) begin

        DSACK1_SYNC <= 1'b1;

    end else begin

        if (Q == 'd9) begin

            DSACK1_SYNC <= 1'b1;

        end

        if (Q == 'd8) begin

            DSACK1_SYNC <= VMA_SYNC;

        end

    end

end

assign VMA = VMA_SYNC;
assign DSACK1 = DSACK1_SYNC;

endmodule
