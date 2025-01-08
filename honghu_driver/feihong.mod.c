#include <linux/build-salt.h>
#include <linux/module.h>
#include <linux/vermagic.h>
#include <linux/compiler.h>

BUILD_SALT;

MODULE_INFO(vermagic, VERMAGIC_STRING);
MODULE_INFO(name, KBUILD_MODNAME);

__visible struct module __this_module
__section(.gnu.linkonce.this_module) = {
	.name = KBUILD_MODNAME,
	.init = init_module,
#ifdef CONFIG_MODULE_UNLOAD
	.exit = cleanup_module,
#endif
	.arch = MODULE_ARCH_INIT,
};

#ifdef CONFIG_RETPOLINE
MODULE_INFO(retpoline, "Y");
#endif

static const struct modversion_info ____versions[]
__used __section(__versions) = {
	{ 0xdd8f8694, "module_layout" },
	{ 0x6bc3fbc0, "__unregister_chrdev" },
	{ 0x428db41d, "kmalloc_caches" },
	{ 0xdda05fe6, "dma_set_mask" },
	{ 0x37879d4d, "pci_disable_device" },
	{ 0x22e92418, "device_destroy" },
	{ 0x9a19ed29, "__register_chrdev" },
	{ 0xd87af866, "pci_release_regions" },
	{ 0x15d7f502, "dma_set_coherent_mask" },
	{ 0xb44ad4b3, "_copy_to_user" },
	{ 0x347f7814, "pci_set_master" },
	{ 0xc5850110, "printk" },
	{ 0x7749276a, "device_create" },
	{ 0x93a219c, "ioremap_nocache" },
	{ 0xdecd0b29, "__stack_chk_fail" },
	{ 0xbdfb6dbb, "__fentry__" },
	{ 0x2eba3d32, "pci_unregister_driver" },
	{ 0xca7a3159, "kmem_cache_alloc_trace" },
	{ 0x37a0cba, "kfree" },
	{ 0xc485366d, "pci_request_regions" },
	{ 0xedc03953, "iounmap" },
	{ 0x9c70ff83, "__pci_register_driver" },
	{ 0xb65e5a32, "class_destroy" },
	{ 0x656e4a6e, "snprintf" },
	{ 0xdef7c04a, "pci_enable_device" },
	{ 0x362ef408, "_copy_from_user" },
	{ 0x2871e975, "__class_create" },
};

MODULE_INFO(depends, "");

MODULE_ALIAS("pci:v000010EEd00007022sv*sd*bc*sc*i*");

MODULE_INFO(srcversion, "AEDC87E7CF1E97B066B2CA6");
