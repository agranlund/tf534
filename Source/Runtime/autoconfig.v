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



module autoconfig(

           input        RESET,
           input 	AS20,
           input 	RW20,
           input 	DS20,

           input [31:0] A,

           input [15:0] D,
           output [7:4] DOUT,

           output 	ACCESS,
           output [1:0] DECODE

       );

localparam RAM_CARD = 0;
localparam SPI_CARD = 1;

localparam CONFIGURING_RAM = 2'b00;
localparam CONFIGURING_SPI = 2'b01;

reg [1:0] config_out = 'd0;
reg [1:0] configured = 'd0;
reg [1:0] shutup = 'd0;
reg [7:4] data_out = 'd0;

// 0xE80000
wire Z2_ACCESS = ({A[31:16]} != {16'h00E8}) | (&config_out);
wire Z2_WRITE = (Z2_ACCESS | RW20);
wire [5:0] zaddr = {A[6:1]};

always @(posedge AS20 or negedge RESET) begin

    if (RESET == 1'b0) begin

        config_out <= 'd0;

    end else begin

        config_out <= configured | shutup;

    end

end

always @(negedge DS20 or negedge RESET) begin

    if (RESET == 1'b0) begin

        configured <= 'd0;
        shutup <= 'd0;
        data_out[7:4] <= 4'hf;

    end else begin

            if (Z2_WRITE == 1'b0) begin

                    case (zaddr)
                    'h22: begin //configure logic
                        if (config_out == CONFIGURING_RAM) configured[RAM_CARD] <= 1'b1;
                    end
                    'h24: begin //configure logic
                        if (config_out == CONFIGURING_SPI) configured[SPI_CARD] <= 1'b1;
                    end
                    'h26: begin // shutup logic
                        if (config_out == CONFIGURING_SPI) shutup[SPI_CARD] <= 1'b1;
                        if (config_out == CONFIGURING_RAM) shutup[RAM_CARD] <= 1'b1;
                    end
                endcase

            end

            // autoconfig ROMs
            case (zaddr)
                6'h00: begin
                if (config_out == CONFIGURING_SPI) data_out[7:4] <= 4'hc;
                if (config_out == CONFIGURING_RAM) data_out[7:4] <= 4'ha;
                end
                6'h01: begin
                if (config_out == CONFIGURING_SPI) data_out[7:4] <= 4'h1;
                if (config_out == CONFIGURING_RAM) data_out[7:4] <= 4'h0;
                end
                6'h02: begin
                if (config_out == CONFIGURING_SPI) data_out[7:4] <= 4'h7;
                if (config_out == CONFIGURING_RAM) data_out[7:4] <= 4'hf;
                end
                // common autoconfig params
                6'h03: data_out[7:4] <= 4'he;

            6'h04: begin
                if (config_out == CONFIGURING_SPI) data_out[7:4] <= 4'h7;
                if (config_out == CONFIGURING_RAM) data_out[7:4] <= 4'h4;
            end
            6'h05: begin
                if (config_out == CONFIGURING_SPI) data_out[7:4] <= 4'hf;
                if (config_out == CONFIGURING_RAM) data_out[7:4] <= 4'h7;
            end
                6'h08: data_out[7:4] <= 4'he;
                6'h09: data_out[7:4] <= 4'hc;
                6'h0a: data_out[7:4] <= 4'h2;
                6'h0b: data_out[7:4] <= 4'h7;
                6'h11: data_out[7:4] <= 4'hd;
                6'h12: data_out[7:4] <= 4'he;
                6'h13: data_out[7:4] <= 4'hd;
                default: data_out[7:4] <= 4'hf;
            endcase
            
    end
end

// decode the base addresses
// these are hardcoded to the address they always get assigned to.
assign DECODE[SPI_CARD] = ({A[31:16]} != {16'h00e9}) | shutup[SPI_CARD];
`ifndef ATARI
assign DECODE[RAM_CARD] = ({A[31:24]} != {8'h40}) | shutup[RAM_CARD];
`else
assign DECODE[RAM_CARD] = ({A[31:22]} != {8'h01, 2'b00}) | shutup[RAM_CARD];    // 4MB TT-RAM
`endif

assign ACCESS = Z2_ACCESS;
assign DOUT = data_out;

endmodule
