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


module ata (
           input         CLK,
           input         AS,
           input         RW,
           input [23:0] A,
           input        WAIT,

           output [1:0] IDECS,
           output        IOR,
           output        IOW,
           output   DTACK,
           output        ACCESS

       );

/* Timing Diagram
                 S0 S1 S2 S3 S4 S5  W  W S6 S7
     __    __    __    __    __    __    __    __    __    __    __    __   
CLK |  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__
     _________________                         _____________________________
AS                    \\\_____________________/
    _______________                            _____________________________
CS                 \__________________________/
    ______________________                     _____________________________
IOR                       \___________________/
    _____________________________        ___________________________________
IOW                              \______/
    _____________________________        ___________________________________
DTACK                            \______/     
    _________________________       ________________________________________
WAIT                         \_____/
        
*/

// decode directly from AS and Address Bus.
`ifndef ATARI
wire GAYLE_IDE = ({A[23:15]} != {8'hDA,1'b0});
`else
wire GAYLE_IDE = ({A[23:16]} != {8'hF0});
`endif

reg ASDLY = 1'b1;
reg ASDLY2 = 1'b1;
reg DTACK_INT = 1'b1;

reg IOR_INT = 1'b1;
reg IOW_INT = 1'b1;

always @(posedge CLK or posedge AS) begin

    if (AS == 1'b1) begin

        ASDLY <= 1'b1;
        ASDLY2 <= 1'b1;

    end else begin

        ASDLY <= AS;
        ASDLY2 <= ASDLY;

    end

end

always @(negedge CLK or posedge AS) begin

    if (AS == 1'b1) begin

        IOR_INT <= 1'b1;
        IOW_INT <= 1'b1;
        DTACK_INT <= 1'b1;

    end else begin

        IOR_INT <= ~RW | ASDLY | GAYLE_IDE;
        IOW_INT <=  RW | ASDLY2 | GAYLE_IDE;
        DTACK_INT <=  ASDLY | GAYLE_IDE;

    end

end

assign IOR = IOR_INT;
assign IOW = IOW_INT ;
assign DTACK = DTACK_INT;

`ifndef ATARI
assign IDECS = A[12] ? {GAYLE_IDE, 1'b1} : {1'b1, GAYLE_IDE};
`else
assign IDECS = A[5] ? {GAYLE_IDE, 1'b1} : {1'b1, GAYLE_IDE};
`endif

assign ACCESS = GAYLE_IDE;


endmodule
