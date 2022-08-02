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


module tf530r2_ram_top(

        input   CLKCPU,
        input	RESET,

        input	[23:0] A,
        inout	[7:0] D,
        input   [1:0] SIZ,
        
        input   IDEINT,
        output  IDEWAIT,
        output  INT2,
        
        input   AS20,
        input   RW20,
        input   DS20,
        
        // cache and burst control
        input   CBREQ,
        output  CBACK,
        output  CIIN,
        output 	STERM,	
        // 32 bit internal cycle.
        // i.e. assert OVR
        output  INTCYCLE,
                
        // ram chip control 
        output [3:0] RAMCS,
        output RAMOE,

        // SPI Port
        output          SPI_CLK,
        output [1:0]    SPI_CS,
        input	        SPI_MISO,
        output          SPI_MOSI

       );

wire [15:0] DATA_BUS;

assign D[7:0] = {DATA_BUS[15:8]};

wire [23:0] ADDRESS_MAP;

assign ADDRESS_MAP[6:0] = A[6:0];
assign ADDRESS_MAP[23:15] = {A[23:15]};
assign ADDRESS_MAP[13:12] = {A[13:12]};

// Instantiate the Unit Under Test (UUT)
	ram_top RAMTOP (

		.CLKCPU ( CLKCPU    ), 
		.RESET  ( RESET     ), 
		
        .AS20   ( AS20      ), 
		.RW20   ( RW20      ), 
		.DS20   ( DS20      ),
        
        .A      ( ADDRESS_MAP ), 
		.D      ( DATA_BUS  ), 
		.SIZ    ( SIZ       ),

		//.RAMA(RAMA), 
		.IDEINT ( IDEINT    ), 
		.IDEWAIT( IDEWAIT_INT   ), 
		.INT2   ( INT2_INT      ), 
		 
		.CBREQ  ( 1'b1      ), 
		//.CBACK  ( CBACK     ), 
		.CIIN   ( CIIN      ), 
		.STERM  ( STERM     ), 

		.INTCYCLE(INTCYCLE), 
		//.SLOWCYCLE(SLOWCYCLE), 
		.DTACK  ( 1'b1      ),

		.RAMCS  ( RAMCS     ), 
		.RAMOE  ( RAMOE     ), 
		
        //.EXTINT ( 1'b1    ), 
		//.HOLD(HOLD), 
		//.WRITEPROT(WRITEPROT), 
		.SPI_CLK( SPI_CLK   ), 
		.SPI_CS ( SPI_CS    ), 
		//.SPI_WCS(SPI_WCS), 
		.SPI_MISO(SPI_MISO), 
		.SPI_MOSI(SPI_MOSI)
	);

assign IDEWAIT = IDEWAIT_INT ? 1'b1 : 1'b0;
assign INT2 = INT2_INT ? 1'bz : 1'b0;
assign CBACK = 1'b1;

endmodule

// Dummy/Fake
module intreqr(
    
    input CLK, 
    
    input [31:0] A,
    inout [15:0] D,
    
    input AS20, 
    input RW20, 
    input INT2, 

    input DTACK,

    output ACK, 
    output INTCYCLE, 
    output IDEWAIT
);

assign INTCYCLE = 1'b1;
assign ACK = 1'b1;
assign IDEWAIT = 1'b1;

endmodule
