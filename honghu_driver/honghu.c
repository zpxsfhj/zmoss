#include <stdio.h>
#include <stdlib.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <fcntl.h>
#include "honghu.h"

struct fpga_t
{
    int fd;
    int id;
};
fpga_t *fpga_open(int id)
{
    fpga_t*fpga;
    fpga= (fpga_t*)malloc(sizeof(fpga_t));
    if (fpga == NULL)
        return NULL;
    fpga->id = id;
    fpga->fd = open("/dev/"DEVICE_NAME,O_RDWR|O_SYNC);
    if(fpga->fd < 0)
    {
        free(fpga);
        return NULL;
    }
    return fpga;
}
void fpga_close(fpga_t *fpga)
{
    close(fpga->fd);
    free(fpga);
}
int fpga_reg_write(fpga_t *fpga,int offset,unsigned int val)
{
    fpga_wr_rd_reg io;
    io.id = fpga->id;
    io.regdata=val;
    return ioctl(fpga->fd,IOCTL_WR_REG,&io);
}
int fpga_reg_read(fpga_t *fpga,int offset,unsigned int *valptr)
{
    fpga_wr_rd_reg io;
    io.id = fpga->id;
    io.regaddr =offset;
    ioctl(fpga->fd,IOCTL_RD_REG,&io);
    *valptr= io.regdata;
    return 0;
}
void fpga_reset(fpga_t * fpga)
{
    ioctl(fpga->fd,IOCTL_RESET,fpga->id);
}