//filename: feihong_driver.c
//version:1.0
//description: Linux PCIe device driver for feihong User Linux Kernel APIs

#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/version.h>
#include <linux/device.h>
#include <linux/err.h>
#include <linux/io.h>
#include <linux/fs.h>
#include <linux/pci.h>
#include <linux/interrupt.h>
#include <linux/sched.h>
#if LINUX_VERSION_CODE >= KERNEL_VERSION(4,11,0)
#include <linux/sched/signal.h>
#endif
#include <linux/rwsem.h>
#include <linux/dma-mapping.h>
#include <linux/pagemap.h>
#include <linux/slab.h>
#include <asm/uaccess.h>
#include <asm/div64.h>
#include <asm/io.h>
#include <linux/cdev.h>
#include "honghu_driver.h"

MODULE_LICENSE("GPL");
MODULE_AUTHOR("zping");
MODULE_DESCRIPTION("A simple Hello World driver");
MODULE_VERSION("1.0");


//PCI设备匹配，通过厂商ID 设备ID
static const struct pci_device_id pciedev_id[] ={
    {PCI_DEVICE(VENDOR_ID0,DEV_FEIHONG_ID)},
    {0},
};
struct fpga_state{
    struct pci_dev * dev;
    struct cdev cdev;
    struct class * mymodule_class;
    dev_t devt;
    void __iomem *bar0;
    unsigned long long bar0_addr;
    unsigned long long bar0_len;
    unsigned long long bar0_flags;
    int id;
    char name[16];
    int vendor_id;
    int device_id;
};

static struct class *mymodule_class;
static dev_t devt;
static atomic_t used_fpgas[NUM_FPGAS];
static struct fpga_state * fpgas[NUM_FPGAS];

static inline void write_reg(struct fpga_state *sc,int offset,unsigned int val)
{
    printk(KERN_INFO "hognhu: start write to fpga\n");
    writel(val,sc->bar0 +(offset<<2));
}
static inline unsigned int read_reg(struct fpga_state *sc,int offset)
{
    printk(KERN_INFO "hognhu: start read from fpga\n");
    return readl(sc->bar0 +(offset<<2));
}
static inline void reset(int id)
{
    printk(KERN_INFO "hognhu: start reset to fpga\n");
    
}
static long fpga_ioctl (struct file *filp,unsigned int ioctlnum,unsigned long ioctlparam)
{
    int rc;
    fpga_wr_rd_reg io;
    printk(KERN_INFO "hognhu: start FPGA IO Ctrl\n");
    switch(ioctlnum)
    {
        case IOCTL_WR_REG:
            if ((rc = copy_from_user(&io,(void*)ioctlparam,sizeof(fpga_wr_rd_reg))))
            {
                printk(KERN_ERR "hognhu: can not read ioctl user parameter.\n");
                return -1;
            }
            write_reg(fpgas[io.id],io.regaddr,io.regdata);
            printk(KERN_INFO "hognhu: write reg addr = %x data = %x\n",io.regaddr,io.regdata);
            return 0 ;
        case IOCTL_RD_REG:
            if ((rc = copy_from_user(&io,(void*)ioctlparam,sizeof(fpga_wr_rd_reg))))
            {
                printk(KERN_ERR "hognhu: can not read ioctl user parameter.\n");
                return -1;
            }
            io.regdata = read_reg(fpgas[io.id],io.regaddr);
            if((rc = copy_to_user((void*)ioctlparam,&io,sizeof(fpga_wr_rd_reg))))
            {
                printk(KERN_ERR "hognhu: can not write to user.\n");
                return -1;
            }
            return 0;
        case IOCTL_RESET:
            reset((int)ioctlparam);
            return 0 ;
        default:
            return -1;
    }

    
}
struct file_operations fpga_fops = { 
    .owner      = THIS_MODULE ,
    .unlocked_ioctl = fpga_ioctl,
};

//gets called for device
static int __devinit feihong_probe(struct pci_dev *dev,const struct pci_device_id *id)
{
    int i ;
    int error;
    struct fpga_state *sc;
    DEBUG_MSG(KERN_INFO "hognhu: start fpga_probe\n");
    //1、启用设备
    error = pci_enable_device(dev);
    if(error <0)
    {
        DEBUG_MSG(KERN_ERR "hognhu: pci_enable_device returned %d\n",error);
        return -1;
    }
    //主机侧使能
    pci_set_master(dev);

    //2、设置 DMA 掩码
    //检查dma是否支持64位
    error = pci_set_dma_mask(dev,DMA_BIT_MASK(64));
    if(!error)
        error = pci_set_consistent_dma_mask(dev,DMA_BIT_MASK(64));
    if(error)
    {
        DEBUG_MSG(KERN_ERR "feihong:cannot set 64 bit DMA mode\n");
        goto perr1;
    }

    //给设备状态结构体分配内存，退出时必须进行释放
    sc = kzalloc(sizeof(*sc),GFP_KERNEL);
    if(sc == NULL){
        DEBUG_MSG(KERN_ERR "feihong:not enough memory to allocate sc\n");
        pci_disable_device(dev);
        return -1;
    }
    //格式化字符串
    snprintf(sc->name,sizeof(sc->name),"%s%d",DEVICE_NAME,0);
    sc->vendor_id = dev->vendor;
    sc->device_id = dev->device;
    DEBUG_MSG(KERN_INFO "feihong: found FPGA with name: %s\n",sc->name);
    DEBUG_MSG(KERN_INFO "feihong: vendor id : 0x%04x\n",sc->vendor_id);
    DEBUG_MSG(KERN_INFO "feihong: device id : 0x%04x\n",sc->device_id);
    //请求MMIO/IOP资源
    error = pci_request_regions(dev,sc->name);
    if(error < 0){
        DEBUG_MSG(KERN_ERR "hognhu: pci_enable_device returned error %d\n",error);
        pci_disable_device(dev);
        kfree(sc);
        return -1;
    }
    sc->bar0_addr = pci_resource_start(dev,0);
    sc->bar0_len = pci_resource_len(dev,0);
    sc->bar0_flags = pci_resource_flags(dev,0);

    printk(KERN_INFO "feihong: BAR 0 address: %llx\n",sc->bar0_addr);
    printk(KERN_INFO "feihong: BAR 0 length: %lld bytes\n",sc->bar0_len);
    //如果bar地址长度不正确（我们在FPGA端分配的2048）
    if(sc->bar0_len != 2048)
    {
        printk(KERN_ERR "feihong: BAR 0 incorrect length \n");
        //释放被分配到的虚拟地址
        pci_release_regions(dev);
        //失能设备
        pci_disable_device(dev);
        //释放设备状态结构体内存
        kfree(sc);
        return -1;
    }
    //物理地址映射到虚拟地址上
    sc->bar0 = ioremap(sc->bar0_addr,sc->bar0_len);
    if(!sc->bar0)
    {
        printk(KERN_ERR "feihong: could not ioremp bar 0 \n");
        //释放被分配到的虚拟地址
        pci_release_regions(dev);
        //失能设备
        pci_disable_device(dev);

        kfree(sc);
        
        return -1;
    }
    error = register_chrdev(MAJOR_NUM,DEVICE_NAME,&fpga_fops);
    if(error < 0)
    {
        printk(KERN_ERR "feihong: failed to register char device %s with error %d\n",DEVICE_NAME,error);
        return -1;
    }
    printk(KERN_INFO "feihong: success to register char device %s\n",DEVICE_NAME);
    //创建设备节点
    mymodule_class = class_create(THIS_MODULE,DEVICE_NAME);
    if(IS_ERR(mymodule_class))
    {
        error = PTR_ERR(mymodule_class);
        printk(KERN_ERR "feihong: class_create() returned %d\n" ,error);
        return -1;
    }
    devt = MKDEV(MAJOR_NUM,0);
    device_create(mymodule_class,NULL,devt,"%s",DEVICE_NAME);

    //存取参数
    pci_set_drvdata(dev,sc);
    sc->dev = dev;
    sc->id = -1;
    for(i=0 ;i<NUM_FPGAS;i++)
    {
        if(!atomic_xchg(&used_fpgas[i],1))
        {
            sc->id = i;
            fpgas[i] = sc;
            break;
        }
    }
    if(sc->id == -1)
    {
        printk(KERN_ERR "feihong: could not save FPGA information %d is limit\n" ,NUM_FPGAS);
    }
    else 
        printk(KERN_INFO "feihong: success to save FPGA information with id %d\n",sc->id);
    printk(KERN_INFO "feihong: end fpga_probe \n");
    return 0 ;
    perr1:
        pci_disable_device(dev);
        return error;
}
static void __devexit fpga_remove(struct pci_dev *dev)
{
    struct fpga_state *sc;
    printk(KERN_INFO "feihong: start fpga_remove\n");
    if((sc = (struct fpga_state *)pci_get_drvdata(dev)) != NULL)
    {
        atomic_set(&used_fpgas[sc->id],0);
        iounmap(sc->bar0);
        kfree(sc); 
    }
    pci_release_regions(dev);
    pci_disable_device(dev);
    pci_set_drvdata(dev,NULL);

    printk(KERN_INFO "feihong: end fpga_remove\n");
    
}
MODULE_DEVICE_TABLE(pci, pciedev_id);
static struct pci_driver fpga_driver = {
	.name = DEVICE_NAME,
    //设备匹配
	.id_table = pciedev_id,	/* Must be non-NULL for probe to be called */
	//初始化设备，如果系统中有未初始化的设备则调用此函数进行设备的匹配工作
    .probe = feihong_probe,	/* New device inserted */
	.remove = __devexit_p(fpga_remove),	/* Device removed (NULL if not a hot-plug capable driver) */
};

//驱动模块挂载函数
static int __init feihong_init(void)
{
    int error;
    printk(KERN_INFO "feihong: start fpga_init!\n");

    //注册PCI 设备驱动
    error = pci_register_driver(&fpga_driver);
    if(error != 0)
    {
        printk(KERN_ERR "feihong:pci_register returned: %d\n",error);
        return error;
    }
    printk(KERN_INFO "feihong: end fpga_init!\n");
    return 0;
}

static void __exit feihong_exit(void)
{
    
    printk(KERN_INFO "feihong: start fpga_exit!\n");
    pci_unregister_driver(&fpga_driver);
    unregister_chrdev(MAJOR_NUM,DEVICE_NAME);
    device_destroy(mymodule_class,devt);
    class_destroy(mymodule_class);
    printk(KERN_INFO "feihong: end fpga_exit!\n");
}

//驱动模块的挂载与卸载
module_init(feihong_init);
module_exit(feihong_exit);

