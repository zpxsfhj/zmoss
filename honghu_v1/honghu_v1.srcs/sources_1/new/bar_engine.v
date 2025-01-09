`timescale 1ns / 1ps
`define DLY #1
/* `default_nettype none */
//***********************************************************************************/
// Project Name  :
// Author        : ZengPing
// Creat Time    : 2025/01/08 09:52
// File Name     : bar_engine.v
// Moduel Name   : bar_engine
// Encoding      : GB2312
// Target Devices: 
// Tool Versions : 
// Called By     : 
// Abstract      : 
//
// Description:
// 1.recive mmem write request packet and write data to bar register or ddr bram
// 2.recive mmem read  request packet and read data from bar register or ddr bram, send read completion packet
// 3.recive IO write/read request packet and operate I/O(some interfaces with external device,such as cmera link)
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
module bar_engine #(
    parameter DATA_WIDTH = 64,
    parameter AXIDATA_WIDTH = 32
)(
    input wire i_rx_pkt_clk,
    input wire i_rx_pkt_rst,
    input wire i_tx_pkt_clk,
    input wire i_axi_clk,
    input wire i_axi_rst,

    input wire                     wrReq_valid     ,
    input wire [DATA_WIDTH-1:0]    wrReq_data      ,
    input wire [9:0]               wrReq_dwlen     ,
    input wire [31:0]              wrReq_address   ,

    input wire                      rdReq_valid     ,
    input wire [31:0]               rdReq_address   ,
    input	wire   	[15:0]          rdReq_reqid     ,
    input	wire  	[7:0]           rdReq_tag       ,
	input	wire  	[9:0]           rdReq_dwlen     ,
	input	wire  	[2:0]           rdReq_TC        ,
	input	wire  	[2:0]           rdReq_attr      ,
	input	wire  	[1:0]           rdReq_at        ,


    output reg  [31:0]                  maxi_lite_awaddr      ,
    input  wire                         maxi_lite_awready     ,
    output reg                          maxi_lite_awvalid     ,

    output reg  [AXIDATA_WIDTH -1 :0]   maxi_lite_wdata       ,
    input  wire                         maxi_lite_wready      ,
    output wire [AXIDATA_WIDTH/8 -1:0]  maxi_lite_wstrb       ,
    output reg                          maxi_lite_wvalid      ,

    output wire                         maxi_lite_bready     ,
    input  wire [1:0]                   maxi_lite_bresp      ,
    input  wire                         maxi_lite_bvalid     ,

    output reg  [31:0]                  maxi_lite_araddr     ,
    input  wire                         maxi_lite_arready    ,
    output reg                          maxi_lite_arvalid    ,

    input  wire [AXIDATA_WIDTH -1 :0]   maxi_lite_rdata      ,
    output reg                          maxi_lite_rready     ,
    input  wire [1:0]                   maxi_lite_rresp      ,
    input  wire                         maxi_lite_rvalid     ,

    //local id 
    input   wire [15:0]                 localID             ,//{ bus dev func id}

	//rdreq to cpld  buffer
    output reg                  rdCpld_valid    ,
    output reg  [9:0]           rdCpld_dwLen    ,
    output reg  [7:0]           rdCpld_tag      ,
    output reg  [2:0]           rdCpld_TC       ,
    output reg  [2:0]           rdCpld_attr     ,
    output reg  [1:0]           rdCpld_at       ,
    output reg  [11:0]          rdCpld_bytecnt  ,
    output reg  [6:0]           rdCpld_lowaddr  ,
    output reg  [127:0]         rdCpld_data     ,
    output reg  [15:0]          rdCpld_reqid    ,
    output reg  [15:0]          rdCpld_cplid    ,
    output reg  [2:0]           rdCpld_status   
    
    
    
    
);
//*******************DEFINE Variables************************************************/
    
    parameter ADDR_VALID_WIDTH      = 16;

    reg [AXIDATA_WIDTH+ADDR_VALID_WIDTH -1 : 0] wrreq_w_fifo_data;
    reg [AXIDATA_WIDTH+ADDR_VALID_WIDTH -1 : 0] wrreq_r_fifo_data;

    reg [AXIDATA_WIDTH+ADDR_VALID_WIDTH -1 : 0] rdreq_w_fifo_data;
    reg [AXIDATA_WIDTH+ADDR_VALID_WIDTH -1 : 0] rdreq_r_fifo_data;

    
    reg rdreq_w_fifo_en;

    reg axi_lite_wbusy;

    wire wrreq_w_empty ;

    wire wrreq_r_fifo_en ;
    
    reg rdreq_r_fifo_en;

    reg axi_lite_rbusy;
    wire rdreq_w_empty;
    
//*******************INSTANCE AREA***************************************************/
    async_fifo_fwft #(
		.C_WIDTH(AXIDATA_WIDTH+ADDR_VALID_WIDTH),
		.C_DEPTH(1024)
	) inst_wrreq_async_fifo_fwft (
		.RD_CLK   (i_axi_clk),
		.RD_RST   (1'b0),
		.WR_CLK   (i_rx_pkt_clk),
		.WR_RST   (1'b0),
		.WR_DATA  (wrreq_w_fifo_data),
		.WR_EN    (wrreq_w_fifo_en),
		.RD_DATA  (wrreq_r_fifo_data),
		.RD_EN    (wrreq_r_fifo_en),
		.WR_FULL  (wrreq_w_full),
		.RD_EMPTY (wrreq_w_empty)
	);
    
    async_fifo_fwft #(
		.C_WIDTH(AXIDATA_WIDTH+ADDR_VALID_WIDTH),
		.C_DEPTH(1024)
	) inst_rdreq_async_fifo_fwft (
		.RD_CLK   (axi_clk),
		.RD_RST   (1'b0),
		.WR_CLK   (USER_CLK),
		.WR_RST   (1'b0),
		.WR_DATA  (rdreq_w_fifo_data),
		.WR_EN    (rdreq_w_fifo_en),
		.RD_DATA  (rdreq_r_fifo_data),
		.RD_EN    (rdreq_r_fifo_en),
		.WR_FULL  (rdreq_w_full),
		.RD_EMPTY (rdreq_w_empty)
	);
//*******************PROGRAM AREA****************************************************/
    always @(posedge i_rx_pkt_clk) begin
        if(i_rx_pkt_rst)
            wrreq_w_fifo_data <= 'd0;
        else 
            wrreq_w_fifo_data <= {wrReq_address[ADDR_VALID_WIDTH - 1:0],wrReq_data[AXIDATA_WIDTH-1 :0]};
    end

    
    always @(posedge i_rx_pkt_clk) begin
        if(i_rx_pkt_rst)begin
            rdreq_w_fifo_en   <= 'd0;
        end
        else if(wrReq_valid == 1'b1 && wrReq_dwlen == 'd1 )
            rdreq_w_fifo_en <= 1'b1;
        else
            rdreq_w_fifo_en <= 1'b0; 
    end
    //read packt to fifo 
    always @(posedge i_rx_pkt_clk) begin
        if(i_rx_pkt_rst)begin
            rdreq_r_fifo_en   <= 'd0;
        end
        else if(rdReq_valid == 1'b1 && rdReq_dwlen == 'd1 )
            rdreq_r_fifo_en <= 1'b1;
        else
            rdreq_r_fifo_en <= 1'b0; 
    end
    always @(posedge i_rx_pkt_clk) begin 
        if (i_rx_pkt_rst) begin
            rdreq_w_fifo_data <= 'd0;
        end
        else if (rdReq_valid == 1'b1 && rdReq_dwlen == 'd1) begin
        	rdreq_w_fifo_data <= {rdReq_at,rdReq_TC,rdReq_attr,rdReq_tag,rdReq_reqid,rdReq_address[ADDR_VALID_WIDTH-1:0]};//byte address
        end
    end


    //axi write
    always @(posedge i_axi_clk) begin
        if(i_axi_rst)
            maxi_lite_awvalid <= 'd0;
        else if(~axi_lite_wbusy && ~wrreq_w_empty)
            maxi_lite_awvalid <= 1'b1;
        else if(maxi_lite_awvalid & maxi_lite_awready)
            maxi_lite_awvalid <= 'd0;
        else
            maxi_lite_awvalid <= maxi_lite_awvalid ;
    end
    always @(posedge i_axi_clk) begin
        if(i_axi_rst)
            maxi_lite_wvalid <= 'd0;
        else if(maxi_lite_awvalid)
            maxi_lite_wvalid <= 1'b1;
        else if(maxi_lite_wvalid & maxi_lite_wready)
            maxi_lite_wvalid <= 1'b0;
        else
            maxi_lite_wvalid <= maxi_lite_wvalid ;
    end

    always @(posedge i_axi_clk) begin
        if(i_axi_rst)
            axi_lite_wbusy <= 'd0;
        else if(maxi_lite_awvalid)
            axi_lite_wbusy <= 1'b1;
        else if(maxi_lite_bready & maxi_lite_bvalid)
            axi_lite_wbusy <= 1'b0;
    end
    assign maxi_lite_bready = axi_lite_wbusy;
    assign maxi_lite_wstrb  = {AXIDATA_WIDTH/8{1'b1}};
    assign wrreq_r_fifo_en  = maxi_lite_bvalid & maxi_lite_bready ;

    always @(posedge i_axi_clk) begin
        if(i_axi_rst)begin
            maxi_lite_awaddr <= 'd0;
            maxi_lite_wdata  <= 'd0;
        end
        else begin
            maxi_lite_awaddr <= wrreq_r_fifo_data[AXIDATA_WIDTH +: ADDR_VALID_WIDTH];
            maxi_lite_wdata  <= wrreq_r_fifo_data[0 +: AXIDATA_WIDTH];
        end
    end

    //axi read
    always @(posedge i_axi_clk) begin
        if(i_axi_rst)
            maxi_lite_arvalid <= 'd0;
        else if(~axi_lite_rbusy && ~rdreq_w_empty)
            maxi_lite_arvalid <= 1'b1;
        else if(maxi_lite_arvalid & maxi_lite_arready)
            maxi_lite_arvalid <= 'd0;
        else
            maxi_lite_arvalid <= maxi_lite_arvalid ;
    end
    always @(posedge i_axi_clk) begin
        if(i_axi_rst)
            maxi_lite_rready <= 'd0;
        else if(maxi_lite_rvalid)
            maxi_lite_rready <= 1'b1;
        else
            maxi_lite_rready <= 1'b0;
    end
    always @(posedge i_axi_clk) begin
        if(i_axi_rst)
            axi_lite_rbusy <= 'd0;
        else if(maxi_lite_awvalid)
            axi_lite_rbusy <= 1'b1;
        else if(maxi_lite_rready & maxi_lite_rvalid)
            axi_lite_rbusy <= 1'b0;
    end

    always @(posedge i_axi_clk) begin
        if(i_axi_rst)
            maxi_lite_araddr <= 'd0;
        else
            maxi_lite_araddr <= rdreq_r_fifo_data[0 +:ADDR_VALID_WIDTH];
    end

    always @(posedge i_axi_clk) begin
        if(i_axi_rst)begin
            rdCpld_valid    <= 'd0;
            rdCpld_cplid     <= 'd0;
            rdCpld_reqid    <= 'd0;
            rdCpld_tag      <= 'd0;
            rdCpld_attr     <= 'd0;
            rdCpld_TC       <= 'd0;
            rdCpld_at       <= 'd0;
            rdCpld_dwLen    <= 'd0;
        end
        else if(maxi_lite_rready & maxi_lite_rvalid)begin
            rdCpld_valid    <= 1'b1;
            rdCpld_cplid    <= localID;
            rdCpld_reqid    <= rdreq_r_fifo_data[ADDR_VALID_WIDTH +: 16];
            rdCpld_tag      <= rdreq_r_fifo_data[ADDR_VALID_WIDTH +16 +: 8];
            rdCpld_attr     <= rdreq_r_fifo_data[ADDR_VALID_WIDTH +16 +8  +: 3];
            rdCpld_TC       <= rdreq_r_fifo_data[ADDR_VALID_WIDTH +16 +8 +3  +: 3];
            rdCpld_at       <= rdreq_r_fifo_data[ADDR_VALID_WIDTH +16 +8 +3 +3  +: 2];
            rdCpld_dwLen    <= 1'b1;
            rdCpld_lowaddr  <= rdReq_address[6:0];
            rdCpld_bytecnt  <= 'd4;
            rdCpld_status   <= 'd0;//sunccess

        end
    end


    
    
endmodule