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


module bus_top(

           input 	CLKCPU,
           input 	CLK7M,

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

           output 	BG,
           output 	LDS,
           output 	UDS,
           output 	VMA,
           output 	E,
           output 	AS,
           output 	BERR,

           input 	IDEWAIT,
           input 	INTCYCLE,
           input    SLOWCYCLE,
           input    INT2,
           output   BUSEN,

           output   DSACK1,
           output 	AVEC,
           output 	CPCS,
           input 	CPSENSE,

           output [2:1] IPL,

           output 	IOR,
           output 	IOW,
           output [1:0] IDECS
       );


/* Timing Diagram
                 S0 S1 S2 S3 S4 S5  W  W S6 S7
         __    __    __    __    __    __    __    __    __    __    __    __   
CLK     |  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__
        ________________                       _____________________________
AS20                    \_____________________/
        ___________________                      _____________________________
AS20DLY                    \_____________________/
        ____________________                     _____________________________
INTCYCLE                    \___________________/

*/

reg AS20DLY = 1'b1;
reg BUSEN_D = 1'b1;

reg BG_INT;
reg BGACK_INT;

reg RW_INT = 1'b1;
reg AS_INT = 1'b1;
reg AS_INTD = 1'b1;

reg LDS_INT = 1'b1;
reg UDS_INT = 1'b1;

wire CPUSPACE = &FC;

wire GAYLE_IDE;
wire DTACK_IDE;

wire FPUOP = CPUSPACE & ({A[19:16]} === {4'b0010});
wire BKPT = CPUSPACE & ({A[19:16]} === {4'b0000});
wire IACK = CPUSPACE & ({A[19:16]} === {4'b1111});
wire BUS_BUSY = BGACK & BGACK_INT;
wire HIGHZ = ~BUS_BUSY | ~INTCYCLE | ~GAYLE_IDE;

`ifndef ATARI
reg INT2_ASSERT = 1'b0;
reg INT2_INT = 1'b0;
reg INT2_IACK_INT = 1'b0;
wire INT2_IACK = IACK & ({A[3:1]} == 3'b010) & ~AS20;
`endif

wire DSACK1_SYNC;
wire VMA_SYNC;

reg DTACK_LATCHED;
reg DTACK_S6;
reg DTACK_S7;
wire DTACK_S7D;
reg [1:0] DSACK_INT;

bus_delay DELAY(
              .AS     ( AS        ),
              .DTACK  ( DTACK_S7  ),
              .OUT    ( DTACK_S7D )
          );

// module to control the 6800 bus timings
m6800 M6800BUS(
          .CLK7M	( CLK7M			),
          .FC       ( FC            ),
          .AS20	    ( AS20		    ),
          .VPA		( VPA		    ),
          .VMA		( VMA_SYNC		),
          .E		( E				),
          .DSACK1	( DSACK1_SYNC 	)
      );

// module to control IDE timings.
ata ATA (

        .CLK	( CLKCPU	),
        .AS	( AS20	),
        .RW	( RW20	),
        .A		( A		),
        .WAIT	( IDEWAIT),

        .IDECS( IDECS	),
        .IOR	( IOR		),
        .IOW	( IOW		),
        .DTACK( DTACK_IDE	),
        .ACCESS( GAYLE_IDE )

    );

reg CPCS_INT = 1'b1;
reg AVEC_INT = 1'b1;
reg CANSTART = 1'b1;

// This block ensures that we see at least
// 1 falling edge of the slow clock before
// starting a new slow bus cycle.
always @(negedge CLK7M or negedge AS) begin

    if (AS == 1'b0) begin

        CANSTART <= 1'b0;

    end else begin

        CANSTART <= BUS_BUSY;

    end

end

always @(posedge CLKCPU) begin

    BGACK_INT <= BGACK;

end

wire AS_AMIGA = AS20DLY | FPUOP | ~GAYLE_IDE | ~INTCYCLE | ~BUS_BUSY | (~CANSTART & AS_INT);

always @(posedge CLK7M or posedge AS20) begin

    if (AS20 == 1'b1) begin

        AS_INT <= 1'b1;
        AS_INTD <= 1'b1;
        
        RW_INT <= 1'b1;

        LDS_INT <= 1'b1;
        UDS_INT <= 1'b1;

        DTACK_S6 <= 1'b1;

    end else begin

        // assert these lines in S2
        // the 68030 assert them one half clock early.
        AS_INT <= AS_AMIGA;  // Low in S2+
        AS_INTD <= AS_INT;   // Low in S4+    

        RW_INT <= RW20 | AS_AMIGA;

        if (RW20 == 1'b1) begin

            // reading when reading the signals are asserted in 7Mhz S2
            UDS_INT <= DS20 | A[0] | AS_AMIGA;
            LDS_INT <= DS20 | ({A[0], SIZ[1:0]} == 3'b001) | AS_AMIGA;

        end else begin

            // when writing the the signals are asserted in 7Mhz S4
            UDS_INT <= DS20 | AS_INT | A[0] | AS_AMIGA;
            LDS_INT <= DS20 | AS_INT  | ({A[0], SIZ[1:0]} == 3'b001) | AS_AMIGA;

        end

        DTACK_S6 <= DTACK_LATCHED;

    end

end

always @(posedge CLKCPU or posedge BG20) begin

    if (BG20 == 1'b1) begin

        BG_INT <= 1'b1;

    end else begin 

        if (AS20 == AS_INT) begin

            BG_INT <= BG20;

        end 

    end

end


always @(negedge CLK7M or posedge AS20) begin

    if (AS20 == 1'b1) begin

        DTACK_LATCHED <= 1'b1;
        DTACK_S7 <= 1'b1;
        
    end else begin

        // latch DTACK on the falling edge of S5
        // Wait states will get introducted if DTACK isnt ready
        DTACK_LATCHED <= AS_INTD | DTACK; // enter S5
        DTACK_S7 <= DTACK_S6;

    end

end

always @(posedge CLKCPU or posedge AS20) begin

    if (AS20 == 1'b1) begin

        DSACK_INT <= 2'b11;

    end else begin

        DSACK_INT <= {DSACK_INT[0], DTACK_S7D};
    
    end

end


always @(posedge CLKCPU or posedge AS20) begin

    if (AS20 == 1'b1) begin

        AS20DLY <= 1'b1;
        CPCS_INT <= 1'b1;
        AVEC_INT <= 1'b1;

    end else begin

        // Delayed Address Strobes
        AS20DLY <= AS20 | FPUOP;
        CPCS_INT <= ~FPUOP | AS20;
        AVEC_INT <= ~IACK | VPA;
        
    end

end

`ifndef ATARI

always @(posedge CLKCPU) begin

    // INTCYCLE USED TO SHUT OFF THE BUS
    BUSEN_D <= ~INTCYCLE | AS_INT;
    INT2_INT <= INT2;
    INT2_IACK_INT <= INT2_IACK;

end

always @(negedge INT2_INT, posedge INT2_IACK_INT) begin 

    if (INT2_IACK_INT == 1'b1) begin 

        INT2_ASSERT <= 1'b0;

    end else begin 

        INT2_ASSERT <= 1'b1;

    end

end

`else

always @(posedge CLKCPU) begin

    // INTCYCLE USED TO SHUT OFF THE BUS
    BUSEN_D <= ~INTCYCLE | AS_INT;
end

`endif


wire VMA_INT = VMA_SYNC;

assign RW =   HIGHZ ? 1'bz : RW_INT;
assign AS =   HIGHZ ? 1'bz : AS_INT;
assign UDS =  HIGHZ ? 1'bz : UDS_INT;
assign LDS =  HIGHZ ? 1'bz : LDS_INT;
assign VMA =  HIGHZ ? 1'bz : VMA_INT;

assign DSACK1 = FPUOP | (~IDEWAIT | DSACK_INT[0]) & DSACK1_SYNC & DTACK_IDE & SLOWCYCLE;

assign BG = BG_INT ? 1'bz : 1'b0;
assign AVEC = AVEC_INT;

assign BERR = (CPCS_INT | ~CPSENSE) ? 1'bz : 1'b0;
assign CPCS = CPCS_INT;
assign BUSEN = BUSEN_D;

`ifndef ATARI
assign IPL[2:1] = INT2_ASSERT ? {2'b10} : {2'bzz};
`else
assign IPL[2:1] = {2'bzz};
`endif

endmodule
