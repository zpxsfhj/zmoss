// honghu_driver.h
#ifndef HONGHU_DRIVER_H
#define HONGHU_DRIVER_H

#include <linux/ioctl.h>

#define DBUG 1
#ifdef DEBUG
#define DEBUG_MSG(...) printk(__VA_ARGS__)
#else
#define DEBUG_MSG(...)
#endif

#define MAJOR_NUM 100
#define DEVICE_NAME "feihong"
#define VENDOR_ID0 0x10EE
#define DEV_FEIHONG_ID 0X7022
#define NUM_FPGAS 5
#ifndef __devinit
#define __devinit
#define __devexit
#define __devexit_p
#endif

struct fpga_wr_rd_reg
{
    int id;
    int regaddr;
    unsigned int regdata;
};

typedef struct fpga_wr_rd_reg fpga_wr_rd_reg;
#define IOCTL_WR_REG _IOW(MAJOR_NUM,2,fpga_wr_rd_reg *)
#define IOCTL_RD_REG _IOR(MAJOR_NUM,3,fpga_wr_rd_reg *)
#define IOCTL_RESET _IOW(MAJOR_NUM,4,int)




 
#endif