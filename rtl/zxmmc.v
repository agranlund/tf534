`define false 1'b 0
`define FALSE 1'b 0
`define true 1'b 1
`define TRUE 1'b 1

`timescale 1 ns / 1 ns // timescale for following modules


//  ZX Spectrum for Altera DE1
//
//  Copyright (c) 2009-2011 Mike Stirling
//
//  All rights reserved
//
//  Redistribution and use in source and synthezised forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
//
//  * Redistributions in synthesized form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
//
//  * Neither the name of the author nor the names of other contributors may
//    be used to endorse or promote products derived from this software without
//    specific prior written agreement from the author.
//
//  * License is granted for non-commercial use only.  A fee may not be charged
//    for redistributions as source code or in synthesized/hardware form without
//    specific prior written agreement from the author.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
//  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
//  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
//  Emulation of ZXMMC+ interface
//
//  (C) 2011 Mike Stirling

module zxmmc (
           CLOCK,
           nRESET,
           CLKEN,
           ENABLE,
           RS,
           nWR,
           DI,
           DO,
           SD_CS0,
           SD_CS1,
           SD_WCS,
           SD_CLK,
           SD_MOSI,
           SD_MISO);


input   CLOCK;
input   nRESET;
input   CLKEN;
input   ENABLE;
input   RS;
input   nWR;
input   [7:0] DI;
output   [7:0] DO;
output   SD_CS0;
output   SD_CS1;
output  SD_WCS;
output   SD_CLK;
output   SD_MOSI;
input    SD_MISO;

wire    [7:0] DO;
reg     SD_CS0;
reg     SD_CS1;
reg     SD_WCS;
reg       done;
wire    SD_CLK;
wire    SD_MOSI;
reg     [3:0] counter;


//  Shift register has an extra bit because we write on the
//  falling edge and read on the rising edge
reg     [8:0] shift_reg;
reg     [7:0] in_reg;

//  Input register read when RS=1

assign DO = RS ? in_reg : {4'h5, SD_WCS, done, SD_CS1, SD_CS0};

//  SD card outputs from clock divider and shift register
assign SD_CLK = counter[0];
assign SD_MOSI = shift_reg[8];

//  Chip selects

always @(posedge CLOCK)
begin
    if (nRESET === 1'b 0) begin
        SD_CS0 <= 1'b 1;
        SD_CS1 <= 1'b 1;
        SD_WCS <= 1'b 1;
    end else if (CLKEN === 1'b 1) begin
        //  The two chip select outputs are controlled directly
        //  by writes to the lowest two bits of the control register
        if (ENABLE === 1'b 1 & RS === 1'b 0 & nWR === 1'b 0) begin
            SD_CS0 <= DI[0];
            SD_CS1 <= DI[1];
            SD_WCS <= DI[3];
        end
    end
end

//  SPI write

always @(posedge CLOCK)
begin

    if (nRESET === 1'b 0) begin
        shift_reg <= {9{1'b 1}};
        in_reg <= {8{1'b 1}};
        counter <= 4'b 1111;   //  Idle
        done <= 1'b0;

    end else if (CLKEN === 1'b 1) begin

        if (counter === 4'b 1111) begin
            //  Store previous shift register value in input register
            in_reg <= shift_reg[7:0];
            done <= 1'b1;

            //  Idle - check for a bus access
            if (ENABLE === 1'b 1 & RS === 1'b 1) begin

                //  Write loads shift register with data
                //  Read loads it with all 1s
                if (nWR === 1'b 1) begin
                    shift_reg <= {9{1'b 1}};
                end else begin
                    shift_reg <= {DI, 1'b 1};
                end

                done <= 1'b0;
                counter <= 4'b 0000;  //  Initiates transfer
            end

            //  Transfer in progress
        end else begin

            counter <= counter + 1;

            if (counter[0] === 1'b 0) begin

                //  Input next bit on rising edge
                shift_reg[0] <= SD_MISO;

                //  Output next bit on falling edge
            end else begin
                shift_reg <= {shift_reg[7:0], 1'b 1};
            end

        end
    end
end



endmodule // module zxmmc

