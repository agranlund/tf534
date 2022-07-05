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


module bus_delay(
    
        input AS,
        input DTACK,
        output OUT
        );

`ifndef ATARI
parameter DELAYS = 10;
`else		
parameter DELAYS = 1;
`endif 
 
   wire [DELAYS:0] dtack_int;
   
 
genvar    c;
generate
   
   for (c = 0; c < DELAYS; c = c + 1) begin: dtackint
 
      FDCP #(.INIT(1'b1))
      DTTACK_FF (
         .Q(dtack_int[c+1]), // Data output
         .C(~dtack_int[c]), // Clock input
         .CLR(1'b0), // Asynchronous clear input
         .D(1'b0), // Data input
         .PRE(AS) // Asynchronous set input
         );
   end
   
endgenerate

assign dtack_int[0] = DTACK;
assign OUT = dtack_int[DELAYS];
   
endmodule