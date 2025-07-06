`timescale 1ns / 1ps
`define DLY #1
/* `default_nettype none */
//***********************************************************************************/
// Project Name  :
// Author        : ZengPing
// Creat Time    : 2025/01/10 13:15
// File Name     : bar_cpl_buffer.v
// Moduel Name   : bar_cpl_buffer
// Encoding      : GB2312
// Target Devices: 
// Tool Versions : 
// Called By     : 
// Abstract      : 
//
// Description:
//
// copyRight(c)2025,ZPING Technology co. Itd..
// All Rights Reserved
//
//***********************************************************************************/
//Modification History:
// 1. initial
//***********************************************************************************/
//**************************
//MODULE DEFINITION
//**************************
module bar_cpl_buffer #(
    parameter DATA_WIDTH = 32,
    parameter PCIE_DATA_WIDTH = 64
)(
    input wire i_clk    ,
    input wire i_rst    ,
    
    input wire i_tx_clk,
    input wire i_tx_rst,

    input wire                              tx_ready    ,
    output wire [PCIE_DATA_WIDTH/8 - 1 : 0] tx_tkeep    ,
    output wire                             tx_tlast    ,
    output wire [3:0]                       tx_tuser    ,
    output wire                             tx_valid    ,
    output reg  [PCIE_DATA_WIDTH - 1: 0]    tx_data     ,
    //cpld packt
    input wire                          rdCpld_eof       ,
    input wire  [3:0]                   rdCpld_eof_index ,
    input wire                          rdCpld_valid     ,
    input wire  [9:0]                   rdCpld_dwLen     ,
    input wire  [7:0]                   rdCpld_tag       ,
    input wire  [2:0]                   rdCpld_TC        ,
    input wire  [2:0]                   rdCpld_attr      ,
    input wire  [1:0]                   rdCpld_at        ,
    input wire  [11:0]                  rdCpld_bytecnt   ,
    input wire  [6:0]                   rdCpld_lowaddr   , 
    input wire  [PCIE_DATA_WIDTH -1 :0] rdCpld_data      ,
    input wire  [15:0]                  rdCpld_reqid     ,
    input wire  [15:0]                  rdCpld_cplid     ,
    input wire  [2:0]                   rdCpld_status     
    
);
//*******************DEFINE Variables************************************************/
    parameter CPLD_HEAD_WIDTH = 96 + 4 ;
    parameter CPLD_DATA_WIDTH = PCIE_DATA_WIDTH + 1;

    parameter IDLE = 0;
    parameter HEAD_SEND0 = 1;
    parameter HEAD_SEND1 = 2;
    parameter DATA_SEND  = 3;

    reg [1:0] state, next_state;
    
    

    wire [2:0] cpld_fmt;
    wire [4:0] cpld_type;
    wire [1:0] cpld_at ;
    wire       cpld_ep ;
    wire       cpld_td ;
    wire       cpld_th ;


    wire [31:0] cpld_head0,cpld_head1,cpld_head2;
    reg [31:0] cpld_head0_r,cpld_head1_r,cpld_head2_r;

    reg                         head_w_fifo_en  ;
    reg [CPLD_HEAD_WIDTH-1 : 0] head_w_fifo_data;

    wire                         head_r_fifo_en  ;
    wire [CPLD_HEAD_WIDTH-1 : 0] head_r_fifo_data;
    wire head_w_full  ;
    wire head_w_empty ;
    reg data_w_fifo_en ;
    reg [CPLD_DATA_WIDTH-1 : 0] data_w_fifo_data;
    wire data_r_fifo_en ;
    wire [CPLD_DATA_WIDTH-1 : 0] data_r_fifo_data;
    wire data_w_full  ;
    wire data_w_empty ;

    reg [2:0] data_r_fifo_valid;

    reg [PCIE_DATA_WIDTH*2 -1 : 0]  rdCpld_data_2r ;
    reg                             rdCpld_valid_r ;
    reg                             rdCpld_eof_r   ;
    reg [3:0]                       rdCpld_eof_index_r;
    reg                             rdCpld_eof_flag ;

    reg  [9:0]                   rdCpld_dwLen_r     ;
    reg  [7:0]                   rdCpld_tag_r       ;
    reg  [2:0]                   rdCpld_TC_r        ;
    reg  [2:0]                   rdCpld_attr_r      ;
    reg  [1:0]                   rdCpld_at_r        ;
    reg  [11:0]                  rdCpld_bytecnt_r   ;
    reg  [6:0]                   rdCpld_lowaddr_r   ;
    reg  [15:0]                  rdCpld_reqid_r     ;
    reg  [15:0]                  rdCpld_cplid_r     ;
    reg  [2:0]                   rdCpld_status_r    ;

    wire data_w_fifo_eof ;

    reg [3:0] tx_eof_index ;

//*******************INSTANCE AREA***************************************************/
    async_fifo_fwft #(
		.C_WIDTH(CPLD_HEAD_WIDTH),
		.C_DEPTH(1024)
    ) inst_head_async_fifo_fwft (
		.RD_CLK   (i_tx_clk),
		.RD_RST   (i_tx_rst),
		.WR_CLK   (i_clk),
		.WR_RST   (i_rst),
		.WR_DATA  (head_w_fifo_data),
		.WR_EN    (head_w_fifo_en),
		.RD_DATA  (head_r_fifo_data),
		.RD_EN    (head_r_fifo_en),
		.WR_FULL  (head_w_full ),
		.RD_EMPTY (head_w_empty)
	);
    
    async_fifo_fwft #(
		.C_WIDTH(CPLD_DATA_WIDTH),
		.C_DEPTH(1024)
	) inst_data_async_fifo_fwft (
		.RD_CLK   (i_tx_clk),
		.RD_RST   (i_tx_rst),
		.WR_CLK   (i_clk),
		.WR_RST   (i_rst),
		.WR_DATA  (data_w_fifo_data),
		.WR_EN    (data_w_fifo_en),
		.RD_DATA  (data_r_fifo_data),
		.RD_EN    (data_r_fifo_en),
		.WR_FULL  (data_w_full),
		.RD_EMPTY (data_w_empty)
	);
    
    
//*******************PROGRAM AREA****************************************************/
    assign cpld_fmt = 3'b010    ;
    assign cpld_type = 5'b01010 ;
    assign cpld_at   = 2'b00;
    assign cpld_ep   = 1'b1;
    assign cpld_td   = 1'b0;
    assign cpld_th   = 1'b0;
    //cpld组包头
    assign cpld_head0 = {cpld_fmt, cpld_type, 1'b0, rdCpld_TC, 
                         1'b0, rdCpld_attr[2], 1'b0, cpld_th, cpld_td, cpld_ep,
                         rdCpld_attr[1:0],cpld_at,rdCpld_dwLen[9:8], rdCpld_dwLen[7:0]
                             };
    assign cpld_head1 = {rdCpld_cplid[15:8], rdCpld_cplid[7:0], rdCpld_status,1'b0, 
                                            rdCpld_bytecnt[11:8], rdCpld_bytecnt[7:0]};
    assign cpld_head2 = {rdCpld_reqid[15:8], rdCpld_reqid[7:0], rdCpld_tag, 1'b0, rdCpld_lowaddr};
    
    always @(posedge i_clk) begin
        if(i_rst)begin
            cpld_head0_r <= 'd0;
            cpld_head1_r <= 'd0;
            cpld_head2_r <= 'd0;
        end
        else if(rdCpld_valid & ~rdCpld_valid_r) begin
            cpld_head0_r <= cpld_head0;
            cpld_head1_r <= cpld_head1;
            cpld_head2_r <= cpld_head2;
        end
    end
    always @(posedge i_clk) begin
        if(i_rst)begin
            rdCpld_valid_r <= 'd0;
            rdCpld_eof_r   <= 'd0;
            rdCpld_eof_index_r <= 'd0;
        end
        else begin
            rdCpld_valid_r <= rdCpld_valid ;
            rdCpld_eof_r   <= rdCpld_valid & rdCpld_eof   ;
            rdCpld_eof_index_r <= rdCpld_eof_index ;
        end
    end
    //cpld 数据
    always @(posedge i_clk) begin
        if(i_rst)
            rdCpld_eof_flag <= 'd0;
        else if(rdCpld_eof_r)begin
            if(rdCpld_eof_index_r + 4 < PCIE_DATA_WIDTH/8)
                rdCpld_eof_flag <= 1'b0;
            else
                rdCpld_eof_flag <= 1'b1;
        end
        else
            rdCpld_eof_flag <= 1'b0;  
    end
    assign data_w_fifo_eof = rdCpld_eof_r & (rdCpld_eof_index_r + 4 < PCIE_DATA_WIDTH/8) | rdCpld_eof_flag ;
    always @(posedge i_clk) begin
        if(i_rst)
            rdCpld_data_2r <= 'd0;
        else
            rdCpld_data_2r <= {rdCpld_data,rdCpld_data_2r[PCIE_DATA_WIDTH*2 -1 : PCIE_DATA_WIDTH]};
    end
    always @(posedge i_clk) begin
        if(i_rst)begin
            data_w_fifo_en      <= 'd0 ;
            data_w_fifo_data    <= 'd0 ;
        end
        else begin
            data_w_fifo_en   <= rdCpld_valid_r | rdCpld_eof_flag;
            data_w_fifo_data <= {data_w_fifo_eof,rdCpld_data_2r[32 +:PCIE_DATA_WIDTH]};
        end

    end

    always @(posedge i_clk) begin
        if(i_rst)begin
            head_w_fifo_en      <= 'd0;
            head_w_fifo_data    <= 'd0;
        end 
        else begin
            head_w_fifo_en   <= data_w_fifo_eof;
            head_w_fifo_data <= {rdCpld_eof_index_r,cpld_head2_r,cpld_head1_r,cpld_head0_r};
        end
    end

    
    
    //{src_dsc,str,err_fwd,ecrc}
    assign tx_tuser = 4'd0;
    assign tx_tkeep = head_r_fifo_en && head_r_fifo_data[96 +:4] == 7 ? 8'h0f : 8'hff ;



    always @(posedge i_tx_clk) begin
        if(i_rst)
            state <= IDLE;
        else
            state <= next_state;
    end
    always @(*) begin
        case (state)
            IDLE: begin
                if(~head_w_empty & ~head_w_empty)
                    next_state = HEAD_SEND0;
                else
                    next_state = state;
            end
            HEAD_SEND0:begin
                if(tx_ready)begin
                    if(PCIE_DATA_WIDTH == 64)
                        next_state = HEAD_SEND1;
                    else
                        next_state = DATA_SEND;
                end
                else
                    next_state = state;
            end
            HEAD_SEND1:begin
                if(tx_ready & data_r_fifo_data[CPLD_DATA_WIDTH-1])
                    next_state = IDLE ;
                else if(tx_ready)
                    next_state = DATA_SEND;
                else
                    next_state = state ;
            end
            DATA_SEND: begin
                if(tx_ready & data_r_fifo_data[CPLD_DATA_WIDTH-1])
                    next_state = IDLE;
                else
                    next_state = state;
            end
            default: next_state = IDLE;
        endcase
    end

    assign data_r_fifo_en = (state == HEAD_SEND1 ||state == DATA_SEND ) && tx_ready;
    assign head_r_fifo_en = state == DATA_SEND && data_r_fifo_data[CPLD_DATA_WIDTH-1] && tx_ready;
    always @(*) begin
            if(state == HEAD_SEND0 && tx_ready)
                tx_data = head_r_fifo_data[63:0];
            else if(state == HEAD_SEND1 && tx_ready)
                tx_data = {data_r_fifo_data[4*8 +:8],data_r_fifo_data[5*8 +:8],
                            data_r_fifo_data[6*8 +:8],data_r_fifo_data[7*8 +:8],
                            head_r_fifo_data[95:64]
                            };
            else
                tx_data = data_r_fifo_data[63:0];
    end

    reg [3:0]         cnt_data_tx;
    wire                add_cnt_data_tx;
    wire                end_cnt_data_tx;
    wire [3:0] max_data_tx ;
    assign max_data_tx = PCIE_DATA_WIDTH == 64? 2:4;
    always @(posedge i_tx_clk) begin
        if(i_rst)
            cnt_data_tx <= 4'd0;
        else if(add_cnt_data_tx) begin
            if(end_cnt_data_tx)
                cnt_data_tx <= 4'd0;
            else
                cnt_data_tx <= cnt_data_tx + 1'b1;
        end
        else
            cnt_data_tx <= cnt_data_tx;
    end
    
    assign add_cnt_data_tx = state == DATA_SEND && tx_ready;
    assign end_cnt_data_tx = add_cnt_data_tx && (cnt_data_tx == max_data_tx - 1'b1);
    /* always @(posedge i_tx_clk) begin
        if(i_tx_rst)
            tx_valid <= 'd0;
        else if(state == IDLE && (~head_w_empty & ~data_w_empty))
            tx_valid <= 1'b1;
        else if(state == HEAD_SEND0)
            tx_valid <= 1'b1;
        else if(end_cnt_data_tx)
            tx_valid <= 1'b1;
        else
            tx_valid <= 1'b0;
    end */
    assign tx_valid = state == HEAD_SEND0 || state == HEAD_SEND1 || state == DATA_SEND ;
    assign tx_tlast       = data_r_fifo_en & data_r_fifo_data[CPLD_DATA_WIDTH-1] ;

    
    
endmodule