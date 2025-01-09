// -----------------------------------------------------------------------------
// Copyright (c) 2014-2024 All rights reserved
// -----------------------------------------------------------------------------
// Author : youkaiyuan v3eduyky@126.com
// Wechat : 15921999232
// File   : functions.vh
// Create : 2024-08-25 14:58:08
// Revise : 2024-08-25 14:58:08
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------

function integer clog2;
	input [31:0] v;
	reg [31:0] value;
	begin
		value = v;
		if (value == 1) begin
			clog2 = 0;
		end
		else begin
			value = value-1;
			for (clog2=0; value>0; clog2=clog2+1)
				value = value>>1;
		end
	end
endfunction
// clog2s -- calculate the ceiling log2 value, min return is 1 (safe).
function integer clog2s;
	input [31:0] v;
	reg [31:0] value;
	begin
		value = v;
		if (value == 1) begin
			clog2s = 1;
		end
		else begin
			value = value-1;
			for (clog2s=0; value>0; clog2s=clog2s+1)
				value = value>>1;
		end
	end
endfunction

