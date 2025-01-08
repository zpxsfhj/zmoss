#ifndef HONGHU_H
#define HONGHU_H

#include "honghu_driver.h"
#ifdef __cplusplus
extern "C"{
#endif
struct fpga_t;
typedef struct fpga_t fpga_t;
fpga_t * fpga_open(int id);
int fpga_reg_write(fpga_t *fpga,int offset,unsigned int val);
int fpga_reg_read(fpga_t *fpga,int offset,unsigned int *valptr);

void fpga_close(fpga_t *fpga);
void fpga_reset(fpga_t *fpga);
#ifdef ____cplusplus
}
#endif
#endif