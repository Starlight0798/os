#include <defs.h>
#include <stdio.h>
#include <dev.h>
#include <vfs.h>
#include <iobuf.h>
#include <inode.h>
#include <unistd.h>
#include <error.h>
#include <assert.h>

static int
stdout_open(struct device *dev, uint32_t open_flags) {
    if (open_flags != O_WRONLY) {
        return -E_INVAL;
    }
    return 0;
}

static int
stdout_close(struct device *dev) {
    return 0;
}

static int
stdout_io(struct device *dev, struct iobuf *iob, bool write) {
    if (write) {
        char *data = iob->io_base;
        for (; iob->io_resid != 0; iob->io_resid --) {
            cputchar(*data ++);
        }
        return 0;
    }
    return -E_INVAL;
}

static int
stdout_ioctl(struct device *dev, int op, void *data) {
    return -E_INVAL;
}

static void
stdout_device_init(struct device *dev) { // 对分配的inode节点的device类型的成员变量进行初始化
    dev->d_blocks = 0; 
    dev->d_blocksize = 1;
    dev->d_open = stdout_open; // 设置设备相应的函数指针
    dev->d_close = stdout_close;
    dev->d_io = stdout_io;
    dev->d_ioctl = stdout_ioctl;
}

void
dev_init_stdout(void) {
    struct inode *node;
    if ((node = dev_create_inode()) == NULL) { // 分配inode节点并初始化
        panic("stdout: dev_create_node.\n");
    }
    stdout_device_init(vop_info(node, device)); // 获取node中device类型的成员变量的地址

    int ret;
    if ((ret = vfs_add_dev("stdout", node, 0)) != 0) { // 将设备节点加入到VFS
        panic("stdout: vfs_add_dev: %e.\n", ret);
    }
}

