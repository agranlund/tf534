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

module tf530r2_bus_top(

           input 	CLKCPU,
           input 	CLK7M,

           output HALT,
           output RESET,

           input 	BG20,
           input 	AS20,
           input 	DS20,
           input 	RW20,
           output 	RW,


           input [2:0] 	FC,
           input [1:0] 	SIZ,

           input [23:0] A,

           input 	BGACK,
           input 	VPA,
           input 	DTACK,
           output    INT2,

           output 	BG,
           output 	LDS,
           output 	UDS,
           output 	VMA,
           output 	E,
           output 	AS,
           output 	BERR,

           output   OVR,
           input 	IDEWAIT,
           input 	INTCYCLE,

           output [1:0] DSACK,
           output 	AVEC,
           output 	CPCS,
           input 	CPSENSE,

           output [1:0] AUX,

           output 	IOR,
           output 	IOW,
           output [1:0] IDECS
       );

wire [23:0] ADDRESS_MAP;

assign ADDRESS_MAP[0] = A[0];
assign ADDRESS_MAP[23:15] = {A[23:15]};
assign ADDRESS_MAP[13:12] = {A[13:12]};

bus_top BUSTOP(

    .CLKCPU     ( CLKCPU        ), 
    .CLK7M      ( CLK7M         ),

    .INTCYCLE   ( INTCYCLE      ),
    .SLOWCYCLE  ( SLOWCYCLE     ),
    .IDEWAIT    ( IDEWAIT       ),
    
    .CPSENSE    ( CPSENSE       ), 
    .CPCS       ( CPCS          ),

    .BG20       ( BG20          ),
    .BG         ( BG            ),
    .BGACK      ( BGACK         ),

    .AS20       ( AS20          ), 
    .DS20       ( DS20          ), 
    .RW20       ( RW20          ), 
    .DSACK1     ( DSACK[1]      ), 
    .AVEC       ( AVEC          ),

    .AS         ( AS            ), 
    .RW         ( RW            ),
    .LDS        ( LDS           ), 
    .UDS        ( UDS           ), 
    .FC         ( FC            ), 

    .INT2       ( 1'b1          ),
    .SIZ        ( SIZ           ),

    .A          ( ADDRESS_MAP   ), 
	       
    .VPA        ( VPA           ), 
    .DTACK      ( DTACK         ), 

    .VMA        ( VMA           ), 
    .E          ( E             ), 
    .BERR       ( BERR          ), 

    .IOR        ( IOR           ),
    .IOW        ( IOW           ),
    .IDECS      ( IDECS         )
);

// pins not used by core.
assign DSACK[0] = 1'bz;
assign RESET = 1'bz;
assign HALT = 1'bz;
assign OVR = 1'bz;
assign INT2 = 1'bz;
assign AUX = {CLK7M, DTACK};
      
reg [3:0] SLOWCYCLE_D;

always @(posedge CLK7M or posedge AS20) begin 

    if (AS20 == 1'b1) begin
    
        SLOWCYCLE_D <= 4'b1111;

    end else begin 

        SLOWCYCLE_D <= {SLOWCYCLE_D[2:0], INTCYCLE};

    end

end

assign SLOWCYCLE = SLOWCYCLE_D[3];

endmodule
