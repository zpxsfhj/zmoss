`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/01/30 17:12:01
// Design Name: 
// Module Name: test_data_gen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module test_pix_gen
#(
    parameter       TAP         =   8       ,
    parameter       BIT         =   12      
)
(

    input   wire                            i_clk       ,
    input   wire                            i_rst       ,
    input   wire                            i_trig      ,
    
    input   wire    [15:0]                  i_line_gap    ,
    input   wire    [3:0]                   i_imag_type ,
    input   wire    [15:0]                  i_ylength   ,
    input   wire    [15:0]                  i_xlength   ,
    
    output  wire                            o_fval      ,
    output  wire                            o_lval      ,
    output  wire    [TAP * 16 - 1 : 0]     o_data

);

function integer clogb2(input integer size);
    begin
        size = size - 1;
        for(clogb2=0; size>0; clogb2=clogb2+1)begin
            size = size >> 1;
        end
    end
endfunction

parameter TAP_POWER = clogb2(TAP);
parameter BIT_SHIFT = 16 - BIT;
reg                             rst = 0;
reg     [15:0]                  line_gap , line_gap_r;
reg     [15:0]                  ylength , ylength_r;
reg     [15:0]                  xlength , xlength_r;
reg     [3:0]                   imag_type , imag_type_r;

reg     [15 : 0]                cnt_onerow = 0;
reg     [15 : 0]                cnt_line = 0;
reg     [15 : 0]           cnt_dyn = 0;
reg     [15:0]                  dyn_rate = 16'd5;

reg     [15 : 0]           pix_data_reg = 0;
reg     [TAP * 16 - 1 : 0]     pix_data = 0;
reg                             fval = 0;
reg                             lval = 0;


reg     [3:0]                   trig_reg = 0;
reg                             trig_edge = 0;



wire [7:0] tap_shift ;
generate
    case (TAP)
        1 : assign tap_shift = 0;
        2 : assign tap_shift = 1;
        4 : assign tap_shift = 2;
        8 : assign tap_shift = 3;
        16: assign tap_shift = 4;
        32: assign tap_shift = 5;
        default: assign tap_shift = 5;
    endcase
endgenerate

always @(posedge i_clk)
    begin
        if(i_rst)
            rst <=  1'b1;
        else if(trig_edge)
            rst <=  1'b0;
        else
            rst <=  rst;
    end

always @(posedge i_clk)
    begin
        line_gap_r   <=  i_line_gap;
        line_gap     <=  line_gap_r;
        ylength_r   <=  i_ylength;
        ylength     <=  ylength_r;
        xlength_r   <=  i_xlength;
        xlength     <=  xlength_r;
        imag_type_r <=  i_imag_type;
        imag_type   <=  imag_type_r;
    end

always @(posedge i_clk)
    begin
        if(i_rst)
            trig_reg    <=  'd0;
        else
            trig_reg    <=  {trig_reg[2:0] , i_trig};
    end

always @(posedge i_clk)
    begin
        trig_edge   <=  trig_reg[3:2] == 2'b01;
    end

always @(posedge i_clk)
    begin
        if(rst | trig_edge)
            cnt_onerow  <=  16'd0;
        else    if(cnt_onerow == (xlength>>tap_shift) + line_gap)
            cnt_onerow  <=  16'd0;
        else
            cnt_onerow  <=  cnt_onerow + 1'b1;
    end

always @(posedge i_clk)
    begin
        if(rst | trig_edge)
            cnt_line    <=  16'd0;
        else    if((cnt_line == ylength + 50) && (cnt_onerow == (xlength>>tap_shift) + line_gap))
            cnt_line    <=  cnt_line;
        else    if(cnt_onerow == (xlength>>tap_shift) + line_gap)
            cnt_line    <=  cnt_line + 1'b1;
        else
            cnt_line    <=  cnt_line;
    end

always @(posedge i_clk)
    begin
        pix_data_reg    <=  cnt_onerow << TAP_POWER;
    end

always @(posedge i_clk)
    begin
        if(rst)
            cnt_dyn <=  'd0;
        else    if((cnt_line == ylength) && (cnt_onerow == (xlength>>tap_shift) + line_gap))
            cnt_dyn <=  cnt_dyn + /*dyn_rate*/'d5;
        else
            cnt_dyn <=  cnt_dyn;
    end

always @(posedge i_clk)
    begin
        if(rst)
            lval    <=  1'b0;
        else    if(cnt_onerow == (xlength>>tap_shift) + 1)
            lval    <=  1'b0;
        else    if(cnt_onerow == 1)
            lval    <=  1'b1;
        else
            lval    <=  lval;
    end

always @(posedge i_clk)
    begin
        if(rst)
            fval    <=  1'b0;
        else    if(cnt_onerow == (xlength>>tap_shift) + 1 && cnt_line == ylength - 1'b1)
            fval    <=  1'b0;
        else    if(cnt_onerow == 1 && cnt_line == 0)
            fval    <=  1'b1;
        else
            fval    <=  fval;
    end

genvar  i;
generate
    for( i = 0; i <= TAP - 1 ; i = i + 1)
        begin   :   pix_data_gen
            always @(posedge i_clk)
                begin
                    case(imag_type)
                        4'd1    :   pix_data[i*16 +:16]   <=  'd0;                                                                //all black
                        4'd2    :   pix_data[i*16 +:16]   <=  {BIT{1'b1}};                                                        //all white
                        4'd3    :   pix_data[i*16 +:16]   <=  (cnt_line                     )<<BIT_SHIFT ;                                              //cross stripe
                        4'd4    :   pix_data[i*16 +:16]   <=  (cnt_line + cnt_dyn           )<<BIT_SHIFT ;                             //cross stripe(dynamic)
                        4'd5    :   pix_data[i*16 +:16]   <=  (pix_data_reg + i             )<<BIT_SHIFT ;                                                //vertical stripe
                        4'd6    :   pix_data[i*16 +:16]   <=  (pix_data_reg + i + cnt_dyn   )<<BIT_SHIFT ;                               //vertical stripe(dynamic)
                        4'd7    :   pix_data[i*16 +:16]   <=  (cnt_line + pix_data_reg + i          )<<BIT_SHIFT;                        //diagonal stripe
                        4'd8    :   pix_data[i*16 +:16]   <=  (cnt_line + pix_data_reg + i + cnt_dyn)<<BIT_SHIFT;       //diagonal stripe(dynamic)
                        default :   pix_data[i*16 +:16]   <=  'd0;
                    endcase
                end
        end
endgenerate

assign  o_data  =  pix_data;
assign  o_fval  =   fval;
assign  o_lval  =   fval & lval;

endmodule
