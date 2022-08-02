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



module fastram(

           input        RESET,
           input        CLK, 
           input        ACCESS,

           input [3:0]  A,
           input [1:0]  SIZ,

           input        AS20,
           input        RW20,
           input        DS20,

           // cache and burst control
           output       CBACK,
           output       CIIN,
           input        CBREQ,
           input        STERM,

           // ram chip control
           output [3:0] RAMCS,
           output       RAMOE,
           output [3:2] RAMA

       );

// ram control lines
wire RAMCS3n = A[1] | A[0];
wire RAMCS2n = (~SIZ[1] & SIZ[0] & ~A[0]) | A[1];
wire RAMCS1n = (SIZ[1] & ~SIZ[0] & ~A[1] & ~A[0]) | (~SIZ[1] & SIZ[0] & ~A[1]) |(A[1] & A[0]);
wire RAMCS0n = (~SIZ[1] & SIZ[0] & ~A[1] ) | (~SIZ[1] & SIZ[0] & ~A[0] ) | (SIZ[1] & ~A[1] & ~A[0] ) | (SIZ[1] & ~SIZ[0] & ~A[1] );

// disable all the RAM.
assign RAMOE = ACCESS;
assign RAMCS = {4{ACCESS}} | ({ RAMCS3n, RAMCS2n, RAMCS1n , RAMCS0n} & {4{~RW20}});

assign CIIN = AS20 | ~ACCESS;

reg BURSTING = 1'b0;
reg [1:0] BCOUNT = 2'b11;

// a read cycle at a tag aligned addres. 
wire CAN_BURST = ({A[3:2]} != 2'b00) | CBREQ | ACCESS | ~RW20;

assign RAMA[3:2] = BURSTING ? {A[3:2]} : BCOUNT;
assign CBACK = BURSTING | CBREQ | (BCOUNT == 2'b11);

always @(negedge AS20) begin

    if (AS20 == 1'b1) begin

        BURSTING <= 1'b1;
    
    end else begin 

        BURSTING <= CAN_BURST;

    end

end

always @(posedge CLK, posedge AS20) begin 

    if (AS20 == 1'b1) begin
   
        BCOUNT = 2'b00;
    
    end else begin 

        if (STERM == 1'b0) begin 

            BCOUNT = BCOUNT + 'd1;
        
        end 

    end

end

endmodule
