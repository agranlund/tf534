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


module intreqr(

    input CLK, 
    
    input [31:0] A,
    inout [15:0] D,
    
    input AS20, 
    input RW20, 
    input INT2, 

    input DTACK,

    output reg ACK, 
    output reg INTCYCLE, 
    output reg IDEWAIT
);

// chipset read of DFF01e
wire ACCESS = {A[31:15],A[8],A[6:0]} != {16'h00DF, 1'b1,1'b0,3'b001,4'he} | AS20 | ~RW20;  

localparam DELAYS = 8-1;

reg DTACK_D = 1'b1;
reg DTACK_D2 = 1'b1;

reg [15:0] data;
reg [DELAYS:0] count;

always @(negedge DTACK, posedge AS20) begin 

    if (AS20 == 1'b1) begin

        DTACK_D <= 1'b1;

    end else begin 

        DTACK_D <= ACCESS;

    end 

end


always @(posedge CLK, posedge AS20) begin 

    if (AS20 == 1'b1) begin

        DTACK_D2 <= 1'b1;
        ACK <= 1'b1;
        INTCYCLE <= 1'b1;
        IDEWAIT <= 1'b1;

        count <= 8'hFF;
        
    end else begin 


        if (DTACK_D == 1'b0) begin 

            DTACK_D2 <= DTACK_D;

        end 


        if (DTACK_D2 == 1'b0) begin

            // do not allow dtack to reach CPU. 
            IDEWAIT <= 1'b0;

            if (count[DELAYS-1] == 1'b1) begin 
                
                data <= {D[15:4], D[3] | ~INT2, D[2:0]};
                
            end 

            // counts a bunch of delays
            count <= {count[DELAYS-1:0], 1'b0};

        end

        INTCYCLE <= count[DELAYS-1];
        ACK <= count[DELAYS];

    end 

end 

assign D = count[DELAYS] ? 16'bzzzzzzzz_zzzzzzzz : data;

endmodule