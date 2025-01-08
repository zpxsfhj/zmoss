#include <stdio.h>
#include <string.h>
#include <fcntl.h>
#include<sys/mman.h>
#include<unistd.h>
#include<sys/types.h>
#include<sys/stat.h>
#include <stdlib.h>
#include <signal.h>
#include <pthread.h>
//#include "timer.h"
#include "honghu.h"
#include "honghu_driver.h"

int main(int argc,char** argv){
    fpga_t *fpga;
    //fpga_info_list info;
    int option;
    int i,k;
    int id;
    int chnnel;
    int recvd;
    fpga_wr_rd_reg io;
    int status;

    if(argc<2)
    {
        printf("Usage:%s <option>\n",argv[0]);
        return -1;
    }
    //Convert string to integer
    option = atoi(argv[1]);
    if(option == 2)// send data,
    {
        if(argc <5)
        {
            printf("Usage:%s %d <fpga id> <offset> <reg data>\n",argv[0],option);
            return -1;
        }
        id = atoi(argv[2]);
        fpga = fpga_open(id);
        if(fpga == NULL)
        {
            printf("Could not get FPGA %d\n",id);
            return -1;
        }
        io.id = id;
        io.regaddr = atoi(argv[3]);
        io.regdata = atoi(argv[4]);
        status = fpga_reg_write(fpga,io.regaddr,io.regdata);
        if(status != 0)
        {
            printf("Write reg Error! %x \n",status);
        }
        fpga_close(fpga);
        return 0;
    }
    if(option == 3)//receive data from bar
    {
        if(argc <4)
        {
            printf("Usage:%s %d <fpga id> <offset>\n",argv[0],option);
            return -1;
        }
        id = atoi(argv[2]);
        fpga = fpga_open(id);
        if(fpga == NULL)
        {
            printf("Could not get FPGA %d\n",id);
            return -1;
        }
        io.id = id;
        io.regaddr = atoi(argv[3]);
        status = fpga_reg_read(fpga,io.regaddr,&(io.regdata));
        if(status != 0)
        {
            printf("read reg Error! %x \n",status);
        }
        fpga_close(fpga);
        return 0;
    }
    else 
    {
        printf("option error!\n");
        return -1;
    }
}

