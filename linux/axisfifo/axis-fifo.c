// SPDX-License-Identifier: GPL-2.0
/*
 * Xilinx AXIS FIFO: interface to the Xilinx AXI-Stream FIFO IP core
 *
 * Copyright (C) 2018 Jacob Feder
 *
 * Authors:  Jacob Feder <jacobsfeder@gmail.com>
 *
 * See Xilinx PG080 document for IP details
 */

/* ----------------------------
 *           includes
 * ----------------------------
 */

#include <linux/kernel.h>
#include <linux/wait.h>
#include <linux/spinlock_types.h>
#include <linux/device.h>
#include <linux/cdev.h>
#include <linux/init.h>
#include <linux/poll.h>
#include <linux/module.h>
#include <linux/slab.h>
#include <linux/io.h>
#include <linux/moduleparam.h>
#include <linux/interrupt.h>
#include <linux/param.h>
#include <linux/fs.h>
#include <linux/types.h>
#include <linux/uaccess.h>
#include <linux/jiffies.h>

#include <linux/of_address.h>
#include <linux/of_device.h>
#include <linux/of_platform.h>

#include "axis-fifo.h"
/* ----------------------------
 *       driver parameters
 * ----------------------------
 */

#define DRIVER_NAME "axis_fifo"

#define READ_BUF_SIZE 128U /* read buffer length in words */
#define WRITE_BUF_SIZE 128U /* write buffer length in words */

/* ----------------------------
 *           globals
 * ----------------------------
 */

static struct class *axis_fifo_driver_class; /* char device class */

static int read_timeout = 1000; /* ms to wait before read() times out */
static int write_timeout = 1000; /* ms to wait before write() times out */

static DECLARE_WAIT_QUEUE_HEAD(axis_read_wait);
static DECLARE_WAIT_QUEUE_HEAD(axis_write_wait);

/* ----------------------------
 * module command-line arguments
 * ----------------------------
 */

module_param(read_timeout, int, 0444);
MODULE_PARM_DESC(read_timeout, "ms to wait before blocking read() timing out; set to -1 for no timeout");
module_param(write_timeout, int, 0444);
MODULE_PARM_DESC(write_timeout, "ms to wait before blocking write() timing out; set to -1 for no timeout");

/* ----------------------------
 *            types
 * ----------------------------
 */

struct axis_fifo {
    int irq; /* interrupt */
    struct resource *mem; /* physical memory */
    void __iomem *base_addr; /* kernel space memory */
    uint32_t fpga_addr;
    uint32_t tx_pkts;
    uint32_t rx_pkts;
    uint32_t rx_bytes;
    uint32_t tx_bytes;

    unsigned int rx_fifo_depth; /* max words in the receive fifo */
    unsigned int tx_fifo_depth; /* max words in the transmit fifo */
    unsigned int rx_fifo_pf_thresh; /* programmable full threshold for rx */
    unsigned int tx_fifo_pf_thresh; /* programmable full threshold for tx */
    unsigned int rx_fifo_pe_thresh; /* programmable empty threshold for rx */
    unsigned int tx_fifo_pe_thresh; /* programmable empty threshold for tx */
    unsigned int tx_max_pkt_size; /* used to trigger poll events */
    unsigned int rx_min_pkt_size; /* used to trigger poll events */
    int has_rx_fifo; /* whether the IP has the rx fifo enabled */
    int has_tx_fifo; /* whether the IP has the tx fifo enabled */
    int has_tkeep; /* whether the IP has TKEEP enabled or not */

    wait_queue_head_t read_queue; /* wait queue for asynchronos read */
    spinlock_t read_queue_lock; /* lock for reading waitqueue */
    wait_queue_head_t write_queue; /* wait queue for asynchronos write */
    spinlock_t write_queue_lock; /* lock for writing waitqueue */
    unsigned int write_flags; /* write file flags */
    unsigned int read_flags; /* read file flags */

    struct device *dt_device; /* device created from the device tree */
    struct device *device; /* device associated with char_device */
    dev_t devt; /* our char device number */
    struct cdev char_device; /* our char device */
};

/* ----------------------------
 * Function Prototypes
 * ----------------------------
 */
/* required for sysfs */
static void reset_ip_core(struct axis_fifo *fifo);

/* ----------------------------
 *         sysfs entries
 * ----------------------------
 */

static ssize_t sysfs_write(struct device *dev, const char *buf,
               size_t count, unsigned int addr_offset)
{
    struct axis_fifo *fifo = dev_get_drvdata(dev);
    unsigned long tmp;
    int rc;

    rc = kstrtoul(buf, 0, &tmp);
    if (rc < 0)
        return rc;

    iowrite32(tmp, fifo->base_addr + addr_offset);

    return count;
}

static ssize_t sysfs_read(struct device *dev, char *buf,
              unsigned int addr_offset)
{
    struct axis_fifo *fifo = dev_get_drvdata(dev);
    unsigned int read_val;
    unsigned int len;
    char tmp[32];

    read_val = ioread32(fifo->base_addr + addr_offset);
    len =  snprintf(tmp, sizeof(tmp), "0x%x\n", read_val);
    memcpy(buf, tmp, len);

    return len;
}

static ssize_t tx_bytes_show(struct device *dev,
             struct device_attribute *attr, char *buf)
{
    unsigned int len;
    char tmp[32];
    struct axis_fifo *fifo = dev_get_drvdata(dev);
    len =  snprintf(tmp, sizeof(tmp), "0x%x\n", fifo->tx_bytes);
    memcpy(buf, tmp, len);
    return len;
}
static DEVICE_ATTR_RO(tx_bytes);

static ssize_t rx_bytes_show(struct device *dev,
             struct device_attribute *attr, char *buf)
{
    unsigned int len;
    char tmp[32];
    struct axis_fifo *fifo = dev_get_drvdata(dev);
    len =  snprintf(tmp, sizeof(tmp), "0x%x\n", fifo->rx_bytes);
    memcpy(buf, tmp, len);
    return len;
}
static DEVICE_ATTR_RO(rx_bytes);


static ssize_t rx_pkts_show(struct device *dev,
             struct device_attribute *attr, char *buf)
{
    unsigned int len;
    char tmp[32];
    struct axis_fifo *fifo = dev_get_drvdata(dev);
    len =  snprintf(tmp, sizeof(tmp), "0x%x\n", fifo->rx_pkts);
    memcpy(buf, tmp, len);
    return len;
}
static DEVICE_ATTR_RO(rx_pkts);

static ssize_t tx_pkts_show(struct device *dev,
             struct device_attribute *attr, char *buf)
{
    unsigned int len;
    char tmp[32];
    struct axis_fifo *fifo = dev_get_drvdata(dev);
    len =  snprintf(tmp, sizeof(tmp), "0x%x\n", fifo->tx_pkts);
    memcpy(buf, tmp, len);
    return len;
}
static DEVICE_ATTR_RO(tx_pkts);


static ssize_t isr_store(struct device *dev, struct device_attribute *attr,
             const char *buf, size_t count)
{
    return sysfs_write(dev, buf, count, XLLF_ISR_OFFSET);
}

static ssize_t isr_show(struct device *dev,
            struct device_attribute *attr, char *buf)
{
    return sysfs_read(dev, buf, XLLF_ISR_OFFSET);
}

static DEVICE_ATTR_RW(isr);

static ssize_t ier_store(struct device *dev, struct device_attribute *attr,
             const char *buf, size_t count)
{
    return sysfs_write(dev, buf, count, XLLF_IER_OFFSET);
}

static ssize_t ier_show(struct device *dev,
            struct device_attribute *attr, char *buf)
{
    return sysfs_read(dev, buf, XLLF_IER_OFFSET);
}

static DEVICE_ATTR_RW(ier);

static ssize_t tdfr_store(struct device *dev, struct device_attribute *attr,
              const char *buf, size_t count)
{
    return sysfs_write(dev, buf, count, XLLF_TDFR_OFFSET);
}

static DEVICE_ATTR_WO(tdfr);

static ssize_t tdfv_show(struct device *dev,
             struct device_attribute *attr, char *buf)
{
    return sysfs_read(dev, buf, XLLF_TDFV_OFFSET);
}

static DEVICE_ATTR_RO(tdfv);

static ssize_t tdfd_store(struct device *dev, struct device_attribute *attr,
              const char *buf, size_t count)
{
    return sysfs_write(dev, buf, count, XLLF_TDFD_OFFSET);
}

static DEVICE_ATTR_WO(tdfd);

static ssize_t tlr_store(struct device *dev, struct device_attribute *attr,
             const char *buf, size_t count)
{
    return sysfs_write(dev, buf, count, XLLF_TLR_OFFSET);
}

static DEVICE_ATTR_WO(tlr);

static ssize_t rdfr_store(struct device *dev, struct device_attribute *attr,
              const char *buf, size_t count)
{
    return sysfs_write(dev, buf, count, XLLF_RDFR_OFFSET);
}

static DEVICE_ATTR_WO(rdfr);

static ssize_t rdfo_show(struct device *dev,
             struct device_attribute *attr, char *buf)
{
    return sysfs_read(dev, buf, XLLF_RDFO_OFFSET);
}

static DEVICE_ATTR_RO(rdfo);

static ssize_t rdfd_show(struct device *dev,
             struct device_attribute *attr, char *buf)
{
    return sysfs_read(dev, buf, XLLF_RDFD_OFFSET);
}

static DEVICE_ATTR_RO(rdfd);

static ssize_t rlr_show(struct device *dev,
            struct device_attribute *attr, char *buf)
{
    return sysfs_read(dev, buf, XLLF_RLR_OFFSET);
}

static DEVICE_ATTR_RO(rlr);

static ssize_t srr_store(struct device *dev, struct device_attribute *attr,
             const char *buf, size_t count)
{
    return sysfs_write(dev, buf, count, XLLF_SRR_OFFSET);
}

static DEVICE_ATTR_WO(srr);

static ssize_t tdr_store(struct device *dev, struct device_attribute *attr,
             const char *buf, size_t count)
{
    return sysfs_write(dev, buf, count, XLLF_TDR_OFFSET);
}

static DEVICE_ATTR_WO(tdr);

static ssize_t rdr_show(struct device *dev,
            struct device_attribute *attr, char *buf)
{
    return sysfs_read(dev, buf, XLLF_RDR_OFFSET);
}

static DEVICE_ATTR_RO(rdr);

static ssize_t core_reset_store(struct device *dev, struct device_attribute *attr,
             const char *buf, size_t count)
{
    struct axis_fifo *fifo = dev_get_drvdata(dev);
    reset_ip_core(fifo);
    return 1;
}

static DEVICE_ATTR_WO(core_reset);

static ssize_t rx_min_pkt_store(struct device *dev, struct device_attribute *attr,
             const char *buf, size_t count)
{
    struct axis_fifo *fifo = dev_get_drvdata(dev);
    unsigned long tmp;
    int rc;

    rc = kstrtoul(buf, 0, &tmp);
    if (rc < 0)
        return rc;

    fifo->rx_min_pkt_size = tmp;

    return strlen(buf);
}

static ssize_t rx_min_pkt_show(struct device *dev,
            struct device_attribute *attr, char *buf)
{
    struct axis_fifo *fifo = dev_get_drvdata(dev);
    unsigned int read_val;
    unsigned int len;
    char tmp[32];

    read_val = fifo->rx_min_pkt_size;
    len =  snprintf(tmp, sizeof(tmp), "0x%x\n", read_val);
    memcpy(buf, tmp, len);
    return len;
}

static DEVICE_ATTR_RW(rx_min_pkt);

static ssize_t tx_max_pkt_store(struct device *dev, struct device_attribute *attr,
             const char *buf, size_t count)
{
    struct axis_fifo *fifo = dev_get_drvdata(dev);
    unsigned long tmp;
    int rc;

    rc = kstrtoul(buf, 0, &tmp);
    if (rc < 0)
        return rc;

    fifo->tx_max_pkt_size = tmp;

    return strlen(buf);
}

static ssize_t tx_max_pkt_show(struct device *dev,
            struct device_attribute *attr, char *buf)
{
    struct axis_fifo *fifo = dev_get_drvdata(dev);
    unsigned int read_val;
    unsigned int len;
    char tmp[32];

    read_val = fifo->tx_max_pkt_size;
    len =  snprintf(tmp, sizeof(tmp), "0x%x\n", read_val);
    memcpy(buf, tmp, len);
    return len;
}

static DEVICE_ATTR_RW(tx_max_pkt);

static struct attribute *axis_fifo_attrs[] = {
    &dev_attr_tx_bytes.attr,
    &dev_attr_rx_bytes.attr,
    &dev_attr_rx_pkts.attr,
    &dev_attr_tx_pkts.attr,
    &dev_attr_isr.attr,
    &dev_attr_ier.attr,
    &dev_attr_tdfr.attr,
    &dev_attr_tdfv.attr,
    &dev_attr_tdfd.attr,
    &dev_attr_tlr.attr,
    &dev_attr_rdfr.attr,
    &dev_attr_rdfo.attr,
    &dev_attr_rdfd.attr,
    &dev_attr_rlr.attr,
    &dev_attr_srr.attr,
    &dev_attr_tdr.attr,
    &dev_attr_rdr.attr,
    &dev_attr_core_reset.attr,
    &dev_attr_tx_max_pkt.attr,
    &dev_attr_rx_min_pkt.attr,
    NULL,
};

static const struct attribute_group axis_fifo_attrs_group = {
    .name = "ip_registers",
    .attrs = axis_fifo_attrs,
};

/* ----------------------------
 *        implementation
 * ----------------------------
 */

static void reset_ip_core(struct axis_fifo *fifo)
{
    iowrite32(XLLF_SRR_RESET_MASK, fifo->base_addr + XLLF_SRR_OFFSET);
    iowrite32(XLLF_TDFR_RESET_MASK, fifo->base_addr + XLLF_TDFR_OFFSET);
    iowrite32(XLLF_RDFR_RESET_MASK, fifo->base_addr + XLLF_RDFR_OFFSET);
    iowrite32(XLLF_INT_TC_MASK | XLLF_INT_RC_MASK | XLLF_INT_RPURE_MASK |
          XLLF_INT_RPORE_MASK | XLLF_INT_RPUE_MASK |
          XLLF_INT_TPOE_MASK | XLLF_INT_TSE_MASK,
          fifo->base_addr + XLLF_IER_OFFSET);
    iowrite32(XLLF_INT_ALL_MASK, fifo->base_addr + XLLF_ISR_OFFSET);
}

static unsigned int axis_poll(struct file *file, poll_table *wait)
{
    unsigned int mask;
    struct axis_fifo *fifo = (struct axis_fifo *)file->private_data;
    unsigned int rdfo;
    unsigned int tdfv;
    mask = 0;

    if (fifo->has_rx_fifo)
        poll_wait(file, &axis_read_wait, wait);
    if (fifo->has_tx_fifo)
        poll_wait(file, &axis_write_wait, wait);

    /* user should set the rx-min-pkt-size
    * in the device tree to indicate when POLLIN will return
    * NOTE : rx-min-pkt-size is in WORDS not BYTES
    */
    if (fifo->has_rx_fifo) {
        rdfo = ioread32(fifo->base_addr + XLLF_RDFO_OFFSET);
        if (rdfo > fifo->rx_min_pkt_size){
            mask |= POLLIN | POLLRDNORM;
        }
    }

    /* user should set the tx-max-pkt-size
    * in the device tree to indicate when POLLOUT will return
    * NOTE : tx-max-pkt-size is in WORDS not BYTES
    */
    if (fifo->has_tx_fifo) {
        tdfv = ioread32(fifo->base_addr + XLLF_TDFV_OFFSET);
        if (tdfv > fifo->tx_max_pkt_size){
            mask |= POLLOUT;
            }
    }

    return mask;
}

/* reads a single packet from the fifo as dictated by the tlast signal */
static ssize_t axis_fifo_read(struct file *f, char __user *buf,
                  size_t len, loff_t *off)
{
    struct axis_fifo *fifo = (struct axis_fifo *)f->private_data;
    size_t bytes_available;
    unsigned int words_available;
        unsigned int leftover;
    unsigned int copied;
    unsigned int copy;
    unsigned int i;
    int ret;
    u32 tmp_buf[READ_BUF_SIZE];

    if (fifo->read_flags & O_NONBLOCK) {
        /* opened in non-blocking mode
         * return if there are no packets available
         */
        if (!ioread32(fifo->base_addr + XLLF_RDFO_OFFSET))
            return -EAGAIN;
    } else {
        /* opened in blocking mode
         * wait for a packet available interrupt (or timeout)
         * if nothing is currently available
         */
        spin_lock_irq(&fifo->read_queue_lock);
        ret = wait_event_interruptible_lock_irq_timeout(
            fifo->read_queue,
            ioread32(fifo->base_addr + XLLF_RDFO_OFFSET),
            fifo->read_queue_lock,
            (read_timeout >= 0) ? msecs_to_jiffies(read_timeout) :
                MAX_SCHEDULE_TIMEOUT);
        spin_unlock_irq(&fifo->read_queue_lock);
                wake_up_interruptible(&axis_read_wait);

        if (ret == 0) {
            /* timeout occurred */
            dev_dbg(fifo->dt_device, "read timeout");
            return -EAGAIN;
        } else if (ret == -ERESTARTSYS) {
            /* signal received */
            return -ERESTARTSYS;
        } else if (ret < 0) {
            dev_err(fifo->dt_device, "wait_event_interruptible_timeout() error in read (ret=%i)\n",
                ret);
            return ret;
        }
    }

    bytes_available = ioread32(fifo->base_addr + XLLF_RLR_OFFSET);
    if (!bytes_available) {
        dev_err(fifo->dt_device, "received a packet of length 0 - fifo core will be reset\n");
        reset_ip_core(fifo);
        return -EIO;
    }

    if (bytes_available > len) {
        dev_err(fifo->dt_device, "user read buffer too small (available bytes=%zu user buffer bytes=%zu) - fifo core will be reset\n",
            bytes_available, len);
        reset_ip_core(fifo);
        return -EINVAL;
    }

    if (!fifo->has_tkeep && bytes_available % sizeof(u32)) {
        /* this probably can't happen unless IP
         * registers were previously mishandled
         */
        dev_err(fifo->dt_device, "received a packet that isn't word-aligned - fifo core will be reset\n");
        reset_ip_core(fifo);
        return -EIO;
    }

    words_available = bytes_available / sizeof(u32);

#ifdef AXIS_FIFO_DEBUG_PRINT
    dev_err(fifo->dt_device,"read: rdfo : %d ... tdfv : %d ... rlr : %d\n",
        ioread32(fifo->base_addr + XLLF_RDFO_OFFSET),
        ioread32(fifo->base_addr + XLLF_TDFV_OFFSET),
        bytes_available);
#endif

    /* read data into an intermediate buffer, copying the contents
     * to userspace when the buffer is full
     */
    copied = 0;
    while (words_available > 0) {
        copy = min(words_available, READ_BUF_SIZE);

        for (i = 0; i < copy; i++) {
            tmp_buf[i] = ioread32(fifo->base_addr +
                          XLLF_RDFD_OFFSET);
        }

        if (copy_to_user(buf + copied * sizeof(u32), tmp_buf,
                 copy * sizeof(u32))) {
            reset_ip_core(fifo);
            return -EFAULT;
        }

        copied += copy;
        words_available -= copy;
    }

    if (fifo->has_tkeep) {
        leftover = bytes_available % sizeof(u32);
        if (leftover) {
            tmp_buf[0] = ioread32(fifo->base_addr +
                                  XLLF_RDFD_OFFSET);

            if (copy_to_user(buf + copied * sizeof(u32), tmp_buf,
                         leftover)) {
                reset_ip_core(fifo);
                return -EFAULT;
            }
        }
    }

    fifo->rx_pkts++;
    fifo->rx_bytes += bytes_available;
    return bytes_available;
}

static ssize_t axis_fifo_write(struct file *f, const char __user *buf,
                   size_t len, loff_t *off)
{
    struct axis_fifo *fifo = (struct axis_fifo *)f->private_data;
    unsigned int words_to_write;
    unsigned int copied;
    unsigned int copiedBytes;
    unsigned int copy;
    unsigned int i;
    int ret;
    u32 tmp_buf[WRITE_BUF_SIZE];
    int leftover;

    if (!fifo->has_tkeep && len % sizeof(u32)) {
        dev_err(fifo->dt_device,
            "tried to send a packet that isn't word-aligned\n");
        return -EINVAL;
    }

    if (len > 0 && len < 4) {
        words_to_write = 1;
        leftover = 0;
    } else {
        words_to_write = len / sizeof(u32);
        leftover = len % sizeof(u32);
    }

    if (!words_to_write) {
        dev_err(fifo->dt_device,
            "tried to send a packet of length 0\n");
        return -EINVAL;
    }

    if (words_to_write > fifo->tx_fifo_depth) {
        dev_err(fifo->dt_device, "tried to write more words [%u] than slots in the fifo buffer [%u]\n",
            words_to_write, fifo->tx_fifo_depth);
        return -EINVAL;
    }

    if (fifo->write_flags & O_NONBLOCK) {
        /* opened in non-blocking mode
         * return if there is not enough room available in the fifo
         */
        if (words_to_write > ioread32(fifo->base_addr +
                          XLLF_TDFV_OFFSET)) {
            return -EAGAIN;
        }
    } else {
        /* opened in blocking mode */

        /* wait for an interrupt (or timeout) if there isn't
         * currently enough room in the fifo
         */
        spin_lock_irq(&fifo->write_queue_lock);
        ret = wait_event_interruptible_lock_irq_timeout(
            fifo->write_queue,
            ioread32(fifo->base_addr + XLLF_TDFV_OFFSET)
                >= words_to_write,
            fifo->write_queue_lock,
            (write_timeout >= 0) ? msecs_to_jiffies(write_timeout) :
                MAX_SCHEDULE_TIMEOUT);
        spin_unlock_irq(&fifo->write_queue_lock);
                wake_up_interruptible(&axis_write_wait);

        if (ret == 0) {
            /* timeout occurred */
            dev_dbg(fifo->dt_device, "write timeout\n");
            return -EAGAIN;
        } else if (ret == -ERESTARTSYS) {
            /* signal received */
            return -ERESTARTSYS;
        } else if (ret < 0) {
            /* unknown error */
            dev_err(fifo->dt_device,
                "wait_event_interruptible_timeout() error in write (ret=%i)\n",
                ret);
            return ret;
        }
    }

#ifdef AXIS_FIFO_DEBUG_PRINT
    dev_err(fifo->dt_device,"write: rdfo : %d ... tdfv : %d\n",
        ioread32(fifo->base_addr + XLLF_RDFO_OFFSET),
        ioread32(fifo->base_addr + XLLF_TDFV_OFFSET));
#endif

    /* write data from an intermediate buffer into the fifo IP, refilling
     * the buffer with userspace data as needed
     */
    copied = 0;
    while (words_to_write > 0) {
        copy = min(words_to_write, WRITE_BUF_SIZE);

        if (copy_from_user(tmp_buf, buf + copied * sizeof(u32),
                   copy * sizeof(u32))) {
            reset_ip_core(fifo);
            return -EFAULT;
        }

        for (i = 0; i < copy; i++)
            iowrite32(tmp_buf[i], fifo->base_addr +
                  XLLF_TDFD_OFFSET);

        copied += copy;
        words_to_write -= copy;
    }

    if (fifo->has_tkeep && leftover) {
                if (copy_from_user(tmp_buf, buf + copied * sizeof(u32),
                                   leftover)) {
                        reset_ip_core(fifo);
                        return -EFAULT;
                }
                iowrite32(tmp_buf[0], fifo->base_addr +
                          XLLF_TDFD_OFFSET);
        }

        /* write packet size to fifo */
    copiedBytes = (fifo->has_tkeep && !!leftover) ? (copied*sizeof(u32)+leftover) : (copied*sizeof(u32));
        iowrite32(copiedBytes, fifo->base_addr + XLLF_TLR_OFFSET);

        fifo->tx_pkts++;
        fifo->tx_bytes += copiedBytes;
        return (ssize_t)copiedBytes;
}


static DEFINE_MUTEX(ioctl_lock);
static long axis_fifo_ioctl(struct file *f, unsigned int cmd, unsigned long arg)
{
    long rc;
    void *__user arg_ptr;
    uint32_t temp_reg;
    struct axis_fifo_kern_regInfo regInfo;
    struct axis_fifo *fifo = (struct axis_fifo *)f->private_data;

    if (mutex_lock_interruptible(&ioctl_lock))
        return -EINTR;

    // Coerce the arguement as a userspace pointer
    arg_ptr = (void __user *)arg;
    temp_reg = 0;

    // Verify that this IOCTL is intended for our device, and is in range
    if (_IOC_TYPE(cmd) != AXIS_FIFO_IOCTL_MAGIC) {
        dev_err(fifo->dt_device, "IOCTL command magic number does not match.\n");
        return -ENOTTY;
    } else if (_IOC_NR(cmd) >= AXIS_FIFO_NUM_IOCTLS) {
        dev_err(fifo->dt_device, "IOCTL command is out of range for this device.\n");
        return -ENOTTY;
    }

    // Perform the specified command
    switch (cmd) {
        case AXIS_FIFO_GET_REG:
            if (copy_from_user(&regInfo, arg_ptr, sizeof(regInfo))) {
                dev_err(fifo->dt_device, "unable to copy status reg to userspace\n");
                return -EFAULT;
            }
            regInfo.regVal = ioread32(fifo->base_addr + regInfo.regNo);
            if (copy_to_user(arg_ptr, &regInfo, sizeof(regInfo))) {
                dev_err(fifo->dt_device, "unable to copy status reg to userspace\n");
                return -EFAULT;
            }
            rc = 0;
            break;

        case AXIS_FIFO_GET_RX_PKTS_READ:
            temp_reg = fifo->rx_pkts;
            if (copy_to_user(arg_ptr, &temp_reg, sizeof(temp_reg))) {
                dev_err(fifo->dt_device, "unable to copy status reg to userspace\n");
                return -EFAULT;
            }
            rc = 0;
            break;

        case AXIS_FIFO_GET_RX_BYTES_READ:
            temp_reg = fifo->rx_bytes;
            if (copy_to_user(arg_ptr, &temp_reg, sizeof(temp_reg))) {
                dev_err(fifo->dt_device, "unable to copy status reg to userspace\n");
                return -EFAULT;
            }
            rc = 0;
            break;

        case AXIS_FIFO_GET_TX_PKTS_SENT:
            temp_reg = fifo->tx_pkts;
            if (copy_to_user(arg_ptr, &temp_reg, sizeof(temp_reg))) {
                dev_err(fifo->dt_device, "unable to copy status reg to userspace\n");
                return -EFAULT;
            }
            rc = 0;
            break;

        case AXIS_FIFO_GET_TX_BYTES_SENT:
            temp_reg = fifo->tx_bytes;
            if (copy_to_user(arg_ptr, &temp_reg, sizeof(temp_reg))) {
                dev_err(fifo->dt_device, "unable to copy status reg to userspace\n");
                return -EFAULT;
            }
            rc = 0;
            break;

        case AXIS_FIFO_SET_REG:
            if (copy_from_user(&regInfo, arg_ptr, sizeof(regInfo))) {
                dev_err(fifo->dt_device, "unable to copy status reg to userspace\n");
                return -EFAULT;
            }
            iowrite32(regInfo.regVal, fifo->base_addr + regInfo.regNo);
            rc = 0;
            break;

        case AXIS_FIFO_GET_TX_VACANCY:
            temp_reg = ioread32(fifo->base_addr + XLLF_TDFV_OFFSET);
            if (copy_to_user(arg_ptr, &temp_reg, sizeof(temp_reg))) {
                dev_err(fifo->dt_device, "unable to copy status reg to userspace\n");
                return -EFAULT;
            }
            rc = 0;
            break;

        case AXIS_FIFO_GET_RX_OCCUPANCY:
            temp_reg = ioread32(fifo->base_addr + XLLF_RDFO_OFFSET);
            if (copy_to_user(arg_ptr, &temp_reg, sizeof(temp_reg))) {
                dev_err(fifo->dt_device, "unable to copy status reg to userspace\n");
                return -EFAULT;
            }
            rc = 0;
            break;

        case AXIS_FIFO_GET_TX_MAX_PKT:
            temp_reg = fifo->tx_max_pkt_size;
            if (copy_to_user(arg_ptr, &temp_reg, sizeof(temp_reg))) {
                dev_err(fifo->dt_device, "unable to copy status reg to userspace\n");
                return -EFAULT;
            }
            rc = 0;
            break;

        case AXIS_FIFO_SET_TX_MAX_PKT:
            if (copy_from_user(&temp_reg, arg_ptr, sizeof(temp_reg))) {
                dev_err(fifo->dt_device, "unable to copy status reg to userspace\n");
                return -EFAULT;
            }
            fifo->tx_max_pkt_size = temp_reg;
            rc = 0;
            break;

        case AXIS_FIFO_GET_RX_MIN_PKT:
            temp_reg = fifo->rx_min_pkt_size;
            if (copy_to_user(arg_ptr, &temp_reg, sizeof(temp_reg))) {
                dev_err(fifo->dt_device, "unable to copy status reg to userspace\n");
                return -EFAULT;
            }
            rc = 0;
            break;

        case AXIS_FIFO_SET_RX_MIN_PKT:
            if (copy_from_user(&temp_reg, arg_ptr, sizeof(temp_reg))) {
                dev_err(fifo->dt_device, "unable to copy status reg to userspace\n");
                return -EFAULT;
            }
            fifo->rx_min_pkt_size = temp_reg;
            rc = 0;
            break;

        case AXIS_FIFO_GET_FPGA_ADDR:
            temp_reg = fifo->fpga_addr;
            if (copy_to_user(arg_ptr, &temp_reg, sizeof(temp_reg))) {
                dev_err(fifo->dt_device, "unable to copy status reg to userspace\n");
                return -EFAULT;
            }
            rc = 0;
            break;

        case AXIS_FIFO_RESET_IP:
            reset_ip_core(fifo);
            break;

        default:
            return -ENOTTY;
    }

    mutex_unlock(&ioctl_lock);
    return rc;
}
static irqreturn_t axis_fifo_irq(int irq, void *dw)
{
    struct axis_fifo *fifo = (struct axis_fifo *)dw;
    unsigned int pending_interrupts;

    do {
        pending_interrupts = ioread32(fifo->base_addr +
                          XLLF_IER_OFFSET) &
                          ioread32(fifo->base_addr
                          + XLLF_ISR_OFFSET);
        if (pending_interrupts & XLLF_INT_RC_MASK) {
            /* packet received */

            /* wake the reader process if it is waiting */
            wake_up(&fifo->read_queue);
            wake_up_interruptible(&axis_read_wait);

            /* clear interrupt */
            iowrite32(XLLF_INT_RC_MASK & XLLF_INT_ALL_MASK,
                  fifo->base_addr + XLLF_ISR_OFFSET);
        } else if (pending_interrupts & XLLF_INT_TC_MASK) {
            /* packet sent */

            /* wake the writer process if it is waiting */
            wake_up(&fifo->write_queue);
            wake_up_interruptible(&axis_write_wait);

            iowrite32(XLLF_INT_TC_MASK & XLLF_INT_ALL_MASK,
                  fifo->base_addr + XLLF_ISR_OFFSET);
        } else if (pending_interrupts & XLLF_INT_TFPF_MASK) {
            /* transmit fifo programmable full */

            iowrite32(XLLF_INT_TFPF_MASK & XLLF_INT_ALL_MASK,
                  fifo->base_addr + XLLF_ISR_OFFSET);
        } else if (pending_interrupts & XLLF_INT_TFPE_MASK) {
            /* transmit fifo programmable empty */

            wake_up_interruptible(&axis_write_wait);
            iowrite32(XLLF_INT_TFPE_MASK & XLLF_INT_ALL_MASK,
                  fifo->base_addr + XLLF_ISR_OFFSET);
        } else if (pending_interrupts & XLLF_INT_RFPF_MASK) {
            /* receive fifo programmable full */

            wake_up_interruptible(&axis_read_wait);
            iowrite32(XLLF_INT_RFPF_MASK & XLLF_INT_ALL_MASK,
                  fifo->base_addr + XLLF_ISR_OFFSET);
        } else if (pending_interrupts & XLLF_INT_RFPE_MASK) {
            /* receive fifo programmable empty */

            iowrite32(XLLF_INT_RFPE_MASK & XLLF_INT_ALL_MASK,
                  fifo->base_addr + XLLF_ISR_OFFSET);
        } else if (pending_interrupts & XLLF_INT_TRC_MASK) {
            /* transmit reset complete interrupt */

            iowrite32(XLLF_INT_TRC_MASK & XLLF_INT_ALL_MASK,
                  fifo->base_addr + XLLF_ISR_OFFSET);
        } else if (pending_interrupts & XLLF_INT_RRC_MASK) {
            /* receive reset complete interrupt */

            iowrite32(XLLF_INT_RRC_MASK & XLLF_INT_ALL_MASK,
                  fifo->base_addr + XLLF_ISR_OFFSET);
        } else if (pending_interrupts & XLLF_INT_RPURE_MASK) {
            /* receive fifo under-read error interrupt */
            dev_err(fifo->dt_device,
                "receive under-read interrupt, reset rx fifo\n");
            iowrite32(XLLF_RDFR_RESET_MASK, fifo->base_addr + XLLF_RDFR_OFFSET);

            iowrite32(XLLF_INT_RPURE_MASK & XLLF_INT_ALL_MASK,
                  fifo->base_addr + XLLF_ISR_OFFSET);
        } else if (pending_interrupts & XLLF_INT_RPORE_MASK) {
            /* receive over-read error interrupt */
            dev_err(fifo->dt_device,
                "receive over-read interrupt, reset rx fifo\n");
            iowrite32(XLLF_RDFR_RESET_MASK, fifo->base_addr + XLLF_RDFR_OFFSET);

            iowrite32(XLLF_INT_RPORE_MASK & XLLF_INT_ALL_MASK,
                  fifo->base_addr + XLLF_ISR_OFFSET);
        } else if (pending_interrupts & XLLF_INT_RPUE_MASK) {
            /* receive underrun error interrupt */
            dev_err(fifo->dt_device,
                "receive underrun error interrupt, reset rx fifo\n");
            iowrite32(XLLF_RDFR_RESET_MASK, fifo->base_addr + XLLF_RDFR_OFFSET);

            iowrite32(XLLF_INT_RPUE_MASK & XLLF_INT_ALL_MASK,
                  fifo->base_addr + XLLF_ISR_OFFSET);
        } else if (pending_interrupts & XLLF_INT_TPOE_MASK) {
            /* transmit overrun error interrupt */
            dev_err(fifo->dt_device,
                "transmit overrun error interrupt, reset tx fifo\n");
            iowrite32(XLLF_TDFR_RESET_MASK, fifo->base_addr + XLLF_TDFR_OFFSET);

            iowrite32(XLLF_INT_TPOE_MASK & XLLF_INT_ALL_MASK,
                  fifo->base_addr + XLLF_ISR_OFFSET);
        } else if (pending_interrupts & XLLF_INT_TSE_MASK) {
            /* transmit length mismatch error interrupt */
            dev_err(fifo->dt_device,
                "transmit length mismatch error interrupt\n");

            iowrite32(XLLF_INT_TSE_MASK & XLLF_INT_ALL_MASK,
                  fifo->base_addr + XLLF_ISR_OFFSET);
        } else if (pending_interrupts) {
            /* unknown interrupt type */
            dev_err(fifo->dt_device,
                "unknown interrupt(s) 0x%x\n",
                pending_interrupts);

            iowrite32(XLLF_INT_ALL_MASK,
                  fifo->base_addr + XLLF_ISR_OFFSET);
        }
    } while (pending_interrupts);

    return IRQ_HANDLED;
}

static int axis_fifo_open(struct inode *inod, struct file *f)
{
    struct axis_fifo *fifo = (struct axis_fifo *)container_of(inod->i_cdev,
                    struct axis_fifo, char_device);
    f->private_data = fifo;

    if (((f->f_flags & O_ACCMODE) == O_WRONLY) ||
        ((f->f_flags & O_ACCMODE) == O_RDWR)) {
        if (fifo->has_tx_fifo) {
            fifo->write_flags = f->f_flags;
        } else {
            dev_err(fifo->dt_device, "tried to open device for write but the transmit fifo is disabled\n");
            return -EPERM;
        }
    }

    if (((f->f_flags & O_ACCMODE) == O_RDONLY) ||
        ((f->f_flags & O_ACCMODE) == O_RDWR)) {
        if (fifo->has_rx_fifo) {
            fifo->read_flags = f->f_flags;
        } else {
            dev_err(fifo->dt_device, "tried to open device for read but the receive fifo is disabled\n");
            return -EPERM;
        }
    }

    return 0;
}

static int axis_fifo_close(struct inode *inod, struct file *f)
{
    f->private_data = NULL;

    return 0;
}

static const struct file_operations fops = {
    .owner = THIS_MODULE,
    .open = axis_fifo_open,
    .release = axis_fifo_close,
    .unlocked_ioctl = axis_fifo_ioctl,
    .read = axis_fifo_read,
    .write = axis_fifo_write,
    .poll = axis_poll
};

/* read named property from the device tree */
static int get_dts_property(struct axis_fifo *fifo,
                char *name, unsigned int *var)
{
    int rc;

    rc = of_property_read_u32(fifo->dt_device->of_node, name, var);
    if (rc) {
        dev_err(fifo->dt_device, "couldn't read IP dts property '%s'",
            name);
        return rc;
    }
    dev_dbg(fifo->dt_device, "dts property '%s' = %u\n",
        name, *var);

    return 0;
}

static int axis_fifo_probe(struct platform_device *pdev)
{
    struct resource *r_irq; /* interrupt resources */
    struct resource *r_mem; /* IO mem resources */
    struct device *dev = &pdev->dev; /* OS device (from device tree) */
    struct axis_fifo *fifo = NULL;

    char device_name[32];

    int rc = 0; /* error return value */

    /* IP properties from device tree */
    unsigned int rxd_tdata_width;
    unsigned int txc_tdata_width;
    unsigned int txd_tdata_width;
    unsigned int tdest_width;
    unsigned int tid_width;
    unsigned int tuser_width;
    unsigned int data_interface_type;
    unsigned int has_tdest;
    unsigned int has_tid;
    unsigned int has_tkeep;
    unsigned int has_tstrb;
    unsigned int has_tuser;
    unsigned int rx_fifo_depth;
    unsigned int rx_programmable_empty_threshold;
    unsigned int rx_programmable_full_threshold;
    unsigned int axi_id_width;
    unsigned int axi4_data_width;
    unsigned int select_xpm;
    unsigned int tx_fifo_depth;
    unsigned int tx_programmable_empty_threshold;
    unsigned int tx_programmable_full_threshold;
    unsigned int use_rx_cut_through;
    unsigned int use_rx_data;
    unsigned int use_tx_control;
    unsigned int use_tx_cut_through;
    unsigned int use_tx_data;
    unsigned int tx_max_pkt_size;
    unsigned int rx_min_pkt_size;

    /* ----------------------------
     *     init wrapper device
     * ----------------------------
     */

    /* allocate device wrapper memory */
    fifo = devm_kmalloc(dev, sizeof(*fifo), GFP_KERNEL);
    if (!fifo)
        return -ENOMEM;

    dev_set_drvdata(dev, fifo);
    fifo->dt_device = dev;

    init_waitqueue_head(&fifo->read_queue);
    init_waitqueue_head(&fifo->write_queue);

    spin_lock_init(&fifo->read_queue_lock);
    spin_lock_init(&fifo->write_queue_lock);

    /* ----------------------------
     *   init device memory space
     * ----------------------------
     */

    /* get iospace for the device */
    r_mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
    if (!r_mem) {
        dev_err(fifo->dt_device, "invalid address\n");
        rc = -ENODEV;
        goto err_initial;
    }

    fifo->mem = r_mem;

    /* request physical memory */
    if (!request_mem_region(fifo->mem->start, resource_size(fifo->mem),
                DRIVER_NAME)) {
        dev_err(fifo->dt_device,
            "couldn't lock memory region at 0x%pa\n",
            &fifo->mem->start);
        rc = -EBUSY;
        goto err_initial;
    }
    dev_dbg(fifo->dt_device, "got memory location [0x%pa - 0x%pa]\n",
        &fifo->mem->start, &fifo->mem->end);
    fifo->fpga_addr = fifo->mem->start;

    /* map physical memory to kernel virtual address space */
    fifo->base_addr = ioremap(fifo->mem->start, resource_size(fifo->mem));
    if (!fifo->base_addr) {
        dev_err(fifo->dt_device, "couldn't map physical memory\n");
        rc = -ENOMEM;
        goto err_mem;
    }
    dev_dbg(fifo->dt_device, "remapped memory to 0x%p\n", fifo->base_addr);

    /* create unique device name */
    snprintf(device_name, sizeof(device_name), "%s_%pa",
         DRIVER_NAME, &fifo->mem->start);

    dev_dbg(fifo->dt_device, "device name [%s]\n", device_name);

    fifo->tx_pkts = 0;
    fifo->rx_pkts = 0;
    fifo->rx_bytes = 0;
    fifo->tx_bytes = 0;
    /* ----------------------------
     *          init IP
     * ----------------------------
     */

    /* retrieve device tree properties */
    rc = get_dts_property(fifo, "xlnx,axi-str-rxd-tdata-width",
                  &rxd_tdata_width);
    if (rc)
        goto err_unmap;
    rc = get_dts_property(fifo, "xlnx,axi-str-txc-tdata-width",
                  &txc_tdata_width);
    if (rc)
        goto err_unmap;
    rc = get_dts_property(fifo, "xlnx,axi-str-txd-tdata-width",
                  &txd_tdata_width);
    if (rc)
        goto err_unmap;
    rc = get_dts_property(fifo, "xlnx,axis-tdest-width", &tdest_width);
    if (rc)
        goto err_unmap;
    rc = get_dts_property(fifo, "xlnx,axis-tid-width", &tid_width);
    if (rc)
        goto err_unmap;
    rc = get_dts_property(fifo, "xlnx,axis-tuser-width", &tuser_width);
    if (rc)
        goto err_unmap;
    rc = get_dts_property(fifo, "xlnx,data-interface-type",
                  &data_interface_type);
    if (rc)
        goto err_unmap;
    rc = get_dts_property(fifo, "xlnx,has-axis-tdest", &has_tdest);
    if (rc)
        goto err_unmap;
    rc = get_dts_property(fifo, "xlnx,has-axis-tid", &has_tid);
    if (rc)
        goto err_unmap;
    rc = get_dts_property(fifo, "xlnx,has-axis-tkeep", &has_tkeep);
    if (rc)
        goto err_unmap;
    rc = get_dts_property(fifo, "xlnx,has-axis-tstrb", &has_tstrb);
    if (rc)
        goto err_unmap;
    rc = get_dts_property(fifo, "xlnx,has-axis-tuser", &has_tuser);
    if (rc)
        goto err_unmap;
    rc = get_dts_property(fifo, "xlnx,rx-fifo-depth", &rx_fifo_depth);
    if (rc)
        goto err_unmap;
    rc = get_dts_property(fifo, "xlnx,rx-fifo-pe-threshold",
                  &rx_programmable_empty_threshold);
    if (rc)
        goto err_unmap;
    rc = get_dts_property(fifo, "xlnx,rx-fifo-pf-threshold",
                  &rx_programmable_full_threshold);
    if (rc)
        goto err_unmap;
    rc = get_dts_property(fifo, "xlnx,s-axi-id-width", &axi_id_width);
    if (rc)
        goto err_unmap;
    rc = get_dts_property(fifo, "xlnx,s-axi4-data-width", &axi4_data_width);
    if (rc)
        goto err_unmap;
    rc = get_dts_property(fifo, "xlnx,select-xpm", &select_xpm);
    if (rc)
        goto err_unmap;
    rc = get_dts_property(fifo, "xlnx,tx-fifo-depth", &tx_fifo_depth);
    if (rc)
        goto err_unmap;
    rc = get_dts_property(fifo, "xlnx,tx-max-pkt-size", &tx_max_pkt_size);
    if (rc)
        goto err_unmap;
    rc = get_dts_property(fifo, "xlnx,rx-min-pkt-size", &rx_min_pkt_size);
    if (rc)
        goto err_unmap;
    rc = get_dts_property(fifo, "xlnx,tx-fifo-pe-threshold",
                  &tx_programmable_empty_threshold);
    if (rc)
        goto err_unmap;
    rc = get_dts_property(fifo, "xlnx,tx-fifo-pf-threshold",
                  &tx_programmable_full_threshold);
    if (rc)
        goto err_unmap;
    rc = get_dts_property(fifo, "xlnx,use-rx-cut-through",
                  &use_rx_cut_through);
    if (rc)
        goto err_unmap;
    rc = get_dts_property(fifo, "xlnx,use-rx-data", &use_rx_data);
    if (rc)
        goto err_unmap;
    rc = get_dts_property(fifo, "xlnx,use-tx-ctrl", &use_tx_control);
    if (rc)
        goto err_unmap;
    rc = get_dts_property(fifo, "xlnx,use-tx-cut-through",
                  &use_tx_cut_through);
    if (rc)
        goto err_unmap;
    rc = get_dts_property(fifo, "xlnx,use-tx-data", &use_tx_data);
    if (rc)
        goto err_unmap;

    /* check validity of device tree properties */
    if (rxd_tdata_width != 32) {
        dev_err(fifo->dt_device,
            "rxd_tdata_width width [%u] unsupported\n",
            rxd_tdata_width);
        rc = -EIO;
        goto err_unmap;
    }
    if (txd_tdata_width != 32) {
        dev_err(fifo->dt_device,
            "txd_tdata_width width [%u] unsupported\n",
            txd_tdata_width);
        rc = -EIO;
        goto err_unmap;
    }
    if (has_tdest) {
        dev_err(fifo->dt_device, "tdest not supported\n");
        rc = -EIO;
        goto err_unmap;
    }
    if (has_tid) {
        dev_err(fifo->dt_device, "tid not supported\n");
        rc = -EIO;
        goto err_unmap;
    }
    if (has_tstrb) {
        dev_err(fifo->dt_device, "tstrb not supported\n");
        rc = -EIO;
        goto err_unmap;
    }
    if (has_tuser) {
        dev_err(fifo->dt_device, "tuser not supported\n");
        rc = -EIO;
        goto err_unmap;
    }
    if (use_rx_cut_through) {
        dev_err(fifo->dt_device, "rx cut-through not supported\n");
        rc = -EIO;
        goto err_unmap;
    }
    if (use_tx_cut_through) {
        dev_err(fifo->dt_device, "tx cut-through not supported\n");
        rc = -EIO;
        goto err_unmap;
    }
    if (use_tx_control) {
        dev_err(fifo->dt_device, "tx control not supported\n");
        rc = -EIO;
        goto err_unmap;
    }

    /* TODO
     * these exist in the device tree but it's unclear what they do
     * - select-xpm
     * - data-interface-type
     */

    /* set device wrapper properties based on IP config */
    fifo->rx_fifo_depth = rx_fifo_depth;
    /* IP sets TDFV to fifo depth - 4 so we will do the same */
    fifo->tx_fifo_depth = tx_fifo_depth - 4;
    fifo->rx_fifo_pf_thresh = rx_programmable_full_threshold;
    fifo->tx_fifo_pf_thresh = tx_programmable_full_threshold;
    fifo->rx_fifo_pe_thresh = rx_programmable_empty_threshold;
    fifo->tx_fifo_pe_thresh = tx_programmable_empty_threshold;
    fifo->has_rx_fifo = !!use_rx_data;
    fifo->has_tx_fifo = !!use_tx_data;
    fifo->has_tkeep = !!has_tkeep;
    fifo->tx_max_pkt_size = tx_max_pkt_size;
    fifo->rx_min_pkt_size = rx_min_pkt_size;

    reset_ip_core(fifo);

    /* ----------------------------
     *    init device interrupts
     * ----------------------------
     */

    /* get IRQ resource */
    r_irq = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
    if (!r_irq) {
        dev_err(fifo->dt_device, "no IRQ found for 0x%pa\n",
            &fifo->mem->start);
        rc = -EIO;
        goto err_unmap;
    }

    /* request IRQ */
    fifo->irq = r_irq->start;
    rc = request_irq(fifo->irq, &axis_fifo_irq, 0, DRIVER_NAME, fifo);
    if (rc) {
        dev_err(fifo->dt_device, "couldn't allocate interrupt %i\n",
            fifo->irq);
        goto err_unmap;
    }

    /* ----------------------------
     *      init char device
     * ----------------------------
     */

    /* allocate device number */
    rc = alloc_chrdev_region(&fifo->devt, 0, 1, DRIVER_NAME);
    if (rc < 0)
        goto err_irq;
    dev_dbg(fifo->dt_device, "allocated device number major %i minor %i\n",
        MAJOR(fifo->devt), MINOR(fifo->devt));

    /* create driver file */
    fifo->device = device_create(axis_fifo_driver_class, NULL, fifo->devt,
                     NULL, device_name);
    if (IS_ERR(fifo->device)) {
        dev_err(fifo->dt_device,
            "couldn't create driver file\n");
        rc = PTR_ERR(fifo->device);
        goto err_chrdev_region;
    }
    dev_set_drvdata(fifo->device, fifo);

    /* create character device */
    cdev_init(&fifo->char_device, &fops);
    rc = cdev_add(&fifo->char_device, fifo->devt, 1);
    if (rc < 0) {
        dev_err(fifo->dt_device, "couldn't create character device\n");
        goto err_dev;
    }

    /* create sysfs entries */
    rc = sysfs_create_group(&fifo->device->kobj, &axis_fifo_attrs_group);
    if (rc < 0) {
        dev_err(fifo->dt_device, "couldn't register sysfs group\n");
        goto err_cdev;
    }

    dev_info(fifo->dt_device, "axis-fifo created at %pa mapped to 0x%pa, irq=%i, major=%i, minor=%i\n",
         &fifo->mem->start, &fifo->base_addr, fifo->irq,
         MAJOR(fifo->devt), MINOR(fifo->devt));

    return 0;

err_cdev:
    cdev_del(&fifo->char_device);
err_dev:
    device_destroy(axis_fifo_driver_class, fifo->devt);
err_chrdev_region:
    unregister_chrdev_region(fifo->devt, 1);
err_irq:
    free_irq(fifo->irq, fifo);
err_unmap:
    iounmap(fifo->base_addr);
err_mem:
    release_mem_region(fifo->mem->start, resource_size(fifo->mem));
err_initial:
    dev_set_drvdata(dev, NULL);
    return rc;
}

static int axis_fifo_remove(struct platform_device *pdev)
{
    struct device *dev = &pdev->dev;
    struct axis_fifo *fifo = dev_get_drvdata(dev);

    sysfs_remove_group(&fifo->device->kobj, &axis_fifo_attrs_group);
    cdev_del(&fifo->char_device);
    dev_set_drvdata(fifo->device, NULL);
    device_destroy(axis_fifo_driver_class, fifo->devt);
    unregister_chrdev_region(fifo->devt, 1);
    free_irq(fifo->irq, fifo);
    iounmap(fifo->base_addr);
    release_mem_region(fifo->mem->start, resource_size(fifo->mem));
    dev_set_drvdata(dev, NULL);
    return 0;
}

static const struct of_device_id axis_fifo_of_match[] = {
    { .compatible = "xlnx,axi-fifo-mm-s-4.1", },
    { .compatible = "xlnx,axi-fifo-mm-s-4.2", },
    {},
};
MODULE_DEVICE_TABLE(of, axis_fifo_of_match);

static struct platform_driver axis_fifo_driver = {
    .driver = {
        .name = DRIVER_NAME,
        .owner = THIS_MODULE,
        .of_match_table = axis_fifo_of_match,
    },
    .probe      = axis_fifo_probe,
    .remove     = axis_fifo_remove,
};

static int __init axis_fifo_init(void)
{
    pr_info("axis-fifo driver loaded with parameters read_timeout = %i, write_timeout = %i\n",
        read_timeout, write_timeout);
    axis_fifo_driver_class = class_create(THIS_MODULE, DRIVER_NAME);
    if (IS_ERR(axis_fifo_driver_class))
        return PTR_ERR(axis_fifo_driver_class);
    return platform_driver_register(&axis_fifo_driver);
}

module_init(axis_fifo_init);

static void __exit axis_fifo_exit(void)
{
    platform_driver_unregister(&axis_fifo_driver);
    class_destroy(axis_fifo_driver_class);
}

module_exit(axis_fifo_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Jacob Feder <jacobsfeder@gmail.com>");
MODULE_DESCRIPTION("Xilinx AXI-Stream FIFO v4.1/v4.2 IP core driver");
