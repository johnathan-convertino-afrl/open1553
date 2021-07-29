#include <linux/module.h>
#include <linux/vermagic.h>
#include <linux/compiler.h>

MODULE_INFO(vermagic, VERMAGIC_STRING);
MODULE_INFO(name, KBUILD_MODNAME);

__visible struct module __this_module
__attribute__((section(".gnu.linkonce.this_module"))) = {
	.name = KBUILD_MODNAME,
	.init = init_module,
#ifdef CONFIG_MODULE_UNLOAD
	.exit = cleanup_module,
#endif
	.arch = MODULE_ARCH_INIT,
};

static const struct modversion_info ____versions[]
__used
__attribute__((section("__versions"))) = {
	{ 0x26a33e1b, __VMLINUX_SYMBOL_STR(module_layout) },
	{ 0xc995c66c, __VMLINUX_SYMBOL_STR(param_ops_int) },
	{ 0x3551dbe3, __VMLINUX_SYMBOL_STR(class_destroy) },
	{ 0xff9c5062, __VMLINUX_SYMBOL_STR(platform_driver_unregister) },
	{ 0x21b1535d, __VMLINUX_SYMBOL_STR(__platform_driver_register) },
	{ 0xcffa10e4, __VMLINUX_SYMBOL_STR(__class_create) },
	{ 0x27e1a049, __VMLINUX_SYMBOL_STR(printk) },
	{ 0x3b389f16, __VMLINUX_SYMBOL_STR(_dev_info) },
	{ 0x7c2d858e, __VMLINUX_SYMBOL_STR(sysfs_create_group) },
	{ 0x92a94bdb, __VMLINUX_SYMBOL_STR(cdev_add) },
	{ 0x2ff3bb75, __VMLINUX_SYMBOL_STR(cdev_init) },
	{ 0x11d28b06, __VMLINUX_SYMBOL_STR(device_create) },
	{ 0x29537c9e, __VMLINUX_SYMBOL_STR(alloc_chrdev_region) },
	{ 0x2072ee9b, __VMLINUX_SYMBOL_STR(request_threaded_irq) },
	{ 0x79c5a9f0, __VMLINUX_SYMBOL_STR(ioremap) },
	{ 0x9416e1d8, __VMLINUX_SYMBOL_STR(__request_region) },
	{ 0xf9d660e2, __VMLINUX_SYMBOL_STR(platform_get_resource) },
	{ 0x93de854a, __VMLINUX_SYMBOL_STR(__init_waitqueue_head) },
	{ 0x1e06ce17, __VMLINUX_SYMBOL_STR(devm_kmalloc) },
	{ 0x2745300b, __VMLINUX_SYMBOL_STR(of_property_read_variable_u32_array) },
	{ 0x8ddd8aad, __VMLINUX_SYMBOL_STR(schedule_timeout) },
	{ 0x1a1431fd, __VMLINUX_SYMBOL_STR(_raw_spin_unlock_irq) },
	{ 0x98dfb43, __VMLINUX_SYMBOL_STR(finish_wait) },
	{ 0x9e52ac12, __VMLINUX_SYMBOL_STR(prepare_to_wait_event) },
	{ 0xfe487975, __VMLINUX_SYMBOL_STR(init_wait_entry) },
	{ 0x7f02188f, __VMLINUX_SYMBOL_STR(__msecs_to_jiffies) },
	{ 0x3507a132, __VMLINUX_SYMBOL_STR(_raw_spin_lock_irq) },
	{ 0x4215a929, __VMLINUX_SYMBOL_STR(__wake_up) },
	{ 0xfa2a45e, __VMLINUX_SYMBOL_STR(__memzero) },
	{ 0x189c5980, __VMLINUX_SYMBOL_STR(arm_copy_to_user) },
	{ 0xe4ca3b4f, __VMLINUX_SYMBOL_STR(mutex_unlock) },
	{ 0x514cc273, __VMLINUX_SYMBOL_STR(arm_copy_from_user) },
	{ 0x2bc1ceec, __VMLINUX_SYMBOL_STR(mutex_lock_interruptible) },
	{ 0xf5429edb, __VMLINUX_SYMBOL_STR(dev_err) },
	{ 0x822137e2, __VMLINUX_SYMBOL_STR(arm_heavy_mb) },
	{ 0x9d669763, __VMLINUX_SYMBOL_STR(memcpy) },
	{ 0xb81960ca, __VMLINUX_SYMBOL_STR(snprintf) },
	{ 0x97255bdf, __VMLINUX_SYMBOL_STR(strlen) },
	{ 0x54a9db5f, __VMLINUX_SYMBOL_STR(_kstrtoul) },
	{ 0x2ab3cc9d, __VMLINUX_SYMBOL_STR(__release_region) },
	{ 0x85f74b00, __VMLINUX_SYMBOL_STR(iomem_resource) },
	{ 0xedc03953, __VMLINUX_SYMBOL_STR(iounmap) },
	{ 0xc1514a3b, __VMLINUX_SYMBOL_STR(free_irq) },
	{ 0x7485e15e, __VMLINUX_SYMBOL_STR(unregister_chrdev_region) },
	{ 0xa9e9a2c1, __VMLINUX_SYMBOL_STR(device_destroy) },
	{ 0xf4c265c8, __VMLINUX_SYMBOL_STR(cdev_del) },
	{ 0x456913ac, __VMLINUX_SYMBOL_STR(sysfs_remove_group) },
	{ 0xefd6cf06, __VMLINUX_SYMBOL_STR(__aeabi_unwind_cpp_pr0) },
};

static const char __module_depends[]
__used
__attribute__((section(".modinfo"))) =
"depends=";

MODULE_ALIAS("of:N*T*Cxlnx,axi-fifo-mm-s-4.1");
MODULE_ALIAS("of:N*T*Cxlnx,axi-fifo-mm-s-4.1C*");
MODULE_ALIAS("of:N*T*Cxlnx,axi-fifo-mm-s-4.2");
MODULE_ALIAS("of:N*T*Cxlnx,axi-fifo-mm-s-4.2C*");
