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



module ram_top(

           input CLKCPU,
           input RESET,

           input [31:0] A,
           inout [15:0] D,
           input [1:0] SIZ,

           output [3:2] RAMA,
           input  IDEINT,
           output IDEWAIT,
           output INT2,

           input AS20,
           input RW20,
           input DS20,

           // cache and burst control
           input CBREQ,
           output CBACK,
           output CIIN,
           output STERM,
           // 32 bit internal cycle.
           // i.e. assert OVR
           output  INTCYCLE,
           output  SLOWCYCLE,


           input   DTACK,

           // ram chip control
           output reg [3:0] RAMCS,
           output reg  RAMOE,

           // SPI Port
           input  EXTINT,
           output HOLD,
           output WRITEPROT,
           output SPI_CLK,
           output [1:0]    SPI_CS,
           output SPI_WCS,
           input  SPI_MISO,
           output SPI_MOSI

       );

reg STERM_D = 1'b1;
reg STERM_D2 = 1'b1;
wire ROM_ACCESS = (A[23:19] != {4'hF, 1'b1}) | AS20;

// produce an internal data strobe

`ifndef ATARI
wire GAYLE_INT2;

wire INT2_STERM;
wire INT2_INTCYCLE;
wire INT2_IDEWAIT;

reg gayle_access = 1'b1;
wire gayle_decode;
wire gayle_dout;

intreqr INT2EMU(

    .CLK  ( CLKCPU ),
    .AS20 ( AS20   ),
    .RW20 ( RW20   ),
    .DTACK ( DTACK ),

    .INT2     ( INT2          ),

    .ACK      ( INT2_STERM    ),
    .IDEWAIT  ( INT2_IDEWAIT  ),
    .INTCYCLE ( INT2_INTCYCLE ),

    .A ( A ),
    .D ( D )
);

gayle GAYLE(

    .CLKCPU ( CLKCPU        ),
    .RESET  ( RESET         ),
    .AS20   ( AS20          ),
    .DS20   ( DS20          ),
    .RW     ( RW20          ),
    .A      ( A             ),
    .IDE_INT( IDEINT        ),
    .INT2   ( GAYLE_INT2    ),
    .DIN    ( D[15]         ),
    .DOUT   ( gayle_dout    ),
    .ACCESS ( gayle_decode  )

);

`else

wire GAYLE_INT2 = IDEINT ? 1'b0 : 1'bz;

wire INT2_STERM = 1'b1;
wire INT2_INTCYCLE = 1'b1;
wire INT2_IDEWAIT = 1'b1;

reg gayle_access = 1'b1;
wire gayle_decode = 1'b1;
wire gayle_dout = 1'b0;

`endif

reg spi_access = 1'b1;
wire spi_decode;
wire [7:0] spi_dout;

reg ram_access = 1'b1;
wire ram_decode;

reg zii_access = 1'b1;
wire zii_decode;
wire [7:4] zii_dout;

reg WAITSTATE;

autoconfig AUTOCONFIG(

    .RESET  ( RESET         ),

    .AS20   ( AS20          ),
    .DS20   ( DS20          ),
    .RW20   ( RW20          ),

    .A      ( A             ),

    .D      ( D[15:0]       ),
    .DOUT   ( zii_dout[7:4] ),

    .ACCESS ( zii_decode	),
    .DECODE ({spi_decode, ram_decode})
);

wire RAMOE_INT;
wire [3:0] RAMCS_INT;

fastram RAMCONTROL (

    .RESET  ( RESET         ),
    .CLK    ( CLKCPU        ),

    .A      ( A[3:0]        ),
    .SIZ    ( SIZ           ),

    .ACCESS ( ram_access | DS20    ),

    .AS20   ( AS20    	    ),
    .DS20   ( DS20          ),
    .RW20   ( RW20          ),

    // ram chip control
    .RAMCS  ( RAMCS_INT	    ),
    .RAMOE  ( RAMOE_INT     ),
    .RAMA   ( RAMA          ),

    .CBACK  ( CBACK         ),
    .STERM  ( STERM_D       ),
    .CIIN   ( CIIN          ),
    .CBREQ  ( CBREQ         )

);

reg CLKB2 = 1'b0;
reg CLKB4 = 1'b0;
reg [15:0] data_out;

always @(posedge CLKCPU) begin 
	
	CLKB2 <= ~CLKB2;
	
    data_out[15:12] <= spi_access ? (zii_access ? {gayle_dout,3'b000} : zii_dout ) : spi_dout[7:4];
    data_out[11:8] <= spi_access ? 4'd0 : spi_dout[3:0];
    data_out[7:0] <=  8'hFF;

end

zxmmc SPIPORT (

   .CLOCK  ( CLKB2     ),
   .nRESET ( RESET      ),
   .CLKEN  ( 1'b1       ),
   .ENABLE ( ~(spi_access | DS20) ),
   .RS     ( A[2]       ),
   .nWR    ( RW20       ),
   .DI     ( D[15:8]    ),
   .DO     ( spi_dout   ),

   .SD_CS0 ( SPI_CS[0]  ),
   .SD_CS1 ( SPI_CS[1]  ),
   .SD_WCS ( SPI_WCS    ),
   .SD_CLK ( SPI_CLK    ),
   .SD_MOSI( SPI_MOSI   ),
   .SD_MISO( SPI_MISO   )

);

reg AS20_D;
reg INTCYCLE_INT = 1'b1;
reg intcycle_dout = 1'b1;

reg SLOWCYCLE_D;

always @(AS20) begin 

  if (AS20 == 1'b1) begin 
      
      zii_access <= 1'b1;
      spi_access <= 1'b1;
      gayle_access <= 1'b1;
      ram_access <= 1'b1;
      
  end else begin 
  
      zii_access <= zii_decode;
      spi_access <= spi_decode;
      gayle_access <= gayle_decode;
      ram_access <= ram_decode;
      
  end 
  
end 

always @(posedge CLKCPU, posedge AS20) begin

    if (AS20 == 1'b1) begin

        RAMCS <= 4'b1111;
        RAMOE <= 1'b1;
        WAITSTATE <= 1'b1;
        STERM_D <= 1'b1;
 
    end else begin

        RAMCS <= RAMCS_INT;
        RAMOE <= RAMOE_INT;
        WAITSTATE <= ram_access | DS20;
        STERM_D <= WAITSTATE | (~STERM_D & ~CBACK);
        
    end

end

// a general access to something this module controls is happening.
wire db_access = spi_access & gayle_access & zii_access;

always @(posedge CLKCPU or posedge AS20) begin

    if (AS20 == 1'b1) begin

        AS20_D <= 1'b1;
        SLOWCYCLE_D <= 1'b1;
        intcycle_dout <= 1'b1;
        
    end else begin

        AS20_D <= AS20;
        SLOWCYCLE_D <= AS20_D | db_access;
        intcycle_dout <= db_access | ~RW20 ;

    end

end

// this triggers the internal override (TF_OVR) signal.
assign SLOWCYCLE = SLOWCYCLE_D  & INT2_STERM;

assign INTCYCLE = ram_access & db_access & INT2_INTCYCLE;
assign IDEWAIT = (INT2_IDEWAIT & RAMOE) ? 1'b1: 1'b0;

// disable all burst control.
assign STERM = STERM_D;
assign INT2 = GAYLE_INT2;

assign D[15:0] = ~intcycle_dout ? data_out : 16'bzzzzzzzz_zzzzzzzz;

assign WRITEPROT = 1'b1;
assign HOLD = 1'b1;

endmodule

