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

module tf520r3_bus_top(

           input 	CLKCPU,
           input 	CLK7M,

           output   RESET,
           output   HALT, 
           output   HIGH,

           input 	BG20,
           input 	AS20,
           input 	DS20,
           input 	RW20,
           output 	RW,

           input [2:0] 	FC,
           input [1:0] 	SIZ,

           input [23:0] A,

           inout 	BGACK,
           input 	VPA,
           input 	DTACK,

           output 	BG,
           output 	LDS,
           output 	UDS,
           output 	VMA,
           output 	E,
           output 	AS,
           output 	BERR,

           output   DSACK1,
           output 	AVEC

          
       );

wire CPSENSE = 1'b1;
wire INTCYCLE = 1'b1;
wire SLOWCYCLE = 1'b1;
wire IDEWAIT = 1'b1;
wire INT2 = 1'b1;

wire [23:0] ADDRESS_MAP;

assign ADDRESS_MAP[0] = A[0];
assign ADDRESS_MAP[19:16] = {A[19:16]};

bus_top BUSTOP(

    .CLKCPU     ( CLKCPU        ), 
    .CLK7M      ( CLK7M         ),

    .INTCYCLE   ( INTCYCLE      ),
    .SLOWCYCLE  ( SLOWCYCLE     ),
    .IDEWAIT    ( IDEWAIT       ),
    .CPSENSE    ( CPSENSE       ), 

    .BG20       ( BG20          ),
    .BG         ( BG            ),
    .BGACK      ( BGACK         ),

    .AS20       ( AS20          ), 
    .DS20       ( DS20          ), 
    .RW20       ( RW20          ), 
    .DSACK1     ( DSACK1        ), 
    .AVEC       ( AVEC          ),

    .AS         ( AS            ), 
    .RW         ( RW            ),
    .LDS        ( LDS           ), 
    .UDS        ( UDS           ), 
    .FC         ( FC            ), 

    .INT2       ( INT2          ),
    .SIZ        ( SIZ           ),

    .A          ( ADDRESS_MAP   ), 
	       
    .VPA        ( VPA           ), 
    .DTACK      ( DTACK         ), 

    .VMA        ( VMA           ), 
    .E          ( E             ), 
    .BERR       ( BERR          ) 
);

// pins not used by core.
assign RESET = 1'bz;
assign HALT = 1'bz;
assign HIGH = 1'b1;

endmodule


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

assign ACCESS = 1'b1;
assign DTACK = 1'b1;
assign IOR = 1'b1;
assign IOW = 1'b1;
assign IDECS = 2'b11;

endmodule