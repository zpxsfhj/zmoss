// -----------------------------------------------------------------------------
// Copyright (c) 2014-2024 All rights reserved
// -----------------------------------------------------------------------------
// Author : youkaiyuan v3eduyky@126.com
// Wechat : 15921999232
// File   : async_fifo_fwft.v
// Create : 2024-08-25 14:57:39
// Revise : 2024-08-25 14:57:39
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------
`timescale 1ns/1ns
module async_fifo_fwft #(
	parameter C_WIDTH = 32,	// Data bus width
	parameter C_DEPTH = 1024,	// Depth of the FIFO
	// Local parameters
	parameter C_REAL_DEPTH = 2**clog2(C_DEPTH),
	parameter C_DEPTH_BITS = clog2s(C_REAL_DEPTH),
	parameter C_DEPTH_P1_BITS = clog2s(C_REAL_DEPTH+1)
)
(
	input RD_CLK,							// Read clock
	input RD_RST,							// Read synchronous reset
	input WR_CLK,						 	// Write clock
	input WR_RST,							// Write synchronous reset
	input [C_WIDTH-1:0] WR_DATA, 			// Write data input (WR_CLK)
	input WR_EN, 							// Write enable, high active (WR_CLK)
	output [C_WIDTH-1:0] RD_DATA, 			// Read data output (RD_CLK)
	input RD_EN,							// Read enable, high active (RD_CLK)
	output WR_FULL, 						// Full condition (WR_CLK)
	output RD_EMPTY 						// Empty condition (RD_CLK)
);

`include "functions.vh"

reg		[C_WIDTH-1:0]			rData=0;
reg		[C_WIDTH-1:0]			rCache=0;
reg		[1:0]					rCount=0;
reg								rFifoDataValid=0;
reg								rDataValid=0;
reg								rCacheValid=0;
wire	[C_WIDTH-1:0]			wData;
wire							wEmpty;
wire							wRen = RD_EN || (rCount < 2'd2);


assign RD_DATA = rData;
assign RD_EMPTY = !rDataValid;


// Wrapped non-FWFT FIFO (synthesis attributes applied to this module will
// determine the memory option).
async_fifo #(.C_WIDTH(C_WIDTH), .C_DEPTH(C_DEPTH)) fifo (
	.WR_CLK(WR_CLK),
	.WR_RST(WR_RST),
	.RD_CLK(RD_CLK),
	.RD_RST(RD_RST),
	.WR_EN(WR_EN),
	.WR_DATA(WR_DATA),
	.WR_FULL(WR_FULL),
	.RD_EN(wRen),
	.RD_DATA(wData),
	.RD_EMPTY(wEmpty)
);

always @ (posedge RD_CLK) begin
	if (RD_RST) begin
		rCount <= #1 0;
		rDataValid <= #1 0;
		rCacheValid <= #1 0;
		rFifoDataValid <= #1 0;
	end
	else begin
		// Keep track of the count
		rCount <= #1 rCount + (wRen & !wEmpty) - (!RD_EMPTY & RD_EN);

		// Signals when wData from FIFO is valid
		rFifoDataValid <= #1 (wRen & !wEmpty);

		// Keep rData up to date
		if (rFifoDataValid) begin
			if (RD_EN | !rDataValid) begin
				rData <= #1 wData;
				rDataValid <= #1 1'd1;
				rCacheValid <= #1 1'd0;
			end
			else begin
				rCacheValid <= #1 1'd1;
			end
			rCache  <= #1 wData;
		end
		else begin
			if (RD_EN | !rDataValid) begin
				rData <= #1 rCache;
				rDataValid <= #1 rCacheValid;
				rCacheValid <= #1 1'd0;
			end
		end
	end
end
 
endmodule
 
