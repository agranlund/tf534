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


module arb(

           input CLK7M,
           input CLKCPU,

           input AS20,
           input AS_INT,

           input BGACK,
           input BG20,

           output reg BG_INT,
           output reg BGACK_INT

       );

always @(posedge CLK7M) begin

    BGACK_INT <= BGACK;

end

// This block ensures that a BG is not issued
// in error when AS and AS20 are in different
// states. This can lead to confusion over
/// whether a bus cycle is already in progress,
always @(posedge CLKCPU or posedge BG20) begin

    if (BG20 == 1'b1) begin

        BG_INT <= 1'b1;

    end else begin

        if (AS20 == AS_INT) begin

            BG_INT <= BG20;

        end

    end

end

endmodule
