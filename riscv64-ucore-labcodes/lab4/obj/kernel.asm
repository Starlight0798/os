
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02092b7          	lui	t0,0xc0209
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	01e31313          	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000c:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200010:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200014:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200018:	03f31313          	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc020001c:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200020:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200024:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200028:	c0209137          	lui	sp,0xc0209

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:
void grade_backtrace(void);

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	0000a517          	auipc	a0,0xa
ffffffffc020003a:	02a50513          	addi	a0,a0,42 # ffffffffc020a060 <edata>
ffffffffc020003e:	00015617          	auipc	a2,0x15
ffffffffc0200042:	5ba60613          	addi	a2,a2,1466 # ffffffffc02155f8 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	631040ef          	jal	ra,ffffffffc0204e7e <memset>

    cons_init();                // init the console
ffffffffc0200052:	4b4000ef          	jal	ra,ffffffffc0200506 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200056:	00005597          	auipc	a1,0x5
ffffffffc020005a:	e8258593          	addi	a1,a1,-382 # ffffffffc0204ed8 <etext>
ffffffffc020005e:	00005517          	auipc	a0,0x5
ffffffffc0200062:	e9a50513          	addi	a0,a0,-358 # ffffffffc0204ef8 <etext+0x20>
ffffffffc0200066:	128000ef          	jal	ra,ffffffffc020018e <cprintf>

    print_kerninfo();
ffffffffc020006a:	16c000ef          	jal	ra,ffffffffc02001d6 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006e:	79d010ef          	jal	ra,ffffffffc020200a <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc0200072:	56c000ef          	jal	ra,ffffffffc02005de <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200076:	5dc000ef          	jal	ra,ffffffffc0200652 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020007a:	195030ef          	jal	ra,ffffffffc0203a0e <vmm_init>
    proc_init();                // init process table
ffffffffc020007e:	60c040ef          	jal	ra,ffffffffc020468a <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc0200082:	4f8000ef          	jal	ra,ffffffffc020057a <ide_init>
    swap_init();                // init swap
ffffffffc0200086:	2a7020ef          	jal	ra,ffffffffc0202b2c <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020008a:	426000ef          	jal	ra,ffffffffc02004b0 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008e:	544000ef          	jal	ra,ffffffffc02005d2 <intr_enable>

    cpu_idle();                 // run idle process
ffffffffc0200092:	7ec040ef          	jal	ra,ffffffffc020487e <cpu_idle>

ffffffffc0200096 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200096:	715d                	addi	sp,sp,-80
ffffffffc0200098:	e486                	sd	ra,72(sp)
ffffffffc020009a:	e0a2                	sd	s0,64(sp)
ffffffffc020009c:	fc26                	sd	s1,56(sp)
ffffffffc020009e:	f84a                	sd	s2,48(sp)
ffffffffc02000a0:	f44e                	sd	s3,40(sp)
ffffffffc02000a2:	f052                	sd	s4,32(sp)
ffffffffc02000a4:	ec56                	sd	s5,24(sp)
ffffffffc02000a6:	e85a                	sd	s6,16(sp)
ffffffffc02000a8:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc02000aa:	c901                	beqz	a0,ffffffffc02000ba <readline+0x24>
        cprintf("%s", prompt);
ffffffffc02000ac:	85aa                	mv	a1,a0
ffffffffc02000ae:	00005517          	auipc	a0,0x5
ffffffffc02000b2:	e5250513          	addi	a0,a0,-430 # ffffffffc0204f00 <etext+0x28>
ffffffffc02000b6:	0d8000ef          	jal	ra,ffffffffc020018e <cprintf>
readline(const char *prompt) {
ffffffffc02000ba:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000bc:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02000be:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02000c0:	4aa9                	li	s5,10
ffffffffc02000c2:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02000c4:	0000ab97          	auipc	s7,0xa
ffffffffc02000c8:	f9cb8b93          	addi	s7,s7,-100 # ffffffffc020a060 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000cc:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02000d0:	0f6000ef          	jal	ra,ffffffffc02001c6 <getchar>
ffffffffc02000d4:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000d6:	00054b63          	bltz	a0,ffffffffc02000ec <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000da:	00a95b63          	ble	a0,s2,ffffffffc02000f0 <readline+0x5a>
ffffffffc02000de:	029a5463          	ble	s1,s4,ffffffffc0200106 <readline+0x70>
        c = getchar();
ffffffffc02000e2:	0e4000ef          	jal	ra,ffffffffc02001c6 <getchar>
ffffffffc02000e6:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000e8:	fe0559e3          	bgez	a0,ffffffffc02000da <readline+0x44>
            return NULL;
ffffffffc02000ec:	4501                	li	a0,0
ffffffffc02000ee:	a099                	j	ffffffffc0200134 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc02000f0:	03341463          	bne	s0,s3,ffffffffc0200118 <readline+0x82>
ffffffffc02000f4:	e8b9                	bnez	s1,ffffffffc020014a <readline+0xb4>
        c = getchar();
ffffffffc02000f6:	0d0000ef          	jal	ra,ffffffffc02001c6 <getchar>
ffffffffc02000fa:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000fc:	fe0548e3          	bltz	a0,ffffffffc02000ec <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200100:	fea958e3          	ble	a0,s2,ffffffffc02000f0 <readline+0x5a>
ffffffffc0200104:	4481                	li	s1,0
            cputchar(c);
ffffffffc0200106:	8522                	mv	a0,s0
ffffffffc0200108:	0ba000ef          	jal	ra,ffffffffc02001c2 <cputchar>
            buf[i ++] = c;
ffffffffc020010c:	009b87b3          	add	a5,s7,s1
ffffffffc0200110:	00878023          	sb	s0,0(a5)
ffffffffc0200114:	2485                	addiw	s1,s1,1
ffffffffc0200116:	bf6d                	j	ffffffffc02000d0 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0200118:	01540463          	beq	s0,s5,ffffffffc0200120 <readline+0x8a>
ffffffffc020011c:	fb641ae3          	bne	s0,s6,ffffffffc02000d0 <readline+0x3a>
            cputchar(c);
ffffffffc0200120:	8522                	mv	a0,s0
ffffffffc0200122:	0a0000ef          	jal	ra,ffffffffc02001c2 <cputchar>
            buf[i] = '\0';
ffffffffc0200126:	0000a517          	auipc	a0,0xa
ffffffffc020012a:	f3a50513          	addi	a0,a0,-198 # ffffffffc020a060 <edata>
ffffffffc020012e:	94aa                	add	s1,s1,a0
ffffffffc0200130:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0200134:	60a6                	ld	ra,72(sp)
ffffffffc0200136:	6406                	ld	s0,64(sp)
ffffffffc0200138:	74e2                	ld	s1,56(sp)
ffffffffc020013a:	7942                	ld	s2,48(sp)
ffffffffc020013c:	79a2                	ld	s3,40(sp)
ffffffffc020013e:	7a02                	ld	s4,32(sp)
ffffffffc0200140:	6ae2                	ld	s5,24(sp)
ffffffffc0200142:	6b42                	ld	s6,16(sp)
ffffffffc0200144:	6ba2                	ld	s7,8(sp)
ffffffffc0200146:	6161                	addi	sp,sp,80
ffffffffc0200148:	8082                	ret
            cputchar(c);
ffffffffc020014a:	4521                	li	a0,8
ffffffffc020014c:	076000ef          	jal	ra,ffffffffc02001c2 <cputchar>
            i --;
ffffffffc0200150:	34fd                	addiw	s1,s1,-1
ffffffffc0200152:	bfbd                	j	ffffffffc02000d0 <readline+0x3a>

ffffffffc0200154 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200154:	1141                	addi	sp,sp,-16
ffffffffc0200156:	e022                	sd	s0,0(sp)
ffffffffc0200158:	e406                	sd	ra,8(sp)
ffffffffc020015a:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020015c:	3ac000ef          	jal	ra,ffffffffc0200508 <cons_putc>
    (*cnt) ++;
ffffffffc0200160:	401c                	lw	a5,0(s0)
}
ffffffffc0200162:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200164:	2785                	addiw	a5,a5,1
ffffffffc0200166:	c01c                	sw	a5,0(s0)
}
ffffffffc0200168:	6402                	ld	s0,0(sp)
ffffffffc020016a:	0141                	addi	sp,sp,16
ffffffffc020016c:	8082                	ret

ffffffffc020016e <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020016e:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200170:	86ae                	mv	a3,a1
ffffffffc0200172:	862a                	mv	a2,a0
ffffffffc0200174:	006c                	addi	a1,sp,12
ffffffffc0200176:	00000517          	auipc	a0,0x0
ffffffffc020017a:	fde50513          	addi	a0,a0,-34 # ffffffffc0200154 <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc020017e:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc0200180:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200182:	0d3040ef          	jal	ra,ffffffffc0204a54 <vprintfmt>
    return cnt;
}
ffffffffc0200186:	60e2                	ld	ra,24(sp)
ffffffffc0200188:	4532                	lw	a0,12(sp)
ffffffffc020018a:	6105                	addi	sp,sp,32
ffffffffc020018c:	8082                	ret

ffffffffc020018e <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc020018e:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc0200190:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc0200194:	f42e                	sd	a1,40(sp)
ffffffffc0200196:	f832                	sd	a2,48(sp)
ffffffffc0200198:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020019a:	862a                	mv	a2,a0
ffffffffc020019c:	004c                	addi	a1,sp,4
ffffffffc020019e:	00000517          	auipc	a0,0x0
ffffffffc02001a2:	fb650513          	addi	a0,a0,-74 # ffffffffc0200154 <cputch>
ffffffffc02001a6:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02001a8:	ec06                	sd	ra,24(sp)
ffffffffc02001aa:	e0ba                	sd	a4,64(sp)
ffffffffc02001ac:	e4be                	sd	a5,72(sp)
ffffffffc02001ae:	e8c2                	sd	a6,80(sp)
ffffffffc02001b0:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02001b2:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02001b4:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02001b6:	09f040ef          	jal	ra,ffffffffc0204a54 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02001ba:	60e2                	ld	ra,24(sp)
ffffffffc02001bc:	4512                	lw	a0,4(sp)
ffffffffc02001be:	6125                	addi	sp,sp,96
ffffffffc02001c0:	8082                	ret

ffffffffc02001c2 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02001c2:	3460006f          	j	ffffffffc0200508 <cons_putc>

ffffffffc02001c6 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02001c6:	1141                	addi	sp,sp,-16
ffffffffc02001c8:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02001ca:	374000ef          	jal	ra,ffffffffc020053e <cons_getc>
ffffffffc02001ce:	dd75                	beqz	a0,ffffffffc02001ca <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc02001d0:	60a2                	ld	ra,8(sp)
ffffffffc02001d2:	0141                	addi	sp,sp,16
ffffffffc02001d4:	8082                	ret

ffffffffc02001d6 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc02001d6:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02001d8:	00005517          	auipc	a0,0x5
ffffffffc02001dc:	d6050513          	addi	a0,a0,-672 # ffffffffc0204f38 <etext+0x60>
void print_kerninfo(void) {
ffffffffc02001e0:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001e2:	fadff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02001e6:	00000597          	auipc	a1,0x0
ffffffffc02001ea:	e5058593          	addi	a1,a1,-432 # ffffffffc0200036 <kern_init>
ffffffffc02001ee:	00005517          	auipc	a0,0x5
ffffffffc02001f2:	d6a50513          	addi	a0,a0,-662 # ffffffffc0204f58 <etext+0x80>
ffffffffc02001f6:	f99ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02001fa:	00005597          	auipc	a1,0x5
ffffffffc02001fe:	cde58593          	addi	a1,a1,-802 # ffffffffc0204ed8 <etext>
ffffffffc0200202:	00005517          	auipc	a0,0x5
ffffffffc0200206:	d7650513          	addi	a0,a0,-650 # ffffffffc0204f78 <etext+0xa0>
ffffffffc020020a:	f85ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020020e:	0000a597          	auipc	a1,0xa
ffffffffc0200212:	e5258593          	addi	a1,a1,-430 # ffffffffc020a060 <edata>
ffffffffc0200216:	00005517          	auipc	a0,0x5
ffffffffc020021a:	d8250513          	addi	a0,a0,-638 # ffffffffc0204f98 <etext+0xc0>
ffffffffc020021e:	f71ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200222:	00015597          	auipc	a1,0x15
ffffffffc0200226:	3d658593          	addi	a1,a1,982 # ffffffffc02155f8 <end>
ffffffffc020022a:	00005517          	auipc	a0,0x5
ffffffffc020022e:	d8e50513          	addi	a0,a0,-626 # ffffffffc0204fb8 <etext+0xe0>
ffffffffc0200232:	f5dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200236:	00015597          	auipc	a1,0x15
ffffffffc020023a:	7c158593          	addi	a1,a1,1985 # ffffffffc02159f7 <end+0x3ff>
ffffffffc020023e:	00000797          	auipc	a5,0x0
ffffffffc0200242:	df878793          	addi	a5,a5,-520 # ffffffffc0200036 <kern_init>
ffffffffc0200246:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020024a:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020024e:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200250:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200254:	95be                	add	a1,a1,a5
ffffffffc0200256:	85a9                	srai	a1,a1,0xa
ffffffffc0200258:	00005517          	auipc	a0,0x5
ffffffffc020025c:	d8050513          	addi	a0,a0,-640 # ffffffffc0204fd8 <etext+0x100>
}
ffffffffc0200260:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200262:	f2dff06f          	j	ffffffffc020018e <cprintf>

ffffffffc0200266 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200266:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc0200268:	00005617          	auipc	a2,0x5
ffffffffc020026c:	ca060613          	addi	a2,a2,-864 # ffffffffc0204f08 <etext+0x30>
ffffffffc0200270:	04d00593          	li	a1,77
ffffffffc0200274:	00005517          	auipc	a0,0x5
ffffffffc0200278:	cac50513          	addi	a0,a0,-852 # ffffffffc0204f20 <etext+0x48>
void print_stackframe(void) {
ffffffffc020027c:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020027e:	1d2000ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0200282 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200282:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200284:	00005617          	auipc	a2,0x5
ffffffffc0200288:	e6460613          	addi	a2,a2,-412 # ffffffffc02050e8 <commands+0xe0>
ffffffffc020028c:	00005597          	auipc	a1,0x5
ffffffffc0200290:	e7c58593          	addi	a1,a1,-388 # ffffffffc0205108 <commands+0x100>
ffffffffc0200294:	00005517          	auipc	a0,0x5
ffffffffc0200298:	e7c50513          	addi	a0,a0,-388 # ffffffffc0205110 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020029c:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020029e:	ef1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02002a2:	00005617          	auipc	a2,0x5
ffffffffc02002a6:	e7e60613          	addi	a2,a2,-386 # ffffffffc0205120 <commands+0x118>
ffffffffc02002aa:	00005597          	auipc	a1,0x5
ffffffffc02002ae:	e9e58593          	addi	a1,a1,-354 # ffffffffc0205148 <commands+0x140>
ffffffffc02002b2:	00005517          	auipc	a0,0x5
ffffffffc02002b6:	e5e50513          	addi	a0,a0,-418 # ffffffffc0205110 <commands+0x108>
ffffffffc02002ba:	ed5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02002be:	00005617          	auipc	a2,0x5
ffffffffc02002c2:	e9a60613          	addi	a2,a2,-358 # ffffffffc0205158 <commands+0x150>
ffffffffc02002c6:	00005597          	auipc	a1,0x5
ffffffffc02002ca:	eb258593          	addi	a1,a1,-334 # ffffffffc0205178 <commands+0x170>
ffffffffc02002ce:	00005517          	auipc	a0,0x5
ffffffffc02002d2:	e4250513          	addi	a0,a0,-446 # ffffffffc0205110 <commands+0x108>
ffffffffc02002d6:	eb9ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    }
    return 0;
}
ffffffffc02002da:	60a2                	ld	ra,8(sp)
ffffffffc02002dc:	4501                	li	a0,0
ffffffffc02002de:	0141                	addi	sp,sp,16
ffffffffc02002e0:	8082                	ret

ffffffffc02002e2 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002e2:	1141                	addi	sp,sp,-16
ffffffffc02002e4:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02002e6:	ef1ff0ef          	jal	ra,ffffffffc02001d6 <print_kerninfo>
    return 0;
}
ffffffffc02002ea:	60a2                	ld	ra,8(sp)
ffffffffc02002ec:	4501                	li	a0,0
ffffffffc02002ee:	0141                	addi	sp,sp,16
ffffffffc02002f0:	8082                	ret

ffffffffc02002f2 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002f2:	1141                	addi	sp,sp,-16
ffffffffc02002f4:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02002f6:	f71ff0ef          	jal	ra,ffffffffc0200266 <print_stackframe>
    return 0;
}
ffffffffc02002fa:	60a2                	ld	ra,8(sp)
ffffffffc02002fc:	4501                	li	a0,0
ffffffffc02002fe:	0141                	addi	sp,sp,16
ffffffffc0200300:	8082                	ret

ffffffffc0200302 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200302:	7115                	addi	sp,sp,-224
ffffffffc0200304:	e962                	sd	s8,144(sp)
ffffffffc0200306:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200308:	00005517          	auipc	a0,0x5
ffffffffc020030c:	d4850513          	addi	a0,a0,-696 # ffffffffc0205050 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200310:	ed86                	sd	ra,216(sp)
ffffffffc0200312:	e9a2                	sd	s0,208(sp)
ffffffffc0200314:	e5a6                	sd	s1,200(sp)
ffffffffc0200316:	e1ca                	sd	s2,192(sp)
ffffffffc0200318:	fd4e                	sd	s3,184(sp)
ffffffffc020031a:	f952                	sd	s4,176(sp)
ffffffffc020031c:	f556                	sd	s5,168(sp)
ffffffffc020031e:	f15a                	sd	s6,160(sp)
ffffffffc0200320:	ed5e                	sd	s7,152(sp)
ffffffffc0200322:	e566                	sd	s9,136(sp)
ffffffffc0200324:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200326:	e69ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020032a:	00005517          	auipc	a0,0x5
ffffffffc020032e:	d4e50513          	addi	a0,a0,-690 # ffffffffc0205078 <commands+0x70>
ffffffffc0200332:	e5dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    if (tf != NULL) {
ffffffffc0200336:	000c0563          	beqz	s8,ffffffffc0200340 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020033a:	8562                	mv	a0,s8
ffffffffc020033c:	4fe000ef          	jal	ra,ffffffffc020083a <print_trapframe>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200340:	4501                	li	a0,0
ffffffffc0200342:	4581                	li	a1,0
ffffffffc0200344:	4601                	li	a2,0
ffffffffc0200346:	48a1                	li	a7,8
ffffffffc0200348:	00000073          	ecall
ffffffffc020034c:	00005c97          	auipc	s9,0x5
ffffffffc0200350:	cbcc8c93          	addi	s9,s9,-836 # ffffffffc0205008 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200354:	00005997          	auipc	s3,0x5
ffffffffc0200358:	d4c98993          	addi	s3,s3,-692 # ffffffffc02050a0 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020035c:	00005917          	auipc	s2,0x5
ffffffffc0200360:	d4c90913          	addi	s2,s2,-692 # ffffffffc02050a8 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc0200364:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200366:	00005b17          	auipc	s6,0x5
ffffffffc020036a:	d4ab0b13          	addi	s6,s6,-694 # ffffffffc02050b0 <commands+0xa8>
    if (argc == 0) {
ffffffffc020036e:	00005a97          	auipc	s5,0x5
ffffffffc0200372:	d9aa8a93          	addi	s5,s5,-614 # ffffffffc0205108 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200376:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200378:	854e                	mv	a0,s3
ffffffffc020037a:	d1dff0ef          	jal	ra,ffffffffc0200096 <readline>
ffffffffc020037e:	842a                	mv	s0,a0
ffffffffc0200380:	dd65                	beqz	a0,ffffffffc0200378 <kmonitor+0x76>
ffffffffc0200382:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200386:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200388:	c999                	beqz	a1,ffffffffc020039e <kmonitor+0x9c>
ffffffffc020038a:	854a                	mv	a0,s2
ffffffffc020038c:	2d5040ef          	jal	ra,ffffffffc0204e60 <strchr>
ffffffffc0200390:	c925                	beqz	a0,ffffffffc0200400 <kmonitor+0xfe>
            *buf ++ = '\0';
ffffffffc0200392:	00144583          	lbu	a1,1(s0)
ffffffffc0200396:	00040023          	sb	zero,0(s0)
ffffffffc020039a:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020039c:	f5fd                	bnez	a1,ffffffffc020038a <kmonitor+0x88>
    if (argc == 0) {
ffffffffc020039e:	dce9                	beqz	s1,ffffffffc0200378 <kmonitor+0x76>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003a0:	6582                	ld	a1,0(sp)
ffffffffc02003a2:	00005d17          	auipc	s10,0x5
ffffffffc02003a6:	c66d0d13          	addi	s10,s10,-922 # ffffffffc0205008 <commands>
    if (argc == 0) {
ffffffffc02003aa:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003ac:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003ae:	0d61                	addi	s10,s10,24
ffffffffc02003b0:	287040ef          	jal	ra,ffffffffc0204e36 <strcmp>
ffffffffc02003b4:	c919                	beqz	a0,ffffffffc02003ca <kmonitor+0xc8>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003b6:	2405                	addiw	s0,s0,1
ffffffffc02003b8:	09740463          	beq	s0,s7,ffffffffc0200440 <kmonitor+0x13e>
ffffffffc02003bc:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003c0:	6582                	ld	a1,0(sp)
ffffffffc02003c2:	0d61                	addi	s10,s10,24
ffffffffc02003c4:	273040ef          	jal	ra,ffffffffc0204e36 <strcmp>
ffffffffc02003c8:	f57d                	bnez	a0,ffffffffc02003b6 <kmonitor+0xb4>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02003ca:	00141793          	slli	a5,s0,0x1
ffffffffc02003ce:	97a2                	add	a5,a5,s0
ffffffffc02003d0:	078e                	slli	a5,a5,0x3
ffffffffc02003d2:	97e6                	add	a5,a5,s9
ffffffffc02003d4:	6b9c                	ld	a5,16(a5)
ffffffffc02003d6:	8662                	mv	a2,s8
ffffffffc02003d8:	002c                	addi	a1,sp,8
ffffffffc02003da:	fff4851b          	addiw	a0,s1,-1
ffffffffc02003de:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02003e0:	f8055ce3          	bgez	a0,ffffffffc0200378 <kmonitor+0x76>
}
ffffffffc02003e4:	60ee                	ld	ra,216(sp)
ffffffffc02003e6:	644e                	ld	s0,208(sp)
ffffffffc02003e8:	64ae                	ld	s1,200(sp)
ffffffffc02003ea:	690e                	ld	s2,192(sp)
ffffffffc02003ec:	79ea                	ld	s3,184(sp)
ffffffffc02003ee:	7a4a                	ld	s4,176(sp)
ffffffffc02003f0:	7aaa                	ld	s5,168(sp)
ffffffffc02003f2:	7b0a                	ld	s6,160(sp)
ffffffffc02003f4:	6bea                	ld	s7,152(sp)
ffffffffc02003f6:	6c4a                	ld	s8,144(sp)
ffffffffc02003f8:	6caa                	ld	s9,136(sp)
ffffffffc02003fa:	6d0a                	ld	s10,128(sp)
ffffffffc02003fc:	612d                	addi	sp,sp,224
ffffffffc02003fe:	8082                	ret
        if (*buf == '\0') {
ffffffffc0200400:	00044783          	lbu	a5,0(s0)
ffffffffc0200404:	dfc9                	beqz	a5,ffffffffc020039e <kmonitor+0x9c>
        if (argc == MAXARGS - 1) {
ffffffffc0200406:	03448863          	beq	s1,s4,ffffffffc0200436 <kmonitor+0x134>
        argv[argc ++] = buf;
ffffffffc020040a:	00349793          	slli	a5,s1,0x3
ffffffffc020040e:	0118                	addi	a4,sp,128
ffffffffc0200410:	97ba                	add	a5,a5,a4
ffffffffc0200412:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200416:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020041a:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020041c:	e591                	bnez	a1,ffffffffc0200428 <kmonitor+0x126>
ffffffffc020041e:	b749                	j	ffffffffc02003a0 <kmonitor+0x9e>
            buf ++;
ffffffffc0200420:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200422:	00044583          	lbu	a1,0(s0)
ffffffffc0200426:	ddad                	beqz	a1,ffffffffc02003a0 <kmonitor+0x9e>
ffffffffc0200428:	854a                	mv	a0,s2
ffffffffc020042a:	237040ef          	jal	ra,ffffffffc0204e60 <strchr>
ffffffffc020042e:	d96d                	beqz	a0,ffffffffc0200420 <kmonitor+0x11e>
ffffffffc0200430:	00044583          	lbu	a1,0(s0)
ffffffffc0200434:	bf91                	j	ffffffffc0200388 <kmonitor+0x86>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200436:	45c1                	li	a1,16
ffffffffc0200438:	855a                	mv	a0,s6
ffffffffc020043a:	d55ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc020043e:	b7f1                	j	ffffffffc020040a <kmonitor+0x108>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200440:	6582                	ld	a1,0(sp)
ffffffffc0200442:	00005517          	auipc	a0,0x5
ffffffffc0200446:	c8e50513          	addi	a0,a0,-882 # ffffffffc02050d0 <commands+0xc8>
ffffffffc020044a:	d45ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    return 0;
ffffffffc020044e:	b72d                	j	ffffffffc0200378 <kmonitor+0x76>

ffffffffc0200450 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200450:	00015317          	auipc	t1,0x15
ffffffffc0200454:	02030313          	addi	t1,t1,32 # ffffffffc0215470 <is_panic>
ffffffffc0200458:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc020045c:	715d                	addi	sp,sp,-80
ffffffffc020045e:	ec06                	sd	ra,24(sp)
ffffffffc0200460:	e822                	sd	s0,16(sp)
ffffffffc0200462:	f436                	sd	a3,40(sp)
ffffffffc0200464:	f83a                	sd	a4,48(sp)
ffffffffc0200466:	fc3e                	sd	a5,56(sp)
ffffffffc0200468:	e0c2                	sd	a6,64(sp)
ffffffffc020046a:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc020046c:	02031c63          	bnez	t1,ffffffffc02004a4 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200470:	4785                	li	a5,1
ffffffffc0200472:	8432                	mv	s0,a2
ffffffffc0200474:	00015717          	auipc	a4,0x15
ffffffffc0200478:	fef72e23          	sw	a5,-4(a4) # ffffffffc0215470 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020047c:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc020047e:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200480:	85aa                	mv	a1,a0
ffffffffc0200482:	00005517          	auipc	a0,0x5
ffffffffc0200486:	d0650513          	addi	a0,a0,-762 # ffffffffc0205188 <commands+0x180>
    va_start(ap, fmt);
ffffffffc020048a:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020048c:	d03ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200490:	65a2                	ld	a1,8(sp)
ffffffffc0200492:	8522                	mv	a0,s0
ffffffffc0200494:	cdbff0ef          	jal	ra,ffffffffc020016e <vcprintf>
    cprintf("\n");
ffffffffc0200498:	00006517          	auipc	a0,0x6
ffffffffc020049c:	c7850513          	addi	a0,a0,-904 # ffffffffc0206110 <default_pmm_manager+0x500>
ffffffffc02004a0:	cefff0ef          	jal	ra,ffffffffc020018e <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02004a4:	134000ef          	jal	ra,ffffffffc02005d8 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02004a8:	4501                	li	a0,0
ffffffffc02004aa:	e59ff0ef          	jal	ra,ffffffffc0200302 <kmonitor>
ffffffffc02004ae:	bfed                	j	ffffffffc02004a8 <__panic+0x58>

ffffffffc02004b0 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02004b0:	67e1                	lui	a5,0x18
ffffffffc02004b2:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc02004b6:	00015717          	auipc	a4,0x15
ffffffffc02004ba:	fcf73123          	sd	a5,-62(a4) # ffffffffc0215478 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02004be:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc02004c2:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02004c4:	953e                	add	a0,a0,a5
ffffffffc02004c6:	4601                	li	a2,0
ffffffffc02004c8:	4881                	li	a7,0
ffffffffc02004ca:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02004ce:	02000793          	li	a5,32
ffffffffc02004d2:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02004d6:	00005517          	auipc	a0,0x5
ffffffffc02004da:	cd250513          	addi	a0,a0,-814 # ffffffffc02051a8 <commands+0x1a0>
    ticks = 0;
ffffffffc02004de:	00015797          	auipc	a5,0x15
ffffffffc02004e2:	fe07b523          	sd	zero,-22(a5) # ffffffffc02154c8 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc02004e6:	ca9ff06f          	j	ffffffffc020018e <cprintf>

ffffffffc02004ea <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02004ea:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02004ee:	00015797          	auipc	a5,0x15
ffffffffc02004f2:	f8a78793          	addi	a5,a5,-118 # ffffffffc0215478 <timebase>
ffffffffc02004f6:	639c                	ld	a5,0(a5)
ffffffffc02004f8:	4581                	li	a1,0
ffffffffc02004fa:	4601                	li	a2,0
ffffffffc02004fc:	953e                	add	a0,a0,a5
ffffffffc02004fe:	4881                	li	a7,0
ffffffffc0200500:	00000073          	ecall
ffffffffc0200504:	8082                	ret

ffffffffc0200506 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200506:	8082                	ret

ffffffffc0200508 <cons_putc>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200508:	100027f3          	csrr	a5,sstatus
ffffffffc020050c:	8b89                	andi	a5,a5,2
ffffffffc020050e:	0ff57513          	andi	a0,a0,255
ffffffffc0200512:	e799                	bnez	a5,ffffffffc0200520 <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200514:	4581                	li	a1,0
ffffffffc0200516:	4601                	li	a2,0
ffffffffc0200518:	4885                	li	a7,1
ffffffffc020051a:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc020051e:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200520:	1101                	addi	sp,sp,-32
ffffffffc0200522:	ec06                	sd	ra,24(sp)
ffffffffc0200524:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200526:	0b2000ef          	jal	ra,ffffffffc02005d8 <intr_disable>
ffffffffc020052a:	6522                	ld	a0,8(sp)
ffffffffc020052c:	4581                	li	a1,0
ffffffffc020052e:	4601                	li	a2,0
ffffffffc0200530:	4885                	li	a7,1
ffffffffc0200532:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200536:	60e2                	ld	ra,24(sp)
ffffffffc0200538:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020053a:	0980006f          	j	ffffffffc02005d2 <intr_enable>

ffffffffc020053e <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020053e:	100027f3          	csrr	a5,sstatus
ffffffffc0200542:	8b89                	andi	a5,a5,2
ffffffffc0200544:	eb89                	bnez	a5,ffffffffc0200556 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200546:	4501                	li	a0,0
ffffffffc0200548:	4581                	li	a1,0
ffffffffc020054a:	4601                	li	a2,0
ffffffffc020054c:	4889                	li	a7,2
ffffffffc020054e:	00000073          	ecall
ffffffffc0200552:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc0200554:	8082                	ret
int cons_getc(void) {
ffffffffc0200556:	1101                	addi	sp,sp,-32
ffffffffc0200558:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc020055a:	07e000ef          	jal	ra,ffffffffc02005d8 <intr_disable>
ffffffffc020055e:	4501                	li	a0,0
ffffffffc0200560:	4581                	li	a1,0
ffffffffc0200562:	4601                	li	a2,0
ffffffffc0200564:	4889                	li	a7,2
ffffffffc0200566:	00000073          	ecall
ffffffffc020056a:	2501                	sext.w	a0,a0
ffffffffc020056c:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc020056e:	064000ef          	jal	ra,ffffffffc02005d2 <intr_enable>
}
ffffffffc0200572:	60e2                	ld	ra,24(sp)
ffffffffc0200574:	6522                	ld	a0,8(sp)
ffffffffc0200576:	6105                	addi	sp,sp,32
ffffffffc0200578:	8082                	ret

ffffffffc020057a <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc020057a:	8082                	ret

ffffffffc020057c <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc020057c:	00253513          	sltiu	a0,a0,2
ffffffffc0200580:	8082                	ret

ffffffffc0200582 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc0200582:	03800513          	li	a0,56
ffffffffc0200586:	8082                	ret

ffffffffc0200588 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200588:	0000a797          	auipc	a5,0xa
ffffffffc020058c:	ed878793          	addi	a5,a5,-296 # ffffffffc020a460 <ide>
ffffffffc0200590:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc0200594:	1141                	addi	sp,sp,-16
ffffffffc0200596:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200598:	95be                	add	a1,a1,a5
ffffffffc020059a:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc020059e:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02005a0:	0f1040ef          	jal	ra,ffffffffc0204e90 <memcpy>
    return 0;
}
ffffffffc02005a4:	60a2                	ld	ra,8(sp)
ffffffffc02005a6:	4501                	li	a0,0
ffffffffc02005a8:	0141                	addi	sp,sp,16
ffffffffc02005aa:	8082                	ret

ffffffffc02005ac <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc02005ac:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02005ae:	0095979b          	slliw	a5,a1,0x9
ffffffffc02005b2:	0000a517          	auipc	a0,0xa
ffffffffc02005b6:	eae50513          	addi	a0,a0,-338 # ffffffffc020a460 <ide>
                   size_t nsecs) {
ffffffffc02005ba:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02005bc:	00969613          	slli	a2,a3,0x9
ffffffffc02005c0:	85ba                	mv	a1,a4
ffffffffc02005c2:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc02005c4:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02005c6:	0cb040ef          	jal	ra,ffffffffc0204e90 <memcpy>
    return 0;
}
ffffffffc02005ca:	60a2                	ld	ra,8(sp)
ffffffffc02005cc:	4501                	li	a0,0
ffffffffc02005ce:	0141                	addi	sp,sp,16
ffffffffc02005d0:	8082                	ret

ffffffffc02005d2 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005d2:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02005d6:	8082                	ret

ffffffffc02005d8 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005d8:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02005dc:	8082                	ret

ffffffffc02005de <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc02005de:	8082                	ret

ffffffffc02005e0 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005e0:	10053783          	ld	a5,256(a0)
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005e4:	1141                	addi	sp,sp,-16
ffffffffc02005e6:	e022                	sd	s0,0(sp)
ffffffffc02005e8:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005ea:	1007f793          	andi	a5,a5,256
static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005ee:	842a                	mv	s0,a0
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02005f0:	11053583          	ld	a1,272(a0)
ffffffffc02005f4:	05500613          	li	a2,85
ffffffffc02005f8:	c399                	beqz	a5,ffffffffc02005fe <pgfault_handler+0x1e>
ffffffffc02005fa:	04b00613          	li	a2,75
ffffffffc02005fe:	11843703          	ld	a4,280(s0)
ffffffffc0200602:	47bd                	li	a5,15
ffffffffc0200604:	05700693          	li	a3,87
ffffffffc0200608:	00f70463          	beq	a4,a5,ffffffffc0200610 <pgfault_handler+0x30>
ffffffffc020060c:	05200693          	li	a3,82
ffffffffc0200610:	00005517          	auipc	a0,0x5
ffffffffc0200614:	e9050513          	addi	a0,a0,-368 # ffffffffc02054a0 <commands+0x498>
ffffffffc0200618:	b77ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc020061c:	00015797          	auipc	a5,0x15
ffffffffc0200620:	fc478793          	addi	a5,a5,-60 # ffffffffc02155e0 <check_mm_struct>
ffffffffc0200624:	6388                	ld	a0,0(a5)
ffffffffc0200626:	c911                	beqz	a0,ffffffffc020063a <pgfault_handler+0x5a>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200628:	11043603          	ld	a2,272(s0)
ffffffffc020062c:	11842583          	lw	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200630:	6402                	ld	s0,0(sp)
ffffffffc0200632:	60a2                	ld	ra,8(sp)
ffffffffc0200634:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200636:	11f0306f          	j	ffffffffc0203f54 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc020063a:	00005617          	auipc	a2,0x5
ffffffffc020063e:	e8660613          	addi	a2,a2,-378 # ffffffffc02054c0 <commands+0x4b8>
ffffffffc0200642:	06200593          	li	a1,98
ffffffffc0200646:	00005517          	auipc	a0,0x5
ffffffffc020064a:	e9250513          	addi	a0,a0,-366 # ffffffffc02054d8 <commands+0x4d0>
ffffffffc020064e:	e03ff0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0200652 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200652:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200656:	00000797          	auipc	a5,0x0
ffffffffc020065a:	48e78793          	addi	a5,a5,1166 # ffffffffc0200ae4 <__alltraps>
ffffffffc020065e:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200662:	000407b7          	lui	a5,0x40
ffffffffc0200666:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020066a:	8082                	ret

ffffffffc020066c <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020066c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020066e:	1141                	addi	sp,sp,-16
ffffffffc0200670:	e022                	sd	s0,0(sp)
ffffffffc0200672:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200674:	00005517          	auipc	a0,0x5
ffffffffc0200678:	e7c50513          	addi	a0,a0,-388 # ffffffffc02054f0 <commands+0x4e8>
void print_regs(struct pushregs *gpr) {
ffffffffc020067c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020067e:	b11ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200682:	640c                	ld	a1,8(s0)
ffffffffc0200684:	00005517          	auipc	a0,0x5
ffffffffc0200688:	e8450513          	addi	a0,a0,-380 # ffffffffc0205508 <commands+0x500>
ffffffffc020068c:	b03ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200690:	680c                	ld	a1,16(s0)
ffffffffc0200692:	00005517          	auipc	a0,0x5
ffffffffc0200696:	e8e50513          	addi	a0,a0,-370 # ffffffffc0205520 <commands+0x518>
ffffffffc020069a:	af5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc020069e:	6c0c                	ld	a1,24(s0)
ffffffffc02006a0:	00005517          	auipc	a0,0x5
ffffffffc02006a4:	e9850513          	addi	a0,a0,-360 # ffffffffc0205538 <commands+0x530>
ffffffffc02006a8:	ae7ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006ac:	700c                	ld	a1,32(s0)
ffffffffc02006ae:	00005517          	auipc	a0,0x5
ffffffffc02006b2:	ea250513          	addi	a0,a0,-350 # ffffffffc0205550 <commands+0x548>
ffffffffc02006b6:	ad9ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006ba:	740c                	ld	a1,40(s0)
ffffffffc02006bc:	00005517          	auipc	a0,0x5
ffffffffc02006c0:	eac50513          	addi	a0,a0,-340 # ffffffffc0205568 <commands+0x560>
ffffffffc02006c4:	acbff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006c8:	780c                	ld	a1,48(s0)
ffffffffc02006ca:	00005517          	auipc	a0,0x5
ffffffffc02006ce:	eb650513          	addi	a0,a0,-330 # ffffffffc0205580 <commands+0x578>
ffffffffc02006d2:	abdff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006d6:	7c0c                	ld	a1,56(s0)
ffffffffc02006d8:	00005517          	auipc	a0,0x5
ffffffffc02006dc:	ec050513          	addi	a0,a0,-320 # ffffffffc0205598 <commands+0x590>
ffffffffc02006e0:	aafff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006e4:	602c                	ld	a1,64(s0)
ffffffffc02006e6:	00005517          	auipc	a0,0x5
ffffffffc02006ea:	eca50513          	addi	a0,a0,-310 # ffffffffc02055b0 <commands+0x5a8>
ffffffffc02006ee:	aa1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006f2:	642c                	ld	a1,72(s0)
ffffffffc02006f4:	00005517          	auipc	a0,0x5
ffffffffc02006f8:	ed450513          	addi	a0,a0,-300 # ffffffffc02055c8 <commands+0x5c0>
ffffffffc02006fc:	a93ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200700:	682c                	ld	a1,80(s0)
ffffffffc0200702:	00005517          	auipc	a0,0x5
ffffffffc0200706:	ede50513          	addi	a0,a0,-290 # ffffffffc02055e0 <commands+0x5d8>
ffffffffc020070a:	a85ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020070e:	6c2c                	ld	a1,88(s0)
ffffffffc0200710:	00005517          	auipc	a0,0x5
ffffffffc0200714:	ee850513          	addi	a0,a0,-280 # ffffffffc02055f8 <commands+0x5f0>
ffffffffc0200718:	a77ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020071c:	702c                	ld	a1,96(s0)
ffffffffc020071e:	00005517          	auipc	a0,0x5
ffffffffc0200722:	ef250513          	addi	a0,a0,-270 # ffffffffc0205610 <commands+0x608>
ffffffffc0200726:	a69ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020072a:	742c                	ld	a1,104(s0)
ffffffffc020072c:	00005517          	auipc	a0,0x5
ffffffffc0200730:	efc50513          	addi	a0,a0,-260 # ffffffffc0205628 <commands+0x620>
ffffffffc0200734:	a5bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200738:	782c                	ld	a1,112(s0)
ffffffffc020073a:	00005517          	auipc	a0,0x5
ffffffffc020073e:	f0650513          	addi	a0,a0,-250 # ffffffffc0205640 <commands+0x638>
ffffffffc0200742:	a4dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200746:	7c2c                	ld	a1,120(s0)
ffffffffc0200748:	00005517          	auipc	a0,0x5
ffffffffc020074c:	f1050513          	addi	a0,a0,-240 # ffffffffc0205658 <commands+0x650>
ffffffffc0200750:	a3fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200754:	604c                	ld	a1,128(s0)
ffffffffc0200756:	00005517          	auipc	a0,0x5
ffffffffc020075a:	f1a50513          	addi	a0,a0,-230 # ffffffffc0205670 <commands+0x668>
ffffffffc020075e:	a31ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200762:	644c                	ld	a1,136(s0)
ffffffffc0200764:	00005517          	auipc	a0,0x5
ffffffffc0200768:	f2450513          	addi	a0,a0,-220 # ffffffffc0205688 <commands+0x680>
ffffffffc020076c:	a23ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200770:	684c                	ld	a1,144(s0)
ffffffffc0200772:	00005517          	auipc	a0,0x5
ffffffffc0200776:	f2e50513          	addi	a0,a0,-210 # ffffffffc02056a0 <commands+0x698>
ffffffffc020077a:	a15ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020077e:	6c4c                	ld	a1,152(s0)
ffffffffc0200780:	00005517          	auipc	a0,0x5
ffffffffc0200784:	f3850513          	addi	a0,a0,-200 # ffffffffc02056b8 <commands+0x6b0>
ffffffffc0200788:	a07ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020078c:	704c                	ld	a1,160(s0)
ffffffffc020078e:	00005517          	auipc	a0,0x5
ffffffffc0200792:	f4250513          	addi	a0,a0,-190 # ffffffffc02056d0 <commands+0x6c8>
ffffffffc0200796:	9f9ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc020079a:	744c                	ld	a1,168(s0)
ffffffffc020079c:	00005517          	auipc	a0,0x5
ffffffffc02007a0:	f4c50513          	addi	a0,a0,-180 # ffffffffc02056e8 <commands+0x6e0>
ffffffffc02007a4:	9ebff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007a8:	784c                	ld	a1,176(s0)
ffffffffc02007aa:	00005517          	auipc	a0,0x5
ffffffffc02007ae:	f5650513          	addi	a0,a0,-170 # ffffffffc0205700 <commands+0x6f8>
ffffffffc02007b2:	9ddff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007b6:	7c4c                	ld	a1,184(s0)
ffffffffc02007b8:	00005517          	auipc	a0,0x5
ffffffffc02007bc:	f6050513          	addi	a0,a0,-160 # ffffffffc0205718 <commands+0x710>
ffffffffc02007c0:	9cfff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007c4:	606c                	ld	a1,192(s0)
ffffffffc02007c6:	00005517          	auipc	a0,0x5
ffffffffc02007ca:	f6a50513          	addi	a0,a0,-150 # ffffffffc0205730 <commands+0x728>
ffffffffc02007ce:	9c1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007d2:	646c                	ld	a1,200(s0)
ffffffffc02007d4:	00005517          	auipc	a0,0x5
ffffffffc02007d8:	f7450513          	addi	a0,a0,-140 # ffffffffc0205748 <commands+0x740>
ffffffffc02007dc:	9b3ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007e0:	686c                	ld	a1,208(s0)
ffffffffc02007e2:	00005517          	auipc	a0,0x5
ffffffffc02007e6:	f7e50513          	addi	a0,a0,-130 # ffffffffc0205760 <commands+0x758>
ffffffffc02007ea:	9a5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007ee:	6c6c                	ld	a1,216(s0)
ffffffffc02007f0:	00005517          	auipc	a0,0x5
ffffffffc02007f4:	f8850513          	addi	a0,a0,-120 # ffffffffc0205778 <commands+0x770>
ffffffffc02007f8:	997ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007fc:	706c                	ld	a1,224(s0)
ffffffffc02007fe:	00005517          	auipc	a0,0x5
ffffffffc0200802:	f9250513          	addi	a0,a0,-110 # ffffffffc0205790 <commands+0x788>
ffffffffc0200806:	989ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020080a:	746c                	ld	a1,232(s0)
ffffffffc020080c:	00005517          	auipc	a0,0x5
ffffffffc0200810:	f9c50513          	addi	a0,a0,-100 # ffffffffc02057a8 <commands+0x7a0>
ffffffffc0200814:	97bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200818:	786c                	ld	a1,240(s0)
ffffffffc020081a:	00005517          	auipc	a0,0x5
ffffffffc020081e:	fa650513          	addi	a0,a0,-90 # ffffffffc02057c0 <commands+0x7b8>
ffffffffc0200822:	96dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200826:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200828:	6402                	ld	s0,0(sp)
ffffffffc020082a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020082c:	00005517          	auipc	a0,0x5
ffffffffc0200830:	fac50513          	addi	a0,a0,-84 # ffffffffc02057d8 <commands+0x7d0>
}
ffffffffc0200834:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200836:	959ff06f          	j	ffffffffc020018e <cprintf>

ffffffffc020083a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020083a:	1141                	addi	sp,sp,-16
ffffffffc020083c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020083e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200840:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200842:	00005517          	auipc	a0,0x5
ffffffffc0200846:	fae50513          	addi	a0,a0,-82 # ffffffffc02057f0 <commands+0x7e8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020084a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020084c:	943ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200850:	8522                	mv	a0,s0
ffffffffc0200852:	e1bff0ef          	jal	ra,ffffffffc020066c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200856:	10043583          	ld	a1,256(s0)
ffffffffc020085a:	00005517          	auipc	a0,0x5
ffffffffc020085e:	fae50513          	addi	a0,a0,-82 # ffffffffc0205808 <commands+0x800>
ffffffffc0200862:	92dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200866:	10843583          	ld	a1,264(s0)
ffffffffc020086a:	00005517          	auipc	a0,0x5
ffffffffc020086e:	fb650513          	addi	a0,a0,-74 # ffffffffc0205820 <commands+0x818>
ffffffffc0200872:	91dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200876:	11043583          	ld	a1,272(s0)
ffffffffc020087a:	00005517          	auipc	a0,0x5
ffffffffc020087e:	fbe50513          	addi	a0,a0,-66 # ffffffffc0205838 <commands+0x830>
ffffffffc0200882:	90dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200886:	11843583          	ld	a1,280(s0)
}
ffffffffc020088a:	6402                	ld	s0,0(sp)
ffffffffc020088c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020088e:	00005517          	auipc	a0,0x5
ffffffffc0200892:	fc250513          	addi	a0,a0,-62 # ffffffffc0205850 <commands+0x848>
}
ffffffffc0200896:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200898:	8f7ff06f          	j	ffffffffc020018e <cprintf>

ffffffffc020089c <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc020089c:	11853783          	ld	a5,280(a0)
ffffffffc02008a0:	577d                	li	a4,-1
ffffffffc02008a2:	8305                	srli	a4,a4,0x1
ffffffffc02008a4:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02008a6:	472d                	li	a4,11
ffffffffc02008a8:	06f76f63          	bltu	a4,a5,ffffffffc0200926 <interrupt_handler+0x8a>
ffffffffc02008ac:	00005717          	auipc	a4,0x5
ffffffffc02008b0:	91870713          	addi	a4,a4,-1768 # ffffffffc02051c4 <commands+0x1bc>
ffffffffc02008b4:	078a                	slli	a5,a5,0x2
ffffffffc02008b6:	97ba                	add	a5,a5,a4
ffffffffc02008b8:	439c                	lw	a5,0(a5)
ffffffffc02008ba:	97ba                	add	a5,a5,a4
ffffffffc02008bc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02008be:	00005517          	auipc	a0,0x5
ffffffffc02008c2:	b9250513          	addi	a0,a0,-1134 # ffffffffc0205450 <commands+0x448>
ffffffffc02008c6:	8c9ff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02008ca:	00005517          	auipc	a0,0x5
ffffffffc02008ce:	b6650513          	addi	a0,a0,-1178 # ffffffffc0205430 <commands+0x428>
ffffffffc02008d2:	8bdff06f          	j	ffffffffc020018e <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02008d6:	00005517          	auipc	a0,0x5
ffffffffc02008da:	b1a50513          	addi	a0,a0,-1254 # ffffffffc02053f0 <commands+0x3e8>
ffffffffc02008de:	8b1ff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02008e2:	00005517          	auipc	a0,0x5
ffffffffc02008e6:	b2e50513          	addi	a0,a0,-1234 # ffffffffc0205410 <commands+0x408>
ffffffffc02008ea:	8a5ff06f          	j	ffffffffc020018e <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc02008ee:	00005517          	auipc	a0,0x5
ffffffffc02008f2:	b9250513          	addi	a0,a0,-1134 # ffffffffc0205480 <commands+0x478>
ffffffffc02008f6:	899ff06f          	j	ffffffffc020018e <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02008fa:	1141                	addi	sp,sp,-16
ffffffffc02008fc:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc02008fe:	bedff0ef          	jal	ra,ffffffffc02004ea <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc0200902:	00015797          	auipc	a5,0x15
ffffffffc0200906:	bc678793          	addi	a5,a5,-1082 # ffffffffc02154c8 <ticks>
ffffffffc020090a:	639c                	ld	a5,0(a5)
ffffffffc020090c:	06400713          	li	a4,100
ffffffffc0200910:	0785                	addi	a5,a5,1
ffffffffc0200912:	02e7f733          	remu	a4,a5,a4
ffffffffc0200916:	00015697          	auipc	a3,0x15
ffffffffc020091a:	baf6b923          	sd	a5,-1102(a3) # ffffffffc02154c8 <ticks>
ffffffffc020091e:	c711                	beqz	a4,ffffffffc020092a <interrupt_handler+0x8e>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200920:	60a2                	ld	ra,8(sp)
ffffffffc0200922:	0141                	addi	sp,sp,16
ffffffffc0200924:	8082                	ret
            print_trapframe(tf);
ffffffffc0200926:	f15ff06f          	j	ffffffffc020083a <print_trapframe>
}
ffffffffc020092a:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020092c:	06400593          	li	a1,100
ffffffffc0200930:	00005517          	auipc	a0,0x5
ffffffffc0200934:	b4050513          	addi	a0,a0,-1216 # ffffffffc0205470 <commands+0x468>
}
ffffffffc0200938:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020093a:	855ff06f          	j	ffffffffc020018e <cprintf>

ffffffffc020093e <exception_handler>:

void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc020093e:	11853783          	ld	a5,280(a0)
ffffffffc0200942:	473d                	li	a4,15
ffffffffc0200944:	16f76563          	bltu	a4,a5,ffffffffc0200aae <exception_handler+0x170>
ffffffffc0200948:	00005717          	auipc	a4,0x5
ffffffffc020094c:	8ac70713          	addi	a4,a4,-1876 # ffffffffc02051f4 <commands+0x1ec>
ffffffffc0200950:	078a                	slli	a5,a5,0x2
ffffffffc0200952:	97ba                	add	a5,a5,a4
ffffffffc0200954:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc0200956:	1101                	addi	sp,sp,-32
ffffffffc0200958:	e822                	sd	s0,16(sp)
ffffffffc020095a:	ec06                	sd	ra,24(sp)
ffffffffc020095c:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc020095e:	97ba                	add	a5,a5,a4
ffffffffc0200960:	842a                	mv	s0,a0
ffffffffc0200962:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc0200964:	00005517          	auipc	a0,0x5
ffffffffc0200968:	a7450513          	addi	a0,a0,-1420 # ffffffffc02053d8 <commands+0x3d0>
ffffffffc020096c:	823ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200970:	8522                	mv	a0,s0
ffffffffc0200972:	c6fff0ef          	jal	ra,ffffffffc02005e0 <pgfault_handler>
ffffffffc0200976:	84aa                	mv	s1,a0
ffffffffc0200978:	12051d63          	bnez	a0,ffffffffc0200ab2 <exception_handler+0x174>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020097c:	60e2                	ld	ra,24(sp)
ffffffffc020097e:	6442                	ld	s0,16(sp)
ffffffffc0200980:	64a2                	ld	s1,8(sp)
ffffffffc0200982:	6105                	addi	sp,sp,32
ffffffffc0200984:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc0200986:	00005517          	auipc	a0,0x5
ffffffffc020098a:	8b250513          	addi	a0,a0,-1870 # ffffffffc0205238 <commands+0x230>
}
ffffffffc020098e:	6442                	ld	s0,16(sp)
ffffffffc0200990:	60e2                	ld	ra,24(sp)
ffffffffc0200992:	64a2                	ld	s1,8(sp)
ffffffffc0200994:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200996:	ff8ff06f          	j	ffffffffc020018e <cprintf>
ffffffffc020099a:	00005517          	auipc	a0,0x5
ffffffffc020099e:	8be50513          	addi	a0,a0,-1858 # ffffffffc0205258 <commands+0x250>
ffffffffc02009a2:	b7f5                	j	ffffffffc020098e <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc02009a4:	00005517          	auipc	a0,0x5
ffffffffc02009a8:	8d450513          	addi	a0,a0,-1836 # ffffffffc0205278 <commands+0x270>
ffffffffc02009ac:	b7cd                	j	ffffffffc020098e <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc02009ae:	00005517          	auipc	a0,0x5
ffffffffc02009b2:	8e250513          	addi	a0,a0,-1822 # ffffffffc0205290 <commands+0x288>
ffffffffc02009b6:	bfe1                	j	ffffffffc020098e <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc02009b8:	00005517          	auipc	a0,0x5
ffffffffc02009bc:	8e850513          	addi	a0,a0,-1816 # ffffffffc02052a0 <commands+0x298>
ffffffffc02009c0:	b7f9                	j	ffffffffc020098e <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02009c2:	00005517          	auipc	a0,0x5
ffffffffc02009c6:	8fe50513          	addi	a0,a0,-1794 # ffffffffc02052c0 <commands+0x2b8>
ffffffffc02009ca:	fc4ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009ce:	8522                	mv	a0,s0
ffffffffc02009d0:	c11ff0ef          	jal	ra,ffffffffc02005e0 <pgfault_handler>
ffffffffc02009d4:	84aa                	mv	s1,a0
ffffffffc02009d6:	d15d                	beqz	a0,ffffffffc020097c <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009d8:	8522                	mv	a0,s0
ffffffffc02009da:	e61ff0ef          	jal	ra,ffffffffc020083a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009de:	86a6                	mv	a3,s1
ffffffffc02009e0:	00005617          	auipc	a2,0x5
ffffffffc02009e4:	8f860613          	addi	a2,a2,-1800 # ffffffffc02052d8 <commands+0x2d0>
ffffffffc02009e8:	0b300593          	li	a1,179
ffffffffc02009ec:	00005517          	auipc	a0,0x5
ffffffffc02009f0:	aec50513          	addi	a0,a0,-1300 # ffffffffc02054d8 <commands+0x4d0>
ffffffffc02009f4:	a5dff0ef          	jal	ra,ffffffffc0200450 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc02009f8:	00005517          	auipc	a0,0x5
ffffffffc02009fc:	90050513          	addi	a0,a0,-1792 # ffffffffc02052f8 <commands+0x2f0>
ffffffffc0200a00:	b779                	j	ffffffffc020098e <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc0200a02:	00005517          	auipc	a0,0x5
ffffffffc0200a06:	90e50513          	addi	a0,a0,-1778 # ffffffffc0205310 <commands+0x308>
ffffffffc0200a0a:	f84ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a0e:	8522                	mv	a0,s0
ffffffffc0200a10:	bd1ff0ef          	jal	ra,ffffffffc02005e0 <pgfault_handler>
ffffffffc0200a14:	84aa                	mv	s1,a0
ffffffffc0200a16:	d13d                	beqz	a0,ffffffffc020097c <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200a18:	8522                	mv	a0,s0
ffffffffc0200a1a:	e21ff0ef          	jal	ra,ffffffffc020083a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a1e:	86a6                	mv	a3,s1
ffffffffc0200a20:	00005617          	auipc	a2,0x5
ffffffffc0200a24:	8b860613          	addi	a2,a2,-1864 # ffffffffc02052d8 <commands+0x2d0>
ffffffffc0200a28:	0bd00593          	li	a1,189
ffffffffc0200a2c:	00005517          	auipc	a0,0x5
ffffffffc0200a30:	aac50513          	addi	a0,a0,-1364 # ffffffffc02054d8 <commands+0x4d0>
ffffffffc0200a34:	a1dff0ef          	jal	ra,ffffffffc0200450 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200a38:	00005517          	auipc	a0,0x5
ffffffffc0200a3c:	8f050513          	addi	a0,a0,-1808 # ffffffffc0205328 <commands+0x320>
ffffffffc0200a40:	b7b9                	j	ffffffffc020098e <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200a42:	00005517          	auipc	a0,0x5
ffffffffc0200a46:	90650513          	addi	a0,a0,-1786 # ffffffffc0205348 <commands+0x340>
ffffffffc0200a4a:	b791                	j	ffffffffc020098e <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a4c:	00005517          	auipc	a0,0x5
ffffffffc0200a50:	91c50513          	addi	a0,a0,-1764 # ffffffffc0205368 <commands+0x360>
ffffffffc0200a54:	bf2d                	j	ffffffffc020098e <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200a56:	00005517          	auipc	a0,0x5
ffffffffc0200a5a:	93250513          	addi	a0,a0,-1742 # ffffffffc0205388 <commands+0x380>
ffffffffc0200a5e:	bf05                	j	ffffffffc020098e <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200a60:	00005517          	auipc	a0,0x5
ffffffffc0200a64:	94850513          	addi	a0,a0,-1720 # ffffffffc02053a8 <commands+0x3a0>
ffffffffc0200a68:	b71d                	j	ffffffffc020098e <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200a6a:	00005517          	auipc	a0,0x5
ffffffffc0200a6e:	95650513          	addi	a0,a0,-1706 # ffffffffc02053c0 <commands+0x3b8>
ffffffffc0200a72:	f1cff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a76:	8522                	mv	a0,s0
ffffffffc0200a78:	b69ff0ef          	jal	ra,ffffffffc02005e0 <pgfault_handler>
ffffffffc0200a7c:	84aa                	mv	s1,a0
ffffffffc0200a7e:	ee050fe3          	beqz	a0,ffffffffc020097c <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200a82:	8522                	mv	a0,s0
ffffffffc0200a84:	db7ff0ef          	jal	ra,ffffffffc020083a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a88:	86a6                	mv	a3,s1
ffffffffc0200a8a:	00005617          	auipc	a2,0x5
ffffffffc0200a8e:	84e60613          	addi	a2,a2,-1970 # ffffffffc02052d8 <commands+0x2d0>
ffffffffc0200a92:	0d300593          	li	a1,211
ffffffffc0200a96:	00005517          	auipc	a0,0x5
ffffffffc0200a9a:	a4250513          	addi	a0,a0,-1470 # ffffffffc02054d8 <commands+0x4d0>
ffffffffc0200a9e:	9b3ff0ef          	jal	ra,ffffffffc0200450 <__panic>
}
ffffffffc0200aa2:	6442                	ld	s0,16(sp)
ffffffffc0200aa4:	60e2                	ld	ra,24(sp)
ffffffffc0200aa6:	64a2                	ld	s1,8(sp)
ffffffffc0200aa8:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200aaa:	d91ff06f          	j	ffffffffc020083a <print_trapframe>
ffffffffc0200aae:	d8dff06f          	j	ffffffffc020083a <print_trapframe>
                print_trapframe(tf);
ffffffffc0200ab2:	8522                	mv	a0,s0
ffffffffc0200ab4:	d87ff0ef          	jal	ra,ffffffffc020083a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200ab8:	86a6                	mv	a3,s1
ffffffffc0200aba:	00005617          	auipc	a2,0x5
ffffffffc0200abe:	81e60613          	addi	a2,a2,-2018 # ffffffffc02052d8 <commands+0x2d0>
ffffffffc0200ac2:	0da00593          	li	a1,218
ffffffffc0200ac6:	00005517          	auipc	a0,0x5
ffffffffc0200aca:	a1250513          	addi	a0,a0,-1518 # ffffffffc02054d8 <commands+0x4d0>
ffffffffc0200ace:	983ff0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0200ad2 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200ad2:	11853783          	ld	a5,280(a0)
ffffffffc0200ad6:	0007c463          	bltz	a5,ffffffffc0200ade <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200ada:	e65ff06f          	j	ffffffffc020093e <exception_handler>
        interrupt_handler(tf);
ffffffffc0200ade:	dbfff06f          	j	ffffffffc020089c <interrupt_handler>
	...

ffffffffc0200ae4 <__alltraps>:
    LOAD  x2,2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200ae4:	14011073          	csrw	sscratch,sp
ffffffffc0200ae8:	712d                	addi	sp,sp,-288
ffffffffc0200aea:	e406                	sd	ra,8(sp)
ffffffffc0200aec:	ec0e                	sd	gp,24(sp)
ffffffffc0200aee:	f012                	sd	tp,32(sp)
ffffffffc0200af0:	f416                	sd	t0,40(sp)
ffffffffc0200af2:	f81a                	sd	t1,48(sp)
ffffffffc0200af4:	fc1e                	sd	t2,56(sp)
ffffffffc0200af6:	e0a2                	sd	s0,64(sp)
ffffffffc0200af8:	e4a6                	sd	s1,72(sp)
ffffffffc0200afa:	e8aa                	sd	a0,80(sp)
ffffffffc0200afc:	ecae                	sd	a1,88(sp)
ffffffffc0200afe:	f0b2                	sd	a2,96(sp)
ffffffffc0200b00:	f4b6                	sd	a3,104(sp)
ffffffffc0200b02:	f8ba                	sd	a4,112(sp)
ffffffffc0200b04:	fcbe                	sd	a5,120(sp)
ffffffffc0200b06:	e142                	sd	a6,128(sp)
ffffffffc0200b08:	e546                	sd	a7,136(sp)
ffffffffc0200b0a:	e94a                	sd	s2,144(sp)
ffffffffc0200b0c:	ed4e                	sd	s3,152(sp)
ffffffffc0200b0e:	f152                	sd	s4,160(sp)
ffffffffc0200b10:	f556                	sd	s5,168(sp)
ffffffffc0200b12:	f95a                	sd	s6,176(sp)
ffffffffc0200b14:	fd5e                	sd	s7,184(sp)
ffffffffc0200b16:	e1e2                	sd	s8,192(sp)
ffffffffc0200b18:	e5e6                	sd	s9,200(sp)
ffffffffc0200b1a:	e9ea                	sd	s10,208(sp)
ffffffffc0200b1c:	edee                	sd	s11,216(sp)
ffffffffc0200b1e:	f1f2                	sd	t3,224(sp)
ffffffffc0200b20:	f5f6                	sd	t4,232(sp)
ffffffffc0200b22:	f9fa                	sd	t5,240(sp)
ffffffffc0200b24:	fdfe                	sd	t6,248(sp)
ffffffffc0200b26:	14002473          	csrr	s0,sscratch
ffffffffc0200b2a:	100024f3          	csrr	s1,sstatus
ffffffffc0200b2e:	14102973          	csrr	s2,sepc
ffffffffc0200b32:	143029f3          	csrr	s3,stval
ffffffffc0200b36:	14202a73          	csrr	s4,scause
ffffffffc0200b3a:	e822                	sd	s0,16(sp)
ffffffffc0200b3c:	e226                	sd	s1,256(sp)
ffffffffc0200b3e:	e64a                	sd	s2,264(sp)
ffffffffc0200b40:	ea4e                	sd	s3,272(sp)
ffffffffc0200b42:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200b44:	850a                	mv	a0,sp
    jal trap
ffffffffc0200b46:	f8dff0ef          	jal	ra,ffffffffc0200ad2 <trap>

ffffffffc0200b4a <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200b4a:	6492                	ld	s1,256(sp)
ffffffffc0200b4c:	6932                	ld	s2,264(sp)
ffffffffc0200b4e:	10049073          	csrw	sstatus,s1
ffffffffc0200b52:	14191073          	csrw	sepc,s2
ffffffffc0200b56:	60a2                	ld	ra,8(sp)
ffffffffc0200b58:	61e2                	ld	gp,24(sp)
ffffffffc0200b5a:	7202                	ld	tp,32(sp)
ffffffffc0200b5c:	72a2                	ld	t0,40(sp)
ffffffffc0200b5e:	7342                	ld	t1,48(sp)
ffffffffc0200b60:	73e2                	ld	t2,56(sp)
ffffffffc0200b62:	6406                	ld	s0,64(sp)
ffffffffc0200b64:	64a6                	ld	s1,72(sp)
ffffffffc0200b66:	6546                	ld	a0,80(sp)
ffffffffc0200b68:	65e6                	ld	a1,88(sp)
ffffffffc0200b6a:	7606                	ld	a2,96(sp)
ffffffffc0200b6c:	76a6                	ld	a3,104(sp)
ffffffffc0200b6e:	7746                	ld	a4,112(sp)
ffffffffc0200b70:	77e6                	ld	a5,120(sp)
ffffffffc0200b72:	680a                	ld	a6,128(sp)
ffffffffc0200b74:	68aa                	ld	a7,136(sp)
ffffffffc0200b76:	694a                	ld	s2,144(sp)
ffffffffc0200b78:	69ea                	ld	s3,152(sp)
ffffffffc0200b7a:	7a0a                	ld	s4,160(sp)
ffffffffc0200b7c:	7aaa                	ld	s5,168(sp)
ffffffffc0200b7e:	7b4a                	ld	s6,176(sp)
ffffffffc0200b80:	7bea                	ld	s7,184(sp)
ffffffffc0200b82:	6c0e                	ld	s8,192(sp)
ffffffffc0200b84:	6cae                	ld	s9,200(sp)
ffffffffc0200b86:	6d4e                	ld	s10,208(sp)
ffffffffc0200b88:	6dee                	ld	s11,216(sp)
ffffffffc0200b8a:	7e0e                	ld	t3,224(sp)
ffffffffc0200b8c:	7eae                	ld	t4,232(sp)
ffffffffc0200b8e:	7f4e                	ld	t5,240(sp)
ffffffffc0200b90:	7fee                	ld	t6,248(sp)
ffffffffc0200b92:	6142                	ld	sp,16(sp)
    # go back from supervisor call
    sret
ffffffffc0200b94:	10200073          	sret

ffffffffc0200b98 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200b98:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200b9a:	bf45                	j	ffffffffc0200b4a <__trapret>
	...

ffffffffc0200b9e <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200b9e:	00015797          	auipc	a5,0x15
ffffffffc0200ba2:	93278793          	addi	a5,a5,-1742 # ffffffffc02154d0 <free_area>
ffffffffc0200ba6:	e79c                	sd	a5,8(a5)
ffffffffc0200ba8:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200baa:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200bae:	8082                	ret

ffffffffc0200bb0 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200bb0:	00015517          	auipc	a0,0x15
ffffffffc0200bb4:	93056503          	lwu	a0,-1744(a0) # ffffffffc02154e0 <free_area+0x10>
ffffffffc0200bb8:	8082                	ret

ffffffffc0200bba <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200bba:	715d                	addi	sp,sp,-80
ffffffffc0200bbc:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200bbe:	00015917          	auipc	s2,0x15
ffffffffc0200bc2:	91290913          	addi	s2,s2,-1774 # ffffffffc02154d0 <free_area>
ffffffffc0200bc6:	00893783          	ld	a5,8(s2)
ffffffffc0200bca:	e486                	sd	ra,72(sp)
ffffffffc0200bcc:	e0a2                	sd	s0,64(sp)
ffffffffc0200bce:	fc26                	sd	s1,56(sp)
ffffffffc0200bd0:	f44e                	sd	s3,40(sp)
ffffffffc0200bd2:	f052                	sd	s4,32(sp)
ffffffffc0200bd4:	ec56                	sd	s5,24(sp)
ffffffffc0200bd6:	e85a                	sd	s6,16(sp)
ffffffffc0200bd8:	e45e                	sd	s7,8(sp)
ffffffffc0200bda:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200bdc:	31278463          	beq	a5,s2,ffffffffc0200ee4 <default_check+0x32a>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200be0:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200be4:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200be6:	8b05                	andi	a4,a4,1
ffffffffc0200be8:	30070263          	beqz	a4,ffffffffc0200eec <default_check+0x332>
    int count = 0, total = 0;
ffffffffc0200bec:	4401                	li	s0,0
ffffffffc0200bee:	4481                	li	s1,0
ffffffffc0200bf0:	a031                	j	ffffffffc0200bfc <default_check+0x42>
ffffffffc0200bf2:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0200bf6:	8b09                	andi	a4,a4,2
ffffffffc0200bf8:	2e070a63          	beqz	a4,ffffffffc0200eec <default_check+0x332>
        count ++, total += p->property;
ffffffffc0200bfc:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200c00:	679c                	ld	a5,8(a5)
ffffffffc0200c02:	2485                	addiw	s1,s1,1
ffffffffc0200c04:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200c06:	ff2796e3          	bne	a5,s2,ffffffffc0200bf2 <default_check+0x38>
ffffffffc0200c0a:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200c0c:	058010ef          	jal	ra,ffffffffc0201c64 <nr_free_pages>
ffffffffc0200c10:	73351e63          	bne	a0,s3,ffffffffc020134c <default_check+0x792>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c14:	4505                	li	a0,1
ffffffffc0200c16:	781000ef          	jal	ra,ffffffffc0201b96 <alloc_pages>
ffffffffc0200c1a:	8a2a                	mv	s4,a0
ffffffffc0200c1c:	46050863          	beqz	a0,ffffffffc020108c <default_check+0x4d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c20:	4505                	li	a0,1
ffffffffc0200c22:	775000ef          	jal	ra,ffffffffc0201b96 <alloc_pages>
ffffffffc0200c26:	89aa                	mv	s3,a0
ffffffffc0200c28:	74050263          	beqz	a0,ffffffffc020136c <default_check+0x7b2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c2c:	4505                	li	a0,1
ffffffffc0200c2e:	769000ef          	jal	ra,ffffffffc0201b96 <alloc_pages>
ffffffffc0200c32:	8aaa                	mv	s5,a0
ffffffffc0200c34:	4c050c63          	beqz	a0,ffffffffc020110c <default_check+0x552>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200c38:	2d3a0a63          	beq	s4,s3,ffffffffc0200f0c <default_check+0x352>
ffffffffc0200c3c:	2caa0863          	beq	s4,a0,ffffffffc0200f0c <default_check+0x352>
ffffffffc0200c40:	2ca98663          	beq	s3,a0,ffffffffc0200f0c <default_check+0x352>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200c44:	000a2783          	lw	a5,0(s4)
ffffffffc0200c48:	2e079263          	bnez	a5,ffffffffc0200f2c <default_check+0x372>
ffffffffc0200c4c:	0009a783          	lw	a5,0(s3)
ffffffffc0200c50:	2c079e63          	bnez	a5,ffffffffc0200f2c <default_check+0x372>
ffffffffc0200c54:	411c                	lw	a5,0(a0)
ffffffffc0200c56:	2c079b63          	bnez	a5,ffffffffc0200f2c <default_check+0x372>
extern size_t npage;
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page) {
    return page - pages + nbase;
ffffffffc0200c5a:	00015797          	auipc	a5,0x15
ffffffffc0200c5e:	8a678793          	addi	a5,a5,-1882 # ffffffffc0215500 <pages>
ffffffffc0200c62:	639c                	ld	a5,0(a5)
ffffffffc0200c64:	00006717          	auipc	a4,0x6
ffffffffc0200c68:	35470713          	addi	a4,a4,852 # ffffffffc0206fb8 <nbase>
ffffffffc0200c6c:	6310                	ld	a2,0(a4)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200c6e:	00015717          	auipc	a4,0x15
ffffffffc0200c72:	82270713          	addi	a4,a4,-2014 # ffffffffc0215490 <npage>
ffffffffc0200c76:	6314                	ld	a3,0(a4)
ffffffffc0200c78:	40fa0733          	sub	a4,s4,a5
ffffffffc0200c7c:	8719                	srai	a4,a4,0x6
ffffffffc0200c7e:	9732                	add	a4,a4,a2
ffffffffc0200c80:	06b2                	slli	a3,a3,0xc
}

static inline uintptr_t
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c82:	0732                	slli	a4,a4,0xc
ffffffffc0200c84:	2cd77463          	bleu	a3,a4,ffffffffc0200f4c <default_check+0x392>
    return page - pages + nbase;
ffffffffc0200c88:	40f98733          	sub	a4,s3,a5
ffffffffc0200c8c:	8719                	srai	a4,a4,0x6
ffffffffc0200c8e:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c90:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200c92:	4ed77d63          	bleu	a3,a4,ffffffffc020118c <default_check+0x5d2>
    return page - pages + nbase;
ffffffffc0200c96:	40f507b3          	sub	a5,a0,a5
ffffffffc0200c9a:	8799                	srai	a5,a5,0x6
ffffffffc0200c9c:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c9e:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200ca0:	34d7f663          	bleu	a3,a5,ffffffffc0200fec <default_check+0x432>
    assert(alloc_page() == NULL);
ffffffffc0200ca4:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200ca6:	00093c03          	ld	s8,0(s2)
ffffffffc0200caa:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200cae:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200cb2:	00015797          	auipc	a5,0x15
ffffffffc0200cb6:	8327b323          	sd	s2,-2010(a5) # ffffffffc02154d8 <free_area+0x8>
ffffffffc0200cba:	00015797          	auipc	a5,0x15
ffffffffc0200cbe:	8127bb23          	sd	s2,-2026(a5) # ffffffffc02154d0 <free_area>
    nr_free = 0;
ffffffffc0200cc2:	00015797          	auipc	a5,0x15
ffffffffc0200cc6:	8007af23          	sw	zero,-2018(a5) # ffffffffc02154e0 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200cca:	6cd000ef          	jal	ra,ffffffffc0201b96 <alloc_pages>
ffffffffc0200cce:	2e051f63          	bnez	a0,ffffffffc0200fcc <default_check+0x412>
    free_page(p0);
ffffffffc0200cd2:	4585                	li	a1,1
ffffffffc0200cd4:	8552                	mv	a0,s4
ffffffffc0200cd6:	749000ef          	jal	ra,ffffffffc0201c1e <free_pages>
    free_page(p1);
ffffffffc0200cda:	4585                	li	a1,1
ffffffffc0200cdc:	854e                	mv	a0,s3
ffffffffc0200cde:	741000ef          	jal	ra,ffffffffc0201c1e <free_pages>
    free_page(p2);
ffffffffc0200ce2:	4585                	li	a1,1
ffffffffc0200ce4:	8556                	mv	a0,s5
ffffffffc0200ce6:	739000ef          	jal	ra,ffffffffc0201c1e <free_pages>
    assert(nr_free == 3);
ffffffffc0200cea:	01092703          	lw	a4,16(s2)
ffffffffc0200cee:	478d                	li	a5,3
ffffffffc0200cf0:	2af71e63          	bne	a4,a5,ffffffffc0200fac <default_check+0x3f2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200cf4:	4505                	li	a0,1
ffffffffc0200cf6:	6a1000ef          	jal	ra,ffffffffc0201b96 <alloc_pages>
ffffffffc0200cfa:	89aa                	mv	s3,a0
ffffffffc0200cfc:	28050863          	beqz	a0,ffffffffc0200f8c <default_check+0x3d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d00:	4505                	li	a0,1
ffffffffc0200d02:	695000ef          	jal	ra,ffffffffc0201b96 <alloc_pages>
ffffffffc0200d06:	8aaa                	mv	s5,a0
ffffffffc0200d08:	3e050263          	beqz	a0,ffffffffc02010ec <default_check+0x532>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200d0c:	4505                	li	a0,1
ffffffffc0200d0e:	689000ef          	jal	ra,ffffffffc0201b96 <alloc_pages>
ffffffffc0200d12:	8a2a                	mv	s4,a0
ffffffffc0200d14:	3a050c63          	beqz	a0,ffffffffc02010cc <default_check+0x512>
    assert(alloc_page() == NULL);
ffffffffc0200d18:	4505                	li	a0,1
ffffffffc0200d1a:	67d000ef          	jal	ra,ffffffffc0201b96 <alloc_pages>
ffffffffc0200d1e:	38051763          	bnez	a0,ffffffffc02010ac <default_check+0x4f2>
    free_page(p0);
ffffffffc0200d22:	4585                	li	a1,1
ffffffffc0200d24:	854e                	mv	a0,s3
ffffffffc0200d26:	6f9000ef          	jal	ra,ffffffffc0201c1e <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200d2a:	00893783          	ld	a5,8(s2)
ffffffffc0200d2e:	23278f63          	beq	a5,s2,ffffffffc0200f6c <default_check+0x3b2>
    assert((p = alloc_page()) == p0);
ffffffffc0200d32:	4505                	li	a0,1
ffffffffc0200d34:	663000ef          	jal	ra,ffffffffc0201b96 <alloc_pages>
ffffffffc0200d38:	32a99a63          	bne	s3,a0,ffffffffc020106c <default_check+0x4b2>
    assert(alloc_page() == NULL);
ffffffffc0200d3c:	4505                	li	a0,1
ffffffffc0200d3e:	659000ef          	jal	ra,ffffffffc0201b96 <alloc_pages>
ffffffffc0200d42:	30051563          	bnez	a0,ffffffffc020104c <default_check+0x492>
    assert(nr_free == 0);
ffffffffc0200d46:	01092783          	lw	a5,16(s2)
ffffffffc0200d4a:	2e079163          	bnez	a5,ffffffffc020102c <default_check+0x472>
    free_page(p);
ffffffffc0200d4e:	854e                	mv	a0,s3
ffffffffc0200d50:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200d52:	00014797          	auipc	a5,0x14
ffffffffc0200d56:	7787bf23          	sd	s8,1918(a5) # ffffffffc02154d0 <free_area>
ffffffffc0200d5a:	00014797          	auipc	a5,0x14
ffffffffc0200d5e:	7777bf23          	sd	s7,1918(a5) # ffffffffc02154d8 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200d62:	00014797          	auipc	a5,0x14
ffffffffc0200d66:	7767af23          	sw	s6,1918(a5) # ffffffffc02154e0 <free_area+0x10>
    free_page(p);
ffffffffc0200d6a:	6b5000ef          	jal	ra,ffffffffc0201c1e <free_pages>
    free_page(p1);
ffffffffc0200d6e:	4585                	li	a1,1
ffffffffc0200d70:	8556                	mv	a0,s5
ffffffffc0200d72:	6ad000ef          	jal	ra,ffffffffc0201c1e <free_pages>
    free_page(p2);
ffffffffc0200d76:	4585                	li	a1,1
ffffffffc0200d78:	8552                	mv	a0,s4
ffffffffc0200d7a:	6a5000ef          	jal	ra,ffffffffc0201c1e <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200d7e:	4515                	li	a0,5
ffffffffc0200d80:	617000ef          	jal	ra,ffffffffc0201b96 <alloc_pages>
ffffffffc0200d84:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200d86:	28050363          	beqz	a0,ffffffffc020100c <default_check+0x452>
ffffffffc0200d8a:	651c                	ld	a5,8(a0)
ffffffffc0200d8c:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200d8e:	8b85                	andi	a5,a5,1
ffffffffc0200d90:	54079e63          	bnez	a5,ffffffffc02012ec <default_check+0x732>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200d94:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200d96:	00093b03          	ld	s6,0(s2)
ffffffffc0200d9a:	00893a83          	ld	s5,8(s2)
ffffffffc0200d9e:	00014797          	auipc	a5,0x14
ffffffffc0200da2:	7327b923          	sd	s2,1842(a5) # ffffffffc02154d0 <free_area>
ffffffffc0200da6:	00014797          	auipc	a5,0x14
ffffffffc0200daa:	7327b923          	sd	s2,1842(a5) # ffffffffc02154d8 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0200dae:	5e9000ef          	jal	ra,ffffffffc0201b96 <alloc_pages>
ffffffffc0200db2:	50051d63          	bnez	a0,ffffffffc02012cc <default_check+0x712>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200db6:	08098a13          	addi	s4,s3,128
ffffffffc0200dba:	8552                	mv	a0,s4
ffffffffc0200dbc:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200dbe:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc0200dc2:	00014797          	auipc	a5,0x14
ffffffffc0200dc6:	7007af23          	sw	zero,1822(a5) # ffffffffc02154e0 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200dca:	655000ef          	jal	ra,ffffffffc0201c1e <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200dce:	4511                	li	a0,4
ffffffffc0200dd0:	5c7000ef          	jal	ra,ffffffffc0201b96 <alloc_pages>
ffffffffc0200dd4:	4c051c63          	bnez	a0,ffffffffc02012ac <default_check+0x6f2>
ffffffffc0200dd8:	0889b783          	ld	a5,136(s3)
ffffffffc0200ddc:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200dde:	8b85                	andi	a5,a5,1
ffffffffc0200de0:	4a078663          	beqz	a5,ffffffffc020128c <default_check+0x6d2>
ffffffffc0200de4:	0909a703          	lw	a4,144(s3)
ffffffffc0200de8:	478d                	li	a5,3
ffffffffc0200dea:	4af71163          	bne	a4,a5,ffffffffc020128c <default_check+0x6d2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200dee:	450d                	li	a0,3
ffffffffc0200df0:	5a7000ef          	jal	ra,ffffffffc0201b96 <alloc_pages>
ffffffffc0200df4:	8c2a                	mv	s8,a0
ffffffffc0200df6:	46050b63          	beqz	a0,ffffffffc020126c <default_check+0x6b2>
    assert(alloc_page() == NULL);
ffffffffc0200dfa:	4505                	li	a0,1
ffffffffc0200dfc:	59b000ef          	jal	ra,ffffffffc0201b96 <alloc_pages>
ffffffffc0200e00:	44051663          	bnez	a0,ffffffffc020124c <default_check+0x692>
    assert(p0 + 2 == p1);
ffffffffc0200e04:	438a1463          	bne	s4,s8,ffffffffc020122c <default_check+0x672>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200e08:	4585                	li	a1,1
ffffffffc0200e0a:	854e                	mv	a0,s3
ffffffffc0200e0c:	613000ef          	jal	ra,ffffffffc0201c1e <free_pages>
    free_pages(p1, 3);
ffffffffc0200e10:	458d                	li	a1,3
ffffffffc0200e12:	8552                	mv	a0,s4
ffffffffc0200e14:	60b000ef          	jal	ra,ffffffffc0201c1e <free_pages>
ffffffffc0200e18:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200e1c:	04098c13          	addi	s8,s3,64
ffffffffc0200e20:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200e22:	8b85                	andi	a5,a5,1
ffffffffc0200e24:	3e078463          	beqz	a5,ffffffffc020120c <default_check+0x652>
ffffffffc0200e28:	0109a703          	lw	a4,16(s3)
ffffffffc0200e2c:	4785                	li	a5,1
ffffffffc0200e2e:	3cf71f63          	bne	a4,a5,ffffffffc020120c <default_check+0x652>
ffffffffc0200e32:	008a3783          	ld	a5,8(s4)
ffffffffc0200e36:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200e38:	8b85                	andi	a5,a5,1
ffffffffc0200e3a:	3a078963          	beqz	a5,ffffffffc02011ec <default_check+0x632>
ffffffffc0200e3e:	010a2703          	lw	a4,16(s4)
ffffffffc0200e42:	478d                	li	a5,3
ffffffffc0200e44:	3af71463          	bne	a4,a5,ffffffffc02011ec <default_check+0x632>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200e48:	4505                	li	a0,1
ffffffffc0200e4a:	54d000ef          	jal	ra,ffffffffc0201b96 <alloc_pages>
ffffffffc0200e4e:	36a99f63          	bne	s3,a0,ffffffffc02011cc <default_check+0x612>
    free_page(p0);
ffffffffc0200e52:	4585                	li	a1,1
ffffffffc0200e54:	5cb000ef          	jal	ra,ffffffffc0201c1e <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200e58:	4509                	li	a0,2
ffffffffc0200e5a:	53d000ef          	jal	ra,ffffffffc0201b96 <alloc_pages>
ffffffffc0200e5e:	34aa1763          	bne	s4,a0,ffffffffc02011ac <default_check+0x5f2>

    free_pages(p0, 2);
ffffffffc0200e62:	4589                	li	a1,2
ffffffffc0200e64:	5bb000ef          	jal	ra,ffffffffc0201c1e <free_pages>
    free_page(p2);
ffffffffc0200e68:	4585                	li	a1,1
ffffffffc0200e6a:	8562                	mv	a0,s8
ffffffffc0200e6c:	5b3000ef          	jal	ra,ffffffffc0201c1e <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200e70:	4515                	li	a0,5
ffffffffc0200e72:	525000ef          	jal	ra,ffffffffc0201b96 <alloc_pages>
ffffffffc0200e76:	89aa                	mv	s3,a0
ffffffffc0200e78:	48050a63          	beqz	a0,ffffffffc020130c <default_check+0x752>
    assert(alloc_page() == NULL);
ffffffffc0200e7c:	4505                	li	a0,1
ffffffffc0200e7e:	519000ef          	jal	ra,ffffffffc0201b96 <alloc_pages>
ffffffffc0200e82:	2e051563          	bnez	a0,ffffffffc020116c <default_check+0x5b2>

    assert(nr_free == 0);
ffffffffc0200e86:	01092783          	lw	a5,16(s2)
ffffffffc0200e8a:	2c079163          	bnez	a5,ffffffffc020114c <default_check+0x592>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200e8e:	4595                	li	a1,5
ffffffffc0200e90:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200e92:	00014797          	auipc	a5,0x14
ffffffffc0200e96:	6577a723          	sw	s7,1614(a5) # ffffffffc02154e0 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0200e9a:	00014797          	auipc	a5,0x14
ffffffffc0200e9e:	6367bb23          	sd	s6,1590(a5) # ffffffffc02154d0 <free_area>
ffffffffc0200ea2:	00014797          	auipc	a5,0x14
ffffffffc0200ea6:	6357bb23          	sd	s5,1590(a5) # ffffffffc02154d8 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0200eaa:	575000ef          	jal	ra,ffffffffc0201c1e <free_pages>
    return listelm->next;
ffffffffc0200eae:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200eb2:	01278963          	beq	a5,s2,ffffffffc0200ec4 <default_check+0x30a>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200eb6:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200eba:	679c                	ld	a5,8(a5)
ffffffffc0200ebc:	34fd                	addiw	s1,s1,-1
ffffffffc0200ebe:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ec0:	ff279be3          	bne	a5,s2,ffffffffc0200eb6 <default_check+0x2fc>
    }
    assert(count == 0);
ffffffffc0200ec4:	26049463          	bnez	s1,ffffffffc020112c <default_check+0x572>
    assert(total == 0);
ffffffffc0200ec8:	46041263          	bnez	s0,ffffffffc020132c <default_check+0x772>
}
ffffffffc0200ecc:	60a6                	ld	ra,72(sp)
ffffffffc0200ece:	6406                	ld	s0,64(sp)
ffffffffc0200ed0:	74e2                	ld	s1,56(sp)
ffffffffc0200ed2:	7942                	ld	s2,48(sp)
ffffffffc0200ed4:	79a2                	ld	s3,40(sp)
ffffffffc0200ed6:	7a02                	ld	s4,32(sp)
ffffffffc0200ed8:	6ae2                	ld	s5,24(sp)
ffffffffc0200eda:	6b42                	ld	s6,16(sp)
ffffffffc0200edc:	6ba2                	ld	s7,8(sp)
ffffffffc0200ede:	6c02                	ld	s8,0(sp)
ffffffffc0200ee0:	6161                	addi	sp,sp,80
ffffffffc0200ee2:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ee4:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200ee6:	4401                	li	s0,0
ffffffffc0200ee8:	4481                	li	s1,0
ffffffffc0200eea:	b30d                	j	ffffffffc0200c0c <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0200eec:	00005697          	auipc	a3,0x5
ffffffffc0200ef0:	97c68693          	addi	a3,a3,-1668 # ffffffffc0205868 <commands+0x860>
ffffffffc0200ef4:	00005617          	auipc	a2,0x5
ffffffffc0200ef8:	98460613          	addi	a2,a2,-1660 # ffffffffc0205878 <commands+0x870>
ffffffffc0200efc:	0f000593          	li	a1,240
ffffffffc0200f00:	00005517          	auipc	a0,0x5
ffffffffc0200f04:	99050513          	addi	a0,a0,-1648 # ffffffffc0205890 <commands+0x888>
ffffffffc0200f08:	d48ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200f0c:	00005697          	auipc	a3,0x5
ffffffffc0200f10:	a1c68693          	addi	a3,a3,-1508 # ffffffffc0205928 <commands+0x920>
ffffffffc0200f14:	00005617          	auipc	a2,0x5
ffffffffc0200f18:	96460613          	addi	a2,a2,-1692 # ffffffffc0205878 <commands+0x870>
ffffffffc0200f1c:	0bd00593          	li	a1,189
ffffffffc0200f20:	00005517          	auipc	a0,0x5
ffffffffc0200f24:	97050513          	addi	a0,a0,-1680 # ffffffffc0205890 <commands+0x888>
ffffffffc0200f28:	d28ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200f2c:	00005697          	auipc	a3,0x5
ffffffffc0200f30:	a2468693          	addi	a3,a3,-1500 # ffffffffc0205950 <commands+0x948>
ffffffffc0200f34:	00005617          	auipc	a2,0x5
ffffffffc0200f38:	94460613          	addi	a2,a2,-1724 # ffffffffc0205878 <commands+0x870>
ffffffffc0200f3c:	0be00593          	li	a1,190
ffffffffc0200f40:	00005517          	auipc	a0,0x5
ffffffffc0200f44:	95050513          	addi	a0,a0,-1712 # ffffffffc0205890 <commands+0x888>
ffffffffc0200f48:	d08ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200f4c:	00005697          	auipc	a3,0x5
ffffffffc0200f50:	a4468693          	addi	a3,a3,-1468 # ffffffffc0205990 <commands+0x988>
ffffffffc0200f54:	00005617          	auipc	a2,0x5
ffffffffc0200f58:	92460613          	addi	a2,a2,-1756 # ffffffffc0205878 <commands+0x870>
ffffffffc0200f5c:	0c000593          	li	a1,192
ffffffffc0200f60:	00005517          	auipc	a0,0x5
ffffffffc0200f64:	93050513          	addi	a0,a0,-1744 # ffffffffc0205890 <commands+0x888>
ffffffffc0200f68:	ce8ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200f6c:	00005697          	auipc	a3,0x5
ffffffffc0200f70:	aac68693          	addi	a3,a3,-1364 # ffffffffc0205a18 <commands+0xa10>
ffffffffc0200f74:	00005617          	auipc	a2,0x5
ffffffffc0200f78:	90460613          	addi	a2,a2,-1788 # ffffffffc0205878 <commands+0x870>
ffffffffc0200f7c:	0d900593          	li	a1,217
ffffffffc0200f80:	00005517          	auipc	a0,0x5
ffffffffc0200f84:	91050513          	addi	a0,a0,-1776 # ffffffffc0205890 <commands+0x888>
ffffffffc0200f88:	cc8ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f8c:	00005697          	auipc	a3,0x5
ffffffffc0200f90:	93c68693          	addi	a3,a3,-1732 # ffffffffc02058c8 <commands+0x8c0>
ffffffffc0200f94:	00005617          	auipc	a2,0x5
ffffffffc0200f98:	8e460613          	addi	a2,a2,-1820 # ffffffffc0205878 <commands+0x870>
ffffffffc0200f9c:	0d200593          	li	a1,210
ffffffffc0200fa0:	00005517          	auipc	a0,0x5
ffffffffc0200fa4:	8f050513          	addi	a0,a0,-1808 # ffffffffc0205890 <commands+0x888>
ffffffffc0200fa8:	ca8ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(nr_free == 3);
ffffffffc0200fac:	00005697          	auipc	a3,0x5
ffffffffc0200fb0:	a5c68693          	addi	a3,a3,-1444 # ffffffffc0205a08 <commands+0xa00>
ffffffffc0200fb4:	00005617          	auipc	a2,0x5
ffffffffc0200fb8:	8c460613          	addi	a2,a2,-1852 # ffffffffc0205878 <commands+0x870>
ffffffffc0200fbc:	0d000593          	li	a1,208
ffffffffc0200fc0:	00005517          	auipc	a0,0x5
ffffffffc0200fc4:	8d050513          	addi	a0,a0,-1840 # ffffffffc0205890 <commands+0x888>
ffffffffc0200fc8:	c88ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200fcc:	00005697          	auipc	a3,0x5
ffffffffc0200fd0:	a2468693          	addi	a3,a3,-1500 # ffffffffc02059f0 <commands+0x9e8>
ffffffffc0200fd4:	00005617          	auipc	a2,0x5
ffffffffc0200fd8:	8a460613          	addi	a2,a2,-1884 # ffffffffc0205878 <commands+0x870>
ffffffffc0200fdc:	0cb00593          	li	a1,203
ffffffffc0200fe0:	00005517          	auipc	a0,0x5
ffffffffc0200fe4:	8b050513          	addi	a0,a0,-1872 # ffffffffc0205890 <commands+0x888>
ffffffffc0200fe8:	c68ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200fec:	00005697          	auipc	a3,0x5
ffffffffc0200ff0:	9e468693          	addi	a3,a3,-1564 # ffffffffc02059d0 <commands+0x9c8>
ffffffffc0200ff4:	00005617          	auipc	a2,0x5
ffffffffc0200ff8:	88460613          	addi	a2,a2,-1916 # ffffffffc0205878 <commands+0x870>
ffffffffc0200ffc:	0c200593          	li	a1,194
ffffffffc0201000:	00005517          	auipc	a0,0x5
ffffffffc0201004:	89050513          	addi	a0,a0,-1904 # ffffffffc0205890 <commands+0x888>
ffffffffc0201008:	c48ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(p0 != NULL);
ffffffffc020100c:	00005697          	auipc	a3,0x5
ffffffffc0201010:	a5468693          	addi	a3,a3,-1452 # ffffffffc0205a60 <commands+0xa58>
ffffffffc0201014:	00005617          	auipc	a2,0x5
ffffffffc0201018:	86460613          	addi	a2,a2,-1948 # ffffffffc0205878 <commands+0x870>
ffffffffc020101c:	0f800593          	li	a1,248
ffffffffc0201020:	00005517          	auipc	a0,0x5
ffffffffc0201024:	87050513          	addi	a0,a0,-1936 # ffffffffc0205890 <commands+0x888>
ffffffffc0201028:	c28ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(nr_free == 0);
ffffffffc020102c:	00005697          	auipc	a3,0x5
ffffffffc0201030:	a2468693          	addi	a3,a3,-1500 # ffffffffc0205a50 <commands+0xa48>
ffffffffc0201034:	00005617          	auipc	a2,0x5
ffffffffc0201038:	84460613          	addi	a2,a2,-1980 # ffffffffc0205878 <commands+0x870>
ffffffffc020103c:	0df00593          	li	a1,223
ffffffffc0201040:	00005517          	auipc	a0,0x5
ffffffffc0201044:	85050513          	addi	a0,a0,-1968 # ffffffffc0205890 <commands+0x888>
ffffffffc0201048:	c08ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020104c:	00005697          	auipc	a3,0x5
ffffffffc0201050:	9a468693          	addi	a3,a3,-1628 # ffffffffc02059f0 <commands+0x9e8>
ffffffffc0201054:	00005617          	auipc	a2,0x5
ffffffffc0201058:	82460613          	addi	a2,a2,-2012 # ffffffffc0205878 <commands+0x870>
ffffffffc020105c:	0dd00593          	li	a1,221
ffffffffc0201060:	00005517          	auipc	a0,0x5
ffffffffc0201064:	83050513          	addi	a0,a0,-2000 # ffffffffc0205890 <commands+0x888>
ffffffffc0201068:	be8ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc020106c:	00005697          	auipc	a3,0x5
ffffffffc0201070:	9c468693          	addi	a3,a3,-1596 # ffffffffc0205a30 <commands+0xa28>
ffffffffc0201074:	00005617          	auipc	a2,0x5
ffffffffc0201078:	80460613          	addi	a2,a2,-2044 # ffffffffc0205878 <commands+0x870>
ffffffffc020107c:	0dc00593          	li	a1,220
ffffffffc0201080:	00005517          	auipc	a0,0x5
ffffffffc0201084:	81050513          	addi	a0,a0,-2032 # ffffffffc0205890 <commands+0x888>
ffffffffc0201088:	bc8ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020108c:	00005697          	auipc	a3,0x5
ffffffffc0201090:	83c68693          	addi	a3,a3,-1988 # ffffffffc02058c8 <commands+0x8c0>
ffffffffc0201094:	00004617          	auipc	a2,0x4
ffffffffc0201098:	7e460613          	addi	a2,a2,2020 # ffffffffc0205878 <commands+0x870>
ffffffffc020109c:	0b900593          	li	a1,185
ffffffffc02010a0:	00004517          	auipc	a0,0x4
ffffffffc02010a4:	7f050513          	addi	a0,a0,2032 # ffffffffc0205890 <commands+0x888>
ffffffffc02010a8:	ba8ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02010ac:	00005697          	auipc	a3,0x5
ffffffffc02010b0:	94468693          	addi	a3,a3,-1724 # ffffffffc02059f0 <commands+0x9e8>
ffffffffc02010b4:	00004617          	auipc	a2,0x4
ffffffffc02010b8:	7c460613          	addi	a2,a2,1988 # ffffffffc0205878 <commands+0x870>
ffffffffc02010bc:	0d600593          	li	a1,214
ffffffffc02010c0:	00004517          	auipc	a0,0x4
ffffffffc02010c4:	7d050513          	addi	a0,a0,2000 # ffffffffc0205890 <commands+0x888>
ffffffffc02010c8:	b88ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02010cc:	00005697          	auipc	a3,0x5
ffffffffc02010d0:	83c68693          	addi	a3,a3,-1988 # ffffffffc0205908 <commands+0x900>
ffffffffc02010d4:	00004617          	auipc	a2,0x4
ffffffffc02010d8:	7a460613          	addi	a2,a2,1956 # ffffffffc0205878 <commands+0x870>
ffffffffc02010dc:	0d400593          	li	a1,212
ffffffffc02010e0:	00004517          	auipc	a0,0x4
ffffffffc02010e4:	7b050513          	addi	a0,a0,1968 # ffffffffc0205890 <commands+0x888>
ffffffffc02010e8:	b68ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02010ec:	00004697          	auipc	a3,0x4
ffffffffc02010f0:	7fc68693          	addi	a3,a3,2044 # ffffffffc02058e8 <commands+0x8e0>
ffffffffc02010f4:	00004617          	auipc	a2,0x4
ffffffffc02010f8:	78460613          	addi	a2,a2,1924 # ffffffffc0205878 <commands+0x870>
ffffffffc02010fc:	0d300593          	li	a1,211
ffffffffc0201100:	00004517          	auipc	a0,0x4
ffffffffc0201104:	79050513          	addi	a0,a0,1936 # ffffffffc0205890 <commands+0x888>
ffffffffc0201108:	b48ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020110c:	00004697          	auipc	a3,0x4
ffffffffc0201110:	7fc68693          	addi	a3,a3,2044 # ffffffffc0205908 <commands+0x900>
ffffffffc0201114:	00004617          	auipc	a2,0x4
ffffffffc0201118:	76460613          	addi	a2,a2,1892 # ffffffffc0205878 <commands+0x870>
ffffffffc020111c:	0bb00593          	li	a1,187
ffffffffc0201120:	00004517          	auipc	a0,0x4
ffffffffc0201124:	77050513          	addi	a0,a0,1904 # ffffffffc0205890 <commands+0x888>
ffffffffc0201128:	b28ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(count == 0);
ffffffffc020112c:	00005697          	auipc	a3,0x5
ffffffffc0201130:	a8468693          	addi	a3,a3,-1404 # ffffffffc0205bb0 <commands+0xba8>
ffffffffc0201134:	00004617          	auipc	a2,0x4
ffffffffc0201138:	74460613          	addi	a2,a2,1860 # ffffffffc0205878 <commands+0x870>
ffffffffc020113c:	12500593          	li	a1,293
ffffffffc0201140:	00004517          	auipc	a0,0x4
ffffffffc0201144:	75050513          	addi	a0,a0,1872 # ffffffffc0205890 <commands+0x888>
ffffffffc0201148:	b08ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(nr_free == 0);
ffffffffc020114c:	00005697          	auipc	a3,0x5
ffffffffc0201150:	90468693          	addi	a3,a3,-1788 # ffffffffc0205a50 <commands+0xa48>
ffffffffc0201154:	00004617          	auipc	a2,0x4
ffffffffc0201158:	72460613          	addi	a2,a2,1828 # ffffffffc0205878 <commands+0x870>
ffffffffc020115c:	11a00593          	li	a1,282
ffffffffc0201160:	00004517          	auipc	a0,0x4
ffffffffc0201164:	73050513          	addi	a0,a0,1840 # ffffffffc0205890 <commands+0x888>
ffffffffc0201168:	ae8ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020116c:	00005697          	auipc	a3,0x5
ffffffffc0201170:	88468693          	addi	a3,a3,-1916 # ffffffffc02059f0 <commands+0x9e8>
ffffffffc0201174:	00004617          	auipc	a2,0x4
ffffffffc0201178:	70460613          	addi	a2,a2,1796 # ffffffffc0205878 <commands+0x870>
ffffffffc020117c:	11800593          	li	a1,280
ffffffffc0201180:	00004517          	auipc	a0,0x4
ffffffffc0201184:	71050513          	addi	a0,a0,1808 # ffffffffc0205890 <commands+0x888>
ffffffffc0201188:	ac8ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020118c:	00005697          	auipc	a3,0x5
ffffffffc0201190:	82468693          	addi	a3,a3,-2012 # ffffffffc02059b0 <commands+0x9a8>
ffffffffc0201194:	00004617          	auipc	a2,0x4
ffffffffc0201198:	6e460613          	addi	a2,a2,1764 # ffffffffc0205878 <commands+0x870>
ffffffffc020119c:	0c100593          	li	a1,193
ffffffffc02011a0:	00004517          	auipc	a0,0x4
ffffffffc02011a4:	6f050513          	addi	a0,a0,1776 # ffffffffc0205890 <commands+0x888>
ffffffffc02011a8:	aa8ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02011ac:	00005697          	auipc	a3,0x5
ffffffffc02011b0:	9c468693          	addi	a3,a3,-1596 # ffffffffc0205b70 <commands+0xb68>
ffffffffc02011b4:	00004617          	auipc	a2,0x4
ffffffffc02011b8:	6c460613          	addi	a2,a2,1732 # ffffffffc0205878 <commands+0x870>
ffffffffc02011bc:	11200593          	li	a1,274
ffffffffc02011c0:	00004517          	auipc	a0,0x4
ffffffffc02011c4:	6d050513          	addi	a0,a0,1744 # ffffffffc0205890 <commands+0x888>
ffffffffc02011c8:	a88ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02011cc:	00005697          	auipc	a3,0x5
ffffffffc02011d0:	98468693          	addi	a3,a3,-1660 # ffffffffc0205b50 <commands+0xb48>
ffffffffc02011d4:	00004617          	auipc	a2,0x4
ffffffffc02011d8:	6a460613          	addi	a2,a2,1700 # ffffffffc0205878 <commands+0x870>
ffffffffc02011dc:	11000593          	li	a1,272
ffffffffc02011e0:	00004517          	auipc	a0,0x4
ffffffffc02011e4:	6b050513          	addi	a0,a0,1712 # ffffffffc0205890 <commands+0x888>
ffffffffc02011e8:	a68ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02011ec:	00005697          	auipc	a3,0x5
ffffffffc02011f0:	93c68693          	addi	a3,a3,-1732 # ffffffffc0205b28 <commands+0xb20>
ffffffffc02011f4:	00004617          	auipc	a2,0x4
ffffffffc02011f8:	68460613          	addi	a2,a2,1668 # ffffffffc0205878 <commands+0x870>
ffffffffc02011fc:	10e00593          	li	a1,270
ffffffffc0201200:	00004517          	auipc	a0,0x4
ffffffffc0201204:	69050513          	addi	a0,a0,1680 # ffffffffc0205890 <commands+0x888>
ffffffffc0201208:	a48ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020120c:	00005697          	auipc	a3,0x5
ffffffffc0201210:	8f468693          	addi	a3,a3,-1804 # ffffffffc0205b00 <commands+0xaf8>
ffffffffc0201214:	00004617          	auipc	a2,0x4
ffffffffc0201218:	66460613          	addi	a2,a2,1636 # ffffffffc0205878 <commands+0x870>
ffffffffc020121c:	10d00593          	li	a1,269
ffffffffc0201220:	00004517          	auipc	a0,0x4
ffffffffc0201224:	67050513          	addi	a0,a0,1648 # ffffffffc0205890 <commands+0x888>
ffffffffc0201228:	a28ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(p0 + 2 == p1);
ffffffffc020122c:	00005697          	auipc	a3,0x5
ffffffffc0201230:	8c468693          	addi	a3,a3,-1852 # ffffffffc0205af0 <commands+0xae8>
ffffffffc0201234:	00004617          	auipc	a2,0x4
ffffffffc0201238:	64460613          	addi	a2,a2,1604 # ffffffffc0205878 <commands+0x870>
ffffffffc020123c:	10800593          	li	a1,264
ffffffffc0201240:	00004517          	auipc	a0,0x4
ffffffffc0201244:	65050513          	addi	a0,a0,1616 # ffffffffc0205890 <commands+0x888>
ffffffffc0201248:	a08ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020124c:	00004697          	auipc	a3,0x4
ffffffffc0201250:	7a468693          	addi	a3,a3,1956 # ffffffffc02059f0 <commands+0x9e8>
ffffffffc0201254:	00004617          	auipc	a2,0x4
ffffffffc0201258:	62460613          	addi	a2,a2,1572 # ffffffffc0205878 <commands+0x870>
ffffffffc020125c:	10700593          	li	a1,263
ffffffffc0201260:	00004517          	auipc	a0,0x4
ffffffffc0201264:	63050513          	addi	a0,a0,1584 # ffffffffc0205890 <commands+0x888>
ffffffffc0201268:	9e8ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020126c:	00005697          	auipc	a3,0x5
ffffffffc0201270:	86468693          	addi	a3,a3,-1948 # ffffffffc0205ad0 <commands+0xac8>
ffffffffc0201274:	00004617          	auipc	a2,0x4
ffffffffc0201278:	60460613          	addi	a2,a2,1540 # ffffffffc0205878 <commands+0x870>
ffffffffc020127c:	10600593          	li	a1,262
ffffffffc0201280:	00004517          	auipc	a0,0x4
ffffffffc0201284:	61050513          	addi	a0,a0,1552 # ffffffffc0205890 <commands+0x888>
ffffffffc0201288:	9c8ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc020128c:	00005697          	auipc	a3,0x5
ffffffffc0201290:	81468693          	addi	a3,a3,-2028 # ffffffffc0205aa0 <commands+0xa98>
ffffffffc0201294:	00004617          	auipc	a2,0x4
ffffffffc0201298:	5e460613          	addi	a2,a2,1508 # ffffffffc0205878 <commands+0x870>
ffffffffc020129c:	10500593          	li	a1,261
ffffffffc02012a0:	00004517          	auipc	a0,0x4
ffffffffc02012a4:	5f050513          	addi	a0,a0,1520 # ffffffffc0205890 <commands+0x888>
ffffffffc02012a8:	9a8ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02012ac:	00004697          	auipc	a3,0x4
ffffffffc02012b0:	7dc68693          	addi	a3,a3,2012 # ffffffffc0205a88 <commands+0xa80>
ffffffffc02012b4:	00004617          	auipc	a2,0x4
ffffffffc02012b8:	5c460613          	addi	a2,a2,1476 # ffffffffc0205878 <commands+0x870>
ffffffffc02012bc:	10400593          	li	a1,260
ffffffffc02012c0:	00004517          	auipc	a0,0x4
ffffffffc02012c4:	5d050513          	addi	a0,a0,1488 # ffffffffc0205890 <commands+0x888>
ffffffffc02012c8:	988ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02012cc:	00004697          	auipc	a3,0x4
ffffffffc02012d0:	72468693          	addi	a3,a3,1828 # ffffffffc02059f0 <commands+0x9e8>
ffffffffc02012d4:	00004617          	auipc	a2,0x4
ffffffffc02012d8:	5a460613          	addi	a2,a2,1444 # ffffffffc0205878 <commands+0x870>
ffffffffc02012dc:	0fe00593          	li	a1,254
ffffffffc02012e0:	00004517          	auipc	a0,0x4
ffffffffc02012e4:	5b050513          	addi	a0,a0,1456 # ffffffffc0205890 <commands+0x888>
ffffffffc02012e8:	968ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(!PageProperty(p0));
ffffffffc02012ec:	00004697          	auipc	a3,0x4
ffffffffc02012f0:	78468693          	addi	a3,a3,1924 # ffffffffc0205a70 <commands+0xa68>
ffffffffc02012f4:	00004617          	auipc	a2,0x4
ffffffffc02012f8:	58460613          	addi	a2,a2,1412 # ffffffffc0205878 <commands+0x870>
ffffffffc02012fc:	0f900593          	li	a1,249
ffffffffc0201300:	00004517          	auipc	a0,0x4
ffffffffc0201304:	59050513          	addi	a0,a0,1424 # ffffffffc0205890 <commands+0x888>
ffffffffc0201308:	948ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020130c:	00005697          	auipc	a3,0x5
ffffffffc0201310:	88468693          	addi	a3,a3,-1916 # ffffffffc0205b90 <commands+0xb88>
ffffffffc0201314:	00004617          	auipc	a2,0x4
ffffffffc0201318:	56460613          	addi	a2,a2,1380 # ffffffffc0205878 <commands+0x870>
ffffffffc020131c:	11700593          	li	a1,279
ffffffffc0201320:	00004517          	auipc	a0,0x4
ffffffffc0201324:	57050513          	addi	a0,a0,1392 # ffffffffc0205890 <commands+0x888>
ffffffffc0201328:	928ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(total == 0);
ffffffffc020132c:	00005697          	auipc	a3,0x5
ffffffffc0201330:	89468693          	addi	a3,a3,-1900 # ffffffffc0205bc0 <commands+0xbb8>
ffffffffc0201334:	00004617          	auipc	a2,0x4
ffffffffc0201338:	54460613          	addi	a2,a2,1348 # ffffffffc0205878 <commands+0x870>
ffffffffc020133c:	12600593          	li	a1,294
ffffffffc0201340:	00004517          	auipc	a0,0x4
ffffffffc0201344:	55050513          	addi	a0,a0,1360 # ffffffffc0205890 <commands+0x888>
ffffffffc0201348:	908ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(total == nr_free_pages());
ffffffffc020134c:	00004697          	auipc	a3,0x4
ffffffffc0201350:	55c68693          	addi	a3,a3,1372 # ffffffffc02058a8 <commands+0x8a0>
ffffffffc0201354:	00004617          	auipc	a2,0x4
ffffffffc0201358:	52460613          	addi	a2,a2,1316 # ffffffffc0205878 <commands+0x870>
ffffffffc020135c:	0f300593          	li	a1,243
ffffffffc0201360:	00004517          	auipc	a0,0x4
ffffffffc0201364:	53050513          	addi	a0,a0,1328 # ffffffffc0205890 <commands+0x888>
ffffffffc0201368:	8e8ff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020136c:	00004697          	auipc	a3,0x4
ffffffffc0201370:	57c68693          	addi	a3,a3,1404 # ffffffffc02058e8 <commands+0x8e0>
ffffffffc0201374:	00004617          	auipc	a2,0x4
ffffffffc0201378:	50460613          	addi	a2,a2,1284 # ffffffffc0205878 <commands+0x870>
ffffffffc020137c:	0ba00593          	li	a1,186
ffffffffc0201380:	00004517          	auipc	a0,0x4
ffffffffc0201384:	51050513          	addi	a0,a0,1296 # ffffffffc0205890 <commands+0x888>
ffffffffc0201388:	8c8ff0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc020138c <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc020138c:	1141                	addi	sp,sp,-16
ffffffffc020138e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201390:	16058e63          	beqz	a1,ffffffffc020150c <default_free_pages+0x180>
    for (; p != base + n; p ++) {
ffffffffc0201394:	00659693          	slli	a3,a1,0x6
ffffffffc0201398:	96aa                	add	a3,a3,a0
ffffffffc020139a:	02d50d63          	beq	a0,a3,ffffffffc02013d4 <default_free_pages+0x48>
ffffffffc020139e:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02013a0:	8b85                	andi	a5,a5,1
ffffffffc02013a2:	14079563          	bnez	a5,ffffffffc02014ec <default_free_pages+0x160>
ffffffffc02013a6:	651c                	ld	a5,8(a0)
ffffffffc02013a8:	8385                	srli	a5,a5,0x1
ffffffffc02013aa:	8b85                	andi	a5,a5,1
ffffffffc02013ac:	14079063          	bnez	a5,ffffffffc02014ec <default_free_pages+0x160>
ffffffffc02013b0:	87aa                	mv	a5,a0
ffffffffc02013b2:	a809                	j	ffffffffc02013c4 <default_free_pages+0x38>
ffffffffc02013b4:	6798                	ld	a4,8(a5)
ffffffffc02013b6:	8b05                	andi	a4,a4,1
ffffffffc02013b8:	12071a63          	bnez	a4,ffffffffc02014ec <default_free_pages+0x160>
ffffffffc02013bc:	6798                	ld	a4,8(a5)
ffffffffc02013be:	8b09                	andi	a4,a4,2
ffffffffc02013c0:	12071663          	bnez	a4,ffffffffc02014ec <default_free_pages+0x160>
        p->flags = 0;
ffffffffc02013c4:	0007b423          	sd	zero,8(a5)
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc02013c8:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02013cc:	04078793          	addi	a5,a5,64
ffffffffc02013d0:	fed792e3          	bne	a5,a3,ffffffffc02013b4 <default_free_pages+0x28>
    base->property = n;
ffffffffc02013d4:	2581                	sext.w	a1,a1
ffffffffc02013d6:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02013d8:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02013dc:	4789                	li	a5,2
ffffffffc02013de:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02013e2:	00014697          	auipc	a3,0x14
ffffffffc02013e6:	0ee68693          	addi	a3,a3,238 # ffffffffc02154d0 <free_area>
ffffffffc02013ea:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02013ec:	669c                	ld	a5,8(a3)
ffffffffc02013ee:	9db9                	addw	a1,a1,a4
ffffffffc02013f0:	00014717          	auipc	a4,0x14
ffffffffc02013f4:	0eb72823          	sw	a1,240(a4) # ffffffffc02154e0 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02013f8:	0cd78163          	beq	a5,a3,ffffffffc02014ba <default_free_pages+0x12e>
            struct Page* page = le2page(le, page_link);
ffffffffc02013fc:	fe878713          	addi	a4,a5,-24
ffffffffc0201400:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201402:	4801                	li	a6,0
ffffffffc0201404:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0201408:	00e56a63          	bltu	a0,a4,ffffffffc020141c <default_free_pages+0x90>
    return listelm->next;
ffffffffc020140c:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020140e:	04d70f63          	beq	a4,a3,ffffffffc020146c <default_free_pages+0xe0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201412:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201414:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201418:	fee57ae3          	bleu	a4,a0,ffffffffc020140c <default_free_pages+0x80>
ffffffffc020141c:	00080663          	beqz	a6,ffffffffc0201428 <default_free_pages+0x9c>
ffffffffc0201420:	00014817          	auipc	a6,0x14
ffffffffc0201424:	0ab83823          	sd	a1,176(a6) # ffffffffc02154d0 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201428:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc020142a:	e390                	sd	a2,0(a5)
ffffffffc020142c:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc020142e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201430:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc0201432:	06d58a63          	beq	a1,a3,ffffffffc02014a6 <default_free_pages+0x11a>
        if (p + p->property == base) {
ffffffffc0201436:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc020143a:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc020143e:	02061793          	slli	a5,a2,0x20
ffffffffc0201442:	83e9                	srli	a5,a5,0x1a
ffffffffc0201444:	97ba                	add	a5,a5,a4
ffffffffc0201446:	04f51b63          	bne	a0,a5,ffffffffc020149c <default_free_pages+0x110>
            p->property += base->property;
ffffffffc020144a:	491c                	lw	a5,16(a0)
ffffffffc020144c:	9e3d                	addw	a2,a2,a5
ffffffffc020144e:	fec5ac23          	sw	a2,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201452:	57f5                	li	a5,-3
ffffffffc0201454:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201458:	01853803          	ld	a6,24(a0)
ffffffffc020145c:	7110                	ld	a2,32(a0)
            base = p;
ffffffffc020145e:	853a                	mv	a0,a4
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201460:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc0201464:	659c                	ld	a5,8(a1)
ffffffffc0201466:	01063023          	sd	a6,0(a2)
ffffffffc020146a:	a815                	j	ffffffffc020149e <default_free_pages+0x112>
    prev->next = next->prev = elm;
ffffffffc020146c:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020146e:	f114                	sd	a3,32(a0)
ffffffffc0201470:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201472:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201474:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201476:	00d70563          	beq	a4,a3,ffffffffc0201480 <default_free_pages+0xf4>
ffffffffc020147a:	4805                	li	a6,1
ffffffffc020147c:	87ba                	mv	a5,a4
ffffffffc020147e:	bf59                	j	ffffffffc0201414 <default_free_pages+0x88>
ffffffffc0201480:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc0201482:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc0201484:	00d78d63          	beq	a5,a3,ffffffffc020149e <default_free_pages+0x112>
        if (p + p->property == base) {
ffffffffc0201488:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc020148c:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc0201490:	02061793          	slli	a5,a2,0x20
ffffffffc0201494:	83e9                	srli	a5,a5,0x1a
ffffffffc0201496:	97ba                	add	a5,a5,a4
ffffffffc0201498:	faf509e3          	beq	a0,a5,ffffffffc020144a <default_free_pages+0xbe>
ffffffffc020149c:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc020149e:	fe878713          	addi	a4,a5,-24
ffffffffc02014a2:	00d78963          	beq	a5,a3,ffffffffc02014b4 <default_free_pages+0x128>
        if (base + base->property == p) {
ffffffffc02014a6:	4910                	lw	a2,16(a0)
ffffffffc02014a8:	02061693          	slli	a3,a2,0x20
ffffffffc02014ac:	82e9                	srli	a3,a3,0x1a
ffffffffc02014ae:	96aa                	add	a3,a3,a0
ffffffffc02014b0:	00d70e63          	beq	a4,a3,ffffffffc02014cc <default_free_pages+0x140>
}
ffffffffc02014b4:	60a2                	ld	ra,8(sp)
ffffffffc02014b6:	0141                	addi	sp,sp,16
ffffffffc02014b8:	8082                	ret
ffffffffc02014ba:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02014bc:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc02014c0:	e398                	sd	a4,0(a5)
ffffffffc02014c2:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02014c4:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02014c6:	ed1c                	sd	a5,24(a0)
}
ffffffffc02014c8:	0141                	addi	sp,sp,16
ffffffffc02014ca:	8082                	ret
            base->property += p->property;
ffffffffc02014cc:	ff87a703          	lw	a4,-8(a5)
ffffffffc02014d0:	ff078693          	addi	a3,a5,-16
ffffffffc02014d4:	9e39                	addw	a2,a2,a4
ffffffffc02014d6:	c910                	sw	a2,16(a0)
ffffffffc02014d8:	5775                	li	a4,-3
ffffffffc02014da:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02014de:	6398                	ld	a4,0(a5)
ffffffffc02014e0:	679c                	ld	a5,8(a5)
}
ffffffffc02014e2:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02014e4:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02014e6:	e398                	sd	a4,0(a5)
ffffffffc02014e8:	0141                	addi	sp,sp,16
ffffffffc02014ea:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02014ec:	00004697          	auipc	a3,0x4
ffffffffc02014f0:	6e468693          	addi	a3,a3,1764 # ffffffffc0205bd0 <commands+0xbc8>
ffffffffc02014f4:	00004617          	auipc	a2,0x4
ffffffffc02014f8:	38460613          	addi	a2,a2,900 # ffffffffc0205878 <commands+0x870>
ffffffffc02014fc:	08300593          	li	a1,131
ffffffffc0201500:	00004517          	auipc	a0,0x4
ffffffffc0201504:	39050513          	addi	a0,a0,912 # ffffffffc0205890 <commands+0x888>
ffffffffc0201508:	f49fe0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(n > 0);
ffffffffc020150c:	00004697          	auipc	a3,0x4
ffffffffc0201510:	6ec68693          	addi	a3,a3,1772 # ffffffffc0205bf8 <commands+0xbf0>
ffffffffc0201514:	00004617          	auipc	a2,0x4
ffffffffc0201518:	36460613          	addi	a2,a2,868 # ffffffffc0205878 <commands+0x870>
ffffffffc020151c:	08000593          	li	a1,128
ffffffffc0201520:	00004517          	auipc	a0,0x4
ffffffffc0201524:	37050513          	addi	a0,a0,880 # ffffffffc0205890 <commands+0x888>
ffffffffc0201528:	f29fe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc020152c <default_alloc_pages>:
    assert(n > 0);
ffffffffc020152c:	c959                	beqz	a0,ffffffffc02015c2 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc020152e:	00014597          	auipc	a1,0x14
ffffffffc0201532:	fa258593          	addi	a1,a1,-94 # ffffffffc02154d0 <free_area>
ffffffffc0201536:	0105a803          	lw	a6,16(a1)
ffffffffc020153a:	862a                	mv	a2,a0
ffffffffc020153c:	02081793          	slli	a5,a6,0x20
ffffffffc0201540:	9381                	srli	a5,a5,0x20
ffffffffc0201542:	00a7ee63          	bltu	a5,a0,ffffffffc020155e <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0201546:	87ae                	mv	a5,a1
ffffffffc0201548:	a801                	j	ffffffffc0201558 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc020154a:	ff87a703          	lw	a4,-8(a5)
ffffffffc020154e:	02071693          	slli	a3,a4,0x20
ffffffffc0201552:	9281                	srli	a3,a3,0x20
ffffffffc0201554:	00c6f763          	bleu	a2,a3,ffffffffc0201562 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201558:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc020155a:	feb798e3          	bne	a5,a1,ffffffffc020154a <default_alloc_pages+0x1e>
        return NULL;
ffffffffc020155e:	4501                	li	a0,0
}
ffffffffc0201560:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc0201562:	fe878513          	addi	a0,a5,-24
    if (page != NULL) {
ffffffffc0201566:	dd6d                	beqz	a0,ffffffffc0201560 <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc0201568:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc020156c:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc0201570:	00060e1b          	sext.w	t3,a2
ffffffffc0201574:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201578:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc020157c:	02d67863          	bleu	a3,a2,ffffffffc02015ac <default_alloc_pages+0x80>
            struct Page *p = page + n;
ffffffffc0201580:	061a                	slli	a2,a2,0x6
ffffffffc0201582:	962a                	add	a2,a2,a0
            p->property = page->property - n;
ffffffffc0201584:	41c7073b          	subw	a4,a4,t3
ffffffffc0201588:	ca18                	sw	a4,16(a2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020158a:	00860693          	addi	a3,a2,8
ffffffffc020158e:	4709                	li	a4,2
ffffffffc0201590:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201594:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0201598:	01860693          	addi	a3,a2,24
    prev->next = next->prev = elm;
ffffffffc020159c:	0105a803          	lw	a6,16(a1)
ffffffffc02015a0:	e314                	sd	a3,0(a4)
ffffffffc02015a2:	00d8b423          	sd	a3,8(a7)
    elm->next = next;
ffffffffc02015a6:	f218                	sd	a4,32(a2)
    elm->prev = prev;
ffffffffc02015a8:	01163c23          	sd	a7,24(a2)
        nr_free -= n;
ffffffffc02015ac:	41c8083b          	subw	a6,a6,t3
ffffffffc02015b0:	00014717          	auipc	a4,0x14
ffffffffc02015b4:	f3072823          	sw	a6,-208(a4) # ffffffffc02154e0 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02015b8:	5775                	li	a4,-3
ffffffffc02015ba:	17c1                	addi	a5,a5,-16
ffffffffc02015bc:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc02015c0:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc02015c2:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02015c4:	00004697          	auipc	a3,0x4
ffffffffc02015c8:	63468693          	addi	a3,a3,1588 # ffffffffc0205bf8 <commands+0xbf0>
ffffffffc02015cc:	00004617          	auipc	a2,0x4
ffffffffc02015d0:	2ac60613          	addi	a2,a2,684 # ffffffffc0205878 <commands+0x870>
ffffffffc02015d4:	06200593          	li	a1,98
ffffffffc02015d8:	00004517          	auipc	a0,0x4
ffffffffc02015dc:	2b850513          	addi	a0,a0,696 # ffffffffc0205890 <commands+0x888>
default_alloc_pages(size_t n) {
ffffffffc02015e0:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02015e2:	e6ffe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02015e6 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02015e6:	1141                	addi	sp,sp,-16
ffffffffc02015e8:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02015ea:	c1ed                	beqz	a1,ffffffffc02016cc <default_init_memmap+0xe6>
    for (; p != base + n; p ++) {
ffffffffc02015ec:	00659693          	slli	a3,a1,0x6
ffffffffc02015f0:	96aa                	add	a3,a3,a0
ffffffffc02015f2:	02d50463          	beq	a0,a3,ffffffffc020161a <default_init_memmap+0x34>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02015f6:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc02015f8:	87aa                	mv	a5,a0
ffffffffc02015fa:	8b05                	andi	a4,a4,1
ffffffffc02015fc:	e709                	bnez	a4,ffffffffc0201606 <default_init_memmap+0x20>
ffffffffc02015fe:	a07d                	j	ffffffffc02016ac <default_init_memmap+0xc6>
ffffffffc0201600:	6798                	ld	a4,8(a5)
ffffffffc0201602:	8b05                	andi	a4,a4,1
ffffffffc0201604:	c745                	beqz	a4,ffffffffc02016ac <default_init_memmap+0xc6>
        p->flags = p->property = 0;
ffffffffc0201606:	0007a823          	sw	zero,16(a5)
ffffffffc020160a:	0007b423          	sd	zero,8(a5)
ffffffffc020160e:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201612:	04078793          	addi	a5,a5,64
ffffffffc0201616:	fed795e3          	bne	a5,a3,ffffffffc0201600 <default_init_memmap+0x1a>
    base->property = n;
ffffffffc020161a:	2581                	sext.w	a1,a1
ffffffffc020161c:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020161e:	4789                	li	a5,2
ffffffffc0201620:	00850713          	addi	a4,a0,8
ffffffffc0201624:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201628:	00014697          	auipc	a3,0x14
ffffffffc020162c:	ea868693          	addi	a3,a3,-344 # ffffffffc02154d0 <free_area>
ffffffffc0201630:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201632:	669c                	ld	a5,8(a3)
ffffffffc0201634:	9db9                	addw	a1,a1,a4
ffffffffc0201636:	00014717          	auipc	a4,0x14
ffffffffc020163a:	eab72523          	sw	a1,-342(a4) # ffffffffc02154e0 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc020163e:	04d78a63          	beq	a5,a3,ffffffffc0201692 <default_init_memmap+0xac>
            struct Page* page = le2page(le, page_link);
ffffffffc0201642:	fe878713          	addi	a4,a5,-24
ffffffffc0201646:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201648:	4801                	li	a6,0
ffffffffc020164a:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc020164e:	00e56a63          	bltu	a0,a4,ffffffffc0201662 <default_init_memmap+0x7c>
    return listelm->next;
ffffffffc0201652:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201654:	02d70563          	beq	a4,a3,ffffffffc020167e <default_init_memmap+0x98>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201658:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020165a:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020165e:	fee57ae3          	bleu	a4,a0,ffffffffc0201652 <default_init_memmap+0x6c>
ffffffffc0201662:	00080663          	beqz	a6,ffffffffc020166e <default_init_memmap+0x88>
ffffffffc0201666:	00014717          	auipc	a4,0x14
ffffffffc020166a:	e6b73523          	sd	a1,-406(a4) # ffffffffc02154d0 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc020166e:	6398                	ld	a4,0(a5)
}
ffffffffc0201670:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201672:	e390                	sd	a2,0(a5)
ffffffffc0201674:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201676:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201678:	ed18                	sd	a4,24(a0)
ffffffffc020167a:	0141                	addi	sp,sp,16
ffffffffc020167c:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020167e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201680:	f114                	sd	a3,32(a0)
ffffffffc0201682:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201684:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201686:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201688:	00d70e63          	beq	a4,a3,ffffffffc02016a4 <default_init_memmap+0xbe>
ffffffffc020168c:	4805                	li	a6,1
ffffffffc020168e:	87ba                	mv	a5,a4
ffffffffc0201690:	b7e9                	j	ffffffffc020165a <default_init_memmap+0x74>
}
ffffffffc0201692:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201694:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201698:	e398                	sd	a4,0(a5)
ffffffffc020169a:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020169c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020169e:	ed1c                	sd	a5,24(a0)
}
ffffffffc02016a0:	0141                	addi	sp,sp,16
ffffffffc02016a2:	8082                	ret
ffffffffc02016a4:	60a2                	ld	ra,8(sp)
ffffffffc02016a6:	e290                	sd	a2,0(a3)
ffffffffc02016a8:	0141                	addi	sp,sp,16
ffffffffc02016aa:	8082                	ret
        assert(PageReserved(p));
ffffffffc02016ac:	00004697          	auipc	a3,0x4
ffffffffc02016b0:	55468693          	addi	a3,a3,1364 # ffffffffc0205c00 <commands+0xbf8>
ffffffffc02016b4:	00004617          	auipc	a2,0x4
ffffffffc02016b8:	1c460613          	addi	a2,a2,452 # ffffffffc0205878 <commands+0x870>
ffffffffc02016bc:	04900593          	li	a1,73
ffffffffc02016c0:	00004517          	auipc	a0,0x4
ffffffffc02016c4:	1d050513          	addi	a0,a0,464 # ffffffffc0205890 <commands+0x888>
ffffffffc02016c8:	d89fe0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(n > 0);
ffffffffc02016cc:	00004697          	auipc	a3,0x4
ffffffffc02016d0:	52c68693          	addi	a3,a3,1324 # ffffffffc0205bf8 <commands+0xbf0>
ffffffffc02016d4:	00004617          	auipc	a2,0x4
ffffffffc02016d8:	1a460613          	addi	a2,a2,420 # ffffffffc0205878 <commands+0x870>
ffffffffc02016dc:	04600593          	li	a1,70
ffffffffc02016e0:	00004517          	auipc	a0,0x4
ffffffffc02016e4:	1b050513          	addi	a0,a0,432 # ffffffffc0205890 <commands+0x888>
ffffffffc02016e8:	d69fe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02016ec <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc02016ec:	c125                	beqz	a0,ffffffffc020174c <slob_free+0x60>
		return;

	if (size)
ffffffffc02016ee:	e1a5                	bnez	a1,ffffffffc020174e <slob_free+0x62>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02016f0:	100027f3          	csrr	a5,sstatus
ffffffffc02016f4:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02016f6:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02016f8:	e3bd                	bnez	a5,ffffffffc020175e <slob_free+0x72>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02016fa:	00009797          	auipc	a5,0x9
ffffffffc02016fe:	95678793          	addi	a5,a5,-1706 # ffffffffc020a050 <slobfree>
ffffffffc0201702:	639c                	ld	a5,0(a5)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201704:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201706:	00a7fa63          	bleu	a0,a5,ffffffffc020171a <slob_free+0x2e>
ffffffffc020170a:	00e56c63          	bltu	a0,a4,ffffffffc0201722 <slob_free+0x36>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020170e:	00e7fa63          	bleu	a4,a5,ffffffffc0201722 <slob_free+0x36>
    return 0;
ffffffffc0201712:	87ba                	mv	a5,a4
ffffffffc0201714:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201716:	fea7eae3          	bltu	a5,a0,ffffffffc020170a <slob_free+0x1e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020171a:	fee7ece3          	bltu	a5,a4,ffffffffc0201712 <slob_free+0x26>
ffffffffc020171e:	fee57ae3          	bleu	a4,a0,ffffffffc0201712 <slob_free+0x26>
			break;

	if (b + b->units == cur->next) {
ffffffffc0201722:	4110                	lw	a2,0(a0)
ffffffffc0201724:	00461693          	slli	a3,a2,0x4
ffffffffc0201728:	96aa                	add	a3,a3,a0
ffffffffc020172a:	08d70b63          	beq	a4,a3,ffffffffc02017c0 <slob_free+0xd4>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc020172e:	4394                	lw	a3,0(a5)
		b->next = cur->next;
ffffffffc0201730:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201732:	00469713          	slli	a4,a3,0x4
ffffffffc0201736:	973e                	add	a4,a4,a5
ffffffffc0201738:	08e50f63          	beq	a0,a4,ffffffffc02017d6 <slob_free+0xea>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc020173c:	e788                	sd	a0,8(a5)

	slobfree = cur;
ffffffffc020173e:	00009717          	auipc	a4,0x9
ffffffffc0201742:	90f73923          	sd	a5,-1774(a4) # ffffffffc020a050 <slobfree>
    if (flag) {
ffffffffc0201746:	c199                	beqz	a1,ffffffffc020174c <slob_free+0x60>
        intr_enable();
ffffffffc0201748:	e8bfe06f          	j	ffffffffc02005d2 <intr_enable>
ffffffffc020174c:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc020174e:	05bd                	addi	a1,a1,15
ffffffffc0201750:	8191                	srli	a1,a1,0x4
ffffffffc0201752:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201754:	100027f3          	csrr	a5,sstatus
ffffffffc0201758:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020175a:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020175c:	dfd9                	beqz	a5,ffffffffc02016fa <slob_free+0xe>
{
ffffffffc020175e:	1101                	addi	sp,sp,-32
ffffffffc0201760:	e42a                	sd	a0,8(sp)
ffffffffc0201762:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0201764:	e75fe0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201768:	00009797          	auipc	a5,0x9
ffffffffc020176c:	8e878793          	addi	a5,a5,-1816 # ffffffffc020a050 <slobfree>
ffffffffc0201770:	639c                	ld	a5,0(a5)
        return 1;
ffffffffc0201772:	6522                	ld	a0,8(sp)
ffffffffc0201774:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201776:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201778:	00a7fa63          	bleu	a0,a5,ffffffffc020178c <slob_free+0xa0>
ffffffffc020177c:	00e56c63          	bltu	a0,a4,ffffffffc0201794 <slob_free+0xa8>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201780:	00e7fa63          	bleu	a4,a5,ffffffffc0201794 <slob_free+0xa8>
    return 0;
ffffffffc0201784:	87ba                	mv	a5,a4
ffffffffc0201786:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201788:	fea7eae3          	bltu	a5,a0,ffffffffc020177c <slob_free+0x90>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020178c:	fee7ece3          	bltu	a5,a4,ffffffffc0201784 <slob_free+0x98>
ffffffffc0201790:	fee57ae3          	bleu	a4,a0,ffffffffc0201784 <slob_free+0x98>
	if (b + b->units == cur->next) {
ffffffffc0201794:	4110                	lw	a2,0(a0)
ffffffffc0201796:	00461693          	slli	a3,a2,0x4
ffffffffc020179a:	96aa                	add	a3,a3,a0
ffffffffc020179c:	04d70763          	beq	a4,a3,ffffffffc02017ea <slob_free+0xfe>
		b->next = cur->next;
ffffffffc02017a0:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc02017a2:	4394                	lw	a3,0(a5)
ffffffffc02017a4:	00469713          	slli	a4,a3,0x4
ffffffffc02017a8:	973e                	add	a4,a4,a5
ffffffffc02017aa:	04e50663          	beq	a0,a4,ffffffffc02017f6 <slob_free+0x10a>
		cur->next = b;
ffffffffc02017ae:	e788                	sd	a0,8(a5)
	slobfree = cur;
ffffffffc02017b0:	00009717          	auipc	a4,0x9
ffffffffc02017b4:	8af73023          	sd	a5,-1888(a4) # ffffffffc020a050 <slobfree>
    if (flag) {
ffffffffc02017b8:	e58d                	bnez	a1,ffffffffc02017e2 <slob_free+0xf6>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc02017ba:	60e2                	ld	ra,24(sp)
ffffffffc02017bc:	6105                	addi	sp,sp,32
ffffffffc02017be:	8082                	ret
		b->units += cur->next->units;
ffffffffc02017c0:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc02017c2:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc02017c4:	9e35                	addw	a2,a2,a3
ffffffffc02017c6:	c110                	sw	a2,0(a0)
	if (cur + cur->units == b) {
ffffffffc02017c8:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc02017ca:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc02017cc:	00469713          	slli	a4,a3,0x4
ffffffffc02017d0:	973e                	add	a4,a4,a5
ffffffffc02017d2:	f6e515e3          	bne	a0,a4,ffffffffc020173c <slob_free+0x50>
		cur->units += b->units;
ffffffffc02017d6:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc02017d8:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc02017da:	9eb9                	addw	a3,a3,a4
ffffffffc02017dc:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc02017de:	e790                	sd	a2,8(a5)
ffffffffc02017e0:	bfb9                	j	ffffffffc020173e <slob_free+0x52>
}
ffffffffc02017e2:	60e2                	ld	ra,24(sp)
ffffffffc02017e4:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02017e6:	dedfe06f          	j	ffffffffc02005d2 <intr_enable>
		b->units += cur->next->units;
ffffffffc02017ea:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc02017ec:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc02017ee:	9e35                	addw	a2,a2,a3
ffffffffc02017f0:	c110                	sw	a2,0(a0)
		b->next = cur->next->next;
ffffffffc02017f2:	e518                	sd	a4,8(a0)
ffffffffc02017f4:	b77d                	j	ffffffffc02017a2 <slob_free+0xb6>
		cur->units += b->units;
ffffffffc02017f6:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc02017f8:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc02017fa:	9eb9                	addw	a3,a3,a4
ffffffffc02017fc:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc02017fe:	e790                	sd	a2,8(a5)
ffffffffc0201800:	bf45                	j	ffffffffc02017b0 <slob_free+0xc4>

ffffffffc0201802 <__slob_get_free_pages.isra.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201802:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201804:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201806:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc020180a:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc020180c:	38a000ef          	jal	ra,ffffffffc0201b96 <alloc_pages>
  if(!page)
ffffffffc0201810:	c139                	beqz	a0,ffffffffc0201856 <__slob_get_free_pages.isra.0+0x54>
    return page - pages + nbase;
ffffffffc0201812:	00014797          	auipc	a5,0x14
ffffffffc0201816:	cee78793          	addi	a5,a5,-786 # ffffffffc0215500 <pages>
ffffffffc020181a:	6394                	ld	a3,0(a5)
ffffffffc020181c:	00005797          	auipc	a5,0x5
ffffffffc0201820:	79c78793          	addi	a5,a5,1948 # ffffffffc0206fb8 <nbase>
    return KADDR(page2pa(page));
ffffffffc0201824:	00014717          	auipc	a4,0x14
ffffffffc0201828:	c6c70713          	addi	a4,a4,-916 # ffffffffc0215490 <npage>
    return page - pages + nbase;
ffffffffc020182c:	40d506b3          	sub	a3,a0,a3
ffffffffc0201830:	6388                	ld	a0,0(a5)
ffffffffc0201832:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0201834:	57fd                	li	a5,-1
ffffffffc0201836:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0201838:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc020183a:	83b1                	srli	a5,a5,0xc
ffffffffc020183c:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc020183e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201840:	00e7ff63          	bleu	a4,a5,ffffffffc020185e <__slob_get_free_pages.isra.0+0x5c>
ffffffffc0201844:	00014797          	auipc	a5,0x14
ffffffffc0201848:	cac78793          	addi	a5,a5,-852 # ffffffffc02154f0 <va_pa_offset>
ffffffffc020184c:	6388                	ld	a0,0(a5)
}
ffffffffc020184e:	60a2                	ld	ra,8(sp)
ffffffffc0201850:	9536                	add	a0,a0,a3
ffffffffc0201852:	0141                	addi	sp,sp,16
ffffffffc0201854:	8082                	ret
ffffffffc0201856:	60a2                	ld	ra,8(sp)
    return NULL;
ffffffffc0201858:	4501                	li	a0,0
}
ffffffffc020185a:	0141                	addi	sp,sp,16
ffffffffc020185c:	8082                	ret
ffffffffc020185e:	00004617          	auipc	a2,0x4
ffffffffc0201862:	40260613          	addi	a2,a2,1026 # ffffffffc0205c60 <default_pmm_manager+0x50>
ffffffffc0201866:	06900593          	li	a1,105
ffffffffc020186a:	00004517          	auipc	a0,0x4
ffffffffc020186e:	41e50513          	addi	a0,a0,1054 # ffffffffc0205c88 <default_pmm_manager+0x78>
ffffffffc0201872:	bdffe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0201876 <slob_alloc.isra.1.constprop.3>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201876:	7179                	addi	sp,sp,-48
ffffffffc0201878:	f406                	sd	ra,40(sp)
ffffffffc020187a:	f022                	sd	s0,32(sp)
ffffffffc020187c:	ec26                	sd	s1,24(sp)
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc020187e:	01050713          	addi	a4,a0,16
ffffffffc0201882:	6785                	lui	a5,0x1
ffffffffc0201884:	0cf77b63          	bleu	a5,a4,ffffffffc020195a <slob_alloc.isra.1.constprop.3+0xe4>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201888:	00f50413          	addi	s0,a0,15
ffffffffc020188c:	8011                	srli	s0,s0,0x4
ffffffffc020188e:	2401                	sext.w	s0,s0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201890:	10002673          	csrr	a2,sstatus
ffffffffc0201894:	8a09                	andi	a2,a2,2
ffffffffc0201896:	ea5d                	bnez	a2,ffffffffc020194c <slob_alloc.isra.1.constprop.3+0xd6>
	prev = slobfree;
ffffffffc0201898:	00008497          	auipc	s1,0x8
ffffffffc020189c:	7b848493          	addi	s1,s1,1976 # ffffffffc020a050 <slobfree>
ffffffffc02018a0:	6094                	ld	a3,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02018a2:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02018a4:	4398                	lw	a4,0(a5)
ffffffffc02018a6:	0a875763          	ble	s0,a4,ffffffffc0201954 <slob_alloc.isra.1.constprop.3+0xde>
		if (cur == slobfree) {
ffffffffc02018aa:	00f68a63          	beq	a3,a5,ffffffffc02018be <slob_alloc.isra.1.constprop.3+0x48>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02018ae:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02018b0:	4118                	lw	a4,0(a0)
ffffffffc02018b2:	02875763          	ble	s0,a4,ffffffffc02018e0 <slob_alloc.isra.1.constprop.3+0x6a>
ffffffffc02018b6:	6094                	ld	a3,0(s1)
ffffffffc02018b8:	87aa                	mv	a5,a0
		if (cur == slobfree) {
ffffffffc02018ba:	fef69ae3          	bne	a3,a5,ffffffffc02018ae <slob_alloc.isra.1.constprop.3+0x38>
    if (flag) {
ffffffffc02018be:	ea39                	bnez	a2,ffffffffc0201914 <slob_alloc.isra.1.constprop.3+0x9e>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc02018c0:	4501                	li	a0,0
ffffffffc02018c2:	f41ff0ef          	jal	ra,ffffffffc0201802 <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc02018c6:	cd29                	beqz	a0,ffffffffc0201920 <slob_alloc.isra.1.constprop.3+0xaa>
			slob_free(cur, PAGE_SIZE);
ffffffffc02018c8:	6585                	lui	a1,0x1
ffffffffc02018ca:	e23ff0ef          	jal	ra,ffffffffc02016ec <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02018ce:	10002673          	csrr	a2,sstatus
ffffffffc02018d2:	8a09                	andi	a2,a2,2
ffffffffc02018d4:	ea1d                	bnez	a2,ffffffffc020190a <slob_alloc.isra.1.constprop.3+0x94>
			cur = slobfree;
ffffffffc02018d6:	609c                	ld	a5,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02018d8:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02018da:	4118                	lw	a4,0(a0)
ffffffffc02018dc:	fc874de3          	blt	a4,s0,ffffffffc02018b6 <slob_alloc.isra.1.constprop.3+0x40>
			if (cur->units == units) /* exact fit? */
ffffffffc02018e0:	04e40663          	beq	s0,a4,ffffffffc020192c <slob_alloc.isra.1.constprop.3+0xb6>
				prev->next = cur + units;
ffffffffc02018e4:	00441693          	slli	a3,s0,0x4
ffffffffc02018e8:	96aa                	add	a3,a3,a0
ffffffffc02018ea:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc02018ec:	650c                	ld	a1,8(a0)
				prev->next->units = cur->units - units;
ffffffffc02018ee:	9f01                	subw	a4,a4,s0
ffffffffc02018f0:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc02018f2:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc02018f4:	c100                	sw	s0,0(a0)
			slobfree = prev;
ffffffffc02018f6:	00008717          	auipc	a4,0x8
ffffffffc02018fa:	74f73d23          	sd	a5,1882(a4) # ffffffffc020a050 <slobfree>
    if (flag) {
ffffffffc02018fe:	ee15                	bnez	a2,ffffffffc020193a <slob_alloc.isra.1.constprop.3+0xc4>
}
ffffffffc0201900:	70a2                	ld	ra,40(sp)
ffffffffc0201902:	7402                	ld	s0,32(sp)
ffffffffc0201904:	64e2                	ld	s1,24(sp)
ffffffffc0201906:	6145                	addi	sp,sp,48
ffffffffc0201908:	8082                	ret
        intr_disable();
ffffffffc020190a:	ccffe0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
ffffffffc020190e:	4605                	li	a2,1
			cur = slobfree;
ffffffffc0201910:	609c                	ld	a5,0(s1)
ffffffffc0201912:	b7d9                	j	ffffffffc02018d8 <slob_alloc.isra.1.constprop.3+0x62>
        intr_enable();
ffffffffc0201914:	cbffe0ef          	jal	ra,ffffffffc02005d2 <intr_enable>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201918:	4501                	li	a0,0
ffffffffc020191a:	ee9ff0ef          	jal	ra,ffffffffc0201802 <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc020191e:	f54d                	bnez	a0,ffffffffc02018c8 <slob_alloc.isra.1.constprop.3+0x52>
}
ffffffffc0201920:	70a2                	ld	ra,40(sp)
ffffffffc0201922:	7402                	ld	s0,32(sp)
ffffffffc0201924:	64e2                	ld	s1,24(sp)
				return 0;
ffffffffc0201926:	4501                	li	a0,0
}
ffffffffc0201928:	6145                	addi	sp,sp,48
ffffffffc020192a:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc020192c:	6518                	ld	a4,8(a0)
ffffffffc020192e:	e798                	sd	a4,8(a5)
			slobfree = prev;
ffffffffc0201930:	00008717          	auipc	a4,0x8
ffffffffc0201934:	72f73023          	sd	a5,1824(a4) # ffffffffc020a050 <slobfree>
    if (flag) {
ffffffffc0201938:	d661                	beqz	a2,ffffffffc0201900 <slob_alloc.isra.1.constprop.3+0x8a>
ffffffffc020193a:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc020193c:	c97fe0ef          	jal	ra,ffffffffc02005d2 <intr_enable>
}
ffffffffc0201940:	70a2                	ld	ra,40(sp)
ffffffffc0201942:	7402                	ld	s0,32(sp)
ffffffffc0201944:	6522                	ld	a0,8(sp)
ffffffffc0201946:	64e2                	ld	s1,24(sp)
ffffffffc0201948:	6145                	addi	sp,sp,48
ffffffffc020194a:	8082                	ret
        intr_disable();
ffffffffc020194c:	c8dfe0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
ffffffffc0201950:	4605                	li	a2,1
ffffffffc0201952:	b799                	j	ffffffffc0201898 <slob_alloc.isra.1.constprop.3+0x22>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201954:	853e                	mv	a0,a5
ffffffffc0201956:	87b6                	mv	a5,a3
ffffffffc0201958:	b761                	j	ffffffffc02018e0 <slob_alloc.isra.1.constprop.3+0x6a>
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc020195a:	00004697          	auipc	a3,0x4
ffffffffc020195e:	3a668693          	addi	a3,a3,934 # ffffffffc0205d00 <default_pmm_manager+0xf0>
ffffffffc0201962:	00004617          	auipc	a2,0x4
ffffffffc0201966:	f1660613          	addi	a2,a2,-234 # ffffffffc0205878 <commands+0x870>
ffffffffc020196a:	06300593          	li	a1,99
ffffffffc020196e:	00004517          	auipc	a0,0x4
ffffffffc0201972:	3b250513          	addi	a0,a0,946 # ffffffffc0205d20 <default_pmm_manager+0x110>
ffffffffc0201976:	adbfe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc020197a <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc020197a:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc020197c:	00004517          	auipc	a0,0x4
ffffffffc0201980:	3bc50513          	addi	a0,a0,956 # ffffffffc0205d38 <default_pmm_manager+0x128>
kmalloc_init(void) {
ffffffffc0201984:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0201986:	809fe0ef          	jal	ra,ffffffffc020018e <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc020198a:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc020198c:	00004517          	auipc	a0,0x4
ffffffffc0201990:	35450513          	addi	a0,a0,852 # ffffffffc0205ce0 <default_pmm_manager+0xd0>
}
ffffffffc0201994:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201996:	ff8fe06f          	j	ffffffffc020018e <cprintf>

ffffffffc020199a <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc020199a:	1101                	addi	sp,sp,-32
ffffffffc020199c:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc020199e:	6905                	lui	s2,0x1
{
ffffffffc02019a0:	e822                	sd	s0,16(sp)
ffffffffc02019a2:	ec06                	sd	ra,24(sp)
ffffffffc02019a4:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02019a6:	fef90793          	addi	a5,s2,-17 # fef <BASE_ADDRESS-0xffffffffc01ff011>
{
ffffffffc02019aa:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02019ac:	04a7fc63          	bleu	a0,a5,ffffffffc0201a04 <kmalloc+0x6a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc02019b0:	4561                	li	a0,24
ffffffffc02019b2:	ec5ff0ef          	jal	ra,ffffffffc0201876 <slob_alloc.isra.1.constprop.3>
ffffffffc02019b6:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc02019b8:	cd21                	beqz	a0,ffffffffc0201a10 <kmalloc+0x76>
	bb->order = find_order(size);
ffffffffc02019ba:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc02019be:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc02019c0:	00f95763          	ble	a5,s2,ffffffffc02019ce <kmalloc+0x34>
ffffffffc02019c4:	6705                	lui	a4,0x1
ffffffffc02019c6:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc02019c8:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc02019ca:	fef74ee3          	blt	a4,a5,ffffffffc02019c6 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc02019ce:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc02019d0:	e33ff0ef          	jal	ra,ffffffffc0201802 <__slob_get_free_pages.isra.0>
ffffffffc02019d4:	e488                	sd	a0,8(s1)
ffffffffc02019d6:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc02019d8:	c935                	beqz	a0,ffffffffc0201a4c <kmalloc+0xb2>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019da:	100027f3          	csrr	a5,sstatus
ffffffffc02019de:	8b89                	andi	a5,a5,2
ffffffffc02019e0:	e3a1                	bnez	a5,ffffffffc0201a20 <kmalloc+0x86>
		bb->next = bigblocks;
ffffffffc02019e2:	00014797          	auipc	a5,0x14
ffffffffc02019e6:	a9e78793          	addi	a5,a5,-1378 # ffffffffc0215480 <bigblocks>
ffffffffc02019ea:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc02019ec:	00014717          	auipc	a4,0x14
ffffffffc02019f0:	a8973a23          	sd	s1,-1388(a4) # ffffffffc0215480 <bigblocks>
		bb->next = bigblocks;
ffffffffc02019f4:	e89c                	sd	a5,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc02019f6:	8522                	mv	a0,s0
ffffffffc02019f8:	60e2                	ld	ra,24(sp)
ffffffffc02019fa:	6442                	ld	s0,16(sp)
ffffffffc02019fc:	64a2                	ld	s1,8(sp)
ffffffffc02019fe:	6902                	ld	s2,0(sp)
ffffffffc0201a00:	6105                	addi	sp,sp,32
ffffffffc0201a02:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201a04:	0541                	addi	a0,a0,16
ffffffffc0201a06:	e71ff0ef          	jal	ra,ffffffffc0201876 <slob_alloc.isra.1.constprop.3>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201a0a:	01050413          	addi	s0,a0,16
ffffffffc0201a0e:	f565                	bnez	a0,ffffffffc02019f6 <kmalloc+0x5c>
ffffffffc0201a10:	4401                	li	s0,0
}
ffffffffc0201a12:	8522                	mv	a0,s0
ffffffffc0201a14:	60e2                	ld	ra,24(sp)
ffffffffc0201a16:	6442                	ld	s0,16(sp)
ffffffffc0201a18:	64a2                	ld	s1,8(sp)
ffffffffc0201a1a:	6902                	ld	s2,0(sp)
ffffffffc0201a1c:	6105                	addi	sp,sp,32
ffffffffc0201a1e:	8082                	ret
        intr_disable();
ffffffffc0201a20:	bb9fe0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201a24:	00014797          	auipc	a5,0x14
ffffffffc0201a28:	a5c78793          	addi	a5,a5,-1444 # ffffffffc0215480 <bigblocks>
ffffffffc0201a2c:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201a2e:	00014717          	auipc	a4,0x14
ffffffffc0201a32:	a4973923          	sd	s1,-1454(a4) # ffffffffc0215480 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201a36:	e89c                	sd	a5,16(s1)
        intr_enable();
ffffffffc0201a38:	b9bfe0ef          	jal	ra,ffffffffc02005d2 <intr_enable>
ffffffffc0201a3c:	6480                	ld	s0,8(s1)
}
ffffffffc0201a3e:	60e2                	ld	ra,24(sp)
ffffffffc0201a40:	64a2                	ld	s1,8(sp)
ffffffffc0201a42:	8522                	mv	a0,s0
ffffffffc0201a44:	6442                	ld	s0,16(sp)
ffffffffc0201a46:	6902                	ld	s2,0(sp)
ffffffffc0201a48:	6105                	addi	sp,sp,32
ffffffffc0201a4a:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201a4c:	45e1                	li	a1,24
ffffffffc0201a4e:	8526                	mv	a0,s1
ffffffffc0201a50:	c9dff0ef          	jal	ra,ffffffffc02016ec <slob_free>
  return __kmalloc(size, 0);
ffffffffc0201a54:	b74d                	j	ffffffffc02019f6 <kmalloc+0x5c>

ffffffffc0201a56 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201a56:	c175                	beqz	a0,ffffffffc0201b3a <kfree+0xe4>
{
ffffffffc0201a58:	1101                	addi	sp,sp,-32
ffffffffc0201a5a:	e426                	sd	s1,8(sp)
ffffffffc0201a5c:	ec06                	sd	ra,24(sp)
ffffffffc0201a5e:	e822                	sd	s0,16(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0201a60:	03451793          	slli	a5,a0,0x34
ffffffffc0201a64:	84aa                	mv	s1,a0
ffffffffc0201a66:	eb8d                	bnez	a5,ffffffffc0201a98 <kfree+0x42>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a68:	100027f3          	csrr	a5,sstatus
ffffffffc0201a6c:	8b89                	andi	a5,a5,2
ffffffffc0201a6e:	efc9                	bnez	a5,ffffffffc0201b08 <kfree+0xb2>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201a70:	00014797          	auipc	a5,0x14
ffffffffc0201a74:	a1078793          	addi	a5,a5,-1520 # ffffffffc0215480 <bigblocks>
ffffffffc0201a78:	6394                	ld	a3,0(a5)
ffffffffc0201a7a:	ce99                	beqz	a3,ffffffffc0201a98 <kfree+0x42>
			if (bb->pages == block) {
ffffffffc0201a7c:	669c                	ld	a5,8(a3)
ffffffffc0201a7e:	6a80                	ld	s0,16(a3)
ffffffffc0201a80:	0af50e63          	beq	a0,a5,ffffffffc0201b3c <kfree+0xe6>
    return 0;
ffffffffc0201a84:	4601                	li	a2,0
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201a86:	c801                	beqz	s0,ffffffffc0201a96 <kfree+0x40>
			if (bb->pages == block) {
ffffffffc0201a88:	6418                	ld	a4,8(s0)
ffffffffc0201a8a:	681c                	ld	a5,16(s0)
ffffffffc0201a8c:	00970f63          	beq	a4,s1,ffffffffc0201aaa <kfree+0x54>
ffffffffc0201a90:	86a2                	mv	a3,s0
ffffffffc0201a92:	843e                	mv	s0,a5
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201a94:	f875                	bnez	s0,ffffffffc0201a88 <kfree+0x32>
    if (flag) {
ffffffffc0201a96:	e659                	bnez	a2,ffffffffc0201b24 <kfree+0xce>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201a98:	6442                	ld	s0,16(sp)
ffffffffc0201a9a:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201a9c:	ff048513          	addi	a0,s1,-16
}
ffffffffc0201aa0:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201aa2:	4581                	li	a1,0
}
ffffffffc0201aa4:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201aa6:	c47ff06f          	j	ffffffffc02016ec <slob_free>
				*last = bb->next;
ffffffffc0201aaa:	ea9c                	sd	a5,16(a3)
ffffffffc0201aac:	e641                	bnez	a2,ffffffffc0201b34 <kfree+0xde>
    return pa2page(PADDR(kva));
ffffffffc0201aae:	c02007b7          	lui	a5,0xc0200
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201ab2:	4018                	lw	a4,0(s0)
ffffffffc0201ab4:	08f4ea63          	bltu	s1,a5,ffffffffc0201b48 <kfree+0xf2>
ffffffffc0201ab8:	00014797          	auipc	a5,0x14
ffffffffc0201abc:	a3878793          	addi	a5,a5,-1480 # ffffffffc02154f0 <va_pa_offset>
ffffffffc0201ac0:	6394                	ld	a3,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0201ac2:	00014797          	auipc	a5,0x14
ffffffffc0201ac6:	9ce78793          	addi	a5,a5,-1586 # ffffffffc0215490 <npage>
ffffffffc0201aca:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0201acc:	8c95                	sub	s1,s1,a3
    if (PPN(pa) >= npage) {
ffffffffc0201ace:	80b1                	srli	s1,s1,0xc
ffffffffc0201ad0:	08f4f963          	bleu	a5,s1,ffffffffc0201b62 <kfree+0x10c>
    return &pages[PPN(pa) - nbase];
ffffffffc0201ad4:	00005797          	auipc	a5,0x5
ffffffffc0201ad8:	4e478793          	addi	a5,a5,1252 # ffffffffc0206fb8 <nbase>
ffffffffc0201adc:	639c                	ld	a5,0(a5)
ffffffffc0201ade:	00014697          	auipc	a3,0x14
ffffffffc0201ae2:	a2268693          	addi	a3,a3,-1502 # ffffffffc0215500 <pages>
ffffffffc0201ae6:	6288                	ld	a0,0(a3)
ffffffffc0201ae8:	8c9d                	sub	s1,s1,a5
ffffffffc0201aea:	049a                	slli	s1,s1,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0201aec:	4585                	li	a1,1
ffffffffc0201aee:	9526                	add	a0,a0,s1
ffffffffc0201af0:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201af4:	12a000ef          	jal	ra,ffffffffc0201c1e <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201af8:	8522                	mv	a0,s0
}
ffffffffc0201afa:	6442                	ld	s0,16(sp)
ffffffffc0201afc:	60e2                	ld	ra,24(sp)
ffffffffc0201afe:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201b00:	45e1                	li	a1,24
}
ffffffffc0201b02:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201b04:	be9ff06f          	j	ffffffffc02016ec <slob_free>
        intr_disable();
ffffffffc0201b08:	ad1fe0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201b0c:	00014797          	auipc	a5,0x14
ffffffffc0201b10:	97478793          	addi	a5,a5,-1676 # ffffffffc0215480 <bigblocks>
ffffffffc0201b14:	6394                	ld	a3,0(a5)
ffffffffc0201b16:	c699                	beqz	a3,ffffffffc0201b24 <kfree+0xce>
			if (bb->pages == block) {
ffffffffc0201b18:	669c                	ld	a5,8(a3)
ffffffffc0201b1a:	6a80                	ld	s0,16(a3)
ffffffffc0201b1c:	00f48763          	beq	s1,a5,ffffffffc0201b2a <kfree+0xd4>
        return 1;
ffffffffc0201b20:	4605                	li	a2,1
ffffffffc0201b22:	b795                	j	ffffffffc0201a86 <kfree+0x30>
        intr_enable();
ffffffffc0201b24:	aaffe0ef          	jal	ra,ffffffffc02005d2 <intr_enable>
ffffffffc0201b28:	bf85                	j	ffffffffc0201a98 <kfree+0x42>
				*last = bb->next;
ffffffffc0201b2a:	00014797          	auipc	a5,0x14
ffffffffc0201b2e:	9487bb23          	sd	s0,-1706(a5) # ffffffffc0215480 <bigblocks>
ffffffffc0201b32:	8436                	mv	s0,a3
ffffffffc0201b34:	a9ffe0ef          	jal	ra,ffffffffc02005d2 <intr_enable>
ffffffffc0201b38:	bf9d                	j	ffffffffc0201aae <kfree+0x58>
ffffffffc0201b3a:	8082                	ret
ffffffffc0201b3c:	00014797          	auipc	a5,0x14
ffffffffc0201b40:	9487b223          	sd	s0,-1724(a5) # ffffffffc0215480 <bigblocks>
ffffffffc0201b44:	8436                	mv	s0,a3
ffffffffc0201b46:	b7a5                	j	ffffffffc0201aae <kfree+0x58>
    return pa2page(PADDR(kva));
ffffffffc0201b48:	86a6                	mv	a3,s1
ffffffffc0201b4a:	00004617          	auipc	a2,0x4
ffffffffc0201b4e:	14e60613          	addi	a2,a2,334 # ffffffffc0205c98 <default_pmm_manager+0x88>
ffffffffc0201b52:	06e00593          	li	a1,110
ffffffffc0201b56:	00004517          	auipc	a0,0x4
ffffffffc0201b5a:	13250513          	addi	a0,a0,306 # ffffffffc0205c88 <default_pmm_manager+0x78>
ffffffffc0201b5e:	8f3fe0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201b62:	00004617          	auipc	a2,0x4
ffffffffc0201b66:	15e60613          	addi	a2,a2,350 # ffffffffc0205cc0 <default_pmm_manager+0xb0>
ffffffffc0201b6a:	06200593          	li	a1,98
ffffffffc0201b6e:	00004517          	auipc	a0,0x4
ffffffffc0201b72:	11a50513          	addi	a0,a0,282 # ffffffffc0205c88 <default_pmm_manager+0x78>
ffffffffc0201b76:	8dbfe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0201b7a <pa2page.part.4>:
pa2page(uintptr_t pa) {
ffffffffc0201b7a:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201b7c:	00004617          	auipc	a2,0x4
ffffffffc0201b80:	14460613          	addi	a2,a2,324 # ffffffffc0205cc0 <default_pmm_manager+0xb0>
ffffffffc0201b84:	06200593          	li	a1,98
ffffffffc0201b88:	00004517          	auipc	a0,0x4
ffffffffc0201b8c:	10050513          	addi	a0,a0,256 # ffffffffc0205c88 <default_pmm_manager+0x78>
pa2page(uintptr_t pa) {
ffffffffc0201b90:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201b92:	8bffe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0201b96 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0201b96:	715d                	addi	sp,sp,-80
ffffffffc0201b98:	e0a2                	sd	s0,64(sp)
ffffffffc0201b9a:	fc26                	sd	s1,56(sp)
ffffffffc0201b9c:	f84a                	sd	s2,48(sp)
ffffffffc0201b9e:	f44e                	sd	s3,40(sp)
ffffffffc0201ba0:	f052                	sd	s4,32(sp)
ffffffffc0201ba2:	ec56                	sd	s5,24(sp)
ffffffffc0201ba4:	e486                	sd	ra,72(sp)
ffffffffc0201ba6:	842a                	mv	s0,a0
ffffffffc0201ba8:	00014497          	auipc	s1,0x14
ffffffffc0201bac:	94048493          	addi	s1,s1,-1728 # ffffffffc02154e8 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201bb0:	4985                	li	s3,1
ffffffffc0201bb2:	00014a17          	auipc	s4,0x14
ffffffffc0201bb6:	8eea0a13          	addi	s4,s4,-1810 # ffffffffc02154a0 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201bba:	0005091b          	sext.w	s2,a0
ffffffffc0201bbe:	00014a97          	auipc	s5,0x14
ffffffffc0201bc2:	a22a8a93          	addi	s5,s5,-1502 # ffffffffc02155e0 <check_mm_struct>
ffffffffc0201bc6:	a00d                	j	ffffffffc0201be8 <alloc_pages+0x52>
            page = pmm_manager->alloc_pages(n);
ffffffffc0201bc8:	609c                	ld	a5,0(s1)
ffffffffc0201bca:	6f9c                	ld	a5,24(a5)
ffffffffc0201bcc:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0201bce:	4601                	li	a2,0
ffffffffc0201bd0:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201bd2:	ed0d                	bnez	a0,ffffffffc0201c0c <alloc_pages+0x76>
ffffffffc0201bd4:	0289ec63          	bltu	s3,s0,ffffffffc0201c0c <alloc_pages+0x76>
ffffffffc0201bd8:	000a2783          	lw	a5,0(s4)
ffffffffc0201bdc:	2781                	sext.w	a5,a5
ffffffffc0201bde:	c79d                	beqz	a5,ffffffffc0201c0c <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201be0:	000ab503          	ld	a0,0(s5)
ffffffffc0201be4:	6dc010ef          	jal	ra,ffffffffc02032c0 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201be8:	100027f3          	csrr	a5,sstatus
ffffffffc0201bec:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0201bee:	8522                	mv	a0,s0
ffffffffc0201bf0:	dfe1                	beqz	a5,ffffffffc0201bc8 <alloc_pages+0x32>
        intr_disable();
ffffffffc0201bf2:	9e7fe0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
ffffffffc0201bf6:	609c                	ld	a5,0(s1)
ffffffffc0201bf8:	8522                	mv	a0,s0
ffffffffc0201bfa:	6f9c                	ld	a5,24(a5)
ffffffffc0201bfc:	9782                	jalr	a5
ffffffffc0201bfe:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201c00:	9d3fe0ef          	jal	ra,ffffffffc02005d2 <intr_enable>
ffffffffc0201c04:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0201c06:	4601                	li	a2,0
ffffffffc0201c08:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201c0a:	d569                	beqz	a0,ffffffffc0201bd4 <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201c0c:	60a6                	ld	ra,72(sp)
ffffffffc0201c0e:	6406                	ld	s0,64(sp)
ffffffffc0201c10:	74e2                	ld	s1,56(sp)
ffffffffc0201c12:	7942                	ld	s2,48(sp)
ffffffffc0201c14:	79a2                	ld	s3,40(sp)
ffffffffc0201c16:	7a02                	ld	s4,32(sp)
ffffffffc0201c18:	6ae2                	ld	s5,24(sp)
ffffffffc0201c1a:	6161                	addi	sp,sp,80
ffffffffc0201c1c:	8082                	ret

ffffffffc0201c1e <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c1e:	100027f3          	csrr	a5,sstatus
ffffffffc0201c22:	8b89                	andi	a5,a5,2
ffffffffc0201c24:	eb89                	bnez	a5,ffffffffc0201c36 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201c26:	00014797          	auipc	a5,0x14
ffffffffc0201c2a:	8c278793          	addi	a5,a5,-1854 # ffffffffc02154e8 <pmm_manager>
ffffffffc0201c2e:	639c                	ld	a5,0(a5)
ffffffffc0201c30:	0207b303          	ld	t1,32(a5)
ffffffffc0201c34:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0201c36:	1101                	addi	sp,sp,-32
ffffffffc0201c38:	ec06                	sd	ra,24(sp)
ffffffffc0201c3a:	e822                	sd	s0,16(sp)
ffffffffc0201c3c:	e426                	sd	s1,8(sp)
ffffffffc0201c3e:	842a                	mv	s0,a0
ffffffffc0201c40:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201c42:	997fe0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201c46:	00014797          	auipc	a5,0x14
ffffffffc0201c4a:	8a278793          	addi	a5,a5,-1886 # ffffffffc02154e8 <pmm_manager>
ffffffffc0201c4e:	639c                	ld	a5,0(a5)
ffffffffc0201c50:	85a6                	mv	a1,s1
ffffffffc0201c52:	8522                	mv	a0,s0
ffffffffc0201c54:	739c                	ld	a5,32(a5)
ffffffffc0201c56:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201c58:	6442                	ld	s0,16(sp)
ffffffffc0201c5a:	60e2                	ld	ra,24(sp)
ffffffffc0201c5c:	64a2                	ld	s1,8(sp)
ffffffffc0201c5e:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201c60:	973fe06f          	j	ffffffffc02005d2 <intr_enable>

ffffffffc0201c64 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c64:	100027f3          	csrr	a5,sstatus
ffffffffc0201c68:	8b89                	andi	a5,a5,2
ffffffffc0201c6a:	eb89                	bnez	a5,ffffffffc0201c7c <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201c6c:	00014797          	auipc	a5,0x14
ffffffffc0201c70:	87c78793          	addi	a5,a5,-1924 # ffffffffc02154e8 <pmm_manager>
ffffffffc0201c74:	639c                	ld	a5,0(a5)
ffffffffc0201c76:	0287b303          	ld	t1,40(a5)
ffffffffc0201c7a:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0201c7c:	1141                	addi	sp,sp,-16
ffffffffc0201c7e:	e406                	sd	ra,8(sp)
ffffffffc0201c80:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201c82:	957fe0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201c86:	00014797          	auipc	a5,0x14
ffffffffc0201c8a:	86278793          	addi	a5,a5,-1950 # ffffffffc02154e8 <pmm_manager>
ffffffffc0201c8e:	639c                	ld	a5,0(a5)
ffffffffc0201c90:	779c                	ld	a5,40(a5)
ffffffffc0201c92:	9782                	jalr	a5
ffffffffc0201c94:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201c96:	93dfe0ef          	jal	ra,ffffffffc02005d2 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201c9a:	8522                	mv	a0,s0
ffffffffc0201c9c:	60a2                	ld	ra,8(sp)
ffffffffc0201c9e:	6402                	ld	s0,0(sp)
ffffffffc0201ca0:	0141                	addi	sp,sp,16
ffffffffc0201ca2:	8082                	ret

ffffffffc0201ca4 <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201ca4:	7139                	addi	sp,sp,-64
ffffffffc0201ca6:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201ca8:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0201cac:	1ff4f493          	andi	s1,s1,511
ffffffffc0201cb0:	048e                	slli	s1,s1,0x3
ffffffffc0201cb2:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201cb4:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201cb6:	f04a                	sd	s2,32(sp)
ffffffffc0201cb8:	ec4e                	sd	s3,24(sp)
ffffffffc0201cba:	e852                	sd	s4,16(sp)
ffffffffc0201cbc:	fc06                	sd	ra,56(sp)
ffffffffc0201cbe:	f822                	sd	s0,48(sp)
ffffffffc0201cc0:	e456                	sd	s5,8(sp)
ffffffffc0201cc2:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201cc4:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201cc8:	892e                	mv	s2,a1
ffffffffc0201cca:	8a32                	mv	s4,a2
ffffffffc0201ccc:	00013997          	auipc	s3,0x13
ffffffffc0201cd0:	7c498993          	addi	s3,s3,1988 # ffffffffc0215490 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201cd4:	e7bd                	bnez	a5,ffffffffc0201d42 <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201cd6:	12060c63          	beqz	a2,ffffffffc0201e0e <get_pte+0x16a>
ffffffffc0201cda:	4505                	li	a0,1
ffffffffc0201cdc:	ebbff0ef          	jal	ra,ffffffffc0201b96 <alloc_pages>
ffffffffc0201ce0:	842a                	mv	s0,a0
ffffffffc0201ce2:	12050663          	beqz	a0,ffffffffc0201e0e <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201ce6:	00014b17          	auipc	s6,0x14
ffffffffc0201cea:	81ab0b13          	addi	s6,s6,-2022 # ffffffffc0215500 <pages>
ffffffffc0201cee:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc0201cf2:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201cf4:	00013997          	auipc	s3,0x13
ffffffffc0201cf8:	79c98993          	addi	s3,s3,1948 # ffffffffc0215490 <npage>
    return page - pages + nbase;
ffffffffc0201cfc:	40a40533          	sub	a0,s0,a0
ffffffffc0201d00:	00080ab7          	lui	s5,0x80
ffffffffc0201d04:	8519                	srai	a0,a0,0x6
ffffffffc0201d06:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc0201d0a:	c01c                	sw	a5,0(s0)
ffffffffc0201d0c:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0201d0e:	9556                	add	a0,a0,s5
ffffffffc0201d10:	83b1                	srli	a5,a5,0xc
ffffffffc0201d12:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201d14:	0532                	slli	a0,a0,0xc
ffffffffc0201d16:	14e7f363          	bleu	a4,a5,ffffffffc0201e5c <get_pte+0x1b8>
ffffffffc0201d1a:	00013797          	auipc	a5,0x13
ffffffffc0201d1e:	7d678793          	addi	a5,a5,2006 # ffffffffc02154f0 <va_pa_offset>
ffffffffc0201d22:	639c                	ld	a5,0(a5)
ffffffffc0201d24:	6605                	lui	a2,0x1
ffffffffc0201d26:	4581                	li	a1,0
ffffffffc0201d28:	953e                	add	a0,a0,a5
ffffffffc0201d2a:	154030ef          	jal	ra,ffffffffc0204e7e <memset>
    return page - pages + nbase;
ffffffffc0201d2e:	000b3683          	ld	a3,0(s6)
ffffffffc0201d32:	40d406b3          	sub	a3,s0,a3
ffffffffc0201d36:	8699                	srai	a3,a3,0x6
ffffffffc0201d38:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201d3a:	06aa                	slli	a3,a3,0xa
ffffffffc0201d3c:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201d40:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201d42:	77fd                	lui	a5,0xfffff
ffffffffc0201d44:	068a                	slli	a3,a3,0x2
ffffffffc0201d46:	0009b703          	ld	a4,0(s3)
ffffffffc0201d4a:	8efd                	and	a3,a3,a5
ffffffffc0201d4c:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201d50:	0ce7f163          	bleu	a4,a5,ffffffffc0201e12 <get_pte+0x16e>
ffffffffc0201d54:	00013a97          	auipc	s5,0x13
ffffffffc0201d58:	79ca8a93          	addi	s5,s5,1948 # ffffffffc02154f0 <va_pa_offset>
ffffffffc0201d5c:	000ab403          	ld	s0,0(s5)
ffffffffc0201d60:	01595793          	srli	a5,s2,0x15
ffffffffc0201d64:	1ff7f793          	andi	a5,a5,511
ffffffffc0201d68:	96a2                	add	a3,a3,s0
ffffffffc0201d6a:	00379413          	slli	s0,a5,0x3
ffffffffc0201d6e:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0201d70:	6014                	ld	a3,0(s0)
ffffffffc0201d72:	0016f793          	andi	a5,a3,1
ffffffffc0201d76:	e3ad                	bnez	a5,ffffffffc0201dd8 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201d78:	080a0b63          	beqz	s4,ffffffffc0201e0e <get_pte+0x16a>
ffffffffc0201d7c:	4505                	li	a0,1
ffffffffc0201d7e:	e19ff0ef          	jal	ra,ffffffffc0201b96 <alloc_pages>
ffffffffc0201d82:	84aa                	mv	s1,a0
ffffffffc0201d84:	c549                	beqz	a0,ffffffffc0201e0e <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201d86:	00013b17          	auipc	s6,0x13
ffffffffc0201d8a:	77ab0b13          	addi	s6,s6,1914 # ffffffffc0215500 <pages>
ffffffffc0201d8e:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc0201d92:	4785                	li	a5,1
    return page - pages + nbase;
ffffffffc0201d94:	00080a37          	lui	s4,0x80
ffffffffc0201d98:	40a48533          	sub	a0,s1,a0
ffffffffc0201d9c:	8519                	srai	a0,a0,0x6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201d9e:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc0201da2:	c09c                	sw	a5,0(s1)
ffffffffc0201da4:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0201da6:	9552                	add	a0,a0,s4
ffffffffc0201da8:	83b1                	srli	a5,a5,0xc
ffffffffc0201daa:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201dac:	0532                	slli	a0,a0,0xc
ffffffffc0201dae:	08e7fa63          	bleu	a4,a5,ffffffffc0201e42 <get_pte+0x19e>
ffffffffc0201db2:	000ab783          	ld	a5,0(s5)
ffffffffc0201db6:	6605                	lui	a2,0x1
ffffffffc0201db8:	4581                	li	a1,0
ffffffffc0201dba:	953e                	add	a0,a0,a5
ffffffffc0201dbc:	0c2030ef          	jal	ra,ffffffffc0204e7e <memset>
    return page - pages + nbase;
ffffffffc0201dc0:	000b3683          	ld	a3,0(s6)
ffffffffc0201dc4:	40d486b3          	sub	a3,s1,a3
ffffffffc0201dc8:	8699                	srai	a3,a3,0x6
ffffffffc0201dca:	96d2                	add	a3,a3,s4
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201dcc:	06aa                	slli	a3,a3,0xa
ffffffffc0201dce:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201dd2:	e014                	sd	a3,0(s0)
ffffffffc0201dd4:	0009b703          	ld	a4,0(s3)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201dd8:	068a                	slli	a3,a3,0x2
ffffffffc0201dda:	757d                	lui	a0,0xfffff
ffffffffc0201ddc:	8ee9                	and	a3,a3,a0
ffffffffc0201dde:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201de2:	04e7f463          	bleu	a4,a5,ffffffffc0201e2a <get_pte+0x186>
ffffffffc0201de6:	000ab503          	ld	a0,0(s5)
ffffffffc0201dea:	00c95793          	srli	a5,s2,0xc
ffffffffc0201dee:	1ff7f793          	andi	a5,a5,511
ffffffffc0201df2:	96aa                	add	a3,a3,a0
ffffffffc0201df4:	00379513          	slli	a0,a5,0x3
ffffffffc0201df8:	9536                	add	a0,a0,a3
}
ffffffffc0201dfa:	70e2                	ld	ra,56(sp)
ffffffffc0201dfc:	7442                	ld	s0,48(sp)
ffffffffc0201dfe:	74a2                	ld	s1,40(sp)
ffffffffc0201e00:	7902                	ld	s2,32(sp)
ffffffffc0201e02:	69e2                	ld	s3,24(sp)
ffffffffc0201e04:	6a42                	ld	s4,16(sp)
ffffffffc0201e06:	6aa2                	ld	s5,8(sp)
ffffffffc0201e08:	6b02                	ld	s6,0(sp)
ffffffffc0201e0a:	6121                	addi	sp,sp,64
ffffffffc0201e0c:	8082                	ret
            return NULL;
ffffffffc0201e0e:	4501                	li	a0,0
ffffffffc0201e10:	b7ed                	j	ffffffffc0201dfa <get_pte+0x156>
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201e12:	00004617          	auipc	a2,0x4
ffffffffc0201e16:	e4e60613          	addi	a2,a2,-434 # ffffffffc0205c60 <default_pmm_manager+0x50>
ffffffffc0201e1a:	0e400593          	li	a1,228
ffffffffc0201e1e:	00004517          	auipc	a0,0x4
ffffffffc0201e22:	f3250513          	addi	a0,a0,-206 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc0201e26:	e2afe0ef          	jal	ra,ffffffffc0200450 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201e2a:	00004617          	auipc	a2,0x4
ffffffffc0201e2e:	e3660613          	addi	a2,a2,-458 # ffffffffc0205c60 <default_pmm_manager+0x50>
ffffffffc0201e32:	0ef00593          	li	a1,239
ffffffffc0201e36:	00004517          	auipc	a0,0x4
ffffffffc0201e3a:	f1a50513          	addi	a0,a0,-230 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc0201e3e:	e12fe0ef          	jal	ra,ffffffffc0200450 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201e42:	86aa                	mv	a3,a0
ffffffffc0201e44:	00004617          	auipc	a2,0x4
ffffffffc0201e48:	e1c60613          	addi	a2,a2,-484 # ffffffffc0205c60 <default_pmm_manager+0x50>
ffffffffc0201e4c:	0ec00593          	li	a1,236
ffffffffc0201e50:	00004517          	auipc	a0,0x4
ffffffffc0201e54:	f0050513          	addi	a0,a0,-256 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc0201e58:	df8fe0ef          	jal	ra,ffffffffc0200450 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201e5c:	86aa                	mv	a3,a0
ffffffffc0201e5e:	00004617          	auipc	a2,0x4
ffffffffc0201e62:	e0260613          	addi	a2,a2,-510 # ffffffffc0205c60 <default_pmm_manager+0x50>
ffffffffc0201e66:	0e100593          	li	a1,225
ffffffffc0201e6a:	00004517          	auipc	a0,0x4
ffffffffc0201e6e:	ee650513          	addi	a0,a0,-282 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc0201e72:	ddefe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0201e76 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201e76:	1141                	addi	sp,sp,-16
ffffffffc0201e78:	e022                	sd	s0,0(sp)
ffffffffc0201e7a:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201e7c:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201e7e:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201e80:	e25ff0ef          	jal	ra,ffffffffc0201ca4 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201e84:	c011                	beqz	s0,ffffffffc0201e88 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0201e86:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201e88:	c129                	beqz	a0,ffffffffc0201eca <get_page+0x54>
ffffffffc0201e8a:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201e8c:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201e8e:	0017f713          	andi	a4,a5,1
ffffffffc0201e92:	e709                	bnez	a4,ffffffffc0201e9c <get_page+0x26>
}
ffffffffc0201e94:	60a2                	ld	ra,8(sp)
ffffffffc0201e96:	6402                	ld	s0,0(sp)
ffffffffc0201e98:	0141                	addi	sp,sp,16
ffffffffc0201e9a:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201e9c:	00013717          	auipc	a4,0x13
ffffffffc0201ea0:	5f470713          	addi	a4,a4,1524 # ffffffffc0215490 <npage>
ffffffffc0201ea4:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201ea6:	078a                	slli	a5,a5,0x2
ffffffffc0201ea8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201eaa:	02e7f563          	bleu	a4,a5,ffffffffc0201ed4 <get_page+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0201eae:	00013717          	auipc	a4,0x13
ffffffffc0201eb2:	65270713          	addi	a4,a4,1618 # ffffffffc0215500 <pages>
ffffffffc0201eb6:	6308                	ld	a0,0(a4)
ffffffffc0201eb8:	60a2                	ld	ra,8(sp)
ffffffffc0201eba:	6402                	ld	s0,0(sp)
ffffffffc0201ebc:	fff80737          	lui	a4,0xfff80
ffffffffc0201ec0:	97ba                	add	a5,a5,a4
ffffffffc0201ec2:	079a                	slli	a5,a5,0x6
ffffffffc0201ec4:	953e                	add	a0,a0,a5
ffffffffc0201ec6:	0141                	addi	sp,sp,16
ffffffffc0201ec8:	8082                	ret
ffffffffc0201eca:	60a2                	ld	ra,8(sp)
ffffffffc0201ecc:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0201ece:	4501                	li	a0,0
}
ffffffffc0201ed0:	0141                	addi	sp,sp,16
ffffffffc0201ed2:	8082                	ret
ffffffffc0201ed4:	ca7ff0ef          	jal	ra,ffffffffc0201b7a <pa2page.part.4>

ffffffffc0201ed8 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201ed8:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201eda:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201edc:	e426                	sd	s1,8(sp)
ffffffffc0201ede:	ec06                	sd	ra,24(sp)
ffffffffc0201ee0:	e822                	sd	s0,16(sp)
ffffffffc0201ee2:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201ee4:	dc1ff0ef          	jal	ra,ffffffffc0201ca4 <get_pte>
    if (ptep != NULL) {
ffffffffc0201ee8:	c511                	beqz	a0,ffffffffc0201ef4 <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0201eea:	611c                	ld	a5,0(a0)
ffffffffc0201eec:	842a                	mv	s0,a0
ffffffffc0201eee:	0017f713          	andi	a4,a5,1
ffffffffc0201ef2:	e711                	bnez	a4,ffffffffc0201efe <page_remove+0x26>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0201ef4:	60e2                	ld	ra,24(sp)
ffffffffc0201ef6:	6442                	ld	s0,16(sp)
ffffffffc0201ef8:	64a2                	ld	s1,8(sp)
ffffffffc0201efa:	6105                	addi	sp,sp,32
ffffffffc0201efc:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201efe:	00013717          	auipc	a4,0x13
ffffffffc0201f02:	59270713          	addi	a4,a4,1426 # ffffffffc0215490 <npage>
ffffffffc0201f06:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201f08:	078a                	slli	a5,a5,0x2
ffffffffc0201f0a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201f0c:	02e7fe63          	bleu	a4,a5,ffffffffc0201f48 <page_remove+0x70>
    return &pages[PPN(pa) - nbase];
ffffffffc0201f10:	00013717          	auipc	a4,0x13
ffffffffc0201f14:	5f070713          	addi	a4,a4,1520 # ffffffffc0215500 <pages>
ffffffffc0201f18:	6308                	ld	a0,0(a4)
ffffffffc0201f1a:	fff80737          	lui	a4,0xfff80
ffffffffc0201f1e:	97ba                	add	a5,a5,a4
ffffffffc0201f20:	079a                	slli	a5,a5,0x6
ffffffffc0201f22:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0201f24:	411c                	lw	a5,0(a0)
ffffffffc0201f26:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201f2a:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201f2c:	cb11                	beqz	a4,ffffffffc0201f40 <page_remove+0x68>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201f2e:	00043023          	sd	zero,0(s0)
// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    // flush_tlb();
    // The flush_tlb flush the entire TLB, is there any better way?
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201f32:	12048073          	sfence.vma	s1
}
ffffffffc0201f36:	60e2                	ld	ra,24(sp)
ffffffffc0201f38:	6442                	ld	s0,16(sp)
ffffffffc0201f3a:	64a2                	ld	s1,8(sp)
ffffffffc0201f3c:	6105                	addi	sp,sp,32
ffffffffc0201f3e:	8082                	ret
            free_page(page);
ffffffffc0201f40:	4585                	li	a1,1
ffffffffc0201f42:	cddff0ef          	jal	ra,ffffffffc0201c1e <free_pages>
ffffffffc0201f46:	b7e5                	j	ffffffffc0201f2e <page_remove+0x56>
ffffffffc0201f48:	c33ff0ef          	jal	ra,ffffffffc0201b7a <pa2page.part.4>

ffffffffc0201f4c <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201f4c:	7179                	addi	sp,sp,-48
ffffffffc0201f4e:	e44e                	sd	s3,8(sp)
ffffffffc0201f50:	89b2                	mv	s3,a2
ffffffffc0201f52:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201f54:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201f56:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201f58:	85ce                	mv	a1,s3
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201f5a:	ec26                	sd	s1,24(sp)
ffffffffc0201f5c:	f406                	sd	ra,40(sp)
ffffffffc0201f5e:	e84a                	sd	s2,16(sp)
ffffffffc0201f60:	e052                	sd	s4,0(sp)
ffffffffc0201f62:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201f64:	d41ff0ef          	jal	ra,ffffffffc0201ca4 <get_pte>
    if (ptep == NULL) {
ffffffffc0201f68:	cd49                	beqz	a0,ffffffffc0202002 <page_insert+0xb6>
    page->ref += 1;
ffffffffc0201f6a:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0201f6c:	611c                	ld	a5,0(a0)
ffffffffc0201f6e:	892a                	mv	s2,a0
ffffffffc0201f70:	0016871b          	addiw	a4,a3,1
ffffffffc0201f74:	c018                	sw	a4,0(s0)
ffffffffc0201f76:	0017f713          	andi	a4,a5,1
ffffffffc0201f7a:	ef05                	bnez	a4,ffffffffc0201fb2 <page_insert+0x66>
ffffffffc0201f7c:	00013797          	auipc	a5,0x13
ffffffffc0201f80:	58478793          	addi	a5,a5,1412 # ffffffffc0215500 <pages>
ffffffffc0201f84:	6398                	ld	a4,0(a5)
    return page - pages + nbase;
ffffffffc0201f86:	8c19                	sub	s0,s0,a4
ffffffffc0201f88:	000806b7          	lui	a3,0x80
ffffffffc0201f8c:	8419                	srai	s0,s0,0x6
ffffffffc0201f8e:	9436                	add	s0,s0,a3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201f90:	042a                	slli	s0,s0,0xa
ffffffffc0201f92:	8c45                	or	s0,s0,s1
ffffffffc0201f94:	00146413          	ori	s0,s0,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0201f98:	00893023          	sd	s0,0(s2)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201f9c:	12098073          	sfence.vma	s3
    return 0;
ffffffffc0201fa0:	4501                	li	a0,0
}
ffffffffc0201fa2:	70a2                	ld	ra,40(sp)
ffffffffc0201fa4:	7402                	ld	s0,32(sp)
ffffffffc0201fa6:	64e2                	ld	s1,24(sp)
ffffffffc0201fa8:	6942                	ld	s2,16(sp)
ffffffffc0201faa:	69a2                	ld	s3,8(sp)
ffffffffc0201fac:	6a02                	ld	s4,0(sp)
ffffffffc0201fae:	6145                	addi	sp,sp,48
ffffffffc0201fb0:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201fb2:	00013717          	auipc	a4,0x13
ffffffffc0201fb6:	4de70713          	addi	a4,a4,1246 # ffffffffc0215490 <npage>
ffffffffc0201fba:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201fbc:	078a                	slli	a5,a5,0x2
ffffffffc0201fbe:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201fc0:	04e7f363          	bleu	a4,a5,ffffffffc0202006 <page_insert+0xba>
    return &pages[PPN(pa) - nbase];
ffffffffc0201fc4:	00013a17          	auipc	s4,0x13
ffffffffc0201fc8:	53ca0a13          	addi	s4,s4,1340 # ffffffffc0215500 <pages>
ffffffffc0201fcc:	000a3703          	ld	a4,0(s4)
ffffffffc0201fd0:	fff80537          	lui	a0,0xfff80
ffffffffc0201fd4:	953e                	add	a0,a0,a5
ffffffffc0201fd6:	051a                	slli	a0,a0,0x6
ffffffffc0201fd8:	953a                	add	a0,a0,a4
        if (p == page) {
ffffffffc0201fda:	00a40a63          	beq	s0,a0,ffffffffc0201fee <page_insert+0xa2>
    page->ref -= 1;
ffffffffc0201fde:	411c                	lw	a5,0(a0)
ffffffffc0201fe0:	fff7869b          	addiw	a3,a5,-1
ffffffffc0201fe4:	c114                	sw	a3,0(a0)
        if (page_ref(page) ==
ffffffffc0201fe6:	c691                	beqz	a3,ffffffffc0201ff2 <page_insert+0xa6>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201fe8:	12098073          	sfence.vma	s3
ffffffffc0201fec:	bf69                	j	ffffffffc0201f86 <page_insert+0x3a>
ffffffffc0201fee:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0201ff0:	bf59                	j	ffffffffc0201f86 <page_insert+0x3a>
            free_page(page);
ffffffffc0201ff2:	4585                	li	a1,1
ffffffffc0201ff4:	c2bff0ef          	jal	ra,ffffffffc0201c1e <free_pages>
ffffffffc0201ff8:	000a3703          	ld	a4,0(s4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201ffc:	12098073          	sfence.vma	s3
ffffffffc0202000:	b759                	j	ffffffffc0201f86 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0202002:	5571                	li	a0,-4
ffffffffc0202004:	bf79                	j	ffffffffc0201fa2 <page_insert+0x56>
ffffffffc0202006:	b75ff0ef          	jal	ra,ffffffffc0201b7a <pa2page.part.4>

ffffffffc020200a <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc020200a:	00004797          	auipc	a5,0x4
ffffffffc020200e:	c0678793          	addi	a5,a5,-1018 # ffffffffc0205c10 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202012:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0202014:	715d                	addi	sp,sp,-80
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202016:	00004517          	auipc	a0,0x4
ffffffffc020201a:	d6250513          	addi	a0,a0,-670 # ffffffffc0205d78 <default_pmm_manager+0x168>
void pmm_init(void) {
ffffffffc020201e:	e486                	sd	ra,72(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202020:	00013717          	auipc	a4,0x13
ffffffffc0202024:	4cf73423          	sd	a5,1224(a4) # ffffffffc02154e8 <pmm_manager>
void pmm_init(void) {
ffffffffc0202028:	e0a2                	sd	s0,64(sp)
ffffffffc020202a:	fc26                	sd	s1,56(sp)
ffffffffc020202c:	f84a                	sd	s2,48(sp)
ffffffffc020202e:	f44e                	sd	s3,40(sp)
ffffffffc0202030:	f052                	sd	s4,32(sp)
ffffffffc0202032:	ec56                	sd	s5,24(sp)
ffffffffc0202034:	e85a                	sd	s6,16(sp)
ffffffffc0202036:	e45e                	sd	s7,8(sp)
ffffffffc0202038:	e062                	sd	s8,0(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc020203a:	00013417          	auipc	s0,0x13
ffffffffc020203e:	4ae40413          	addi	s0,s0,1198 # ffffffffc02154e8 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202042:	94cfe0ef          	jal	ra,ffffffffc020018e <cprintf>
    pmm_manager->init();
ffffffffc0202046:	601c                	ld	a5,0(s0)
ffffffffc0202048:	00013497          	auipc	s1,0x13
ffffffffc020204c:	44848493          	addi	s1,s1,1096 # ffffffffc0215490 <npage>
ffffffffc0202050:	00013917          	auipc	s2,0x13
ffffffffc0202054:	4b090913          	addi	s2,s2,1200 # ffffffffc0215500 <pages>
ffffffffc0202058:	679c                	ld	a5,8(a5)
ffffffffc020205a:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc020205c:	57f5                	li	a5,-3
ffffffffc020205e:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0202060:	00004517          	auipc	a0,0x4
ffffffffc0202064:	d3050513          	addi	a0,a0,-720 # ffffffffc0205d90 <default_pmm_manager+0x180>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202068:	00013717          	auipc	a4,0x13
ffffffffc020206c:	48f73423          	sd	a5,1160(a4) # ffffffffc02154f0 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc0202070:	91efe0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0202074:	46c5                	li	a3,17
ffffffffc0202076:	06ee                	slli	a3,a3,0x1b
ffffffffc0202078:	40100613          	li	a2,1025
ffffffffc020207c:	16fd                	addi	a3,a3,-1
ffffffffc020207e:	0656                	slli	a2,a2,0x15
ffffffffc0202080:	07e005b7          	lui	a1,0x7e00
ffffffffc0202084:	00004517          	auipc	a0,0x4
ffffffffc0202088:	d2450513          	addi	a0,a0,-732 # ffffffffc0205da8 <default_pmm_manager+0x198>
ffffffffc020208c:	902fe0ef          	jal	ra,ffffffffc020018e <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202090:	777d                	lui	a4,0xfffff
ffffffffc0202092:	00014797          	auipc	a5,0x14
ffffffffc0202096:	56578793          	addi	a5,a5,1381 # ffffffffc02165f7 <end+0xfff>
ffffffffc020209a:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc020209c:	00088737          	lui	a4,0x88
ffffffffc02020a0:	00013697          	auipc	a3,0x13
ffffffffc02020a4:	3ee6b823          	sd	a4,1008(a3) # ffffffffc0215490 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02020a8:	00013717          	auipc	a4,0x13
ffffffffc02020ac:	44f73c23          	sd	a5,1112(a4) # ffffffffc0215500 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02020b0:	4701                	li	a4,0
ffffffffc02020b2:	4685                	li	a3,1
ffffffffc02020b4:	fff80837          	lui	a6,0xfff80
ffffffffc02020b8:	a019                	j	ffffffffc02020be <pmm_init+0xb4>
ffffffffc02020ba:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc02020be:	00671613          	slli	a2,a4,0x6
ffffffffc02020c2:	97b2                	add	a5,a5,a2
ffffffffc02020c4:	07a1                	addi	a5,a5,8
ffffffffc02020c6:	40d7b02f          	amoor.d	zero,a3,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02020ca:	6090                	ld	a2,0(s1)
ffffffffc02020cc:	0705                	addi	a4,a4,1
ffffffffc02020ce:	010607b3          	add	a5,a2,a6
ffffffffc02020d2:	fef764e3          	bltu	a4,a5,ffffffffc02020ba <pmm_init+0xb0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02020d6:	00093503          	ld	a0,0(s2)
ffffffffc02020da:	fe0007b7          	lui	a5,0xfe000
ffffffffc02020de:	00661693          	slli	a3,a2,0x6
ffffffffc02020e2:	97aa                	add	a5,a5,a0
ffffffffc02020e4:	96be                	add	a3,a3,a5
ffffffffc02020e6:	c02007b7          	lui	a5,0xc0200
ffffffffc02020ea:	7af6ed63          	bltu	a3,a5,ffffffffc02028a4 <pmm_init+0x89a>
ffffffffc02020ee:	00013997          	auipc	s3,0x13
ffffffffc02020f2:	40298993          	addi	s3,s3,1026 # ffffffffc02154f0 <va_pa_offset>
ffffffffc02020f6:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc02020fa:	47c5                	li	a5,17
ffffffffc02020fc:	07ee                	slli	a5,a5,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02020fe:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc0202100:	02f6f763          	bleu	a5,a3,ffffffffc020212e <pmm_init+0x124>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202104:	6585                	lui	a1,0x1
ffffffffc0202106:	15fd                	addi	a1,a1,-1
ffffffffc0202108:	96ae                	add	a3,a3,a1
    if (PPN(pa) >= npage) {
ffffffffc020210a:	00c6d713          	srli	a4,a3,0xc
ffffffffc020210e:	48c77a63          	bleu	a2,a4,ffffffffc02025a2 <pmm_init+0x598>
    pmm_manager->init_memmap(base, n);
ffffffffc0202112:	6010                	ld	a2,0(s0)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202114:	75fd                	lui	a1,0xfffff
ffffffffc0202116:	8eed                	and	a3,a3,a1
    return &pages[PPN(pa) - nbase];
ffffffffc0202118:	9742                	add	a4,a4,a6
    pmm_manager->init_memmap(base, n);
ffffffffc020211a:	6a10                	ld	a2,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020211c:	40d786b3          	sub	a3,a5,a3
ffffffffc0202120:	071a                	slli	a4,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc0202122:	00c6d593          	srli	a1,a3,0xc
ffffffffc0202126:	953a                	add	a0,a0,a4
ffffffffc0202128:	9602                	jalr	a2
ffffffffc020212a:	0009b583          	ld	a1,0(s3)
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc020212e:	00004517          	auipc	a0,0x4
ffffffffc0202132:	ca250513          	addi	a0,a0,-862 # ffffffffc0205dd0 <default_pmm_manager+0x1c0>
ffffffffc0202136:	858fe0ef          	jal	ra,ffffffffc020018e <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020213a:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020213c:	00013417          	auipc	s0,0x13
ffffffffc0202140:	34c40413          	addi	s0,s0,844 # ffffffffc0215488 <boot_pgdir>
    pmm_manager->check();
ffffffffc0202144:	7b9c                	ld	a5,48(a5)
ffffffffc0202146:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0202148:	00004517          	auipc	a0,0x4
ffffffffc020214c:	ca050513          	addi	a0,a0,-864 # ffffffffc0205de8 <default_pmm_manager+0x1d8>
ffffffffc0202150:	83efe0ef          	jal	ra,ffffffffc020018e <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202154:	00007697          	auipc	a3,0x7
ffffffffc0202158:	eac68693          	addi	a3,a3,-340 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc020215c:	00013797          	auipc	a5,0x13
ffffffffc0202160:	32d7b623          	sd	a3,812(a5) # ffffffffc0215488 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202164:	c02007b7          	lui	a5,0xc0200
ffffffffc0202168:	10f6eae3          	bltu	a3,a5,ffffffffc0202a7c <pmm_init+0xa72>
ffffffffc020216c:	0009b783          	ld	a5,0(s3)
ffffffffc0202170:	8e9d                	sub	a3,a3,a5
ffffffffc0202172:	00013797          	auipc	a5,0x13
ffffffffc0202176:	38d7b323          	sd	a3,902(a5) # ffffffffc02154f8 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc020217a:	aebff0ef          	jal	ra,ffffffffc0201c64 <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020217e:	6098                	ld	a4,0(s1)
ffffffffc0202180:	c80007b7          	lui	a5,0xc8000
ffffffffc0202184:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc0202186:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202188:	0ce7eae3          	bltu	a5,a4,ffffffffc0202a5c <pmm_init+0xa52>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc020218c:	6008                	ld	a0,0(s0)
ffffffffc020218e:	44050463          	beqz	a0,ffffffffc02025d6 <pmm_init+0x5cc>
ffffffffc0202192:	6785                	lui	a5,0x1
ffffffffc0202194:	17fd                	addi	a5,a5,-1
ffffffffc0202196:	8fe9                	and	a5,a5,a0
ffffffffc0202198:	2781                	sext.w	a5,a5
ffffffffc020219a:	42079e63          	bnez	a5,ffffffffc02025d6 <pmm_init+0x5cc>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc020219e:	4601                	li	a2,0
ffffffffc02021a0:	4581                	li	a1,0
ffffffffc02021a2:	cd5ff0ef          	jal	ra,ffffffffc0201e76 <get_page>
ffffffffc02021a6:	78051b63          	bnez	a0,ffffffffc020293c <pmm_init+0x932>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc02021aa:	4505                	li	a0,1
ffffffffc02021ac:	9ebff0ef          	jal	ra,ffffffffc0201b96 <alloc_pages>
ffffffffc02021b0:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02021b2:	6008                	ld	a0,0(s0)
ffffffffc02021b4:	4681                	li	a3,0
ffffffffc02021b6:	4601                	li	a2,0
ffffffffc02021b8:	85d6                	mv	a1,s5
ffffffffc02021ba:	d93ff0ef          	jal	ra,ffffffffc0201f4c <page_insert>
ffffffffc02021be:	7a051f63          	bnez	a0,ffffffffc020297c <pmm_init+0x972>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02021c2:	6008                	ld	a0,0(s0)
ffffffffc02021c4:	4601                	li	a2,0
ffffffffc02021c6:	4581                	li	a1,0
ffffffffc02021c8:	addff0ef          	jal	ra,ffffffffc0201ca4 <get_pte>
ffffffffc02021cc:	78050863          	beqz	a0,ffffffffc020295c <pmm_init+0x952>
    assert(pte2page(*ptep) == p1);
ffffffffc02021d0:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02021d2:	0017f713          	andi	a4,a5,1
ffffffffc02021d6:	3e070463          	beqz	a4,ffffffffc02025be <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc02021da:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02021dc:	078a                	slli	a5,a5,0x2
ffffffffc02021de:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02021e0:	3ce7f163          	bleu	a4,a5,ffffffffc02025a2 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02021e4:	00093683          	ld	a3,0(s2)
ffffffffc02021e8:	fff80637          	lui	a2,0xfff80
ffffffffc02021ec:	97b2                	add	a5,a5,a2
ffffffffc02021ee:	079a                	slli	a5,a5,0x6
ffffffffc02021f0:	97b6                	add	a5,a5,a3
ffffffffc02021f2:	72fa9563          	bne	s5,a5,ffffffffc020291c <pmm_init+0x912>
    assert(page_ref(p1) == 1);
ffffffffc02021f6:	000aab83          	lw	s7,0(s5)
ffffffffc02021fa:	4785                	li	a5,1
ffffffffc02021fc:	70fb9063          	bne	s7,a5,ffffffffc02028fc <pmm_init+0x8f2>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202200:	6008                	ld	a0,0(s0)
ffffffffc0202202:	76fd                	lui	a3,0xfffff
ffffffffc0202204:	611c                	ld	a5,0(a0)
ffffffffc0202206:	078a                	slli	a5,a5,0x2
ffffffffc0202208:	8ff5                	and	a5,a5,a3
ffffffffc020220a:	00c7d613          	srli	a2,a5,0xc
ffffffffc020220e:	66e67e63          	bleu	a4,a2,ffffffffc020288a <pmm_init+0x880>
ffffffffc0202212:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202216:	97e2                	add	a5,a5,s8
ffffffffc0202218:	0007bb03          	ld	s6,0(a5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc020221c:	0b0a                	slli	s6,s6,0x2
ffffffffc020221e:	00db7b33          	and	s6,s6,a3
ffffffffc0202222:	00cb5793          	srli	a5,s6,0xc
ffffffffc0202226:	56e7f863          	bleu	a4,a5,ffffffffc0202796 <pmm_init+0x78c>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020222a:	4601                	li	a2,0
ffffffffc020222c:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020222e:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202230:	a75ff0ef          	jal	ra,ffffffffc0201ca4 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202234:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202236:	55651063          	bne	a0,s6,ffffffffc0202776 <pmm_init+0x76c>

    p2 = alloc_page();
ffffffffc020223a:	4505                	li	a0,1
ffffffffc020223c:	95bff0ef          	jal	ra,ffffffffc0201b96 <alloc_pages>
ffffffffc0202240:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202242:	6008                	ld	a0,0(s0)
ffffffffc0202244:	46d1                	li	a3,20
ffffffffc0202246:	6605                	lui	a2,0x1
ffffffffc0202248:	85da                	mv	a1,s6
ffffffffc020224a:	d03ff0ef          	jal	ra,ffffffffc0201f4c <page_insert>
ffffffffc020224e:	50051463          	bnez	a0,ffffffffc0202756 <pmm_init+0x74c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202252:	6008                	ld	a0,0(s0)
ffffffffc0202254:	4601                	li	a2,0
ffffffffc0202256:	6585                	lui	a1,0x1
ffffffffc0202258:	a4dff0ef          	jal	ra,ffffffffc0201ca4 <get_pte>
ffffffffc020225c:	4c050d63          	beqz	a0,ffffffffc0202736 <pmm_init+0x72c>
    assert(*ptep & PTE_U);
ffffffffc0202260:	611c                	ld	a5,0(a0)
ffffffffc0202262:	0107f713          	andi	a4,a5,16
ffffffffc0202266:	4a070863          	beqz	a4,ffffffffc0202716 <pmm_init+0x70c>
    assert(*ptep & PTE_W);
ffffffffc020226a:	8b91                	andi	a5,a5,4
ffffffffc020226c:	48078563          	beqz	a5,ffffffffc02026f6 <pmm_init+0x6ec>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0202270:	6008                	ld	a0,0(s0)
ffffffffc0202272:	611c                	ld	a5,0(a0)
ffffffffc0202274:	8bc1                	andi	a5,a5,16
ffffffffc0202276:	46078063          	beqz	a5,ffffffffc02026d6 <pmm_init+0x6cc>
    assert(page_ref(p2) == 1);
ffffffffc020227a:	000b2783          	lw	a5,0(s6)
ffffffffc020227e:	43779c63          	bne	a5,s7,ffffffffc02026b6 <pmm_init+0x6ac>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202282:	4681                	li	a3,0
ffffffffc0202284:	6605                	lui	a2,0x1
ffffffffc0202286:	85d6                	mv	a1,s5
ffffffffc0202288:	cc5ff0ef          	jal	ra,ffffffffc0201f4c <page_insert>
ffffffffc020228c:	40051563          	bnez	a0,ffffffffc0202696 <pmm_init+0x68c>
    assert(page_ref(p1) == 2);
ffffffffc0202290:	000aa703          	lw	a4,0(s5)
ffffffffc0202294:	4789                	li	a5,2
ffffffffc0202296:	3ef71063          	bne	a4,a5,ffffffffc0202676 <pmm_init+0x66c>
    assert(page_ref(p2) == 0);
ffffffffc020229a:	000b2783          	lw	a5,0(s6)
ffffffffc020229e:	3a079c63          	bnez	a5,ffffffffc0202656 <pmm_init+0x64c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02022a2:	6008                	ld	a0,0(s0)
ffffffffc02022a4:	4601                	li	a2,0
ffffffffc02022a6:	6585                	lui	a1,0x1
ffffffffc02022a8:	9fdff0ef          	jal	ra,ffffffffc0201ca4 <get_pte>
ffffffffc02022ac:	38050563          	beqz	a0,ffffffffc0202636 <pmm_init+0x62c>
    assert(pte2page(*ptep) == p1);
ffffffffc02022b0:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02022b2:	00177793          	andi	a5,a4,1
ffffffffc02022b6:	30078463          	beqz	a5,ffffffffc02025be <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc02022ba:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02022bc:	00271793          	slli	a5,a4,0x2
ffffffffc02022c0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02022c2:	2ed7f063          	bleu	a3,a5,ffffffffc02025a2 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02022c6:	00093683          	ld	a3,0(s2)
ffffffffc02022ca:	fff80637          	lui	a2,0xfff80
ffffffffc02022ce:	97b2                	add	a5,a5,a2
ffffffffc02022d0:	079a                	slli	a5,a5,0x6
ffffffffc02022d2:	97b6                	add	a5,a5,a3
ffffffffc02022d4:	32fa9163          	bne	s5,a5,ffffffffc02025f6 <pmm_init+0x5ec>
    assert((*ptep & PTE_U) == 0);
ffffffffc02022d8:	8b41                	andi	a4,a4,16
ffffffffc02022da:	70071163          	bnez	a4,ffffffffc02029dc <pmm_init+0x9d2>

    page_remove(boot_pgdir, 0x0);
ffffffffc02022de:	6008                	ld	a0,0(s0)
ffffffffc02022e0:	4581                	li	a1,0
ffffffffc02022e2:	bf7ff0ef          	jal	ra,ffffffffc0201ed8 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc02022e6:	000aa703          	lw	a4,0(s5)
ffffffffc02022ea:	4785                	li	a5,1
ffffffffc02022ec:	6cf71863          	bne	a4,a5,ffffffffc02029bc <pmm_init+0x9b2>
    assert(page_ref(p2) == 0);
ffffffffc02022f0:	000b2783          	lw	a5,0(s6)
ffffffffc02022f4:	6a079463          	bnez	a5,ffffffffc020299c <pmm_init+0x992>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc02022f8:	6008                	ld	a0,0(s0)
ffffffffc02022fa:	6585                	lui	a1,0x1
ffffffffc02022fc:	bddff0ef          	jal	ra,ffffffffc0201ed8 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0202300:	000aa783          	lw	a5,0(s5)
ffffffffc0202304:	50079363          	bnez	a5,ffffffffc020280a <pmm_init+0x800>
    assert(page_ref(p2) == 0);
ffffffffc0202308:	000b2783          	lw	a5,0(s6)
ffffffffc020230c:	4c079f63          	bnez	a5,ffffffffc02027ea <pmm_init+0x7e0>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202310:	00043a83          	ld	s5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202314:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202316:	000ab783          	ld	a5,0(s5)
ffffffffc020231a:	078a                	slli	a5,a5,0x2
ffffffffc020231c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020231e:	28c7f263          	bleu	a2,a5,ffffffffc02025a2 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202322:	fff80737          	lui	a4,0xfff80
ffffffffc0202326:	00093503          	ld	a0,0(s2)
ffffffffc020232a:	97ba                	add	a5,a5,a4
ffffffffc020232c:	079a                	slli	a5,a5,0x6
ffffffffc020232e:	00f50733          	add	a4,a0,a5
ffffffffc0202332:	4314                	lw	a3,0(a4)
ffffffffc0202334:	4705                	li	a4,1
ffffffffc0202336:	48e69a63          	bne	a3,a4,ffffffffc02027ca <pmm_init+0x7c0>
    return page - pages + nbase;
ffffffffc020233a:	8799                	srai	a5,a5,0x6
ffffffffc020233c:	00080b37          	lui	s6,0x80
    return KADDR(page2pa(page));
ffffffffc0202340:	577d                	li	a4,-1
    return page - pages + nbase;
ffffffffc0202342:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc0202344:	8331                	srli	a4,a4,0xc
ffffffffc0202346:	8f7d                	and	a4,a4,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0202348:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc020234a:	46c77363          	bleu	a2,a4,ffffffffc02027b0 <pmm_init+0x7a6>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc020234e:	0009b683          	ld	a3,0(s3)
ffffffffc0202352:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc0202354:	639c                	ld	a5,0(a5)
ffffffffc0202356:	078a                	slli	a5,a5,0x2
ffffffffc0202358:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020235a:	24c7f463          	bleu	a2,a5,ffffffffc02025a2 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc020235e:	416787b3          	sub	a5,a5,s6
ffffffffc0202362:	079a                	slli	a5,a5,0x6
ffffffffc0202364:	953e                	add	a0,a0,a5
ffffffffc0202366:	4585                	li	a1,1
ffffffffc0202368:	8b7ff0ef          	jal	ra,ffffffffc0201c1e <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020236c:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage) {
ffffffffc0202370:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202372:	078a                	slli	a5,a5,0x2
ffffffffc0202374:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202376:	22e7f663          	bleu	a4,a5,ffffffffc02025a2 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc020237a:	00093503          	ld	a0,0(s2)
ffffffffc020237e:	416787b3          	sub	a5,a5,s6
ffffffffc0202382:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0202384:	953e                	add	a0,a0,a5
ffffffffc0202386:	4585                	li	a1,1
ffffffffc0202388:	897ff0ef          	jal	ra,ffffffffc0201c1e <free_pages>
    boot_pgdir[0] = 0;
ffffffffc020238c:	601c                	ld	a5,0(s0)
ffffffffc020238e:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc0202392:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202396:	8cfff0ef          	jal	ra,ffffffffc0201c64 <nr_free_pages>
ffffffffc020239a:	68aa1163          	bne	s4,a0,ffffffffc0202a1c <pmm_init+0xa12>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc020239e:	00004517          	auipc	a0,0x4
ffffffffc02023a2:	d5a50513          	addi	a0,a0,-678 # ffffffffc02060f8 <default_pmm_manager+0x4e8>
ffffffffc02023a6:	de9fd0ef          	jal	ra,ffffffffc020018e <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc02023aa:	8bbff0ef          	jal	ra,ffffffffc0201c64 <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02023ae:	6098                	ld	a4,0(s1)
ffffffffc02023b0:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc02023b4:	8a2a                	mv	s4,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02023b6:	00c71693          	slli	a3,a4,0xc
ffffffffc02023ba:	18d7f563          	bleu	a3,a5,ffffffffc0202544 <pmm_init+0x53a>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02023be:	83b1                	srli	a5,a5,0xc
ffffffffc02023c0:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02023c2:	c0200ab7          	lui	s5,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02023c6:	1ae7f163          	bleu	a4,a5,ffffffffc0202568 <pmm_init+0x55e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02023ca:	7bfd                	lui	s7,0xfffff
ffffffffc02023cc:	6b05                	lui	s6,0x1
ffffffffc02023ce:	a029                	j	ffffffffc02023d8 <pmm_init+0x3ce>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02023d0:	00cad713          	srli	a4,s5,0xc
ffffffffc02023d4:	18f77a63          	bleu	a5,a4,ffffffffc0202568 <pmm_init+0x55e>
ffffffffc02023d8:	0009b583          	ld	a1,0(s3)
ffffffffc02023dc:	4601                	li	a2,0
ffffffffc02023de:	95d6                	add	a1,a1,s5
ffffffffc02023e0:	8c5ff0ef          	jal	ra,ffffffffc0201ca4 <get_pte>
ffffffffc02023e4:	16050263          	beqz	a0,ffffffffc0202548 <pmm_init+0x53e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02023e8:	611c                	ld	a5,0(a0)
ffffffffc02023ea:	078a                	slli	a5,a5,0x2
ffffffffc02023ec:	0177f7b3          	and	a5,a5,s7
ffffffffc02023f0:	19579963          	bne	a5,s5,ffffffffc0202582 <pmm_init+0x578>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02023f4:	609c                	ld	a5,0(s1)
ffffffffc02023f6:	9ada                	add	s5,s5,s6
ffffffffc02023f8:	6008                	ld	a0,0(s0)
ffffffffc02023fa:	00c79713          	slli	a4,a5,0xc
ffffffffc02023fe:	fceae9e3          	bltu	s5,a4,ffffffffc02023d0 <pmm_init+0x3c6>
    }

    assert(boot_pgdir[0] == 0);
ffffffffc0202402:	611c                	ld	a5,0(a0)
ffffffffc0202404:	62079c63          	bnez	a5,ffffffffc0202a3c <pmm_init+0xa32>

    struct Page *p;
    p = alloc_page();
ffffffffc0202408:	4505                	li	a0,1
ffffffffc020240a:	f8cff0ef          	jal	ra,ffffffffc0201b96 <alloc_pages>
ffffffffc020240e:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202410:	6008                	ld	a0,0(s0)
ffffffffc0202412:	4699                	li	a3,6
ffffffffc0202414:	10000613          	li	a2,256
ffffffffc0202418:	85d6                	mv	a1,s5
ffffffffc020241a:	b33ff0ef          	jal	ra,ffffffffc0201f4c <page_insert>
ffffffffc020241e:	1e051c63          	bnez	a0,ffffffffc0202616 <pmm_init+0x60c>
    assert(page_ref(p) == 1);
ffffffffc0202422:	000aa703          	lw	a4,0(s5) # ffffffffc0200000 <kern_entry>
ffffffffc0202426:	4785                	li	a5,1
ffffffffc0202428:	44f71163          	bne	a4,a5,ffffffffc020286a <pmm_init+0x860>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020242c:	6008                	ld	a0,0(s0)
ffffffffc020242e:	6b05                	lui	s6,0x1
ffffffffc0202430:	4699                	li	a3,6
ffffffffc0202432:	100b0613          	addi	a2,s6,256 # 1100 <BASE_ADDRESS-0xffffffffc01fef00>
ffffffffc0202436:	85d6                	mv	a1,s5
ffffffffc0202438:	b15ff0ef          	jal	ra,ffffffffc0201f4c <page_insert>
ffffffffc020243c:	40051763          	bnez	a0,ffffffffc020284a <pmm_init+0x840>
    assert(page_ref(p) == 2);
ffffffffc0202440:	000aa703          	lw	a4,0(s5)
ffffffffc0202444:	4789                	li	a5,2
ffffffffc0202446:	3ef71263          	bne	a4,a5,ffffffffc020282a <pmm_init+0x820>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc020244a:	00004597          	auipc	a1,0x4
ffffffffc020244e:	de658593          	addi	a1,a1,-538 # ffffffffc0206230 <default_pmm_manager+0x620>
ffffffffc0202452:	10000513          	li	a0,256
ffffffffc0202456:	1cf020ef          	jal	ra,ffffffffc0204e24 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020245a:	100b0593          	addi	a1,s6,256
ffffffffc020245e:	10000513          	li	a0,256
ffffffffc0202462:	1d5020ef          	jal	ra,ffffffffc0204e36 <strcmp>
ffffffffc0202466:	44051b63          	bnez	a0,ffffffffc02028bc <pmm_init+0x8b2>
    return page - pages + nbase;
ffffffffc020246a:	00093683          	ld	a3,0(s2)
ffffffffc020246e:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0202472:	5b7d                	li	s6,-1
    return page - pages + nbase;
ffffffffc0202474:	40da86b3          	sub	a3,s5,a3
ffffffffc0202478:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc020247a:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc020247c:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc020247e:	00cb5b13          	srli	s6,s6,0xc
ffffffffc0202482:	0166f733          	and	a4,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202486:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202488:	10f77f63          	bleu	a5,a4,ffffffffc02025a6 <pmm_init+0x59c>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc020248c:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202490:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202494:	96be                	add	a3,a3,a5
ffffffffc0202496:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fde9b08>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020249a:	147020ef          	jal	ra,ffffffffc0204de0 <strlen>
ffffffffc020249e:	54051f63          	bnez	a0,ffffffffc02029fc <pmm_init+0x9f2>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02024a2:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02024a6:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02024a8:	000bb683          	ld	a3,0(s7) # fffffffffffff000 <end+0x3fde9a08>
ffffffffc02024ac:	068a                	slli	a3,a3,0x2
ffffffffc02024ae:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc02024b0:	0ef6f963          	bleu	a5,a3,ffffffffc02025a2 <pmm_init+0x598>
    return KADDR(page2pa(page));
ffffffffc02024b4:	0166fb33          	and	s6,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc02024b8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02024ba:	0efb7663          	bleu	a5,s6,ffffffffc02025a6 <pmm_init+0x59c>
ffffffffc02024be:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc02024c2:	4585                	li	a1,1
ffffffffc02024c4:	8556                	mv	a0,s5
ffffffffc02024c6:	99b6                	add	s3,s3,a3
ffffffffc02024c8:	f56ff0ef          	jal	ra,ffffffffc0201c1e <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02024cc:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc02024d0:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02024d2:	078a                	slli	a5,a5,0x2
ffffffffc02024d4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02024d6:	0ce7f663          	bleu	a4,a5,ffffffffc02025a2 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02024da:	00093503          	ld	a0,0(s2)
ffffffffc02024de:	fff809b7          	lui	s3,0xfff80
ffffffffc02024e2:	97ce                	add	a5,a5,s3
ffffffffc02024e4:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc02024e6:	953e                	add	a0,a0,a5
ffffffffc02024e8:	4585                	li	a1,1
ffffffffc02024ea:	f34ff0ef          	jal	ra,ffffffffc0201c1e <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02024ee:	000bb783          	ld	a5,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc02024f2:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02024f4:	078a                	slli	a5,a5,0x2
ffffffffc02024f6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02024f8:	0ae7f563          	bleu	a4,a5,ffffffffc02025a2 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02024fc:	00093503          	ld	a0,0(s2)
ffffffffc0202500:	97ce                	add	a5,a5,s3
ffffffffc0202502:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0202504:	953e                	add	a0,a0,a5
ffffffffc0202506:	4585                	li	a1,1
ffffffffc0202508:	f16ff0ef          	jal	ra,ffffffffc0201c1e <free_pages>
    boot_pgdir[0] = 0;
ffffffffc020250c:	601c                	ld	a5,0(s0)
ffffffffc020250e:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>
  asm volatile("sfence.vma");
ffffffffc0202512:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202516:	f4eff0ef          	jal	ra,ffffffffc0201c64 <nr_free_pages>
ffffffffc020251a:	3caa1163          	bne	s4,a0,ffffffffc02028dc <pmm_init+0x8d2>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc020251e:	00004517          	auipc	a0,0x4
ffffffffc0202522:	d8a50513          	addi	a0,a0,-630 # ffffffffc02062a8 <default_pmm_manager+0x698>
ffffffffc0202526:	c69fd0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc020252a:	6406                	ld	s0,64(sp)
ffffffffc020252c:	60a6                	ld	ra,72(sp)
ffffffffc020252e:	74e2                	ld	s1,56(sp)
ffffffffc0202530:	7942                	ld	s2,48(sp)
ffffffffc0202532:	79a2                	ld	s3,40(sp)
ffffffffc0202534:	7a02                	ld	s4,32(sp)
ffffffffc0202536:	6ae2                	ld	s5,24(sp)
ffffffffc0202538:	6b42                	ld	s6,16(sp)
ffffffffc020253a:	6ba2                	ld	s7,8(sp)
ffffffffc020253c:	6c02                	ld	s8,0(sp)
ffffffffc020253e:	6161                	addi	sp,sp,80
    kmalloc_init();
ffffffffc0202540:	c3aff06f          	j	ffffffffc020197a <kmalloc_init>
ffffffffc0202544:	6008                	ld	a0,0(s0)
ffffffffc0202546:	bd75                	j	ffffffffc0202402 <pmm_init+0x3f8>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202548:	00004697          	auipc	a3,0x4
ffffffffc020254c:	bd068693          	addi	a3,a3,-1072 # ffffffffc0206118 <default_pmm_manager+0x508>
ffffffffc0202550:	00003617          	auipc	a2,0x3
ffffffffc0202554:	32860613          	addi	a2,a2,808 # ffffffffc0205878 <commands+0x870>
ffffffffc0202558:	19d00593          	li	a1,413
ffffffffc020255c:	00003517          	auipc	a0,0x3
ffffffffc0202560:	7f450513          	addi	a0,a0,2036 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc0202564:	eedfd0ef          	jal	ra,ffffffffc0200450 <__panic>
ffffffffc0202568:	86d6                	mv	a3,s5
ffffffffc020256a:	00003617          	auipc	a2,0x3
ffffffffc020256e:	6f660613          	addi	a2,a2,1782 # ffffffffc0205c60 <default_pmm_manager+0x50>
ffffffffc0202572:	19d00593          	li	a1,413
ffffffffc0202576:	00003517          	auipc	a0,0x3
ffffffffc020257a:	7da50513          	addi	a0,a0,2010 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc020257e:	ed3fd0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202582:	00004697          	auipc	a3,0x4
ffffffffc0202586:	bd668693          	addi	a3,a3,-1066 # ffffffffc0206158 <default_pmm_manager+0x548>
ffffffffc020258a:	00003617          	auipc	a2,0x3
ffffffffc020258e:	2ee60613          	addi	a2,a2,750 # ffffffffc0205878 <commands+0x870>
ffffffffc0202592:	19e00593          	li	a1,414
ffffffffc0202596:	00003517          	auipc	a0,0x3
ffffffffc020259a:	7ba50513          	addi	a0,a0,1978 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc020259e:	eb3fd0ef          	jal	ra,ffffffffc0200450 <__panic>
ffffffffc02025a2:	dd8ff0ef          	jal	ra,ffffffffc0201b7a <pa2page.part.4>
    return KADDR(page2pa(page));
ffffffffc02025a6:	00003617          	auipc	a2,0x3
ffffffffc02025aa:	6ba60613          	addi	a2,a2,1722 # ffffffffc0205c60 <default_pmm_manager+0x50>
ffffffffc02025ae:	06900593          	li	a1,105
ffffffffc02025b2:	00003517          	auipc	a0,0x3
ffffffffc02025b6:	6d650513          	addi	a0,a0,1750 # ffffffffc0205c88 <default_pmm_manager+0x78>
ffffffffc02025ba:	e97fd0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02025be:	00004617          	auipc	a2,0x4
ffffffffc02025c2:	92a60613          	addi	a2,a2,-1750 # ffffffffc0205ee8 <default_pmm_manager+0x2d8>
ffffffffc02025c6:	07400593          	li	a1,116
ffffffffc02025ca:	00003517          	auipc	a0,0x3
ffffffffc02025ce:	6be50513          	addi	a0,a0,1726 # ffffffffc0205c88 <default_pmm_manager+0x78>
ffffffffc02025d2:	e7ffd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02025d6:	00004697          	auipc	a3,0x4
ffffffffc02025da:	85268693          	addi	a3,a3,-1966 # ffffffffc0205e28 <default_pmm_manager+0x218>
ffffffffc02025de:	00003617          	auipc	a2,0x3
ffffffffc02025e2:	29a60613          	addi	a2,a2,666 # ffffffffc0205878 <commands+0x870>
ffffffffc02025e6:	16100593          	li	a1,353
ffffffffc02025ea:	00003517          	auipc	a0,0x3
ffffffffc02025ee:	76650513          	addi	a0,a0,1894 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc02025f2:	e5ffd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02025f6:	00004697          	auipc	a3,0x4
ffffffffc02025fa:	91a68693          	addi	a3,a3,-1766 # ffffffffc0205f10 <default_pmm_manager+0x300>
ffffffffc02025fe:	00003617          	auipc	a2,0x3
ffffffffc0202602:	27a60613          	addi	a2,a2,634 # ffffffffc0205878 <commands+0x870>
ffffffffc0202606:	17d00593          	li	a1,381
ffffffffc020260a:	00003517          	auipc	a0,0x3
ffffffffc020260e:	74650513          	addi	a0,a0,1862 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc0202612:	e3ffd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202616:	00004697          	auipc	a3,0x4
ffffffffc020261a:	b7268693          	addi	a3,a3,-1166 # ffffffffc0206188 <default_pmm_manager+0x578>
ffffffffc020261e:	00003617          	auipc	a2,0x3
ffffffffc0202622:	25a60613          	addi	a2,a2,602 # ffffffffc0205878 <commands+0x870>
ffffffffc0202626:	1a500593          	li	a1,421
ffffffffc020262a:	00003517          	auipc	a0,0x3
ffffffffc020262e:	72650513          	addi	a0,a0,1830 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc0202632:	e1ffd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202636:	00004697          	auipc	a3,0x4
ffffffffc020263a:	96a68693          	addi	a3,a3,-1686 # ffffffffc0205fa0 <default_pmm_manager+0x390>
ffffffffc020263e:	00003617          	auipc	a2,0x3
ffffffffc0202642:	23a60613          	addi	a2,a2,570 # ffffffffc0205878 <commands+0x870>
ffffffffc0202646:	17c00593          	li	a1,380
ffffffffc020264a:	00003517          	auipc	a0,0x3
ffffffffc020264e:	70650513          	addi	a0,a0,1798 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc0202652:	dfffd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202656:	00004697          	auipc	a3,0x4
ffffffffc020265a:	a1268693          	addi	a3,a3,-1518 # ffffffffc0206068 <default_pmm_manager+0x458>
ffffffffc020265e:	00003617          	auipc	a2,0x3
ffffffffc0202662:	21a60613          	addi	a2,a2,538 # ffffffffc0205878 <commands+0x870>
ffffffffc0202666:	17b00593          	li	a1,379
ffffffffc020266a:	00003517          	auipc	a0,0x3
ffffffffc020266e:	6e650513          	addi	a0,a0,1766 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc0202672:	ddffd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0202676:	00004697          	auipc	a3,0x4
ffffffffc020267a:	9da68693          	addi	a3,a3,-1574 # ffffffffc0206050 <default_pmm_manager+0x440>
ffffffffc020267e:	00003617          	auipc	a2,0x3
ffffffffc0202682:	1fa60613          	addi	a2,a2,506 # ffffffffc0205878 <commands+0x870>
ffffffffc0202686:	17a00593          	li	a1,378
ffffffffc020268a:	00003517          	auipc	a0,0x3
ffffffffc020268e:	6c650513          	addi	a0,a0,1734 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc0202692:	dbffd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202696:	00004697          	auipc	a3,0x4
ffffffffc020269a:	98a68693          	addi	a3,a3,-1654 # ffffffffc0206020 <default_pmm_manager+0x410>
ffffffffc020269e:	00003617          	auipc	a2,0x3
ffffffffc02026a2:	1da60613          	addi	a2,a2,474 # ffffffffc0205878 <commands+0x870>
ffffffffc02026a6:	17900593          	li	a1,377
ffffffffc02026aa:	00003517          	auipc	a0,0x3
ffffffffc02026ae:	6a650513          	addi	a0,a0,1702 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc02026b2:	d9ffd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc02026b6:	00004697          	auipc	a3,0x4
ffffffffc02026ba:	95268693          	addi	a3,a3,-1710 # ffffffffc0206008 <default_pmm_manager+0x3f8>
ffffffffc02026be:	00003617          	auipc	a2,0x3
ffffffffc02026c2:	1ba60613          	addi	a2,a2,442 # ffffffffc0205878 <commands+0x870>
ffffffffc02026c6:	17700593          	li	a1,375
ffffffffc02026ca:	00003517          	auipc	a0,0x3
ffffffffc02026ce:	68650513          	addi	a0,a0,1670 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc02026d2:	d7ffd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02026d6:	00004697          	auipc	a3,0x4
ffffffffc02026da:	91a68693          	addi	a3,a3,-1766 # ffffffffc0205ff0 <default_pmm_manager+0x3e0>
ffffffffc02026de:	00003617          	auipc	a2,0x3
ffffffffc02026e2:	19a60613          	addi	a2,a2,410 # ffffffffc0205878 <commands+0x870>
ffffffffc02026e6:	17600593          	li	a1,374
ffffffffc02026ea:	00003517          	auipc	a0,0x3
ffffffffc02026ee:	66650513          	addi	a0,a0,1638 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc02026f2:	d5ffd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(*ptep & PTE_W);
ffffffffc02026f6:	00004697          	auipc	a3,0x4
ffffffffc02026fa:	8ea68693          	addi	a3,a3,-1814 # ffffffffc0205fe0 <default_pmm_manager+0x3d0>
ffffffffc02026fe:	00003617          	auipc	a2,0x3
ffffffffc0202702:	17a60613          	addi	a2,a2,378 # ffffffffc0205878 <commands+0x870>
ffffffffc0202706:	17500593          	li	a1,373
ffffffffc020270a:	00003517          	auipc	a0,0x3
ffffffffc020270e:	64650513          	addi	a0,a0,1606 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc0202712:	d3ffd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202716:	00004697          	auipc	a3,0x4
ffffffffc020271a:	8ba68693          	addi	a3,a3,-1862 # ffffffffc0205fd0 <default_pmm_manager+0x3c0>
ffffffffc020271e:	00003617          	auipc	a2,0x3
ffffffffc0202722:	15a60613          	addi	a2,a2,346 # ffffffffc0205878 <commands+0x870>
ffffffffc0202726:	17400593          	li	a1,372
ffffffffc020272a:	00003517          	auipc	a0,0x3
ffffffffc020272e:	62650513          	addi	a0,a0,1574 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc0202732:	d1ffd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202736:	00004697          	auipc	a3,0x4
ffffffffc020273a:	86a68693          	addi	a3,a3,-1942 # ffffffffc0205fa0 <default_pmm_manager+0x390>
ffffffffc020273e:	00003617          	auipc	a2,0x3
ffffffffc0202742:	13a60613          	addi	a2,a2,314 # ffffffffc0205878 <commands+0x870>
ffffffffc0202746:	17300593          	li	a1,371
ffffffffc020274a:	00003517          	auipc	a0,0x3
ffffffffc020274e:	60650513          	addi	a0,a0,1542 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc0202752:	cfffd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202756:	00004697          	auipc	a3,0x4
ffffffffc020275a:	81268693          	addi	a3,a3,-2030 # ffffffffc0205f68 <default_pmm_manager+0x358>
ffffffffc020275e:	00003617          	auipc	a2,0x3
ffffffffc0202762:	11a60613          	addi	a2,a2,282 # ffffffffc0205878 <commands+0x870>
ffffffffc0202766:	17200593          	li	a1,370
ffffffffc020276a:	00003517          	auipc	a0,0x3
ffffffffc020276e:	5e650513          	addi	a0,a0,1510 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc0202772:	cdffd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202776:	00003697          	auipc	a3,0x3
ffffffffc020277a:	7ca68693          	addi	a3,a3,1994 # ffffffffc0205f40 <default_pmm_manager+0x330>
ffffffffc020277e:	00003617          	auipc	a2,0x3
ffffffffc0202782:	0fa60613          	addi	a2,a2,250 # ffffffffc0205878 <commands+0x870>
ffffffffc0202786:	16f00593          	li	a1,367
ffffffffc020278a:	00003517          	auipc	a0,0x3
ffffffffc020278e:	5c650513          	addi	a0,a0,1478 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc0202792:	cbffd0ef          	jal	ra,ffffffffc0200450 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202796:	86da                	mv	a3,s6
ffffffffc0202798:	00003617          	auipc	a2,0x3
ffffffffc020279c:	4c860613          	addi	a2,a2,1224 # ffffffffc0205c60 <default_pmm_manager+0x50>
ffffffffc02027a0:	16e00593          	li	a1,366
ffffffffc02027a4:	00003517          	auipc	a0,0x3
ffffffffc02027a8:	5ac50513          	addi	a0,a0,1452 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc02027ac:	ca5fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    return KADDR(page2pa(page));
ffffffffc02027b0:	86be                	mv	a3,a5
ffffffffc02027b2:	00003617          	auipc	a2,0x3
ffffffffc02027b6:	4ae60613          	addi	a2,a2,1198 # ffffffffc0205c60 <default_pmm_manager+0x50>
ffffffffc02027ba:	06900593          	li	a1,105
ffffffffc02027be:	00003517          	auipc	a0,0x3
ffffffffc02027c2:	4ca50513          	addi	a0,a0,1226 # ffffffffc0205c88 <default_pmm_manager+0x78>
ffffffffc02027c6:	c8bfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02027ca:	00004697          	auipc	a3,0x4
ffffffffc02027ce:	8e668693          	addi	a3,a3,-1818 # ffffffffc02060b0 <default_pmm_manager+0x4a0>
ffffffffc02027d2:	00003617          	auipc	a2,0x3
ffffffffc02027d6:	0a660613          	addi	a2,a2,166 # ffffffffc0205878 <commands+0x870>
ffffffffc02027da:	18800593          	li	a1,392
ffffffffc02027de:	00003517          	auipc	a0,0x3
ffffffffc02027e2:	57250513          	addi	a0,a0,1394 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc02027e6:	c6bfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02027ea:	00004697          	auipc	a3,0x4
ffffffffc02027ee:	87e68693          	addi	a3,a3,-1922 # ffffffffc0206068 <default_pmm_manager+0x458>
ffffffffc02027f2:	00003617          	auipc	a2,0x3
ffffffffc02027f6:	08660613          	addi	a2,a2,134 # ffffffffc0205878 <commands+0x870>
ffffffffc02027fa:	18600593          	li	a1,390
ffffffffc02027fe:	00003517          	auipc	a0,0x3
ffffffffc0202802:	55250513          	addi	a0,a0,1362 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc0202806:	c4bfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc020280a:	00004697          	auipc	a3,0x4
ffffffffc020280e:	88e68693          	addi	a3,a3,-1906 # ffffffffc0206098 <default_pmm_manager+0x488>
ffffffffc0202812:	00003617          	auipc	a2,0x3
ffffffffc0202816:	06660613          	addi	a2,a2,102 # ffffffffc0205878 <commands+0x870>
ffffffffc020281a:	18500593          	li	a1,389
ffffffffc020281e:	00003517          	auipc	a0,0x3
ffffffffc0202822:	53250513          	addi	a0,a0,1330 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc0202826:	c2bfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p) == 2);
ffffffffc020282a:	00004697          	auipc	a3,0x4
ffffffffc020282e:	9ee68693          	addi	a3,a3,-1554 # ffffffffc0206218 <default_pmm_manager+0x608>
ffffffffc0202832:	00003617          	auipc	a2,0x3
ffffffffc0202836:	04660613          	addi	a2,a2,70 # ffffffffc0205878 <commands+0x870>
ffffffffc020283a:	1a800593          	li	a1,424
ffffffffc020283e:	00003517          	auipc	a0,0x3
ffffffffc0202842:	51250513          	addi	a0,a0,1298 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc0202846:	c0bfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020284a:	00004697          	auipc	a3,0x4
ffffffffc020284e:	98e68693          	addi	a3,a3,-1650 # ffffffffc02061d8 <default_pmm_manager+0x5c8>
ffffffffc0202852:	00003617          	auipc	a2,0x3
ffffffffc0202856:	02660613          	addi	a2,a2,38 # ffffffffc0205878 <commands+0x870>
ffffffffc020285a:	1a700593          	li	a1,423
ffffffffc020285e:	00003517          	auipc	a0,0x3
ffffffffc0202862:	4f250513          	addi	a0,a0,1266 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc0202866:	bebfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p) == 1);
ffffffffc020286a:	00004697          	auipc	a3,0x4
ffffffffc020286e:	95668693          	addi	a3,a3,-1706 # ffffffffc02061c0 <default_pmm_manager+0x5b0>
ffffffffc0202872:	00003617          	auipc	a2,0x3
ffffffffc0202876:	00660613          	addi	a2,a2,6 # ffffffffc0205878 <commands+0x870>
ffffffffc020287a:	1a600593          	li	a1,422
ffffffffc020287e:	00003517          	auipc	a0,0x3
ffffffffc0202882:	4d250513          	addi	a0,a0,1234 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc0202886:	bcbfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc020288a:	86be                	mv	a3,a5
ffffffffc020288c:	00003617          	auipc	a2,0x3
ffffffffc0202890:	3d460613          	addi	a2,a2,980 # ffffffffc0205c60 <default_pmm_manager+0x50>
ffffffffc0202894:	16d00593          	li	a1,365
ffffffffc0202898:	00003517          	auipc	a0,0x3
ffffffffc020289c:	4b850513          	addi	a0,a0,1208 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc02028a0:	bb1fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02028a4:	00003617          	auipc	a2,0x3
ffffffffc02028a8:	3f460613          	addi	a2,a2,1012 # ffffffffc0205c98 <default_pmm_manager+0x88>
ffffffffc02028ac:	07f00593          	li	a1,127
ffffffffc02028b0:	00003517          	auipc	a0,0x3
ffffffffc02028b4:	4a050513          	addi	a0,a0,1184 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc02028b8:	b99fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02028bc:	00004697          	auipc	a3,0x4
ffffffffc02028c0:	98c68693          	addi	a3,a3,-1652 # ffffffffc0206248 <default_pmm_manager+0x638>
ffffffffc02028c4:	00003617          	auipc	a2,0x3
ffffffffc02028c8:	fb460613          	addi	a2,a2,-76 # ffffffffc0205878 <commands+0x870>
ffffffffc02028cc:	1ac00593          	li	a1,428
ffffffffc02028d0:	00003517          	auipc	a0,0x3
ffffffffc02028d4:	48050513          	addi	a0,a0,1152 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc02028d8:	b79fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02028dc:	00003697          	auipc	a3,0x3
ffffffffc02028e0:	7fc68693          	addi	a3,a3,2044 # ffffffffc02060d8 <default_pmm_manager+0x4c8>
ffffffffc02028e4:	00003617          	auipc	a2,0x3
ffffffffc02028e8:	f9460613          	addi	a2,a2,-108 # ffffffffc0205878 <commands+0x870>
ffffffffc02028ec:	1b800593          	li	a1,440
ffffffffc02028f0:	00003517          	auipc	a0,0x3
ffffffffc02028f4:	46050513          	addi	a0,a0,1120 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc02028f8:	b59fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02028fc:	00003697          	auipc	a3,0x3
ffffffffc0202900:	62c68693          	addi	a3,a3,1580 # ffffffffc0205f28 <default_pmm_manager+0x318>
ffffffffc0202904:	00003617          	auipc	a2,0x3
ffffffffc0202908:	f7460613          	addi	a2,a2,-140 # ffffffffc0205878 <commands+0x870>
ffffffffc020290c:	16b00593          	li	a1,363
ffffffffc0202910:	00003517          	auipc	a0,0x3
ffffffffc0202914:	44050513          	addi	a0,a0,1088 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc0202918:	b39fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020291c:	00003697          	auipc	a3,0x3
ffffffffc0202920:	5f468693          	addi	a3,a3,1524 # ffffffffc0205f10 <default_pmm_manager+0x300>
ffffffffc0202924:	00003617          	auipc	a2,0x3
ffffffffc0202928:	f5460613          	addi	a2,a2,-172 # ffffffffc0205878 <commands+0x870>
ffffffffc020292c:	16a00593          	li	a1,362
ffffffffc0202930:	00003517          	auipc	a0,0x3
ffffffffc0202934:	42050513          	addi	a0,a0,1056 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc0202938:	b19fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc020293c:	00003697          	auipc	a3,0x3
ffffffffc0202940:	52468693          	addi	a3,a3,1316 # ffffffffc0205e60 <default_pmm_manager+0x250>
ffffffffc0202944:	00003617          	auipc	a2,0x3
ffffffffc0202948:	f3460613          	addi	a2,a2,-204 # ffffffffc0205878 <commands+0x870>
ffffffffc020294c:	16200593          	li	a1,354
ffffffffc0202950:	00003517          	auipc	a0,0x3
ffffffffc0202954:	40050513          	addi	a0,a0,1024 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc0202958:	af9fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc020295c:	00003697          	auipc	a3,0x3
ffffffffc0202960:	55c68693          	addi	a3,a3,1372 # ffffffffc0205eb8 <default_pmm_manager+0x2a8>
ffffffffc0202964:	00003617          	auipc	a2,0x3
ffffffffc0202968:	f1460613          	addi	a2,a2,-236 # ffffffffc0205878 <commands+0x870>
ffffffffc020296c:	16900593          	li	a1,361
ffffffffc0202970:	00003517          	auipc	a0,0x3
ffffffffc0202974:	3e050513          	addi	a0,a0,992 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc0202978:	ad9fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc020297c:	00003697          	auipc	a3,0x3
ffffffffc0202980:	50c68693          	addi	a3,a3,1292 # ffffffffc0205e88 <default_pmm_manager+0x278>
ffffffffc0202984:	00003617          	auipc	a2,0x3
ffffffffc0202988:	ef460613          	addi	a2,a2,-268 # ffffffffc0205878 <commands+0x870>
ffffffffc020298c:	16600593          	li	a1,358
ffffffffc0202990:	00003517          	auipc	a0,0x3
ffffffffc0202994:	3c050513          	addi	a0,a0,960 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc0202998:	ab9fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020299c:	00003697          	auipc	a3,0x3
ffffffffc02029a0:	6cc68693          	addi	a3,a3,1740 # ffffffffc0206068 <default_pmm_manager+0x458>
ffffffffc02029a4:	00003617          	auipc	a2,0x3
ffffffffc02029a8:	ed460613          	addi	a2,a2,-300 # ffffffffc0205878 <commands+0x870>
ffffffffc02029ac:	18200593          	li	a1,386
ffffffffc02029b0:	00003517          	auipc	a0,0x3
ffffffffc02029b4:	3a050513          	addi	a0,a0,928 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc02029b8:	a99fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02029bc:	00003697          	auipc	a3,0x3
ffffffffc02029c0:	56c68693          	addi	a3,a3,1388 # ffffffffc0205f28 <default_pmm_manager+0x318>
ffffffffc02029c4:	00003617          	auipc	a2,0x3
ffffffffc02029c8:	eb460613          	addi	a2,a2,-332 # ffffffffc0205878 <commands+0x870>
ffffffffc02029cc:	18100593          	li	a1,385
ffffffffc02029d0:	00003517          	auipc	a0,0x3
ffffffffc02029d4:	38050513          	addi	a0,a0,896 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc02029d8:	a79fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02029dc:	00003697          	auipc	a3,0x3
ffffffffc02029e0:	6a468693          	addi	a3,a3,1700 # ffffffffc0206080 <default_pmm_manager+0x470>
ffffffffc02029e4:	00003617          	auipc	a2,0x3
ffffffffc02029e8:	e9460613          	addi	a2,a2,-364 # ffffffffc0205878 <commands+0x870>
ffffffffc02029ec:	17e00593          	li	a1,382
ffffffffc02029f0:	00003517          	auipc	a0,0x3
ffffffffc02029f4:	36050513          	addi	a0,a0,864 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc02029f8:	a59fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02029fc:	00004697          	auipc	a3,0x4
ffffffffc0202a00:	88468693          	addi	a3,a3,-1916 # ffffffffc0206280 <default_pmm_manager+0x670>
ffffffffc0202a04:	00003617          	auipc	a2,0x3
ffffffffc0202a08:	e7460613          	addi	a2,a2,-396 # ffffffffc0205878 <commands+0x870>
ffffffffc0202a0c:	1af00593          	li	a1,431
ffffffffc0202a10:	00003517          	auipc	a0,0x3
ffffffffc0202a14:	34050513          	addi	a0,a0,832 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc0202a18:	a39fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202a1c:	00003697          	auipc	a3,0x3
ffffffffc0202a20:	6bc68693          	addi	a3,a3,1724 # ffffffffc02060d8 <default_pmm_manager+0x4c8>
ffffffffc0202a24:	00003617          	auipc	a2,0x3
ffffffffc0202a28:	e5460613          	addi	a2,a2,-428 # ffffffffc0205878 <commands+0x870>
ffffffffc0202a2c:	19000593          	li	a1,400
ffffffffc0202a30:	00003517          	auipc	a0,0x3
ffffffffc0202a34:	32050513          	addi	a0,a0,800 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc0202a38:	a19fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0202a3c:	00003697          	auipc	a3,0x3
ffffffffc0202a40:	73468693          	addi	a3,a3,1844 # ffffffffc0206170 <default_pmm_manager+0x560>
ffffffffc0202a44:	00003617          	auipc	a2,0x3
ffffffffc0202a48:	e3460613          	addi	a2,a2,-460 # ffffffffc0205878 <commands+0x870>
ffffffffc0202a4c:	1a100593          	li	a1,417
ffffffffc0202a50:	00003517          	auipc	a0,0x3
ffffffffc0202a54:	30050513          	addi	a0,a0,768 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc0202a58:	9f9fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202a5c:	00003697          	auipc	a3,0x3
ffffffffc0202a60:	3ac68693          	addi	a3,a3,940 # ffffffffc0205e08 <default_pmm_manager+0x1f8>
ffffffffc0202a64:	00003617          	auipc	a2,0x3
ffffffffc0202a68:	e1460613          	addi	a2,a2,-492 # ffffffffc0205878 <commands+0x870>
ffffffffc0202a6c:	16000593          	li	a1,352
ffffffffc0202a70:	00003517          	auipc	a0,0x3
ffffffffc0202a74:	2e050513          	addi	a0,a0,736 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc0202a78:	9d9fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202a7c:	00003617          	auipc	a2,0x3
ffffffffc0202a80:	21c60613          	addi	a2,a2,540 # ffffffffc0205c98 <default_pmm_manager+0x88>
ffffffffc0202a84:	0c300593          	li	a1,195
ffffffffc0202a88:	00003517          	auipc	a0,0x3
ffffffffc0202a8c:	2c850513          	addi	a0,a0,712 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc0202a90:	9c1fd0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0202a94 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202a94:	12058073          	sfence.vma	a1
}
ffffffffc0202a98:	8082                	ret

ffffffffc0202a9a <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202a9a:	7179                	addi	sp,sp,-48
ffffffffc0202a9c:	e84a                	sd	s2,16(sp)
ffffffffc0202a9e:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0202aa0:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202aa2:	f022                	sd	s0,32(sp)
ffffffffc0202aa4:	ec26                	sd	s1,24(sp)
ffffffffc0202aa6:	e44e                	sd	s3,8(sp)
ffffffffc0202aa8:	f406                	sd	ra,40(sp)
ffffffffc0202aaa:	84ae                	mv	s1,a1
ffffffffc0202aac:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0202aae:	8e8ff0ef          	jal	ra,ffffffffc0201b96 <alloc_pages>
ffffffffc0202ab2:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0202ab4:	cd19                	beqz	a0,ffffffffc0202ad2 <pgdir_alloc_page+0x38>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0202ab6:	85aa                	mv	a1,a0
ffffffffc0202ab8:	86ce                	mv	a3,s3
ffffffffc0202aba:	8626                	mv	a2,s1
ffffffffc0202abc:	854a                	mv	a0,s2
ffffffffc0202abe:	c8eff0ef          	jal	ra,ffffffffc0201f4c <page_insert>
ffffffffc0202ac2:	ed39                	bnez	a0,ffffffffc0202b20 <pgdir_alloc_page+0x86>
        if (swap_init_ok) {
ffffffffc0202ac4:	00013797          	auipc	a5,0x13
ffffffffc0202ac8:	9dc78793          	addi	a5,a5,-1572 # ffffffffc02154a0 <swap_init_ok>
ffffffffc0202acc:	439c                	lw	a5,0(a5)
ffffffffc0202ace:	2781                	sext.w	a5,a5
ffffffffc0202ad0:	eb89                	bnez	a5,ffffffffc0202ae2 <pgdir_alloc_page+0x48>
}
ffffffffc0202ad2:	8522                	mv	a0,s0
ffffffffc0202ad4:	70a2                	ld	ra,40(sp)
ffffffffc0202ad6:	7402                	ld	s0,32(sp)
ffffffffc0202ad8:	64e2                	ld	s1,24(sp)
ffffffffc0202ada:	6942                	ld	s2,16(sp)
ffffffffc0202adc:	69a2                	ld	s3,8(sp)
ffffffffc0202ade:	6145                	addi	sp,sp,48
ffffffffc0202ae0:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0202ae2:	00013797          	auipc	a5,0x13
ffffffffc0202ae6:	afe78793          	addi	a5,a5,-1282 # ffffffffc02155e0 <check_mm_struct>
ffffffffc0202aea:	6388                	ld	a0,0(a5)
ffffffffc0202aec:	4681                	li	a3,0
ffffffffc0202aee:	8622                	mv	a2,s0
ffffffffc0202af0:	85a6                	mv	a1,s1
ffffffffc0202af2:	7be000ef          	jal	ra,ffffffffc02032b0 <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0202af6:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0202af8:	fc04                	sd	s1,56(s0)
            assert(page_ref(page) == 1);
ffffffffc0202afa:	4785                	li	a5,1
ffffffffc0202afc:	fcf70be3          	beq	a4,a5,ffffffffc0202ad2 <pgdir_alloc_page+0x38>
ffffffffc0202b00:	00003697          	auipc	a3,0x3
ffffffffc0202b04:	26068693          	addi	a3,a3,608 # ffffffffc0205d60 <default_pmm_manager+0x150>
ffffffffc0202b08:	00003617          	auipc	a2,0x3
ffffffffc0202b0c:	d7060613          	addi	a2,a2,-656 # ffffffffc0205878 <commands+0x870>
ffffffffc0202b10:	14800593          	li	a1,328
ffffffffc0202b14:	00003517          	auipc	a0,0x3
ffffffffc0202b18:	23c50513          	addi	a0,a0,572 # ffffffffc0205d50 <default_pmm_manager+0x140>
ffffffffc0202b1c:	935fd0ef          	jal	ra,ffffffffc0200450 <__panic>
            free_page(page);
ffffffffc0202b20:	8522                	mv	a0,s0
ffffffffc0202b22:	4585                	li	a1,1
ffffffffc0202b24:	8faff0ef          	jal	ra,ffffffffc0201c1e <free_pages>
            return NULL;
ffffffffc0202b28:	4401                	li	s0,0
ffffffffc0202b2a:	b765                	j	ffffffffc0202ad2 <pgdir_alloc_page+0x38>

ffffffffc0202b2c <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0202b2c:	7135                	addi	sp,sp,-160
ffffffffc0202b2e:	ed06                	sd	ra,152(sp)
ffffffffc0202b30:	e922                	sd	s0,144(sp)
ffffffffc0202b32:	e526                	sd	s1,136(sp)
ffffffffc0202b34:	e14a                	sd	s2,128(sp)
ffffffffc0202b36:	fcce                	sd	s3,120(sp)
ffffffffc0202b38:	f8d2                	sd	s4,112(sp)
ffffffffc0202b3a:	f4d6                	sd	s5,104(sp)
ffffffffc0202b3c:	f0da                	sd	s6,96(sp)
ffffffffc0202b3e:	ecde                	sd	s7,88(sp)
ffffffffc0202b40:	e8e2                	sd	s8,80(sp)
ffffffffc0202b42:	e4e6                	sd	s9,72(sp)
ffffffffc0202b44:	e0ea                	sd	s10,64(sp)
ffffffffc0202b46:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202b48:	4f2010ef          	jal	ra,ffffffffc020403a <swapfs_init>
     // if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
     // {
     //      panic("bad max_swap_offset %08x.\n", max_swap_offset);
     // }
     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0202b4c:	00013797          	auipc	a5,0x13
ffffffffc0202b50:	a4478793          	addi	a5,a5,-1468 # ffffffffc0215590 <max_swap_offset>
ffffffffc0202b54:	6394                	ld	a3,0(a5)
ffffffffc0202b56:	010007b7          	lui	a5,0x1000
ffffffffc0202b5a:	17e1                	addi	a5,a5,-8
ffffffffc0202b5c:	ff968713          	addi	a4,a3,-7
ffffffffc0202b60:	4ae7e863          	bltu	a5,a4,ffffffffc0203010 <swap_init+0x4e4>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_fifo;
ffffffffc0202b64:	00007797          	auipc	a5,0x7
ffffffffc0202b68:	4ac78793          	addi	a5,a5,1196 # ffffffffc020a010 <swap_manager_fifo>
     int r = sm->init();
ffffffffc0202b6c:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc0202b6e:	00013697          	auipc	a3,0x13
ffffffffc0202b72:	92f6b523          	sd	a5,-1750(a3) # ffffffffc0215498 <sm>
     int r = sm->init();
ffffffffc0202b76:	9702                	jalr	a4
ffffffffc0202b78:	8aaa                	mv	s5,a0
     
     if (r == 0)
ffffffffc0202b7a:	c10d                	beqz	a0,ffffffffc0202b9c <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0202b7c:	60ea                	ld	ra,152(sp)
ffffffffc0202b7e:	644a                	ld	s0,144(sp)
ffffffffc0202b80:	8556                	mv	a0,s5
ffffffffc0202b82:	64aa                	ld	s1,136(sp)
ffffffffc0202b84:	690a                	ld	s2,128(sp)
ffffffffc0202b86:	79e6                	ld	s3,120(sp)
ffffffffc0202b88:	7a46                	ld	s4,112(sp)
ffffffffc0202b8a:	7aa6                	ld	s5,104(sp)
ffffffffc0202b8c:	7b06                	ld	s6,96(sp)
ffffffffc0202b8e:	6be6                	ld	s7,88(sp)
ffffffffc0202b90:	6c46                	ld	s8,80(sp)
ffffffffc0202b92:	6ca6                	ld	s9,72(sp)
ffffffffc0202b94:	6d06                	ld	s10,64(sp)
ffffffffc0202b96:	7de2                	ld	s11,56(sp)
ffffffffc0202b98:	610d                	addi	sp,sp,160
ffffffffc0202b9a:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202b9c:	00013797          	auipc	a5,0x13
ffffffffc0202ba0:	8fc78793          	addi	a5,a5,-1796 # ffffffffc0215498 <sm>
ffffffffc0202ba4:	639c                	ld	a5,0(a5)
ffffffffc0202ba6:	00003517          	auipc	a0,0x3
ffffffffc0202baa:	7a250513          	addi	a0,a0,1954 # ffffffffc0206348 <default_pmm_manager+0x738>
    return listelm->next;
ffffffffc0202bae:	00013417          	auipc	s0,0x13
ffffffffc0202bb2:	92240413          	addi	s0,s0,-1758 # ffffffffc02154d0 <free_area>
ffffffffc0202bb6:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0202bb8:	4785                	li	a5,1
ffffffffc0202bba:	00013717          	auipc	a4,0x13
ffffffffc0202bbe:	8ef72323          	sw	a5,-1818(a4) # ffffffffc02154a0 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202bc2:	dccfd0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0202bc6:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202bc8:	36878863          	beq	a5,s0,ffffffffc0202f38 <swap_init+0x40c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202bcc:	ff07b703          	ld	a4,-16(a5)
ffffffffc0202bd0:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202bd2:	8b05                	andi	a4,a4,1
ffffffffc0202bd4:	36070663          	beqz	a4,ffffffffc0202f40 <swap_init+0x414>
     int ret, count = 0, total = 0, i;
ffffffffc0202bd8:	4481                	li	s1,0
ffffffffc0202bda:	4901                	li	s2,0
ffffffffc0202bdc:	a031                	j	ffffffffc0202be8 <swap_init+0xbc>
ffffffffc0202bde:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0202be2:	8b09                	andi	a4,a4,2
ffffffffc0202be4:	34070e63          	beqz	a4,ffffffffc0202f40 <swap_init+0x414>
        count ++, total += p->property;
ffffffffc0202be8:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202bec:	679c                	ld	a5,8(a5)
ffffffffc0202bee:	2905                	addiw	s2,s2,1
ffffffffc0202bf0:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202bf2:	fe8796e3          	bne	a5,s0,ffffffffc0202bde <swap_init+0xb2>
ffffffffc0202bf6:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc0202bf8:	86cff0ef          	jal	ra,ffffffffc0201c64 <nr_free_pages>
ffffffffc0202bfc:	69351263          	bne	a0,s3,ffffffffc0203280 <swap_init+0x754>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202c00:	8626                	mv	a2,s1
ffffffffc0202c02:	85ca                	mv	a1,s2
ffffffffc0202c04:	00003517          	auipc	a0,0x3
ffffffffc0202c08:	75c50513          	addi	a0,a0,1884 # ffffffffc0206360 <default_pmm_manager+0x750>
ffffffffc0202c0c:	d82fd0ef          	jal	ra,ffffffffc020018e <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202c10:	44b000ef          	jal	ra,ffffffffc020385a <mm_create>
ffffffffc0202c14:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0202c16:	60050563          	beqz	a0,ffffffffc0203220 <swap_init+0x6f4>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0202c1a:	00013797          	auipc	a5,0x13
ffffffffc0202c1e:	9c678793          	addi	a5,a5,-1594 # ffffffffc02155e0 <check_mm_struct>
ffffffffc0202c22:	639c                	ld	a5,0(a5)
ffffffffc0202c24:	60079e63          	bnez	a5,ffffffffc0203240 <swap_init+0x714>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202c28:	00013797          	auipc	a5,0x13
ffffffffc0202c2c:	86078793          	addi	a5,a5,-1952 # ffffffffc0215488 <boot_pgdir>
ffffffffc0202c30:	0007bb03          	ld	s6,0(a5)
     check_mm_struct = mm;
ffffffffc0202c34:	00013797          	auipc	a5,0x13
ffffffffc0202c38:	9aa7b623          	sd	a0,-1620(a5) # ffffffffc02155e0 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc0202c3c:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202c40:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202c44:	4e079263          	bnez	a5,ffffffffc0203128 <swap_init+0x5fc>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202c48:	6599                	lui	a1,0x6
ffffffffc0202c4a:	460d                	li	a2,3
ffffffffc0202c4c:	6505                	lui	a0,0x1
ffffffffc0202c4e:	459000ef          	jal	ra,ffffffffc02038a6 <vma_create>
ffffffffc0202c52:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202c54:	4e050a63          	beqz	a0,ffffffffc0203148 <swap_init+0x61c>

     insert_vma_struct(mm, vma);
ffffffffc0202c58:	855e                	mv	a0,s7
ffffffffc0202c5a:	4b9000ef          	jal	ra,ffffffffc0203912 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0202c5e:	00003517          	auipc	a0,0x3
ffffffffc0202c62:	77250513          	addi	a0,a0,1906 # ffffffffc02063d0 <default_pmm_manager+0x7c0>
ffffffffc0202c66:	d28fd0ef          	jal	ra,ffffffffc020018e <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202c6a:	018bb503          	ld	a0,24(s7)
ffffffffc0202c6e:	4605                	li	a2,1
ffffffffc0202c70:	6585                	lui	a1,0x1
ffffffffc0202c72:	832ff0ef          	jal	ra,ffffffffc0201ca4 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0202c76:	4e050963          	beqz	a0,ffffffffc0203168 <swap_init+0x63c>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202c7a:	00003517          	auipc	a0,0x3
ffffffffc0202c7e:	7a650513          	addi	a0,a0,1958 # ffffffffc0206420 <default_pmm_manager+0x810>
ffffffffc0202c82:	00013997          	auipc	s3,0x13
ffffffffc0202c86:	88698993          	addi	s3,s3,-1914 # ffffffffc0215508 <check_rp>
ffffffffc0202c8a:	d04fd0ef          	jal	ra,ffffffffc020018e <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202c8e:	00013a17          	auipc	s4,0x13
ffffffffc0202c92:	89aa0a13          	addi	s4,s4,-1894 # ffffffffc0215528 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202c96:	8c4e                	mv	s8,s3
          check_rp[i] = alloc_page();
ffffffffc0202c98:	4505                	li	a0,1
ffffffffc0202c9a:	efdfe0ef          	jal	ra,ffffffffc0201b96 <alloc_pages>
ffffffffc0202c9e:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc0202ca2:	32050763          	beqz	a0,ffffffffc0202fd0 <swap_init+0x4a4>
ffffffffc0202ca6:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202ca8:	8b89                	andi	a5,a5,2
ffffffffc0202caa:	30079363          	bnez	a5,ffffffffc0202fb0 <swap_init+0x484>
ffffffffc0202cae:	0c21                	addi	s8,s8,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202cb0:	ff4c14e3          	bne	s8,s4,ffffffffc0202c98 <swap_init+0x16c>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202cb4:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0202cb6:	00013c17          	auipc	s8,0x13
ffffffffc0202cba:	852c0c13          	addi	s8,s8,-1966 # ffffffffc0215508 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc0202cbe:	ec3e                	sd	a5,24(sp)
ffffffffc0202cc0:	641c                	ld	a5,8(s0)
ffffffffc0202cc2:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0202cc4:	481c                	lw	a5,16(s0)
ffffffffc0202cc6:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0202cc8:	00013797          	auipc	a5,0x13
ffffffffc0202ccc:	8087b823          	sd	s0,-2032(a5) # ffffffffc02154d8 <free_area+0x8>
ffffffffc0202cd0:	00013797          	auipc	a5,0x13
ffffffffc0202cd4:	8087b023          	sd	s0,-2048(a5) # ffffffffc02154d0 <free_area>
     nr_free = 0;
ffffffffc0202cd8:	00013797          	auipc	a5,0x13
ffffffffc0202cdc:	8007a423          	sw	zero,-2040(a5) # ffffffffc02154e0 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0202ce0:	000c3503          	ld	a0,0(s8)
ffffffffc0202ce4:	4585                	li	a1,1
ffffffffc0202ce6:	0c21                	addi	s8,s8,8
ffffffffc0202ce8:	f37fe0ef          	jal	ra,ffffffffc0201c1e <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202cec:	ff4c1ae3          	bne	s8,s4,ffffffffc0202ce0 <swap_init+0x1b4>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202cf0:	01042c03          	lw	s8,16(s0)
ffffffffc0202cf4:	4791                	li	a5,4
ffffffffc0202cf6:	50fc1563          	bne	s8,a5,ffffffffc0203200 <swap_init+0x6d4>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202cfa:	00003517          	auipc	a0,0x3
ffffffffc0202cfe:	7ae50513          	addi	a0,a0,1966 # ffffffffc02064a8 <default_pmm_manager+0x898>
ffffffffc0202d02:	c8cfd0ef          	jal	ra,ffffffffc020018e <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202d06:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0202d08:	00012797          	auipc	a5,0x12
ffffffffc0202d0c:	7807ae23          	sw	zero,1948(a5) # ffffffffc02154a4 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202d10:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc0202d12:	00012797          	auipc	a5,0x12
ffffffffc0202d16:	79278793          	addi	a5,a5,1938 # ffffffffc02154a4 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202d1a:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0202d1e:	4398                	lw	a4,0(a5)
ffffffffc0202d20:	4585                	li	a1,1
ffffffffc0202d22:	2701                	sext.w	a4,a4
ffffffffc0202d24:	38b71263          	bne	a4,a1,ffffffffc02030a8 <swap_init+0x57c>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202d28:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc0202d2c:	4394                	lw	a3,0(a5)
ffffffffc0202d2e:	2681                	sext.w	a3,a3
ffffffffc0202d30:	38e69c63          	bne	a3,a4,ffffffffc02030c8 <swap_init+0x59c>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202d34:	6689                	lui	a3,0x2
ffffffffc0202d36:	462d                	li	a2,11
ffffffffc0202d38:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0202d3c:	4398                	lw	a4,0(a5)
ffffffffc0202d3e:	4589                	li	a1,2
ffffffffc0202d40:	2701                	sext.w	a4,a4
ffffffffc0202d42:	2eb71363          	bne	a4,a1,ffffffffc0203028 <swap_init+0x4fc>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202d46:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0202d4a:	4394                	lw	a3,0(a5)
ffffffffc0202d4c:	2681                	sext.w	a3,a3
ffffffffc0202d4e:	2ee69d63          	bne	a3,a4,ffffffffc0203048 <swap_init+0x51c>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202d52:	668d                	lui	a3,0x3
ffffffffc0202d54:	4631                	li	a2,12
ffffffffc0202d56:	00c68023          	sb	a2,0(a3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0202d5a:	4398                	lw	a4,0(a5)
ffffffffc0202d5c:	458d                	li	a1,3
ffffffffc0202d5e:	2701                	sext.w	a4,a4
ffffffffc0202d60:	30b71463          	bne	a4,a1,ffffffffc0203068 <swap_init+0x53c>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202d64:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0202d68:	4394                	lw	a3,0(a5)
ffffffffc0202d6a:	2681                	sext.w	a3,a3
ffffffffc0202d6c:	30e69e63          	bne	a3,a4,ffffffffc0203088 <swap_init+0x55c>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202d70:	6691                	lui	a3,0x4
ffffffffc0202d72:	4635                	li	a2,13
ffffffffc0202d74:	00c68023          	sb	a2,0(a3) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0202d78:	4398                	lw	a4,0(a5)
ffffffffc0202d7a:	2701                	sext.w	a4,a4
ffffffffc0202d7c:	37871663          	bne	a4,s8,ffffffffc02030e8 <swap_init+0x5bc>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202d80:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0202d84:	439c                	lw	a5,0(a5)
ffffffffc0202d86:	2781                	sext.w	a5,a5
ffffffffc0202d88:	38e79063          	bne	a5,a4,ffffffffc0203108 <swap_init+0x5dc>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0202d8c:	481c                	lw	a5,16(s0)
ffffffffc0202d8e:	3e079d63          	bnez	a5,ffffffffc0203188 <swap_init+0x65c>
ffffffffc0202d92:	00012797          	auipc	a5,0x12
ffffffffc0202d96:	79678793          	addi	a5,a5,1942 # ffffffffc0215528 <swap_in_seq_no>
ffffffffc0202d9a:	00012717          	auipc	a4,0x12
ffffffffc0202d9e:	7b670713          	addi	a4,a4,1974 # ffffffffc0215550 <swap_out_seq_no>
ffffffffc0202da2:	00012617          	auipc	a2,0x12
ffffffffc0202da6:	7ae60613          	addi	a2,a2,1966 # ffffffffc0215550 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202daa:	56fd                	li	a3,-1
ffffffffc0202dac:	c394                	sw	a3,0(a5)
ffffffffc0202dae:	c314                	sw	a3,0(a4)
ffffffffc0202db0:	0791                	addi	a5,a5,4
ffffffffc0202db2:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202db4:	fef61ce3          	bne	a2,a5,ffffffffc0202dac <swap_init+0x280>
ffffffffc0202db8:	00012697          	auipc	a3,0x12
ffffffffc0202dbc:	7f868693          	addi	a3,a3,2040 # ffffffffc02155b0 <check_ptep>
ffffffffc0202dc0:	00012817          	auipc	a6,0x12
ffffffffc0202dc4:	74880813          	addi	a6,a6,1864 # ffffffffc0215508 <check_rp>
ffffffffc0202dc8:	6d05                	lui	s10,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202dca:	00012c97          	auipc	s9,0x12
ffffffffc0202dce:	6c6c8c93          	addi	s9,s9,1734 # ffffffffc0215490 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202dd2:	00004d97          	auipc	s11,0x4
ffffffffc0202dd6:	1e6d8d93          	addi	s11,s11,486 # ffffffffc0206fb8 <nbase>
ffffffffc0202dda:	00012c17          	auipc	s8,0x12
ffffffffc0202dde:	726c0c13          	addi	s8,s8,1830 # ffffffffc0215500 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0202de2:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202de6:	4601                	li	a2,0
ffffffffc0202de8:	85ea                	mv	a1,s10
ffffffffc0202dea:	855a                	mv	a0,s6
ffffffffc0202dec:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc0202dee:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202df0:	eb5fe0ef          	jal	ra,ffffffffc0201ca4 <get_pte>
ffffffffc0202df4:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202df6:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202df8:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc0202dfa:	1e050b63          	beqz	a0,ffffffffc0202ff0 <swap_init+0x4c4>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202dfe:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202e00:	0017f613          	andi	a2,a5,1
ffffffffc0202e04:	18060a63          	beqz	a2,ffffffffc0202f98 <swap_init+0x46c>
    if (PPN(pa) >= npage) {
ffffffffc0202e08:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202e0c:	078a                	slli	a5,a5,0x2
ffffffffc0202e0e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202e10:	14c7f863          	bleu	a2,a5,ffffffffc0202f60 <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc0202e14:	000db703          	ld	a4,0(s11)
ffffffffc0202e18:	000c3603          	ld	a2,0(s8)
ffffffffc0202e1c:	00083583          	ld	a1,0(a6)
ffffffffc0202e20:	8f99                	sub	a5,a5,a4
ffffffffc0202e22:	079a                	slli	a5,a5,0x6
ffffffffc0202e24:	e43a                	sd	a4,8(sp)
ffffffffc0202e26:	97b2                	add	a5,a5,a2
ffffffffc0202e28:	14f59863          	bne	a1,a5,ffffffffc0202f78 <swap_init+0x44c>
ffffffffc0202e2c:	6785                	lui	a5,0x1
ffffffffc0202e2e:	9d3e                	add	s10,s10,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202e30:	6795                	lui	a5,0x5
ffffffffc0202e32:	06a1                	addi	a3,a3,8
ffffffffc0202e34:	0821                	addi	a6,a6,8
ffffffffc0202e36:	fafd16e3          	bne	s10,a5,ffffffffc0202de2 <swap_init+0x2b6>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202e3a:	00003517          	auipc	a0,0x3
ffffffffc0202e3e:	71650513          	addi	a0,a0,1814 # ffffffffc0206550 <default_pmm_manager+0x940>
ffffffffc0202e42:	b4cfd0ef          	jal	ra,ffffffffc020018e <cprintf>
    int ret = sm->check_swap();
ffffffffc0202e46:	00012797          	auipc	a5,0x12
ffffffffc0202e4a:	65278793          	addi	a5,a5,1618 # ffffffffc0215498 <sm>
ffffffffc0202e4e:	639c                	ld	a5,0(a5)
ffffffffc0202e50:	7f9c                	ld	a5,56(a5)
ffffffffc0202e52:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202e54:	40051663          	bnez	a0,ffffffffc0203260 <swap_init+0x734>

     nr_free = nr_free_store;
ffffffffc0202e58:	77a2                	ld	a5,40(sp)
ffffffffc0202e5a:	00012717          	auipc	a4,0x12
ffffffffc0202e5e:	68f72323          	sw	a5,1670(a4) # ffffffffc02154e0 <free_area+0x10>
     free_list = free_list_store;
ffffffffc0202e62:	67e2                	ld	a5,24(sp)
ffffffffc0202e64:	00012717          	auipc	a4,0x12
ffffffffc0202e68:	66f73623          	sd	a5,1644(a4) # ffffffffc02154d0 <free_area>
ffffffffc0202e6c:	7782                	ld	a5,32(sp)
ffffffffc0202e6e:	00012717          	auipc	a4,0x12
ffffffffc0202e72:	66f73523          	sd	a5,1642(a4) # ffffffffc02154d8 <free_area+0x8>

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202e76:	0009b503          	ld	a0,0(s3)
ffffffffc0202e7a:	4585                	li	a1,1
ffffffffc0202e7c:	09a1                	addi	s3,s3,8
ffffffffc0202e7e:	da1fe0ef          	jal	ra,ffffffffc0201c1e <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202e82:	ff499ae3          	bne	s3,s4,ffffffffc0202e76 <swap_init+0x34a>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0202e86:	855e                	mv	a0,s7
ffffffffc0202e88:	359000ef          	jal	ra,ffffffffc02039e0 <mm_destroy>

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202e8c:	00012797          	auipc	a5,0x12
ffffffffc0202e90:	5fc78793          	addi	a5,a5,1532 # ffffffffc0215488 <boot_pgdir>
ffffffffc0202e94:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0202e96:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202e9a:	6394                	ld	a3,0(a5)
ffffffffc0202e9c:	068a                	slli	a3,a3,0x2
ffffffffc0202e9e:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202ea0:	0ce6f063          	bleu	a4,a3,ffffffffc0202f60 <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ea4:	67a2                	ld	a5,8(sp)
ffffffffc0202ea6:	000c3503          	ld	a0,0(s8)
ffffffffc0202eaa:	8e9d                	sub	a3,a3,a5
ffffffffc0202eac:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0202eae:	8699                	srai	a3,a3,0x6
ffffffffc0202eb0:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0202eb2:	57fd                	li	a5,-1
ffffffffc0202eb4:	83b1                	srli	a5,a5,0xc
ffffffffc0202eb6:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0202eb8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202eba:	2ee7f763          	bleu	a4,a5,ffffffffc02031a8 <swap_init+0x67c>
     free_page(pde2page(pd0[0]));
ffffffffc0202ebe:	00012797          	auipc	a5,0x12
ffffffffc0202ec2:	63278793          	addi	a5,a5,1586 # ffffffffc02154f0 <va_pa_offset>
ffffffffc0202ec6:	639c                	ld	a5,0(a5)
ffffffffc0202ec8:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202eca:	629c                	ld	a5,0(a3)
ffffffffc0202ecc:	078a                	slli	a5,a5,0x2
ffffffffc0202ece:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202ed0:	08e7f863          	bleu	a4,a5,ffffffffc0202f60 <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ed4:	69a2                	ld	s3,8(sp)
ffffffffc0202ed6:	4585                	li	a1,1
ffffffffc0202ed8:	413787b3          	sub	a5,a5,s3
ffffffffc0202edc:	079a                	slli	a5,a5,0x6
ffffffffc0202ede:	953e                	add	a0,a0,a5
ffffffffc0202ee0:	d3ffe0ef          	jal	ra,ffffffffc0201c1e <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ee4:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0202ee8:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202eec:	078a                	slli	a5,a5,0x2
ffffffffc0202eee:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202ef0:	06e7f863          	bleu	a4,a5,ffffffffc0202f60 <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ef4:	000c3503          	ld	a0,0(s8)
ffffffffc0202ef8:	413787b3          	sub	a5,a5,s3
ffffffffc0202efc:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0202efe:	4585                	li	a1,1
ffffffffc0202f00:	953e                	add	a0,a0,a5
ffffffffc0202f02:	d1dfe0ef          	jal	ra,ffffffffc0201c1e <free_pages>
     pgdir[0] = 0;
ffffffffc0202f06:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0202f0a:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0202f0e:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202f10:	00878963          	beq	a5,s0,ffffffffc0202f22 <swap_init+0x3f6>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0202f14:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202f18:	679c                	ld	a5,8(a5)
ffffffffc0202f1a:	397d                	addiw	s2,s2,-1
ffffffffc0202f1c:	9c99                	subw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202f1e:	fe879be3          	bne	a5,s0,ffffffffc0202f14 <swap_init+0x3e8>
     }
     assert(count==0);
ffffffffc0202f22:	28091f63          	bnez	s2,ffffffffc02031c0 <swap_init+0x694>
     assert(total==0);
ffffffffc0202f26:	2a049d63          	bnez	s1,ffffffffc02031e0 <swap_init+0x6b4>

     cprintf("check_swap() succeeded!\n");
ffffffffc0202f2a:	00003517          	auipc	a0,0x3
ffffffffc0202f2e:	67650513          	addi	a0,a0,1654 # ffffffffc02065a0 <default_pmm_manager+0x990>
ffffffffc0202f32:	a5cfd0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0202f36:	b199                	j	ffffffffc0202b7c <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0202f38:	4481                	li	s1,0
ffffffffc0202f3a:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202f3c:	4981                	li	s3,0
ffffffffc0202f3e:	b96d                	j	ffffffffc0202bf8 <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc0202f40:	00003697          	auipc	a3,0x3
ffffffffc0202f44:	92868693          	addi	a3,a3,-1752 # ffffffffc0205868 <commands+0x860>
ffffffffc0202f48:	00003617          	auipc	a2,0x3
ffffffffc0202f4c:	93060613          	addi	a2,a2,-1744 # ffffffffc0205878 <commands+0x870>
ffffffffc0202f50:	0bd00593          	li	a1,189
ffffffffc0202f54:	00003517          	auipc	a0,0x3
ffffffffc0202f58:	3e450513          	addi	a0,a0,996 # ffffffffc0206338 <default_pmm_manager+0x728>
ffffffffc0202f5c:	cf4fd0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202f60:	00003617          	auipc	a2,0x3
ffffffffc0202f64:	d6060613          	addi	a2,a2,-672 # ffffffffc0205cc0 <default_pmm_manager+0xb0>
ffffffffc0202f68:	06200593          	li	a1,98
ffffffffc0202f6c:	00003517          	auipc	a0,0x3
ffffffffc0202f70:	d1c50513          	addi	a0,a0,-740 # ffffffffc0205c88 <default_pmm_manager+0x78>
ffffffffc0202f74:	cdcfd0ef          	jal	ra,ffffffffc0200450 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202f78:	00003697          	auipc	a3,0x3
ffffffffc0202f7c:	5b068693          	addi	a3,a3,1456 # ffffffffc0206528 <default_pmm_manager+0x918>
ffffffffc0202f80:	00003617          	auipc	a2,0x3
ffffffffc0202f84:	8f860613          	addi	a2,a2,-1800 # ffffffffc0205878 <commands+0x870>
ffffffffc0202f88:	0fd00593          	li	a1,253
ffffffffc0202f8c:	00003517          	auipc	a0,0x3
ffffffffc0202f90:	3ac50513          	addi	a0,a0,940 # ffffffffc0206338 <default_pmm_manager+0x728>
ffffffffc0202f94:	cbcfd0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202f98:	00003617          	auipc	a2,0x3
ffffffffc0202f9c:	f5060613          	addi	a2,a2,-176 # ffffffffc0205ee8 <default_pmm_manager+0x2d8>
ffffffffc0202fa0:	07400593          	li	a1,116
ffffffffc0202fa4:	00003517          	auipc	a0,0x3
ffffffffc0202fa8:	ce450513          	addi	a0,a0,-796 # ffffffffc0205c88 <default_pmm_manager+0x78>
ffffffffc0202fac:	ca4fd0ef          	jal	ra,ffffffffc0200450 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202fb0:	00003697          	auipc	a3,0x3
ffffffffc0202fb4:	4b068693          	addi	a3,a3,1200 # ffffffffc0206460 <default_pmm_manager+0x850>
ffffffffc0202fb8:	00003617          	auipc	a2,0x3
ffffffffc0202fbc:	8c060613          	addi	a2,a2,-1856 # ffffffffc0205878 <commands+0x870>
ffffffffc0202fc0:	0de00593          	li	a1,222
ffffffffc0202fc4:	00003517          	auipc	a0,0x3
ffffffffc0202fc8:	37450513          	addi	a0,a0,884 # ffffffffc0206338 <default_pmm_manager+0x728>
ffffffffc0202fcc:	c84fd0ef          	jal	ra,ffffffffc0200450 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202fd0:	00003697          	auipc	a3,0x3
ffffffffc0202fd4:	47868693          	addi	a3,a3,1144 # ffffffffc0206448 <default_pmm_manager+0x838>
ffffffffc0202fd8:	00003617          	auipc	a2,0x3
ffffffffc0202fdc:	8a060613          	addi	a2,a2,-1888 # ffffffffc0205878 <commands+0x870>
ffffffffc0202fe0:	0dd00593          	li	a1,221
ffffffffc0202fe4:	00003517          	auipc	a0,0x3
ffffffffc0202fe8:	35450513          	addi	a0,a0,852 # ffffffffc0206338 <default_pmm_manager+0x728>
ffffffffc0202fec:	c64fd0ef          	jal	ra,ffffffffc0200450 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0202ff0:	00003697          	auipc	a3,0x3
ffffffffc0202ff4:	52068693          	addi	a3,a3,1312 # ffffffffc0206510 <default_pmm_manager+0x900>
ffffffffc0202ff8:	00003617          	auipc	a2,0x3
ffffffffc0202ffc:	88060613          	addi	a2,a2,-1920 # ffffffffc0205878 <commands+0x870>
ffffffffc0203000:	0fc00593          	li	a1,252
ffffffffc0203004:	00003517          	auipc	a0,0x3
ffffffffc0203008:	33450513          	addi	a0,a0,820 # ffffffffc0206338 <default_pmm_manager+0x728>
ffffffffc020300c:	c44fd0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0203010:	00003617          	auipc	a2,0x3
ffffffffc0203014:	30860613          	addi	a2,a2,776 # ffffffffc0206318 <default_pmm_manager+0x708>
ffffffffc0203018:	02a00593          	li	a1,42
ffffffffc020301c:	00003517          	auipc	a0,0x3
ffffffffc0203020:	31c50513          	addi	a0,a0,796 # ffffffffc0206338 <default_pmm_manager+0x728>
ffffffffc0203024:	c2cfd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==2);
ffffffffc0203028:	00003697          	auipc	a3,0x3
ffffffffc020302c:	4b868693          	addi	a3,a3,1208 # ffffffffc02064e0 <default_pmm_manager+0x8d0>
ffffffffc0203030:	00003617          	auipc	a2,0x3
ffffffffc0203034:	84860613          	addi	a2,a2,-1976 # ffffffffc0205878 <commands+0x870>
ffffffffc0203038:	09800593          	li	a1,152
ffffffffc020303c:	00003517          	auipc	a0,0x3
ffffffffc0203040:	2fc50513          	addi	a0,a0,764 # ffffffffc0206338 <default_pmm_manager+0x728>
ffffffffc0203044:	c0cfd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==2);
ffffffffc0203048:	00003697          	auipc	a3,0x3
ffffffffc020304c:	49868693          	addi	a3,a3,1176 # ffffffffc02064e0 <default_pmm_manager+0x8d0>
ffffffffc0203050:	00003617          	auipc	a2,0x3
ffffffffc0203054:	82860613          	addi	a2,a2,-2008 # ffffffffc0205878 <commands+0x870>
ffffffffc0203058:	09a00593          	li	a1,154
ffffffffc020305c:	00003517          	auipc	a0,0x3
ffffffffc0203060:	2dc50513          	addi	a0,a0,732 # ffffffffc0206338 <default_pmm_manager+0x728>
ffffffffc0203064:	becfd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==3);
ffffffffc0203068:	00003697          	auipc	a3,0x3
ffffffffc020306c:	48868693          	addi	a3,a3,1160 # ffffffffc02064f0 <default_pmm_manager+0x8e0>
ffffffffc0203070:	00003617          	auipc	a2,0x3
ffffffffc0203074:	80860613          	addi	a2,a2,-2040 # ffffffffc0205878 <commands+0x870>
ffffffffc0203078:	09c00593          	li	a1,156
ffffffffc020307c:	00003517          	auipc	a0,0x3
ffffffffc0203080:	2bc50513          	addi	a0,a0,700 # ffffffffc0206338 <default_pmm_manager+0x728>
ffffffffc0203084:	bccfd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==3);
ffffffffc0203088:	00003697          	auipc	a3,0x3
ffffffffc020308c:	46868693          	addi	a3,a3,1128 # ffffffffc02064f0 <default_pmm_manager+0x8e0>
ffffffffc0203090:	00002617          	auipc	a2,0x2
ffffffffc0203094:	7e860613          	addi	a2,a2,2024 # ffffffffc0205878 <commands+0x870>
ffffffffc0203098:	09e00593          	li	a1,158
ffffffffc020309c:	00003517          	auipc	a0,0x3
ffffffffc02030a0:	29c50513          	addi	a0,a0,668 # ffffffffc0206338 <default_pmm_manager+0x728>
ffffffffc02030a4:	bacfd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==1);
ffffffffc02030a8:	00003697          	auipc	a3,0x3
ffffffffc02030ac:	42868693          	addi	a3,a3,1064 # ffffffffc02064d0 <default_pmm_manager+0x8c0>
ffffffffc02030b0:	00002617          	auipc	a2,0x2
ffffffffc02030b4:	7c860613          	addi	a2,a2,1992 # ffffffffc0205878 <commands+0x870>
ffffffffc02030b8:	09400593          	li	a1,148
ffffffffc02030bc:	00003517          	auipc	a0,0x3
ffffffffc02030c0:	27c50513          	addi	a0,a0,636 # ffffffffc0206338 <default_pmm_manager+0x728>
ffffffffc02030c4:	b8cfd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==1);
ffffffffc02030c8:	00003697          	auipc	a3,0x3
ffffffffc02030cc:	40868693          	addi	a3,a3,1032 # ffffffffc02064d0 <default_pmm_manager+0x8c0>
ffffffffc02030d0:	00002617          	auipc	a2,0x2
ffffffffc02030d4:	7a860613          	addi	a2,a2,1960 # ffffffffc0205878 <commands+0x870>
ffffffffc02030d8:	09600593          	li	a1,150
ffffffffc02030dc:	00003517          	auipc	a0,0x3
ffffffffc02030e0:	25c50513          	addi	a0,a0,604 # ffffffffc0206338 <default_pmm_manager+0x728>
ffffffffc02030e4:	b6cfd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==4);
ffffffffc02030e8:	00003697          	auipc	a3,0x3
ffffffffc02030ec:	41868693          	addi	a3,a3,1048 # ffffffffc0206500 <default_pmm_manager+0x8f0>
ffffffffc02030f0:	00002617          	auipc	a2,0x2
ffffffffc02030f4:	78860613          	addi	a2,a2,1928 # ffffffffc0205878 <commands+0x870>
ffffffffc02030f8:	0a000593          	li	a1,160
ffffffffc02030fc:	00003517          	auipc	a0,0x3
ffffffffc0203100:	23c50513          	addi	a0,a0,572 # ffffffffc0206338 <default_pmm_manager+0x728>
ffffffffc0203104:	b4cfd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==4);
ffffffffc0203108:	00003697          	auipc	a3,0x3
ffffffffc020310c:	3f868693          	addi	a3,a3,1016 # ffffffffc0206500 <default_pmm_manager+0x8f0>
ffffffffc0203110:	00002617          	auipc	a2,0x2
ffffffffc0203114:	76860613          	addi	a2,a2,1896 # ffffffffc0205878 <commands+0x870>
ffffffffc0203118:	0a200593          	li	a1,162
ffffffffc020311c:	00003517          	auipc	a0,0x3
ffffffffc0203120:	21c50513          	addi	a0,a0,540 # ffffffffc0206338 <default_pmm_manager+0x728>
ffffffffc0203124:	b2cfd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0203128:	00003697          	auipc	a3,0x3
ffffffffc020312c:	28868693          	addi	a3,a3,648 # ffffffffc02063b0 <default_pmm_manager+0x7a0>
ffffffffc0203130:	00002617          	auipc	a2,0x2
ffffffffc0203134:	74860613          	addi	a2,a2,1864 # ffffffffc0205878 <commands+0x870>
ffffffffc0203138:	0cd00593          	li	a1,205
ffffffffc020313c:	00003517          	auipc	a0,0x3
ffffffffc0203140:	1fc50513          	addi	a0,a0,508 # ffffffffc0206338 <default_pmm_manager+0x728>
ffffffffc0203144:	b0cfd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(vma != NULL);
ffffffffc0203148:	00003697          	auipc	a3,0x3
ffffffffc020314c:	27868693          	addi	a3,a3,632 # ffffffffc02063c0 <default_pmm_manager+0x7b0>
ffffffffc0203150:	00002617          	auipc	a2,0x2
ffffffffc0203154:	72860613          	addi	a2,a2,1832 # ffffffffc0205878 <commands+0x870>
ffffffffc0203158:	0d000593          	li	a1,208
ffffffffc020315c:	00003517          	auipc	a0,0x3
ffffffffc0203160:	1dc50513          	addi	a0,a0,476 # ffffffffc0206338 <default_pmm_manager+0x728>
ffffffffc0203164:	aecfd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0203168:	00003697          	auipc	a3,0x3
ffffffffc020316c:	2a068693          	addi	a3,a3,672 # ffffffffc0206408 <default_pmm_manager+0x7f8>
ffffffffc0203170:	00002617          	auipc	a2,0x2
ffffffffc0203174:	70860613          	addi	a2,a2,1800 # ffffffffc0205878 <commands+0x870>
ffffffffc0203178:	0d800593          	li	a1,216
ffffffffc020317c:	00003517          	auipc	a0,0x3
ffffffffc0203180:	1bc50513          	addi	a0,a0,444 # ffffffffc0206338 <default_pmm_manager+0x728>
ffffffffc0203184:	accfd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert( nr_free == 0);         
ffffffffc0203188:	00003697          	auipc	a3,0x3
ffffffffc020318c:	8c868693          	addi	a3,a3,-1848 # ffffffffc0205a50 <commands+0xa48>
ffffffffc0203190:	00002617          	auipc	a2,0x2
ffffffffc0203194:	6e860613          	addi	a2,a2,1768 # ffffffffc0205878 <commands+0x870>
ffffffffc0203198:	0f400593          	li	a1,244
ffffffffc020319c:	00003517          	auipc	a0,0x3
ffffffffc02031a0:	19c50513          	addi	a0,a0,412 # ffffffffc0206338 <default_pmm_manager+0x728>
ffffffffc02031a4:	aacfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    return KADDR(page2pa(page));
ffffffffc02031a8:	00003617          	auipc	a2,0x3
ffffffffc02031ac:	ab860613          	addi	a2,a2,-1352 # ffffffffc0205c60 <default_pmm_manager+0x50>
ffffffffc02031b0:	06900593          	li	a1,105
ffffffffc02031b4:	00003517          	auipc	a0,0x3
ffffffffc02031b8:	ad450513          	addi	a0,a0,-1324 # ffffffffc0205c88 <default_pmm_manager+0x78>
ffffffffc02031bc:	a94fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(count==0);
ffffffffc02031c0:	00003697          	auipc	a3,0x3
ffffffffc02031c4:	3c068693          	addi	a3,a3,960 # ffffffffc0206580 <default_pmm_manager+0x970>
ffffffffc02031c8:	00002617          	auipc	a2,0x2
ffffffffc02031cc:	6b060613          	addi	a2,a2,1712 # ffffffffc0205878 <commands+0x870>
ffffffffc02031d0:	11c00593          	li	a1,284
ffffffffc02031d4:	00003517          	auipc	a0,0x3
ffffffffc02031d8:	16450513          	addi	a0,a0,356 # ffffffffc0206338 <default_pmm_manager+0x728>
ffffffffc02031dc:	a74fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(total==0);
ffffffffc02031e0:	00003697          	auipc	a3,0x3
ffffffffc02031e4:	3b068693          	addi	a3,a3,944 # ffffffffc0206590 <default_pmm_manager+0x980>
ffffffffc02031e8:	00002617          	auipc	a2,0x2
ffffffffc02031ec:	69060613          	addi	a2,a2,1680 # ffffffffc0205878 <commands+0x870>
ffffffffc02031f0:	11d00593          	li	a1,285
ffffffffc02031f4:	00003517          	auipc	a0,0x3
ffffffffc02031f8:	14450513          	addi	a0,a0,324 # ffffffffc0206338 <default_pmm_manager+0x728>
ffffffffc02031fc:	a54fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203200:	00003697          	auipc	a3,0x3
ffffffffc0203204:	28068693          	addi	a3,a3,640 # ffffffffc0206480 <default_pmm_manager+0x870>
ffffffffc0203208:	00002617          	auipc	a2,0x2
ffffffffc020320c:	67060613          	addi	a2,a2,1648 # ffffffffc0205878 <commands+0x870>
ffffffffc0203210:	0eb00593          	li	a1,235
ffffffffc0203214:	00003517          	auipc	a0,0x3
ffffffffc0203218:	12450513          	addi	a0,a0,292 # ffffffffc0206338 <default_pmm_manager+0x728>
ffffffffc020321c:	a34fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(mm != NULL);
ffffffffc0203220:	00003697          	auipc	a3,0x3
ffffffffc0203224:	16868693          	addi	a3,a3,360 # ffffffffc0206388 <default_pmm_manager+0x778>
ffffffffc0203228:	00002617          	auipc	a2,0x2
ffffffffc020322c:	65060613          	addi	a2,a2,1616 # ffffffffc0205878 <commands+0x870>
ffffffffc0203230:	0c500593          	li	a1,197
ffffffffc0203234:	00003517          	auipc	a0,0x3
ffffffffc0203238:	10450513          	addi	a0,a0,260 # ffffffffc0206338 <default_pmm_manager+0x728>
ffffffffc020323c:	a14fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0203240:	00003697          	auipc	a3,0x3
ffffffffc0203244:	15868693          	addi	a3,a3,344 # ffffffffc0206398 <default_pmm_manager+0x788>
ffffffffc0203248:	00002617          	auipc	a2,0x2
ffffffffc020324c:	63060613          	addi	a2,a2,1584 # ffffffffc0205878 <commands+0x870>
ffffffffc0203250:	0c800593          	li	a1,200
ffffffffc0203254:	00003517          	auipc	a0,0x3
ffffffffc0203258:	0e450513          	addi	a0,a0,228 # ffffffffc0206338 <default_pmm_manager+0x728>
ffffffffc020325c:	9f4fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(ret==0);
ffffffffc0203260:	00003697          	auipc	a3,0x3
ffffffffc0203264:	31868693          	addi	a3,a3,792 # ffffffffc0206578 <default_pmm_manager+0x968>
ffffffffc0203268:	00002617          	auipc	a2,0x2
ffffffffc020326c:	61060613          	addi	a2,a2,1552 # ffffffffc0205878 <commands+0x870>
ffffffffc0203270:	10300593          	li	a1,259
ffffffffc0203274:	00003517          	auipc	a0,0x3
ffffffffc0203278:	0c450513          	addi	a0,a0,196 # ffffffffc0206338 <default_pmm_manager+0x728>
ffffffffc020327c:	9d4fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(total == nr_free_pages());
ffffffffc0203280:	00002697          	auipc	a3,0x2
ffffffffc0203284:	62868693          	addi	a3,a3,1576 # ffffffffc02058a8 <commands+0x8a0>
ffffffffc0203288:	00002617          	auipc	a2,0x2
ffffffffc020328c:	5f060613          	addi	a2,a2,1520 # ffffffffc0205878 <commands+0x870>
ffffffffc0203290:	0c000593          	li	a1,192
ffffffffc0203294:	00003517          	auipc	a0,0x3
ffffffffc0203298:	0a450513          	addi	a0,a0,164 # ffffffffc0206338 <default_pmm_manager+0x728>
ffffffffc020329c:	9b4fd0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02032a0 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc02032a0:	00012797          	auipc	a5,0x12
ffffffffc02032a4:	1f878793          	addi	a5,a5,504 # ffffffffc0215498 <sm>
ffffffffc02032a8:	639c                	ld	a5,0(a5)
ffffffffc02032aa:	0107b303          	ld	t1,16(a5)
ffffffffc02032ae:	8302                	jr	t1

ffffffffc02032b0 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc02032b0:	00012797          	auipc	a5,0x12
ffffffffc02032b4:	1e878793          	addi	a5,a5,488 # ffffffffc0215498 <sm>
ffffffffc02032b8:	639c                	ld	a5,0(a5)
ffffffffc02032ba:	0207b303          	ld	t1,32(a5)
ffffffffc02032be:	8302                	jr	t1

ffffffffc02032c0 <swap_out>:
{
ffffffffc02032c0:	711d                	addi	sp,sp,-96
ffffffffc02032c2:	ec86                	sd	ra,88(sp)
ffffffffc02032c4:	e8a2                	sd	s0,80(sp)
ffffffffc02032c6:	e4a6                	sd	s1,72(sp)
ffffffffc02032c8:	e0ca                	sd	s2,64(sp)
ffffffffc02032ca:	fc4e                	sd	s3,56(sp)
ffffffffc02032cc:	f852                	sd	s4,48(sp)
ffffffffc02032ce:	f456                	sd	s5,40(sp)
ffffffffc02032d0:	f05a                	sd	s6,32(sp)
ffffffffc02032d2:	ec5e                	sd	s7,24(sp)
ffffffffc02032d4:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc02032d6:	cde9                	beqz	a1,ffffffffc02033b0 <swap_out+0xf0>
ffffffffc02032d8:	8ab2                	mv	s5,a2
ffffffffc02032da:	892a                	mv	s2,a0
ffffffffc02032dc:	8a2e                	mv	s4,a1
ffffffffc02032de:	4401                	li	s0,0
ffffffffc02032e0:	00012997          	auipc	s3,0x12
ffffffffc02032e4:	1b898993          	addi	s3,s3,440 # ffffffffc0215498 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02032e8:	00003b17          	auipc	s6,0x3
ffffffffc02032ec:	338b0b13          	addi	s6,s6,824 # ffffffffc0206620 <default_pmm_manager+0xa10>
                    cprintf("SWAP: failed to save\n");
ffffffffc02032f0:	00003b97          	auipc	s7,0x3
ffffffffc02032f4:	318b8b93          	addi	s7,s7,792 # ffffffffc0206608 <default_pmm_manager+0x9f8>
ffffffffc02032f8:	a825                	j	ffffffffc0203330 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02032fa:	67a2                	ld	a5,8(sp)
ffffffffc02032fc:	8626                	mv	a2,s1
ffffffffc02032fe:	85a2                	mv	a1,s0
ffffffffc0203300:	7f94                	ld	a3,56(a5)
ffffffffc0203302:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203304:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203306:	82b1                	srli	a3,a3,0xc
ffffffffc0203308:	0685                	addi	a3,a3,1
ffffffffc020330a:	e85fc0ef          	jal	ra,ffffffffc020018e <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc020330e:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0203310:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203312:	7d1c                	ld	a5,56(a0)
ffffffffc0203314:	83b1                	srli	a5,a5,0xc
ffffffffc0203316:	0785                	addi	a5,a5,1
ffffffffc0203318:	07a2                	slli	a5,a5,0x8
ffffffffc020331a:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc020331e:	901fe0ef          	jal	ra,ffffffffc0201c1e <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0203322:	01893503          	ld	a0,24(s2)
ffffffffc0203326:	85a6                	mv	a1,s1
ffffffffc0203328:	f6cff0ef          	jal	ra,ffffffffc0202a94 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc020332c:	048a0d63          	beq	s4,s0,ffffffffc0203386 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203330:	0009b783          	ld	a5,0(s3)
ffffffffc0203334:	8656                	mv	a2,s5
ffffffffc0203336:	002c                	addi	a1,sp,8
ffffffffc0203338:	7b9c                	ld	a5,48(a5)
ffffffffc020333a:	854a                	mv	a0,s2
ffffffffc020333c:	9782                	jalr	a5
          if (r != 0) {
ffffffffc020333e:	e12d                	bnez	a0,ffffffffc02033a0 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0203340:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203342:	01893503          	ld	a0,24(s2)
ffffffffc0203346:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203348:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020334a:	85a6                	mv	a1,s1
ffffffffc020334c:	959fe0ef          	jal	ra,ffffffffc0201ca4 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203350:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203352:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203354:	8b85                	andi	a5,a5,1
ffffffffc0203356:	cfb9                	beqz	a5,ffffffffc02033b4 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203358:	65a2                	ld	a1,8(sp)
ffffffffc020335a:	7d9c                	ld	a5,56(a1)
ffffffffc020335c:	83b1                	srli	a5,a5,0xc
ffffffffc020335e:	00178513          	addi	a0,a5,1
ffffffffc0203362:	0522                	slli	a0,a0,0x8
ffffffffc0203364:	5a7000ef          	jal	ra,ffffffffc020410a <swapfs_write>
ffffffffc0203368:	d949                	beqz	a0,ffffffffc02032fa <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc020336a:	855e                	mv	a0,s7
ffffffffc020336c:	e23fc0ef          	jal	ra,ffffffffc020018e <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203370:	0009b783          	ld	a5,0(s3)
ffffffffc0203374:	6622                	ld	a2,8(sp)
ffffffffc0203376:	4681                	li	a3,0
ffffffffc0203378:	739c                	ld	a5,32(a5)
ffffffffc020337a:	85a6                	mv	a1,s1
ffffffffc020337c:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc020337e:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203380:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0203382:	fa8a17e3          	bne	s4,s0,ffffffffc0203330 <swap_out+0x70>
}
ffffffffc0203386:	8522                	mv	a0,s0
ffffffffc0203388:	60e6                	ld	ra,88(sp)
ffffffffc020338a:	6446                	ld	s0,80(sp)
ffffffffc020338c:	64a6                	ld	s1,72(sp)
ffffffffc020338e:	6906                	ld	s2,64(sp)
ffffffffc0203390:	79e2                	ld	s3,56(sp)
ffffffffc0203392:	7a42                	ld	s4,48(sp)
ffffffffc0203394:	7aa2                	ld	s5,40(sp)
ffffffffc0203396:	7b02                	ld	s6,32(sp)
ffffffffc0203398:	6be2                	ld	s7,24(sp)
ffffffffc020339a:	6c42                	ld	s8,16(sp)
ffffffffc020339c:	6125                	addi	sp,sp,96
ffffffffc020339e:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc02033a0:	85a2                	mv	a1,s0
ffffffffc02033a2:	00003517          	auipc	a0,0x3
ffffffffc02033a6:	21e50513          	addi	a0,a0,542 # ffffffffc02065c0 <default_pmm_manager+0x9b0>
ffffffffc02033aa:	de5fc0ef          	jal	ra,ffffffffc020018e <cprintf>
                  break;
ffffffffc02033ae:	bfe1                	j	ffffffffc0203386 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc02033b0:	4401                	li	s0,0
ffffffffc02033b2:	bfd1                	j	ffffffffc0203386 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc02033b4:	00003697          	auipc	a3,0x3
ffffffffc02033b8:	23c68693          	addi	a3,a3,572 # ffffffffc02065f0 <default_pmm_manager+0x9e0>
ffffffffc02033bc:	00002617          	auipc	a2,0x2
ffffffffc02033c0:	4bc60613          	addi	a2,a2,1212 # ffffffffc0205878 <commands+0x870>
ffffffffc02033c4:	06900593          	li	a1,105
ffffffffc02033c8:	00003517          	auipc	a0,0x3
ffffffffc02033cc:	f7050513          	addi	a0,a0,-144 # ffffffffc0206338 <default_pmm_manager+0x728>
ffffffffc02033d0:	880fd0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02033d4 <swap_in>:
{
ffffffffc02033d4:	7179                	addi	sp,sp,-48
ffffffffc02033d6:	e84a                	sd	s2,16(sp)
ffffffffc02033d8:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc02033da:	4505                	li	a0,1
{
ffffffffc02033dc:	ec26                	sd	s1,24(sp)
ffffffffc02033de:	e44e                	sd	s3,8(sp)
ffffffffc02033e0:	f406                	sd	ra,40(sp)
ffffffffc02033e2:	f022                	sd	s0,32(sp)
ffffffffc02033e4:	84ae                	mv	s1,a1
ffffffffc02033e6:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc02033e8:	faefe0ef          	jal	ra,ffffffffc0201b96 <alloc_pages>
     assert(result!=NULL);
ffffffffc02033ec:	c129                	beqz	a0,ffffffffc020342e <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc02033ee:	842a                	mv	s0,a0
ffffffffc02033f0:	01893503          	ld	a0,24(s2)
ffffffffc02033f4:	4601                	li	a2,0
ffffffffc02033f6:	85a6                	mv	a1,s1
ffffffffc02033f8:	8adfe0ef          	jal	ra,ffffffffc0201ca4 <get_pte>
ffffffffc02033fc:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc02033fe:	6108                	ld	a0,0(a0)
ffffffffc0203400:	85a2                	mv	a1,s0
ffffffffc0203402:	471000ef          	jal	ra,ffffffffc0204072 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203406:	00093583          	ld	a1,0(s2)
ffffffffc020340a:	8626                	mv	a2,s1
ffffffffc020340c:	00003517          	auipc	a0,0x3
ffffffffc0203410:	ecc50513          	addi	a0,a0,-308 # ffffffffc02062d8 <default_pmm_manager+0x6c8>
ffffffffc0203414:	81a1                	srli	a1,a1,0x8
ffffffffc0203416:	d79fc0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc020341a:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc020341c:	0089b023          	sd	s0,0(s3)
}
ffffffffc0203420:	7402                	ld	s0,32(sp)
ffffffffc0203422:	64e2                	ld	s1,24(sp)
ffffffffc0203424:	6942                	ld	s2,16(sp)
ffffffffc0203426:	69a2                	ld	s3,8(sp)
ffffffffc0203428:	4501                	li	a0,0
ffffffffc020342a:	6145                	addi	sp,sp,48
ffffffffc020342c:	8082                	ret
     assert(result!=NULL);
ffffffffc020342e:	00003697          	auipc	a3,0x3
ffffffffc0203432:	e9a68693          	addi	a3,a3,-358 # ffffffffc02062c8 <default_pmm_manager+0x6b8>
ffffffffc0203436:	00002617          	auipc	a2,0x2
ffffffffc020343a:	44260613          	addi	a2,a2,1090 # ffffffffc0205878 <commands+0x870>
ffffffffc020343e:	07f00593          	li	a1,127
ffffffffc0203442:	00003517          	auipc	a0,0x3
ffffffffc0203446:	ef650513          	addi	a0,a0,-266 # ffffffffc0206338 <default_pmm_manager+0x728>
ffffffffc020344a:	806fd0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc020344e <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc020344e:	00012797          	auipc	a5,0x12
ffffffffc0203452:	18278793          	addi	a5,a5,386 # ffffffffc02155d0 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0203456:	f51c                	sd	a5,40(a0)
ffffffffc0203458:	e79c                	sd	a5,8(a5)
ffffffffc020345a:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc020345c:	4501                	li	a0,0
ffffffffc020345e:	8082                	ret

ffffffffc0203460 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0203460:	4501                	li	a0,0
ffffffffc0203462:	8082                	ret

ffffffffc0203464 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203464:	4501                	li	a0,0
ffffffffc0203466:	8082                	ret

ffffffffc0203468 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0203468:	4501                	li	a0,0
ffffffffc020346a:	8082                	ret

ffffffffc020346c <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc020346c:	711d                	addi	sp,sp,-96
ffffffffc020346e:	fc4e                	sd	s3,56(sp)
ffffffffc0203470:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203472:	00003517          	auipc	a0,0x3
ffffffffc0203476:	1ee50513          	addi	a0,a0,494 # ffffffffc0206660 <default_pmm_manager+0xa50>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc020347a:	698d                	lui	s3,0x3
ffffffffc020347c:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc020347e:	e8a2                	sd	s0,80(sp)
ffffffffc0203480:	e4a6                	sd	s1,72(sp)
ffffffffc0203482:	ec86                	sd	ra,88(sp)
ffffffffc0203484:	e0ca                	sd	s2,64(sp)
ffffffffc0203486:	f456                	sd	s5,40(sp)
ffffffffc0203488:	f05a                	sd	s6,32(sp)
ffffffffc020348a:	ec5e                	sd	s7,24(sp)
ffffffffc020348c:	e862                	sd	s8,16(sp)
ffffffffc020348e:	e466                	sd	s9,8(sp)
    assert(pgfault_num==4);
ffffffffc0203490:	00012417          	auipc	s0,0x12
ffffffffc0203494:	01440413          	addi	s0,s0,20 # ffffffffc02154a4 <pgfault_num>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203498:	cf7fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc020349c:	01498023          	sb	s4,0(s3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc02034a0:	4004                	lw	s1,0(s0)
ffffffffc02034a2:	4791                	li	a5,4
ffffffffc02034a4:	2481                	sext.w	s1,s1
ffffffffc02034a6:	14f49963          	bne	s1,a5,ffffffffc02035f8 <_fifo_check_swap+0x18c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02034aa:	00003517          	auipc	a0,0x3
ffffffffc02034ae:	1f650513          	addi	a0,a0,502 # ffffffffc02066a0 <default_pmm_manager+0xa90>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02034b2:	6a85                	lui	s5,0x1
ffffffffc02034b4:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02034b6:	cd9fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02034ba:	016a8023          	sb	s6,0(s5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc02034be:	00042903          	lw	s2,0(s0)
ffffffffc02034c2:	2901                	sext.w	s2,s2
ffffffffc02034c4:	2a991a63          	bne	s2,s1,ffffffffc0203778 <_fifo_check_swap+0x30c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02034c8:	00003517          	auipc	a0,0x3
ffffffffc02034cc:	20050513          	addi	a0,a0,512 # ffffffffc02066c8 <default_pmm_manager+0xab8>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02034d0:	6b91                	lui	s7,0x4
ffffffffc02034d2:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02034d4:	cbbfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02034d8:	018b8023          	sb	s8,0(s7) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc02034dc:	4004                	lw	s1,0(s0)
ffffffffc02034de:	2481                	sext.w	s1,s1
ffffffffc02034e0:	27249c63          	bne	s1,s2,ffffffffc0203758 <_fifo_check_swap+0x2ec>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02034e4:	00003517          	auipc	a0,0x3
ffffffffc02034e8:	20c50513          	addi	a0,a0,524 # ffffffffc02066f0 <default_pmm_manager+0xae0>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02034ec:	6909                	lui	s2,0x2
ffffffffc02034ee:	4cad                	li	s9,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02034f0:	c9ffc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02034f4:	01990023          	sb	s9,0(s2) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc02034f8:	401c                	lw	a5,0(s0)
ffffffffc02034fa:	2781                	sext.w	a5,a5
ffffffffc02034fc:	22979e63          	bne	a5,s1,ffffffffc0203738 <_fifo_check_swap+0x2cc>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203500:	00003517          	auipc	a0,0x3
ffffffffc0203504:	21850513          	addi	a0,a0,536 # ffffffffc0206718 <default_pmm_manager+0xb08>
ffffffffc0203508:	c87fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc020350c:	6795                	lui	a5,0x5
ffffffffc020350e:	4739                	li	a4,14
ffffffffc0203510:	00e78023          	sb	a4,0(a5) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0203514:	4004                	lw	s1,0(s0)
ffffffffc0203516:	4795                	li	a5,5
ffffffffc0203518:	2481                	sext.w	s1,s1
ffffffffc020351a:	1ef49f63          	bne	s1,a5,ffffffffc0203718 <_fifo_check_swap+0x2ac>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc020351e:	00003517          	auipc	a0,0x3
ffffffffc0203522:	1d250513          	addi	a0,a0,466 # ffffffffc02066f0 <default_pmm_manager+0xae0>
ffffffffc0203526:	c69fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020352a:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==5);
ffffffffc020352e:	401c                	lw	a5,0(s0)
ffffffffc0203530:	2781                	sext.w	a5,a5
ffffffffc0203532:	1c979363          	bne	a5,s1,ffffffffc02036f8 <_fifo_check_swap+0x28c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203536:	00003517          	auipc	a0,0x3
ffffffffc020353a:	16a50513          	addi	a0,a0,362 # ffffffffc02066a0 <default_pmm_manager+0xa90>
ffffffffc020353e:	c51fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203542:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0203546:	401c                	lw	a5,0(s0)
ffffffffc0203548:	4719                	li	a4,6
ffffffffc020354a:	2781                	sext.w	a5,a5
ffffffffc020354c:	18e79663          	bne	a5,a4,ffffffffc02036d8 <_fifo_check_swap+0x26c>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203550:	00003517          	auipc	a0,0x3
ffffffffc0203554:	1a050513          	addi	a0,a0,416 # ffffffffc02066f0 <default_pmm_manager+0xae0>
ffffffffc0203558:	c37fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020355c:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==7);
ffffffffc0203560:	401c                	lw	a5,0(s0)
ffffffffc0203562:	471d                	li	a4,7
ffffffffc0203564:	2781                	sext.w	a5,a5
ffffffffc0203566:	14e79963          	bne	a5,a4,ffffffffc02036b8 <_fifo_check_swap+0x24c>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc020356a:	00003517          	auipc	a0,0x3
ffffffffc020356e:	0f650513          	addi	a0,a0,246 # ffffffffc0206660 <default_pmm_manager+0xa50>
ffffffffc0203572:	c1dfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203576:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc020357a:	401c                	lw	a5,0(s0)
ffffffffc020357c:	4721                	li	a4,8
ffffffffc020357e:	2781                	sext.w	a5,a5
ffffffffc0203580:	10e79c63          	bne	a5,a4,ffffffffc0203698 <_fifo_check_swap+0x22c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203584:	00003517          	auipc	a0,0x3
ffffffffc0203588:	14450513          	addi	a0,a0,324 # ffffffffc02066c8 <default_pmm_manager+0xab8>
ffffffffc020358c:	c03fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203590:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0203594:	401c                	lw	a5,0(s0)
ffffffffc0203596:	4725                	li	a4,9
ffffffffc0203598:	2781                	sext.w	a5,a5
ffffffffc020359a:	0ce79f63          	bne	a5,a4,ffffffffc0203678 <_fifo_check_swap+0x20c>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc020359e:	00003517          	auipc	a0,0x3
ffffffffc02035a2:	17a50513          	addi	a0,a0,378 # ffffffffc0206718 <default_pmm_manager+0xb08>
ffffffffc02035a6:	be9fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02035aa:	6795                	lui	a5,0x5
ffffffffc02035ac:	4739                	li	a4,14
ffffffffc02035ae:	00e78023          	sb	a4,0(a5) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==10);
ffffffffc02035b2:	4004                	lw	s1,0(s0)
ffffffffc02035b4:	47a9                	li	a5,10
ffffffffc02035b6:	2481                	sext.w	s1,s1
ffffffffc02035b8:	0af49063          	bne	s1,a5,ffffffffc0203658 <_fifo_check_swap+0x1ec>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02035bc:	00003517          	auipc	a0,0x3
ffffffffc02035c0:	0e450513          	addi	a0,a0,228 # ffffffffc02066a0 <default_pmm_manager+0xa90>
ffffffffc02035c4:	bcbfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02035c8:	6785                	lui	a5,0x1
ffffffffc02035ca:	0007c783          	lbu	a5,0(a5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc02035ce:	06979563          	bne	a5,s1,ffffffffc0203638 <_fifo_check_swap+0x1cc>
    assert(pgfault_num==11);
ffffffffc02035d2:	401c                	lw	a5,0(s0)
ffffffffc02035d4:	472d                	li	a4,11
ffffffffc02035d6:	2781                	sext.w	a5,a5
ffffffffc02035d8:	04e79063          	bne	a5,a4,ffffffffc0203618 <_fifo_check_swap+0x1ac>
}
ffffffffc02035dc:	60e6                	ld	ra,88(sp)
ffffffffc02035de:	6446                	ld	s0,80(sp)
ffffffffc02035e0:	64a6                	ld	s1,72(sp)
ffffffffc02035e2:	6906                	ld	s2,64(sp)
ffffffffc02035e4:	79e2                	ld	s3,56(sp)
ffffffffc02035e6:	7a42                	ld	s4,48(sp)
ffffffffc02035e8:	7aa2                	ld	s5,40(sp)
ffffffffc02035ea:	7b02                	ld	s6,32(sp)
ffffffffc02035ec:	6be2                	ld	s7,24(sp)
ffffffffc02035ee:	6c42                	ld	s8,16(sp)
ffffffffc02035f0:	6ca2                	ld	s9,8(sp)
ffffffffc02035f2:	4501                	li	a0,0
ffffffffc02035f4:	6125                	addi	sp,sp,96
ffffffffc02035f6:	8082                	ret
    assert(pgfault_num==4);
ffffffffc02035f8:	00003697          	auipc	a3,0x3
ffffffffc02035fc:	f0868693          	addi	a3,a3,-248 # ffffffffc0206500 <default_pmm_manager+0x8f0>
ffffffffc0203600:	00002617          	auipc	a2,0x2
ffffffffc0203604:	27860613          	addi	a2,a2,632 # ffffffffc0205878 <commands+0x870>
ffffffffc0203608:	05100593          	li	a1,81
ffffffffc020360c:	00003517          	auipc	a0,0x3
ffffffffc0203610:	07c50513          	addi	a0,a0,124 # ffffffffc0206688 <default_pmm_manager+0xa78>
ffffffffc0203614:	e3dfc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==11);
ffffffffc0203618:	00003697          	auipc	a3,0x3
ffffffffc020361c:	1b068693          	addi	a3,a3,432 # ffffffffc02067c8 <default_pmm_manager+0xbb8>
ffffffffc0203620:	00002617          	auipc	a2,0x2
ffffffffc0203624:	25860613          	addi	a2,a2,600 # ffffffffc0205878 <commands+0x870>
ffffffffc0203628:	07300593          	li	a1,115
ffffffffc020362c:	00003517          	auipc	a0,0x3
ffffffffc0203630:	05c50513          	addi	a0,a0,92 # ffffffffc0206688 <default_pmm_manager+0xa78>
ffffffffc0203634:	e1dfc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203638:	00003697          	auipc	a3,0x3
ffffffffc020363c:	16868693          	addi	a3,a3,360 # ffffffffc02067a0 <default_pmm_manager+0xb90>
ffffffffc0203640:	00002617          	auipc	a2,0x2
ffffffffc0203644:	23860613          	addi	a2,a2,568 # ffffffffc0205878 <commands+0x870>
ffffffffc0203648:	07100593          	li	a1,113
ffffffffc020364c:	00003517          	auipc	a0,0x3
ffffffffc0203650:	03c50513          	addi	a0,a0,60 # ffffffffc0206688 <default_pmm_manager+0xa78>
ffffffffc0203654:	dfdfc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==10);
ffffffffc0203658:	00003697          	auipc	a3,0x3
ffffffffc020365c:	13868693          	addi	a3,a3,312 # ffffffffc0206790 <default_pmm_manager+0xb80>
ffffffffc0203660:	00002617          	auipc	a2,0x2
ffffffffc0203664:	21860613          	addi	a2,a2,536 # ffffffffc0205878 <commands+0x870>
ffffffffc0203668:	06f00593          	li	a1,111
ffffffffc020366c:	00003517          	auipc	a0,0x3
ffffffffc0203670:	01c50513          	addi	a0,a0,28 # ffffffffc0206688 <default_pmm_manager+0xa78>
ffffffffc0203674:	dddfc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==9);
ffffffffc0203678:	00003697          	auipc	a3,0x3
ffffffffc020367c:	10868693          	addi	a3,a3,264 # ffffffffc0206780 <default_pmm_manager+0xb70>
ffffffffc0203680:	00002617          	auipc	a2,0x2
ffffffffc0203684:	1f860613          	addi	a2,a2,504 # ffffffffc0205878 <commands+0x870>
ffffffffc0203688:	06c00593          	li	a1,108
ffffffffc020368c:	00003517          	auipc	a0,0x3
ffffffffc0203690:	ffc50513          	addi	a0,a0,-4 # ffffffffc0206688 <default_pmm_manager+0xa78>
ffffffffc0203694:	dbdfc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==8);
ffffffffc0203698:	00003697          	auipc	a3,0x3
ffffffffc020369c:	0d868693          	addi	a3,a3,216 # ffffffffc0206770 <default_pmm_manager+0xb60>
ffffffffc02036a0:	00002617          	auipc	a2,0x2
ffffffffc02036a4:	1d860613          	addi	a2,a2,472 # ffffffffc0205878 <commands+0x870>
ffffffffc02036a8:	06900593          	li	a1,105
ffffffffc02036ac:	00003517          	auipc	a0,0x3
ffffffffc02036b0:	fdc50513          	addi	a0,a0,-36 # ffffffffc0206688 <default_pmm_manager+0xa78>
ffffffffc02036b4:	d9dfc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==7);
ffffffffc02036b8:	00003697          	auipc	a3,0x3
ffffffffc02036bc:	0a868693          	addi	a3,a3,168 # ffffffffc0206760 <default_pmm_manager+0xb50>
ffffffffc02036c0:	00002617          	auipc	a2,0x2
ffffffffc02036c4:	1b860613          	addi	a2,a2,440 # ffffffffc0205878 <commands+0x870>
ffffffffc02036c8:	06600593          	li	a1,102
ffffffffc02036cc:	00003517          	auipc	a0,0x3
ffffffffc02036d0:	fbc50513          	addi	a0,a0,-68 # ffffffffc0206688 <default_pmm_manager+0xa78>
ffffffffc02036d4:	d7dfc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==6);
ffffffffc02036d8:	00003697          	auipc	a3,0x3
ffffffffc02036dc:	07868693          	addi	a3,a3,120 # ffffffffc0206750 <default_pmm_manager+0xb40>
ffffffffc02036e0:	00002617          	auipc	a2,0x2
ffffffffc02036e4:	19860613          	addi	a2,a2,408 # ffffffffc0205878 <commands+0x870>
ffffffffc02036e8:	06300593          	li	a1,99
ffffffffc02036ec:	00003517          	auipc	a0,0x3
ffffffffc02036f0:	f9c50513          	addi	a0,a0,-100 # ffffffffc0206688 <default_pmm_manager+0xa78>
ffffffffc02036f4:	d5dfc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==5);
ffffffffc02036f8:	00003697          	auipc	a3,0x3
ffffffffc02036fc:	04868693          	addi	a3,a3,72 # ffffffffc0206740 <default_pmm_manager+0xb30>
ffffffffc0203700:	00002617          	auipc	a2,0x2
ffffffffc0203704:	17860613          	addi	a2,a2,376 # ffffffffc0205878 <commands+0x870>
ffffffffc0203708:	06000593          	li	a1,96
ffffffffc020370c:	00003517          	auipc	a0,0x3
ffffffffc0203710:	f7c50513          	addi	a0,a0,-132 # ffffffffc0206688 <default_pmm_manager+0xa78>
ffffffffc0203714:	d3dfc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==5);
ffffffffc0203718:	00003697          	auipc	a3,0x3
ffffffffc020371c:	02868693          	addi	a3,a3,40 # ffffffffc0206740 <default_pmm_manager+0xb30>
ffffffffc0203720:	00002617          	auipc	a2,0x2
ffffffffc0203724:	15860613          	addi	a2,a2,344 # ffffffffc0205878 <commands+0x870>
ffffffffc0203728:	05d00593          	li	a1,93
ffffffffc020372c:	00003517          	auipc	a0,0x3
ffffffffc0203730:	f5c50513          	addi	a0,a0,-164 # ffffffffc0206688 <default_pmm_manager+0xa78>
ffffffffc0203734:	d1dfc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==4);
ffffffffc0203738:	00003697          	auipc	a3,0x3
ffffffffc020373c:	dc868693          	addi	a3,a3,-568 # ffffffffc0206500 <default_pmm_manager+0x8f0>
ffffffffc0203740:	00002617          	auipc	a2,0x2
ffffffffc0203744:	13860613          	addi	a2,a2,312 # ffffffffc0205878 <commands+0x870>
ffffffffc0203748:	05a00593          	li	a1,90
ffffffffc020374c:	00003517          	auipc	a0,0x3
ffffffffc0203750:	f3c50513          	addi	a0,a0,-196 # ffffffffc0206688 <default_pmm_manager+0xa78>
ffffffffc0203754:	cfdfc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==4);
ffffffffc0203758:	00003697          	auipc	a3,0x3
ffffffffc020375c:	da868693          	addi	a3,a3,-600 # ffffffffc0206500 <default_pmm_manager+0x8f0>
ffffffffc0203760:	00002617          	auipc	a2,0x2
ffffffffc0203764:	11860613          	addi	a2,a2,280 # ffffffffc0205878 <commands+0x870>
ffffffffc0203768:	05700593          	li	a1,87
ffffffffc020376c:	00003517          	auipc	a0,0x3
ffffffffc0203770:	f1c50513          	addi	a0,a0,-228 # ffffffffc0206688 <default_pmm_manager+0xa78>
ffffffffc0203774:	cddfc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==4);
ffffffffc0203778:	00003697          	auipc	a3,0x3
ffffffffc020377c:	d8868693          	addi	a3,a3,-632 # ffffffffc0206500 <default_pmm_manager+0x8f0>
ffffffffc0203780:	00002617          	auipc	a2,0x2
ffffffffc0203784:	0f860613          	addi	a2,a2,248 # ffffffffc0205878 <commands+0x870>
ffffffffc0203788:	05400593          	li	a1,84
ffffffffc020378c:	00003517          	auipc	a0,0x3
ffffffffc0203790:	efc50513          	addi	a0,a0,-260 # ffffffffc0206688 <default_pmm_manager+0xa78>
ffffffffc0203794:	cbdfc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0203798 <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203798:	751c                	ld	a5,40(a0)
{
ffffffffc020379a:	1141                	addi	sp,sp,-16
ffffffffc020379c:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc020379e:	cf91                	beqz	a5,ffffffffc02037ba <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc02037a0:	ee0d                	bnez	a2,ffffffffc02037da <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc02037a2:	679c                	ld	a5,8(a5)
}
ffffffffc02037a4:	60a2                	ld	ra,8(sp)
ffffffffc02037a6:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc02037a8:	6394                	ld	a3,0(a5)
ffffffffc02037aa:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc02037ac:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc02037b0:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc02037b2:	e314                	sd	a3,0(a4)
ffffffffc02037b4:	e19c                	sd	a5,0(a1)
}
ffffffffc02037b6:	0141                	addi	sp,sp,16
ffffffffc02037b8:	8082                	ret
         assert(head != NULL);
ffffffffc02037ba:	00003697          	auipc	a3,0x3
ffffffffc02037be:	03e68693          	addi	a3,a3,62 # ffffffffc02067f8 <default_pmm_manager+0xbe8>
ffffffffc02037c2:	00002617          	auipc	a2,0x2
ffffffffc02037c6:	0b660613          	addi	a2,a2,182 # ffffffffc0205878 <commands+0x870>
ffffffffc02037ca:	04100593          	li	a1,65
ffffffffc02037ce:	00003517          	auipc	a0,0x3
ffffffffc02037d2:	eba50513          	addi	a0,a0,-326 # ffffffffc0206688 <default_pmm_manager+0xa78>
ffffffffc02037d6:	c7bfc0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(in_tick==0);
ffffffffc02037da:	00003697          	auipc	a3,0x3
ffffffffc02037de:	02e68693          	addi	a3,a3,46 # ffffffffc0206808 <default_pmm_manager+0xbf8>
ffffffffc02037e2:	00002617          	auipc	a2,0x2
ffffffffc02037e6:	09660613          	addi	a2,a2,150 # ffffffffc0205878 <commands+0x870>
ffffffffc02037ea:	04200593          	li	a1,66
ffffffffc02037ee:	00003517          	auipc	a0,0x3
ffffffffc02037f2:	e9a50513          	addi	a0,a0,-358 # ffffffffc0206688 <default_pmm_manager+0xa78>
ffffffffc02037f6:	c5bfc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02037fa <_fifo_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc02037fa:	02860713          	addi	a4,a2,40
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02037fe:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0203800:	cb09                	beqz	a4,ffffffffc0203812 <_fifo_map_swappable+0x18>
ffffffffc0203802:	cb81                	beqz	a5,ffffffffc0203812 <_fifo_map_swappable+0x18>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203804:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc0203806:	e398                	sd	a4,0(a5)
}
ffffffffc0203808:	4501                	li	a0,0
ffffffffc020380a:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc020380c:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc020380e:	f614                	sd	a3,40(a2)
ffffffffc0203810:	8082                	ret
{
ffffffffc0203812:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0203814:	00003697          	auipc	a3,0x3
ffffffffc0203818:	fc468693          	addi	a3,a3,-60 # ffffffffc02067d8 <default_pmm_manager+0xbc8>
ffffffffc020381c:	00002617          	auipc	a2,0x2
ffffffffc0203820:	05c60613          	addi	a2,a2,92 # ffffffffc0205878 <commands+0x870>
ffffffffc0203824:	03200593          	li	a1,50
ffffffffc0203828:	00003517          	auipc	a0,0x3
ffffffffc020382c:	e6050513          	addi	a0,a0,-416 # ffffffffc0206688 <default_pmm_manager+0xa78>
{
ffffffffc0203830:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0203832:	c1ffc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0203836 <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0203836:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0203838:	00003697          	auipc	a3,0x3
ffffffffc020383c:	ff868693          	addi	a3,a3,-8 # ffffffffc0206830 <default_pmm_manager+0xc20>
ffffffffc0203840:	00002617          	auipc	a2,0x2
ffffffffc0203844:	03860613          	addi	a2,a2,56 # ffffffffc0205878 <commands+0x870>
ffffffffc0203848:	07e00593          	li	a1,126
ffffffffc020384c:	00003517          	auipc	a0,0x3
ffffffffc0203850:	00450513          	addi	a0,a0,4 # ffffffffc0206850 <default_pmm_manager+0xc40>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0203854:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0203856:	bfbfc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc020385a <mm_create>:
mm_create(void) {
ffffffffc020385a:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020385c:	03000513          	li	a0,48
mm_create(void) {
ffffffffc0203860:	e022                	sd	s0,0(sp)
ffffffffc0203862:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203864:	936fe0ef          	jal	ra,ffffffffc020199a <kmalloc>
ffffffffc0203868:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc020386a:	c115                	beqz	a0,ffffffffc020388e <mm_create+0x34>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020386c:	00012797          	auipc	a5,0x12
ffffffffc0203870:	c3478793          	addi	a5,a5,-972 # ffffffffc02154a0 <swap_init_ok>
ffffffffc0203874:	439c                	lw	a5,0(a5)
    elm->prev = elm->next = elm;
ffffffffc0203876:	e408                	sd	a0,8(s0)
ffffffffc0203878:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc020387a:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc020387e:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203882:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203886:	2781                	sext.w	a5,a5
ffffffffc0203888:	eb81                	bnez	a5,ffffffffc0203898 <mm_create+0x3e>
        else mm->sm_priv = NULL;
ffffffffc020388a:	02053423          	sd	zero,40(a0)
}
ffffffffc020388e:	8522                	mv	a0,s0
ffffffffc0203890:	60a2                	ld	ra,8(sp)
ffffffffc0203892:	6402                	ld	s0,0(sp)
ffffffffc0203894:	0141                	addi	sp,sp,16
ffffffffc0203896:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203898:	a09ff0ef          	jal	ra,ffffffffc02032a0 <swap_init_mm>
}
ffffffffc020389c:	8522                	mv	a0,s0
ffffffffc020389e:	60a2                	ld	ra,8(sp)
ffffffffc02038a0:	6402                	ld	s0,0(sp)
ffffffffc02038a2:	0141                	addi	sp,sp,16
ffffffffc02038a4:	8082                	ret

ffffffffc02038a6 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc02038a6:	1101                	addi	sp,sp,-32
ffffffffc02038a8:	e04a                	sd	s2,0(sp)
ffffffffc02038aa:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02038ac:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc02038b0:	e822                	sd	s0,16(sp)
ffffffffc02038b2:	e426                	sd	s1,8(sp)
ffffffffc02038b4:	ec06                	sd	ra,24(sp)
ffffffffc02038b6:	84ae                	mv	s1,a1
ffffffffc02038b8:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02038ba:	8e0fe0ef          	jal	ra,ffffffffc020199a <kmalloc>
    if (vma != NULL) {
ffffffffc02038be:	c509                	beqz	a0,ffffffffc02038c8 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc02038c0:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc02038c4:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02038c6:	cd00                	sw	s0,24(a0)
}
ffffffffc02038c8:	60e2                	ld	ra,24(sp)
ffffffffc02038ca:	6442                	ld	s0,16(sp)
ffffffffc02038cc:	64a2                	ld	s1,8(sp)
ffffffffc02038ce:	6902                	ld	s2,0(sp)
ffffffffc02038d0:	6105                	addi	sp,sp,32
ffffffffc02038d2:	8082                	ret

ffffffffc02038d4 <find_vma>:
    if (mm != NULL) {
ffffffffc02038d4:	c51d                	beqz	a0,ffffffffc0203902 <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc02038d6:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02038d8:	c781                	beqz	a5,ffffffffc02038e0 <find_vma+0xc>
ffffffffc02038da:	6798                	ld	a4,8(a5)
ffffffffc02038dc:	02e5f663          	bleu	a4,a1,ffffffffc0203908 <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc02038e0:	87aa                	mv	a5,a0
    return listelm->next;
ffffffffc02038e2:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc02038e4:	00f50f63          	beq	a0,a5,ffffffffc0203902 <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc02038e8:	fe87b703          	ld	a4,-24(a5)
ffffffffc02038ec:	fee5ebe3          	bltu	a1,a4,ffffffffc02038e2 <find_vma+0xe>
ffffffffc02038f0:	ff07b703          	ld	a4,-16(a5)
ffffffffc02038f4:	fee5f7e3          	bleu	a4,a1,ffffffffc02038e2 <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc02038f8:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc02038fa:	c781                	beqz	a5,ffffffffc0203902 <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc02038fc:	e91c                	sd	a5,16(a0)
}
ffffffffc02038fe:	853e                	mv	a0,a5
ffffffffc0203900:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc0203902:	4781                	li	a5,0
}
ffffffffc0203904:	853e                	mv	a0,a5
ffffffffc0203906:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0203908:	6b98                	ld	a4,16(a5)
ffffffffc020390a:	fce5fbe3          	bleu	a4,a1,ffffffffc02038e0 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc020390e:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc0203910:	b7fd                	j	ffffffffc02038fe <find_vma+0x2a>

ffffffffc0203912 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203912:	6590                	ld	a2,8(a1)
ffffffffc0203914:	0105b803          	ld	a6,16(a1) # 1010 <BASE_ADDRESS-0xffffffffc01feff0>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0203918:	1141                	addi	sp,sp,-16
ffffffffc020391a:	e406                	sd	ra,8(sp)
ffffffffc020391c:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc020391e:	01066863          	bltu	a2,a6,ffffffffc020392e <insert_vma_struct+0x1c>
ffffffffc0203922:	a8b9                	j	ffffffffc0203980 <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0203924:	fe87b683          	ld	a3,-24(a5)
ffffffffc0203928:	04d66763          	bltu	a2,a3,ffffffffc0203976 <insert_vma_struct+0x64>
ffffffffc020392c:	873e                	mv	a4,a5
ffffffffc020392e:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc0203930:	fef51ae3          	bne	a0,a5,ffffffffc0203924 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0203934:	02a70463          	beq	a4,a0,ffffffffc020395c <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0203938:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc020393c:	fe873883          	ld	a7,-24(a4)
ffffffffc0203940:	08d8f063          	bleu	a3,a7,ffffffffc02039c0 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203944:	04d66e63          	bltu	a2,a3,ffffffffc02039a0 <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc0203948:	00f50a63          	beq	a0,a5,ffffffffc020395c <insert_vma_struct+0x4a>
ffffffffc020394c:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203950:	0506e863          	bltu	a3,a6,ffffffffc02039a0 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc0203954:	ff07b603          	ld	a2,-16(a5)
ffffffffc0203958:	02c6f263          	bleu	a2,a3,ffffffffc020397c <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc020395c:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc020395e:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0203960:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc0203964:	e390                	sd	a2,0(a5)
ffffffffc0203966:	e710                	sd	a2,8(a4)
}
ffffffffc0203968:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc020396a:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc020396c:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc020396e:	2685                	addiw	a3,a3,1
ffffffffc0203970:	d114                	sw	a3,32(a0)
}
ffffffffc0203972:	0141                	addi	sp,sp,16
ffffffffc0203974:	8082                	ret
    if (le_prev != list) {
ffffffffc0203976:	fca711e3          	bne	a4,a0,ffffffffc0203938 <insert_vma_struct+0x26>
ffffffffc020397a:	bfd9                	j	ffffffffc0203950 <insert_vma_struct+0x3e>
ffffffffc020397c:	ebbff0ef          	jal	ra,ffffffffc0203836 <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203980:	00003697          	auipc	a3,0x3
ffffffffc0203984:	f8068693          	addi	a3,a3,-128 # ffffffffc0206900 <default_pmm_manager+0xcf0>
ffffffffc0203988:	00002617          	auipc	a2,0x2
ffffffffc020398c:	ef060613          	addi	a2,a2,-272 # ffffffffc0205878 <commands+0x870>
ffffffffc0203990:	08500593          	li	a1,133
ffffffffc0203994:	00003517          	auipc	a0,0x3
ffffffffc0203998:	ebc50513          	addi	a0,a0,-324 # ffffffffc0206850 <default_pmm_manager+0xc40>
ffffffffc020399c:	ab5fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02039a0:	00003697          	auipc	a3,0x3
ffffffffc02039a4:	fa068693          	addi	a3,a3,-96 # ffffffffc0206940 <default_pmm_manager+0xd30>
ffffffffc02039a8:	00002617          	auipc	a2,0x2
ffffffffc02039ac:	ed060613          	addi	a2,a2,-304 # ffffffffc0205878 <commands+0x870>
ffffffffc02039b0:	07d00593          	li	a1,125
ffffffffc02039b4:	00003517          	auipc	a0,0x3
ffffffffc02039b8:	e9c50513          	addi	a0,a0,-356 # ffffffffc0206850 <default_pmm_manager+0xc40>
ffffffffc02039bc:	a95fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc02039c0:	00003697          	auipc	a3,0x3
ffffffffc02039c4:	f6068693          	addi	a3,a3,-160 # ffffffffc0206920 <default_pmm_manager+0xd10>
ffffffffc02039c8:	00002617          	auipc	a2,0x2
ffffffffc02039cc:	eb060613          	addi	a2,a2,-336 # ffffffffc0205878 <commands+0x870>
ffffffffc02039d0:	07c00593          	li	a1,124
ffffffffc02039d4:	00003517          	auipc	a0,0x3
ffffffffc02039d8:	e7c50513          	addi	a0,a0,-388 # ffffffffc0206850 <default_pmm_manager+0xc40>
ffffffffc02039dc:	a75fc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02039e0 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc02039e0:	1141                	addi	sp,sp,-16
ffffffffc02039e2:	e022                	sd	s0,0(sp)
ffffffffc02039e4:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc02039e6:	6508                	ld	a0,8(a0)
ffffffffc02039e8:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc02039ea:	00a40c63          	beq	s0,a0,ffffffffc0203a02 <mm_destroy+0x22>
    __list_del(listelm->prev, listelm->next);
ffffffffc02039ee:	6118                	ld	a4,0(a0)
ffffffffc02039f0:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc02039f2:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc02039f4:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02039f6:	e398                	sd	a4,0(a5)
ffffffffc02039f8:	85efe0ef          	jal	ra,ffffffffc0201a56 <kfree>
    return listelm->next;
ffffffffc02039fc:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc02039fe:	fea418e3          	bne	s0,a0,ffffffffc02039ee <mm_destroy+0xe>
    }
    kfree(mm); //kfree mm
ffffffffc0203a02:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0203a04:	6402                	ld	s0,0(sp)
ffffffffc0203a06:	60a2                	ld	ra,8(sp)
ffffffffc0203a08:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc0203a0a:	84cfe06f          	j	ffffffffc0201a56 <kfree>

ffffffffc0203a0e <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0203a0e:	7139                	addi	sp,sp,-64
ffffffffc0203a10:	f822                	sd	s0,48(sp)
ffffffffc0203a12:	f426                	sd	s1,40(sp)
ffffffffc0203a14:	fc06                	sd	ra,56(sp)
ffffffffc0203a16:	f04a                	sd	s2,32(sp)
ffffffffc0203a18:	ec4e                	sd	s3,24(sp)
ffffffffc0203a1a:	e852                	sd	s4,16(sp)
ffffffffc0203a1c:	e456                	sd	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    struct mm_struct *mm = mm_create();
ffffffffc0203a1e:	e3dff0ef          	jal	ra,ffffffffc020385a <mm_create>
    assert(mm != NULL);
ffffffffc0203a22:	842a                	mv	s0,a0
ffffffffc0203a24:	03200493          	li	s1,50
ffffffffc0203a28:	e919                	bnez	a0,ffffffffc0203a3e <vmm_init+0x30>
ffffffffc0203a2a:	a989                	j	ffffffffc0203e7c <vmm_init+0x46e>
        vma->vm_start = vm_start;
ffffffffc0203a2c:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203a2e:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203a30:	00052c23          	sw	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203a34:	14ed                	addi	s1,s1,-5
ffffffffc0203a36:	8522                	mv	a0,s0
ffffffffc0203a38:	edbff0ef          	jal	ra,ffffffffc0203912 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0203a3c:	c88d                	beqz	s1,ffffffffc0203a6e <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203a3e:	03000513          	li	a0,48
ffffffffc0203a42:	f59fd0ef          	jal	ra,ffffffffc020199a <kmalloc>
ffffffffc0203a46:	85aa                	mv	a1,a0
ffffffffc0203a48:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0203a4c:	f165                	bnez	a0,ffffffffc0203a2c <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc0203a4e:	00003697          	auipc	a3,0x3
ffffffffc0203a52:	97268693          	addi	a3,a3,-1678 # ffffffffc02063c0 <default_pmm_manager+0x7b0>
ffffffffc0203a56:	00002617          	auipc	a2,0x2
ffffffffc0203a5a:	e2260613          	addi	a2,a2,-478 # ffffffffc0205878 <commands+0x870>
ffffffffc0203a5e:	0c900593          	li	a1,201
ffffffffc0203a62:	00003517          	auipc	a0,0x3
ffffffffc0203a66:	dee50513          	addi	a0,a0,-530 # ffffffffc0206850 <default_pmm_manager+0xc40>
ffffffffc0203a6a:	9e7fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc0203a6e:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203a72:	1f900913          	li	s2,505
ffffffffc0203a76:	a819                	j	ffffffffc0203a8c <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc0203a78:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203a7a:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203a7c:	00052c23          	sw	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203a80:	0495                	addi	s1,s1,5
ffffffffc0203a82:	8522                	mv	a0,s0
ffffffffc0203a84:	e8fff0ef          	jal	ra,ffffffffc0203912 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203a88:	03248a63          	beq	s1,s2,ffffffffc0203abc <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203a8c:	03000513          	li	a0,48
ffffffffc0203a90:	f0bfd0ef          	jal	ra,ffffffffc020199a <kmalloc>
ffffffffc0203a94:	85aa                	mv	a1,a0
ffffffffc0203a96:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0203a9a:	fd79                	bnez	a0,ffffffffc0203a78 <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc0203a9c:	00003697          	auipc	a3,0x3
ffffffffc0203aa0:	92468693          	addi	a3,a3,-1756 # ffffffffc02063c0 <default_pmm_manager+0x7b0>
ffffffffc0203aa4:	00002617          	auipc	a2,0x2
ffffffffc0203aa8:	dd460613          	addi	a2,a2,-556 # ffffffffc0205878 <commands+0x870>
ffffffffc0203aac:	0cf00593          	li	a1,207
ffffffffc0203ab0:	00003517          	auipc	a0,0x3
ffffffffc0203ab4:	da050513          	addi	a0,a0,-608 # ffffffffc0206850 <default_pmm_manager+0xc40>
ffffffffc0203ab8:	999fc0ef          	jal	ra,ffffffffc0200450 <__panic>
ffffffffc0203abc:	6418                	ld	a4,8(s0)
ffffffffc0203abe:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0203ac0:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0203ac4:	2ee40063          	beq	s0,a4,ffffffffc0203da4 <vmm_init+0x396>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203ac8:	fe873603          	ld	a2,-24(a4)
ffffffffc0203acc:	ffe78693          	addi	a3,a5,-2
ffffffffc0203ad0:	24d61a63          	bne	a2,a3,ffffffffc0203d24 <vmm_init+0x316>
ffffffffc0203ad4:	ff073683          	ld	a3,-16(a4)
ffffffffc0203ad8:	24f69663          	bne	a3,a5,ffffffffc0203d24 <vmm_init+0x316>
ffffffffc0203adc:	0795                	addi	a5,a5,5
ffffffffc0203ade:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc0203ae0:	feb792e3          	bne	a5,a1,ffffffffc0203ac4 <vmm_init+0xb6>
ffffffffc0203ae4:	491d                	li	s2,7
ffffffffc0203ae6:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203ae8:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0203aec:	85a6                	mv	a1,s1
ffffffffc0203aee:	8522                	mv	a0,s0
ffffffffc0203af0:	de5ff0ef          	jal	ra,ffffffffc02038d4 <find_vma>
ffffffffc0203af4:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc0203af6:	30050763          	beqz	a0,ffffffffc0203e04 <vmm_init+0x3f6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0203afa:	00148593          	addi	a1,s1,1
ffffffffc0203afe:	8522                	mv	a0,s0
ffffffffc0203b00:	dd5ff0ef          	jal	ra,ffffffffc02038d4 <find_vma>
ffffffffc0203b04:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0203b06:	2c050f63          	beqz	a0,ffffffffc0203de4 <vmm_init+0x3d6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0203b0a:	85ca                	mv	a1,s2
ffffffffc0203b0c:	8522                	mv	a0,s0
ffffffffc0203b0e:	dc7ff0ef          	jal	ra,ffffffffc02038d4 <find_vma>
        assert(vma3 == NULL);
ffffffffc0203b12:	2a051963          	bnez	a0,ffffffffc0203dc4 <vmm_init+0x3b6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0203b16:	00348593          	addi	a1,s1,3
ffffffffc0203b1a:	8522                	mv	a0,s0
ffffffffc0203b1c:	db9ff0ef          	jal	ra,ffffffffc02038d4 <find_vma>
        assert(vma4 == NULL);
ffffffffc0203b20:	32051263          	bnez	a0,ffffffffc0203e44 <vmm_init+0x436>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0203b24:	00448593          	addi	a1,s1,4
ffffffffc0203b28:	8522                	mv	a0,s0
ffffffffc0203b2a:	dabff0ef          	jal	ra,ffffffffc02038d4 <find_vma>
        assert(vma5 == NULL);
ffffffffc0203b2e:	2e051b63          	bnez	a0,ffffffffc0203e24 <vmm_init+0x416>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203b32:	008a3783          	ld	a5,8(s4)
ffffffffc0203b36:	20979763          	bne	a5,s1,ffffffffc0203d44 <vmm_init+0x336>
ffffffffc0203b3a:	010a3783          	ld	a5,16(s4)
ffffffffc0203b3e:	21279363          	bne	a5,s2,ffffffffc0203d44 <vmm_init+0x336>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203b42:	0089b783          	ld	a5,8(s3)
ffffffffc0203b46:	20979f63          	bne	a5,s1,ffffffffc0203d64 <vmm_init+0x356>
ffffffffc0203b4a:	0109b783          	ld	a5,16(s3)
ffffffffc0203b4e:	21279b63          	bne	a5,s2,ffffffffc0203d64 <vmm_init+0x356>
ffffffffc0203b52:	0495                	addi	s1,s1,5
ffffffffc0203b54:	0915                	addi	s2,s2,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203b56:	f9549be3          	bne	s1,s5,ffffffffc0203aec <vmm_init+0xde>
ffffffffc0203b5a:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0203b5c:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0203b5e:	85a6                	mv	a1,s1
ffffffffc0203b60:	8522                	mv	a0,s0
ffffffffc0203b62:	d73ff0ef          	jal	ra,ffffffffc02038d4 <find_vma>
ffffffffc0203b66:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc0203b6a:	c90d                	beqz	a0,ffffffffc0203b9c <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0203b6c:	6914                	ld	a3,16(a0)
ffffffffc0203b6e:	6510                	ld	a2,8(a0)
ffffffffc0203b70:	00003517          	auipc	a0,0x3
ffffffffc0203b74:	ef050513          	addi	a0,a0,-272 # ffffffffc0206a60 <default_pmm_manager+0xe50>
ffffffffc0203b78:	e16fc0ef          	jal	ra,ffffffffc020018e <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0203b7c:	00003697          	auipc	a3,0x3
ffffffffc0203b80:	f0c68693          	addi	a3,a3,-244 # ffffffffc0206a88 <default_pmm_manager+0xe78>
ffffffffc0203b84:	00002617          	auipc	a2,0x2
ffffffffc0203b88:	cf460613          	addi	a2,a2,-780 # ffffffffc0205878 <commands+0x870>
ffffffffc0203b8c:	0f100593          	li	a1,241
ffffffffc0203b90:	00003517          	auipc	a0,0x3
ffffffffc0203b94:	cc050513          	addi	a0,a0,-832 # ffffffffc0206850 <default_pmm_manager+0xc40>
ffffffffc0203b98:	8b9fc0ef          	jal	ra,ffffffffc0200450 <__panic>
ffffffffc0203b9c:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc0203b9e:	fd2490e3          	bne	s1,s2,ffffffffc0203b5e <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc0203ba2:	8522                	mv	a0,s0
ffffffffc0203ba4:	e3dff0ef          	jal	ra,ffffffffc02039e0 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203ba8:	00003517          	auipc	a0,0x3
ffffffffc0203bac:	ef850513          	addi	a0,a0,-264 # ffffffffc0206aa0 <default_pmm_manager+0xe90>
ffffffffc0203bb0:	ddefc0ef          	jal	ra,ffffffffc020018e <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203bb4:	8b0fe0ef          	jal	ra,ffffffffc0201c64 <nr_free_pages>
ffffffffc0203bb8:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc0203bba:	ca1ff0ef          	jal	ra,ffffffffc020385a <mm_create>
ffffffffc0203bbe:	00012797          	auipc	a5,0x12
ffffffffc0203bc2:	a2a7b123          	sd	a0,-1502(a5) # ffffffffc02155e0 <check_mm_struct>
ffffffffc0203bc6:	84aa                	mv	s1,a0
    assert(check_mm_struct != NULL);
ffffffffc0203bc8:	36050663          	beqz	a0,ffffffffc0203f34 <vmm_init+0x526>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203bcc:	00012797          	auipc	a5,0x12
ffffffffc0203bd0:	8bc78793          	addi	a5,a5,-1860 # ffffffffc0215488 <boot_pgdir>
ffffffffc0203bd4:	0007b903          	ld	s2,0(a5)
    assert(pgdir[0] == 0);
ffffffffc0203bd8:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203bdc:	01253c23          	sd	s2,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0203be0:	2c079e63          	bnez	a5,ffffffffc0203ebc <vmm_init+0x4ae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203be4:	03000513          	li	a0,48
ffffffffc0203be8:	db3fd0ef          	jal	ra,ffffffffc020199a <kmalloc>
ffffffffc0203bec:	842a                	mv	s0,a0
    if (vma != NULL) {
ffffffffc0203bee:	18050b63          	beqz	a0,ffffffffc0203d84 <vmm_init+0x376>
        vma->vm_end = vm_end;
ffffffffc0203bf2:	002007b7          	lui	a5,0x200
ffffffffc0203bf6:	e81c                	sd	a5,16(s0)
        vma->vm_flags = vm_flags;
ffffffffc0203bf8:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0203bfa:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0203bfc:	cc1c                	sw	a5,24(s0)
    insert_vma_struct(mm, vma);
ffffffffc0203bfe:	8526                	mv	a0,s1
        vma->vm_start = vm_start;
ffffffffc0203c00:	00043423          	sd	zero,8(s0)
    insert_vma_struct(mm, vma);
ffffffffc0203c04:	d0fff0ef          	jal	ra,ffffffffc0203912 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0203c08:	10000593          	li	a1,256
ffffffffc0203c0c:	8526                	mv	a0,s1
ffffffffc0203c0e:	cc7ff0ef          	jal	ra,ffffffffc02038d4 <find_vma>
ffffffffc0203c12:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0203c16:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0203c1a:	2ca41163          	bne	s0,a0,ffffffffc0203edc <vmm_init+0x4ce>
        *(char *)(addr + i) = i;
ffffffffc0203c1e:	00f78023          	sb	a5,0(a5) # 200000 <BASE_ADDRESS-0xffffffffc0000000>
        sum += i;
ffffffffc0203c22:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc0203c24:	fee79de3          	bne	a5,a4,ffffffffc0203c1e <vmm_init+0x210>
        sum += i;
ffffffffc0203c28:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc0203c2a:	10000793          	li	a5,256
        sum += i;
ffffffffc0203c2e:	35670713          	addi	a4,a4,854 # 1356 <BASE_ADDRESS-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0203c32:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0203c36:	0007c683          	lbu	a3,0(a5)
ffffffffc0203c3a:	0785                	addi	a5,a5,1
ffffffffc0203c3c:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0203c3e:	fec79ce3          	bne	a5,a2,ffffffffc0203c36 <vmm_init+0x228>
    }
    assert(sum == 0);
ffffffffc0203c42:	2c071963          	bnez	a4,ffffffffc0203f14 <vmm_init+0x506>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203c46:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203c4a:	00012a97          	auipc	s5,0x12
ffffffffc0203c4e:	846a8a93          	addi	s5,s5,-1978 # ffffffffc0215490 <npage>
ffffffffc0203c52:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203c56:	078a                	slli	a5,a5,0x2
ffffffffc0203c58:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203c5a:	20e7f563          	bleu	a4,a5,ffffffffc0203e64 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0203c5e:	00003697          	auipc	a3,0x3
ffffffffc0203c62:	35a68693          	addi	a3,a3,858 # ffffffffc0206fb8 <nbase>
ffffffffc0203c66:	0006ba03          	ld	s4,0(a3)
ffffffffc0203c6a:	414786b3          	sub	a3,a5,s4
ffffffffc0203c6e:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0203c70:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0203c72:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0203c74:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0203c76:	83b1                	srli	a5,a5,0xc
ffffffffc0203c78:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0203c7a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203c7c:	28e7f063          	bleu	a4,a5,ffffffffc0203efc <vmm_init+0x4ee>
ffffffffc0203c80:	00012797          	auipc	a5,0x12
ffffffffc0203c84:	87078793          	addi	a5,a5,-1936 # ffffffffc02154f0 <va_pa_offset>
ffffffffc0203c88:	6380                	ld	s0,0(a5)

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0203c8a:	4581                	li	a1,0
ffffffffc0203c8c:	854a                	mv	a0,s2
ffffffffc0203c8e:	9436                	add	s0,s0,a3
ffffffffc0203c90:	a48fe0ef          	jal	ra,ffffffffc0201ed8 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203c94:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0203c96:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203c9a:	078a                	slli	a5,a5,0x2
ffffffffc0203c9c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203c9e:	1ce7f363          	bleu	a4,a5,ffffffffc0203e64 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0203ca2:	00012417          	auipc	s0,0x12
ffffffffc0203ca6:	85e40413          	addi	s0,s0,-1954 # ffffffffc0215500 <pages>
ffffffffc0203caa:	6008                	ld	a0,0(s0)
ffffffffc0203cac:	414787b3          	sub	a5,a5,s4
ffffffffc0203cb0:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0203cb2:	953e                	add	a0,a0,a5
ffffffffc0203cb4:	4585                	li	a1,1
ffffffffc0203cb6:	f69fd0ef          	jal	ra,ffffffffc0201c1e <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203cba:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203cbe:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203cc2:	078a                	slli	a5,a5,0x2
ffffffffc0203cc4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203cc6:	18e7ff63          	bleu	a4,a5,ffffffffc0203e64 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0203cca:	6008                	ld	a0,0(s0)
ffffffffc0203ccc:	414787b3          	sub	a5,a5,s4
ffffffffc0203cd0:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0203cd2:	4585                	li	a1,1
ffffffffc0203cd4:	953e                	add	a0,a0,a5
ffffffffc0203cd6:	f49fd0ef          	jal	ra,ffffffffc0201c1e <free_pages>
    pgdir[0] = 0;
ffffffffc0203cda:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc0203cde:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc0203ce2:	0004bc23          	sd	zero,24(s1)
    mm_destroy(mm);
ffffffffc0203ce6:	8526                	mv	a0,s1
ffffffffc0203ce8:	cf9ff0ef          	jal	ra,ffffffffc02039e0 <mm_destroy>
    check_mm_struct = NULL;
ffffffffc0203cec:	00012797          	auipc	a5,0x12
ffffffffc0203cf0:	8e07ba23          	sd	zero,-1804(a5) # ffffffffc02155e0 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203cf4:	f71fd0ef          	jal	ra,ffffffffc0201c64 <nr_free_pages>
ffffffffc0203cf8:	1aa99263          	bne	s3,a0,ffffffffc0203e9c <vmm_init+0x48e>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0203cfc:	00003517          	auipc	a0,0x3
ffffffffc0203d00:	e3450513          	addi	a0,a0,-460 # ffffffffc0206b30 <default_pmm_manager+0xf20>
ffffffffc0203d04:	c8afc0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc0203d08:	7442                	ld	s0,48(sp)
ffffffffc0203d0a:	70e2                	ld	ra,56(sp)
ffffffffc0203d0c:	74a2                	ld	s1,40(sp)
ffffffffc0203d0e:	7902                	ld	s2,32(sp)
ffffffffc0203d10:	69e2                	ld	s3,24(sp)
ffffffffc0203d12:	6a42                	ld	s4,16(sp)
ffffffffc0203d14:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203d16:	00003517          	auipc	a0,0x3
ffffffffc0203d1a:	e3a50513          	addi	a0,a0,-454 # ffffffffc0206b50 <default_pmm_manager+0xf40>
}
ffffffffc0203d1e:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203d20:	c6efc06f          	j	ffffffffc020018e <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203d24:	00003697          	auipc	a3,0x3
ffffffffc0203d28:	c5468693          	addi	a3,a3,-940 # ffffffffc0206978 <default_pmm_manager+0xd68>
ffffffffc0203d2c:	00002617          	auipc	a2,0x2
ffffffffc0203d30:	b4c60613          	addi	a2,a2,-1204 # ffffffffc0205878 <commands+0x870>
ffffffffc0203d34:	0d800593          	li	a1,216
ffffffffc0203d38:	00003517          	auipc	a0,0x3
ffffffffc0203d3c:	b1850513          	addi	a0,a0,-1256 # ffffffffc0206850 <default_pmm_manager+0xc40>
ffffffffc0203d40:	f10fc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203d44:	00003697          	auipc	a3,0x3
ffffffffc0203d48:	cbc68693          	addi	a3,a3,-836 # ffffffffc0206a00 <default_pmm_manager+0xdf0>
ffffffffc0203d4c:	00002617          	auipc	a2,0x2
ffffffffc0203d50:	b2c60613          	addi	a2,a2,-1236 # ffffffffc0205878 <commands+0x870>
ffffffffc0203d54:	0e800593          	li	a1,232
ffffffffc0203d58:	00003517          	auipc	a0,0x3
ffffffffc0203d5c:	af850513          	addi	a0,a0,-1288 # ffffffffc0206850 <default_pmm_manager+0xc40>
ffffffffc0203d60:	ef0fc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203d64:	00003697          	auipc	a3,0x3
ffffffffc0203d68:	ccc68693          	addi	a3,a3,-820 # ffffffffc0206a30 <default_pmm_manager+0xe20>
ffffffffc0203d6c:	00002617          	auipc	a2,0x2
ffffffffc0203d70:	b0c60613          	addi	a2,a2,-1268 # ffffffffc0205878 <commands+0x870>
ffffffffc0203d74:	0e900593          	li	a1,233
ffffffffc0203d78:	00003517          	auipc	a0,0x3
ffffffffc0203d7c:	ad850513          	addi	a0,a0,-1320 # ffffffffc0206850 <default_pmm_manager+0xc40>
ffffffffc0203d80:	ed0fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(vma != NULL);
ffffffffc0203d84:	00002697          	auipc	a3,0x2
ffffffffc0203d88:	63c68693          	addi	a3,a3,1596 # ffffffffc02063c0 <default_pmm_manager+0x7b0>
ffffffffc0203d8c:	00002617          	auipc	a2,0x2
ffffffffc0203d90:	aec60613          	addi	a2,a2,-1300 # ffffffffc0205878 <commands+0x870>
ffffffffc0203d94:	10800593          	li	a1,264
ffffffffc0203d98:	00003517          	auipc	a0,0x3
ffffffffc0203d9c:	ab850513          	addi	a0,a0,-1352 # ffffffffc0206850 <default_pmm_manager+0xc40>
ffffffffc0203da0:	eb0fc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203da4:	00003697          	auipc	a3,0x3
ffffffffc0203da8:	bbc68693          	addi	a3,a3,-1092 # ffffffffc0206960 <default_pmm_manager+0xd50>
ffffffffc0203dac:	00002617          	auipc	a2,0x2
ffffffffc0203db0:	acc60613          	addi	a2,a2,-1332 # ffffffffc0205878 <commands+0x870>
ffffffffc0203db4:	0d600593          	li	a1,214
ffffffffc0203db8:	00003517          	auipc	a0,0x3
ffffffffc0203dbc:	a9850513          	addi	a0,a0,-1384 # ffffffffc0206850 <default_pmm_manager+0xc40>
ffffffffc0203dc0:	e90fc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(vma3 == NULL);
ffffffffc0203dc4:	00003697          	auipc	a3,0x3
ffffffffc0203dc8:	c0c68693          	addi	a3,a3,-1012 # ffffffffc02069d0 <default_pmm_manager+0xdc0>
ffffffffc0203dcc:	00002617          	auipc	a2,0x2
ffffffffc0203dd0:	aac60613          	addi	a2,a2,-1364 # ffffffffc0205878 <commands+0x870>
ffffffffc0203dd4:	0e200593          	li	a1,226
ffffffffc0203dd8:	00003517          	auipc	a0,0x3
ffffffffc0203ddc:	a7850513          	addi	a0,a0,-1416 # ffffffffc0206850 <default_pmm_manager+0xc40>
ffffffffc0203de0:	e70fc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(vma2 != NULL);
ffffffffc0203de4:	00003697          	auipc	a3,0x3
ffffffffc0203de8:	bdc68693          	addi	a3,a3,-1060 # ffffffffc02069c0 <default_pmm_manager+0xdb0>
ffffffffc0203dec:	00002617          	auipc	a2,0x2
ffffffffc0203df0:	a8c60613          	addi	a2,a2,-1396 # ffffffffc0205878 <commands+0x870>
ffffffffc0203df4:	0e000593          	li	a1,224
ffffffffc0203df8:	00003517          	auipc	a0,0x3
ffffffffc0203dfc:	a5850513          	addi	a0,a0,-1448 # ffffffffc0206850 <default_pmm_manager+0xc40>
ffffffffc0203e00:	e50fc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(vma1 != NULL);
ffffffffc0203e04:	00003697          	auipc	a3,0x3
ffffffffc0203e08:	bac68693          	addi	a3,a3,-1108 # ffffffffc02069b0 <default_pmm_manager+0xda0>
ffffffffc0203e0c:	00002617          	auipc	a2,0x2
ffffffffc0203e10:	a6c60613          	addi	a2,a2,-1428 # ffffffffc0205878 <commands+0x870>
ffffffffc0203e14:	0de00593          	li	a1,222
ffffffffc0203e18:	00003517          	auipc	a0,0x3
ffffffffc0203e1c:	a3850513          	addi	a0,a0,-1480 # ffffffffc0206850 <default_pmm_manager+0xc40>
ffffffffc0203e20:	e30fc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(vma5 == NULL);
ffffffffc0203e24:	00003697          	auipc	a3,0x3
ffffffffc0203e28:	bcc68693          	addi	a3,a3,-1076 # ffffffffc02069f0 <default_pmm_manager+0xde0>
ffffffffc0203e2c:	00002617          	auipc	a2,0x2
ffffffffc0203e30:	a4c60613          	addi	a2,a2,-1460 # ffffffffc0205878 <commands+0x870>
ffffffffc0203e34:	0e600593          	li	a1,230
ffffffffc0203e38:	00003517          	auipc	a0,0x3
ffffffffc0203e3c:	a1850513          	addi	a0,a0,-1512 # ffffffffc0206850 <default_pmm_manager+0xc40>
ffffffffc0203e40:	e10fc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(vma4 == NULL);
ffffffffc0203e44:	00003697          	auipc	a3,0x3
ffffffffc0203e48:	b9c68693          	addi	a3,a3,-1124 # ffffffffc02069e0 <default_pmm_manager+0xdd0>
ffffffffc0203e4c:	00002617          	auipc	a2,0x2
ffffffffc0203e50:	a2c60613          	addi	a2,a2,-1492 # ffffffffc0205878 <commands+0x870>
ffffffffc0203e54:	0e400593          	li	a1,228
ffffffffc0203e58:	00003517          	auipc	a0,0x3
ffffffffc0203e5c:	9f850513          	addi	a0,a0,-1544 # ffffffffc0206850 <default_pmm_manager+0xc40>
ffffffffc0203e60:	df0fc0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203e64:	00002617          	auipc	a2,0x2
ffffffffc0203e68:	e5c60613          	addi	a2,a2,-420 # ffffffffc0205cc0 <default_pmm_manager+0xb0>
ffffffffc0203e6c:	06200593          	li	a1,98
ffffffffc0203e70:	00002517          	auipc	a0,0x2
ffffffffc0203e74:	e1850513          	addi	a0,a0,-488 # ffffffffc0205c88 <default_pmm_manager+0x78>
ffffffffc0203e78:	dd8fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(mm != NULL);
ffffffffc0203e7c:	00002697          	auipc	a3,0x2
ffffffffc0203e80:	50c68693          	addi	a3,a3,1292 # ffffffffc0206388 <default_pmm_manager+0x778>
ffffffffc0203e84:	00002617          	auipc	a2,0x2
ffffffffc0203e88:	9f460613          	addi	a2,a2,-1548 # ffffffffc0205878 <commands+0x870>
ffffffffc0203e8c:	0c200593          	li	a1,194
ffffffffc0203e90:	00003517          	auipc	a0,0x3
ffffffffc0203e94:	9c050513          	addi	a0,a0,-1600 # ffffffffc0206850 <default_pmm_manager+0xc40>
ffffffffc0203e98:	db8fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203e9c:	00003697          	auipc	a3,0x3
ffffffffc0203ea0:	c6c68693          	addi	a3,a3,-916 # ffffffffc0206b08 <default_pmm_manager+0xef8>
ffffffffc0203ea4:	00002617          	auipc	a2,0x2
ffffffffc0203ea8:	9d460613          	addi	a2,a2,-1580 # ffffffffc0205878 <commands+0x870>
ffffffffc0203eac:	12400593          	li	a1,292
ffffffffc0203eb0:	00003517          	auipc	a0,0x3
ffffffffc0203eb4:	9a050513          	addi	a0,a0,-1632 # ffffffffc0206850 <default_pmm_manager+0xc40>
ffffffffc0203eb8:	d98fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0203ebc:	00002697          	auipc	a3,0x2
ffffffffc0203ec0:	4f468693          	addi	a3,a3,1268 # ffffffffc02063b0 <default_pmm_manager+0x7a0>
ffffffffc0203ec4:	00002617          	auipc	a2,0x2
ffffffffc0203ec8:	9b460613          	addi	a2,a2,-1612 # ffffffffc0205878 <commands+0x870>
ffffffffc0203ecc:	10500593          	li	a1,261
ffffffffc0203ed0:	00003517          	auipc	a0,0x3
ffffffffc0203ed4:	98050513          	addi	a0,a0,-1664 # ffffffffc0206850 <default_pmm_manager+0xc40>
ffffffffc0203ed8:	d78fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0203edc:	00003697          	auipc	a3,0x3
ffffffffc0203ee0:	bfc68693          	addi	a3,a3,-1028 # ffffffffc0206ad8 <default_pmm_manager+0xec8>
ffffffffc0203ee4:	00002617          	auipc	a2,0x2
ffffffffc0203ee8:	99460613          	addi	a2,a2,-1644 # ffffffffc0205878 <commands+0x870>
ffffffffc0203eec:	10d00593          	li	a1,269
ffffffffc0203ef0:	00003517          	auipc	a0,0x3
ffffffffc0203ef4:	96050513          	addi	a0,a0,-1696 # ffffffffc0206850 <default_pmm_manager+0xc40>
ffffffffc0203ef8:	d58fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203efc:	00002617          	auipc	a2,0x2
ffffffffc0203f00:	d6460613          	addi	a2,a2,-668 # ffffffffc0205c60 <default_pmm_manager+0x50>
ffffffffc0203f04:	06900593          	li	a1,105
ffffffffc0203f08:	00002517          	auipc	a0,0x2
ffffffffc0203f0c:	d8050513          	addi	a0,a0,-640 # ffffffffc0205c88 <default_pmm_manager+0x78>
ffffffffc0203f10:	d40fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(sum == 0);
ffffffffc0203f14:	00003697          	auipc	a3,0x3
ffffffffc0203f18:	be468693          	addi	a3,a3,-1052 # ffffffffc0206af8 <default_pmm_manager+0xee8>
ffffffffc0203f1c:	00002617          	auipc	a2,0x2
ffffffffc0203f20:	95c60613          	addi	a2,a2,-1700 # ffffffffc0205878 <commands+0x870>
ffffffffc0203f24:	11700593          	li	a1,279
ffffffffc0203f28:	00003517          	auipc	a0,0x3
ffffffffc0203f2c:	92850513          	addi	a0,a0,-1752 # ffffffffc0206850 <default_pmm_manager+0xc40>
ffffffffc0203f30:	d20fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0203f34:	00003697          	auipc	a3,0x3
ffffffffc0203f38:	b8c68693          	addi	a3,a3,-1140 # ffffffffc0206ac0 <default_pmm_manager+0xeb0>
ffffffffc0203f3c:	00002617          	auipc	a2,0x2
ffffffffc0203f40:	93c60613          	addi	a2,a2,-1732 # ffffffffc0205878 <commands+0x870>
ffffffffc0203f44:	10100593          	li	a1,257
ffffffffc0203f48:	00003517          	auipc	a0,0x3
ffffffffc0203f4c:	90850513          	addi	a0,a0,-1784 # ffffffffc0206850 <default_pmm_manager+0xc40>
ffffffffc0203f50:	d00fc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0203f54 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0203f54:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203f56:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0203f58:	f022                	sd	s0,32(sp)
ffffffffc0203f5a:	ec26                	sd	s1,24(sp)
ffffffffc0203f5c:	f406                	sd	ra,40(sp)
ffffffffc0203f5e:	e84a                	sd	s2,16(sp)
ffffffffc0203f60:	8432                	mv	s0,a2
ffffffffc0203f62:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203f64:	971ff0ef          	jal	ra,ffffffffc02038d4 <find_vma>

    pgfault_num++;
ffffffffc0203f68:	00011797          	auipc	a5,0x11
ffffffffc0203f6c:	53c78793          	addi	a5,a5,1340 # ffffffffc02154a4 <pgfault_num>
ffffffffc0203f70:	439c                	lw	a5,0(a5)
ffffffffc0203f72:	2785                	addiw	a5,a5,1
ffffffffc0203f74:	00011717          	auipc	a4,0x11
ffffffffc0203f78:	52f72823          	sw	a5,1328(a4) # ffffffffc02154a4 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0203f7c:	c551                	beqz	a0,ffffffffc0204008 <do_pgfault+0xb4>
ffffffffc0203f7e:	651c                	ld	a5,8(a0)
ffffffffc0203f80:	08f46463          	bltu	s0,a5,ffffffffc0204008 <do_pgfault+0xb4>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203f84:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0203f86:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203f88:	8b89                	andi	a5,a5,2
ffffffffc0203f8a:	efb1                	bnez	a5,ffffffffc0203fe6 <do_pgfault+0x92>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203f8c:	767d                	lui	a2,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0203f8e:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203f90:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0203f92:	85a2                	mv	a1,s0
ffffffffc0203f94:	4605                	li	a2,1
ffffffffc0203f96:	d0ffd0ef          	jal	ra,ffffffffc0201ca4 <get_pte>
ffffffffc0203f9a:	c941                	beqz	a0,ffffffffc020402a <do_pgfault+0xd6>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0203f9c:	610c                	ld	a1,0(a0)
ffffffffc0203f9e:	c5b1                	beqz	a1,ffffffffc0203fea <do_pgfault+0x96>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0203fa0:	00011797          	auipc	a5,0x11
ffffffffc0203fa4:	50078793          	addi	a5,a5,1280 # ffffffffc02154a0 <swap_init_ok>
ffffffffc0203fa8:	439c                	lw	a5,0(a5)
ffffffffc0203faa:	2781                	sext.w	a5,a5
ffffffffc0203fac:	c7bd                	beqz	a5,ffffffffc020401a <do_pgfault+0xc6>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            swap_in(mm,addr,&page);
ffffffffc0203fae:	85a2                	mv	a1,s0
ffffffffc0203fb0:	0030                	addi	a2,sp,8
ffffffffc0203fb2:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0203fb4:	e402                	sd	zero,8(sp)
            swap_in(mm,addr,&page);
ffffffffc0203fb6:	c1eff0ef          	jal	ra,ffffffffc02033d4 <swap_in>
            page_insert(mm->pgdir,page,addr,perm);
ffffffffc0203fba:	65a2                	ld	a1,8(sp)
ffffffffc0203fbc:	6c88                	ld	a0,24(s1)
ffffffffc0203fbe:	86ca                	mv	a3,s2
ffffffffc0203fc0:	8622                	mv	a2,s0
ffffffffc0203fc2:	f8bfd0ef          	jal	ra,ffffffffc0201f4c <page_insert>
            swap_map_swappable(mm,addr,page,1);
ffffffffc0203fc6:	6622                	ld	a2,8(sp)
ffffffffc0203fc8:	4685                	li	a3,1
ffffffffc0203fca:	85a2                	mv	a1,s0
ffffffffc0203fcc:	8526                	mv	a0,s1
ffffffffc0203fce:	ae2ff0ef          	jal	ra,ffffffffc02032b0 <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc0203fd2:	6722                	ld	a4,8(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0203fd4:	4781                	li	a5,0
            page->pra_vaddr = addr;
ffffffffc0203fd6:	ff00                	sd	s0,56(a4)
failed:
    return ret;
}
ffffffffc0203fd8:	70a2                	ld	ra,40(sp)
ffffffffc0203fda:	7402                	ld	s0,32(sp)
ffffffffc0203fdc:	64e2                	ld	s1,24(sp)
ffffffffc0203fde:	6942                	ld	s2,16(sp)
ffffffffc0203fe0:	853e                	mv	a0,a5
ffffffffc0203fe2:	6145                	addi	sp,sp,48
ffffffffc0203fe4:	8082                	ret
        perm |= READ_WRITE;
ffffffffc0203fe6:	495d                	li	s2,23
ffffffffc0203fe8:	b755                	j	ffffffffc0203f8c <do_pgfault+0x38>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203fea:	6c88                	ld	a0,24(s1)
ffffffffc0203fec:	864a                	mv	a2,s2
ffffffffc0203fee:	85a2                	mv	a1,s0
ffffffffc0203ff0:	aabfe0ef          	jal	ra,ffffffffc0202a9a <pgdir_alloc_page>
   ret = 0;
ffffffffc0203ff4:	4781                	li	a5,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203ff6:	f16d                	bnez	a0,ffffffffc0203fd8 <do_pgfault+0x84>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0203ff8:	00003517          	auipc	a0,0x3
ffffffffc0203ffc:	8b850513          	addi	a0,a0,-1864 # ffffffffc02068b0 <default_pmm_manager+0xca0>
ffffffffc0204000:	98efc0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204004:	57f1                	li	a5,-4
            goto failed;
ffffffffc0204006:	bfc9                	j	ffffffffc0203fd8 <do_pgfault+0x84>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0204008:	85a2                	mv	a1,s0
ffffffffc020400a:	00003517          	auipc	a0,0x3
ffffffffc020400e:	85650513          	addi	a0,a0,-1962 # ffffffffc0206860 <default_pmm_manager+0xc50>
ffffffffc0204012:	97cfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    int ret = -E_INVAL;
ffffffffc0204016:	57f5                	li	a5,-3
        goto failed;
ffffffffc0204018:	b7c1                	j	ffffffffc0203fd8 <do_pgfault+0x84>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc020401a:	00003517          	auipc	a0,0x3
ffffffffc020401e:	8be50513          	addi	a0,a0,-1858 # ffffffffc02068d8 <default_pmm_manager+0xcc8>
ffffffffc0204022:	96cfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204026:	57f1                	li	a5,-4
            goto failed;
ffffffffc0204028:	bf45                	j	ffffffffc0203fd8 <do_pgfault+0x84>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc020402a:	00003517          	auipc	a0,0x3
ffffffffc020402e:	86650513          	addi	a0,a0,-1946 # ffffffffc0206890 <default_pmm_manager+0xc80>
ffffffffc0204032:	95cfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204036:	57f1                	li	a5,-4
        goto failed;
ffffffffc0204038:	b745                	j	ffffffffc0203fd8 <do_pgfault+0x84>

ffffffffc020403a <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc020403a:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc020403c:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc020403e:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204040:	d3cfc0ef          	jal	ra,ffffffffc020057c <ide_device_valid>
ffffffffc0204044:	cd01                	beqz	a0,ffffffffc020405c <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204046:	4505                	li	a0,1
ffffffffc0204048:	d3afc0ef          	jal	ra,ffffffffc0200582 <ide_device_size>
}
ffffffffc020404c:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc020404e:	810d                	srli	a0,a0,0x3
ffffffffc0204050:	00011797          	auipc	a5,0x11
ffffffffc0204054:	54a7b023          	sd	a0,1344(a5) # ffffffffc0215590 <max_swap_offset>
}
ffffffffc0204058:	0141                	addi	sp,sp,16
ffffffffc020405a:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc020405c:	00003617          	auipc	a2,0x3
ffffffffc0204060:	b0c60613          	addi	a2,a2,-1268 # ffffffffc0206b68 <default_pmm_manager+0xf58>
ffffffffc0204064:	45b5                	li	a1,13
ffffffffc0204066:	00003517          	auipc	a0,0x3
ffffffffc020406a:	b2250513          	addi	a0,a0,-1246 # ffffffffc0206b88 <default_pmm_manager+0xf78>
ffffffffc020406e:	be2fc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0204072 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204072:	1141                	addi	sp,sp,-16
ffffffffc0204074:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204076:	00855793          	srli	a5,a0,0x8
ffffffffc020407a:	cfb9                	beqz	a5,ffffffffc02040d8 <swapfs_read+0x66>
ffffffffc020407c:	00011717          	auipc	a4,0x11
ffffffffc0204080:	51470713          	addi	a4,a4,1300 # ffffffffc0215590 <max_swap_offset>
ffffffffc0204084:	6318                	ld	a4,0(a4)
ffffffffc0204086:	04e7f963          	bleu	a4,a5,ffffffffc02040d8 <swapfs_read+0x66>
    return page - pages + nbase;
ffffffffc020408a:	00011717          	auipc	a4,0x11
ffffffffc020408e:	47670713          	addi	a4,a4,1142 # ffffffffc0215500 <pages>
ffffffffc0204092:	6310                	ld	a2,0(a4)
ffffffffc0204094:	00003717          	auipc	a4,0x3
ffffffffc0204098:	f2470713          	addi	a4,a4,-220 # ffffffffc0206fb8 <nbase>
    return KADDR(page2pa(page));
ffffffffc020409c:	00011697          	auipc	a3,0x11
ffffffffc02040a0:	3f468693          	addi	a3,a3,1012 # ffffffffc0215490 <npage>
    return page - pages + nbase;
ffffffffc02040a4:	40c58633          	sub	a2,a1,a2
ffffffffc02040a8:	630c                	ld	a1,0(a4)
ffffffffc02040aa:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc02040ac:	577d                	li	a4,-1
ffffffffc02040ae:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc02040b0:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc02040b2:	8331                	srli	a4,a4,0xc
ffffffffc02040b4:	8f71                	and	a4,a4,a2
ffffffffc02040b6:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc02040ba:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc02040bc:	02d77a63          	bleu	a3,a4,ffffffffc02040f0 <swapfs_read+0x7e>
ffffffffc02040c0:	00011797          	auipc	a5,0x11
ffffffffc02040c4:	43078793          	addi	a5,a5,1072 # ffffffffc02154f0 <va_pa_offset>
ffffffffc02040c8:	639c                	ld	a5,0(a5)
}
ffffffffc02040ca:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02040cc:	46a1                	li	a3,8
ffffffffc02040ce:	963e                	add	a2,a2,a5
ffffffffc02040d0:	4505                	li	a0,1
}
ffffffffc02040d2:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02040d4:	cb4fc06f          	j	ffffffffc0200588 <ide_read_secs>
ffffffffc02040d8:	86aa                	mv	a3,a0
ffffffffc02040da:	00003617          	auipc	a2,0x3
ffffffffc02040de:	ac660613          	addi	a2,a2,-1338 # ffffffffc0206ba0 <default_pmm_manager+0xf90>
ffffffffc02040e2:	45d1                	li	a1,20
ffffffffc02040e4:	00003517          	auipc	a0,0x3
ffffffffc02040e8:	aa450513          	addi	a0,a0,-1372 # ffffffffc0206b88 <default_pmm_manager+0xf78>
ffffffffc02040ec:	b64fc0ef          	jal	ra,ffffffffc0200450 <__panic>
ffffffffc02040f0:	86b2                	mv	a3,a2
ffffffffc02040f2:	06900593          	li	a1,105
ffffffffc02040f6:	00002617          	auipc	a2,0x2
ffffffffc02040fa:	b6a60613          	addi	a2,a2,-1174 # ffffffffc0205c60 <default_pmm_manager+0x50>
ffffffffc02040fe:	00002517          	auipc	a0,0x2
ffffffffc0204102:	b8a50513          	addi	a0,a0,-1142 # ffffffffc0205c88 <default_pmm_manager+0x78>
ffffffffc0204106:	b4afc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc020410a <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc020410a:	1141                	addi	sp,sp,-16
ffffffffc020410c:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc020410e:	00855793          	srli	a5,a0,0x8
ffffffffc0204112:	cfb9                	beqz	a5,ffffffffc0204170 <swapfs_write+0x66>
ffffffffc0204114:	00011717          	auipc	a4,0x11
ffffffffc0204118:	47c70713          	addi	a4,a4,1148 # ffffffffc0215590 <max_swap_offset>
ffffffffc020411c:	6318                	ld	a4,0(a4)
ffffffffc020411e:	04e7f963          	bleu	a4,a5,ffffffffc0204170 <swapfs_write+0x66>
    return page - pages + nbase;
ffffffffc0204122:	00011717          	auipc	a4,0x11
ffffffffc0204126:	3de70713          	addi	a4,a4,990 # ffffffffc0215500 <pages>
ffffffffc020412a:	6310                	ld	a2,0(a4)
ffffffffc020412c:	00003717          	auipc	a4,0x3
ffffffffc0204130:	e8c70713          	addi	a4,a4,-372 # ffffffffc0206fb8 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204134:	00011697          	auipc	a3,0x11
ffffffffc0204138:	35c68693          	addi	a3,a3,860 # ffffffffc0215490 <npage>
    return page - pages + nbase;
ffffffffc020413c:	40c58633          	sub	a2,a1,a2
ffffffffc0204140:	630c                	ld	a1,0(a4)
ffffffffc0204142:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204144:	577d                	li	a4,-1
ffffffffc0204146:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc0204148:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc020414a:	8331                	srli	a4,a4,0xc
ffffffffc020414c:	8f71                	and	a4,a4,a2
ffffffffc020414e:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204152:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204154:	02d77a63          	bleu	a3,a4,ffffffffc0204188 <swapfs_write+0x7e>
ffffffffc0204158:	00011797          	auipc	a5,0x11
ffffffffc020415c:	39878793          	addi	a5,a5,920 # ffffffffc02154f0 <va_pa_offset>
ffffffffc0204160:	639c                	ld	a5,0(a5)
}
ffffffffc0204162:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204164:	46a1                	li	a3,8
ffffffffc0204166:	963e                	add	a2,a2,a5
ffffffffc0204168:	4505                	li	a0,1
}
ffffffffc020416a:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc020416c:	c40fc06f          	j	ffffffffc02005ac <ide_write_secs>
ffffffffc0204170:	86aa                	mv	a3,a0
ffffffffc0204172:	00003617          	auipc	a2,0x3
ffffffffc0204176:	a2e60613          	addi	a2,a2,-1490 # ffffffffc0206ba0 <default_pmm_manager+0xf90>
ffffffffc020417a:	45e5                	li	a1,25
ffffffffc020417c:	00003517          	auipc	a0,0x3
ffffffffc0204180:	a0c50513          	addi	a0,a0,-1524 # ffffffffc0206b88 <default_pmm_manager+0xf78>
ffffffffc0204184:	accfc0ef          	jal	ra,ffffffffc0200450 <__panic>
ffffffffc0204188:	86b2                	mv	a3,a2
ffffffffc020418a:	06900593          	li	a1,105
ffffffffc020418e:	00002617          	auipc	a2,0x2
ffffffffc0204192:	ad260613          	addi	a2,a2,-1326 # ffffffffc0205c60 <default_pmm_manager+0x50>
ffffffffc0204196:	00002517          	auipc	a0,0x2
ffffffffc020419a:	af250513          	addi	a0,a0,-1294 # ffffffffc0205c88 <default_pmm_manager+0x78>
ffffffffc020419e:	ab2fc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02041a2 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc02041a2:	8526                	mv	a0,s1
	jalr s0
ffffffffc02041a4:	9402                	jalr	s0

	jal do_exit
ffffffffc02041a6:	4c8000ef          	jal	ra,ffffffffc020466e <do_exit>

ffffffffc02041aa <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc02041aa:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc02041ac:	0e800513          	li	a0,232
alloc_proc(void) {
ffffffffc02041b0:	e022                	sd	s0,0(sp)
ffffffffc02041b2:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc02041b4:	fe6fd0ef          	jal	ra,ffffffffc020199a <kmalloc>
ffffffffc02041b8:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc02041ba:	c529                	beqz	a0,ffffffffc0204204 <alloc_proc+0x5a>
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
    proc->state = PROC_UNINIT;
ffffffffc02041bc:	57fd                	li	a5,-1
ffffffffc02041be:	1782                	slli	a5,a5,0x20
ffffffffc02041c0:	e11c                	sd	a5,0(a0)
    proc->runs = 0;
    proc->kstack = 0;
    proc->need_resched = 0;
    proc->parent = NULL;
    proc->mm = NULL;
    memset(&(proc->context), 0, sizeof(struct context));
ffffffffc02041c2:	07000613          	li	a2,112
ffffffffc02041c6:	4581                	li	a1,0
    proc->runs = 0;
ffffffffc02041c8:	00052423          	sw	zero,8(a0)
    proc->kstack = 0;
ffffffffc02041cc:	00053823          	sd	zero,16(a0)
    proc->need_resched = 0;
ffffffffc02041d0:	00052c23          	sw	zero,24(a0)
    proc->parent = NULL;
ffffffffc02041d4:	02053023          	sd	zero,32(a0)
    proc->mm = NULL;
ffffffffc02041d8:	02053423          	sd	zero,40(a0)
    memset(&(proc->context), 0, sizeof(struct context));
ffffffffc02041dc:	03050513          	addi	a0,a0,48
ffffffffc02041e0:	49f000ef          	jal	ra,ffffffffc0204e7e <memset>
    proc->tf = NULL;
    proc->cr3 = boot_cr3;
ffffffffc02041e4:	00011797          	auipc	a5,0x11
ffffffffc02041e8:	31478793          	addi	a5,a5,788 # ffffffffc02154f8 <boot_cr3>
ffffffffc02041ec:	639c                	ld	a5,0(a5)
    proc->tf = NULL;
ffffffffc02041ee:	0a043023          	sd	zero,160(s0)
    proc->flags = 0;
ffffffffc02041f2:	0a042823          	sw	zero,176(s0)
    proc->cr3 = boot_cr3;
ffffffffc02041f6:	f45c                	sd	a5,168(s0)
    memset(proc->name, 0, PROC_NAME_LEN);
ffffffffc02041f8:	463d                	li	a2,15
ffffffffc02041fa:	4581                	li	a1,0
ffffffffc02041fc:	0b440513          	addi	a0,s0,180
ffffffffc0204200:	47f000ef          	jal	ra,ffffffffc0204e7e <memset>

    }
    return proc;
}
ffffffffc0204204:	8522                	mv	a0,s0
ffffffffc0204206:	60a2                	ld	ra,8(sp)
ffffffffc0204208:	6402                	ld	s0,0(sp)
ffffffffc020420a:	0141                	addi	sp,sp,16
ffffffffc020420c:	8082                	ret

ffffffffc020420e <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc020420e:	00011797          	auipc	a5,0x11
ffffffffc0204212:	29a78793          	addi	a5,a5,666 # ffffffffc02154a8 <current>
ffffffffc0204216:	639c                	ld	a5,0(a5)
ffffffffc0204218:	73c8                	ld	a0,160(a5)
ffffffffc020421a:	97ffc06f          	j	ffffffffc0200b98 <forkrets>

ffffffffc020421e <set_proc_name>:
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc020421e:	1101                	addi	sp,sp,-32
ffffffffc0204220:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204222:	0b450413          	addi	s0,a0,180
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204226:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204228:	4641                	li	a2,16
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc020422a:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020422c:	8522                	mv	a0,s0
ffffffffc020422e:	4581                	li	a1,0
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204230:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204232:	44d000ef          	jal	ra,ffffffffc0204e7e <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204236:	8522                	mv	a0,s0
}
ffffffffc0204238:	6442                	ld	s0,16(sp)
ffffffffc020423a:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020423c:	85a6                	mv	a1,s1
}
ffffffffc020423e:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204240:	463d                	li	a2,15
}
ffffffffc0204242:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204244:	44d0006f          	j	ffffffffc0204e90 <memcpy>

ffffffffc0204248 <get_proc_name>:
get_proc_name(struct proc_struct *proc) {
ffffffffc0204248:	1101                	addi	sp,sp,-32
ffffffffc020424a:	e822                	sd	s0,16(sp)
    memset(name, 0, sizeof(name));
ffffffffc020424c:	00011417          	auipc	s0,0x11
ffffffffc0204250:	21440413          	addi	s0,s0,532 # ffffffffc0215460 <name.1565>
get_proc_name(struct proc_struct *proc) {
ffffffffc0204254:	e426                	sd	s1,8(sp)
    memset(name, 0, sizeof(name));
ffffffffc0204256:	4641                	li	a2,16
get_proc_name(struct proc_struct *proc) {
ffffffffc0204258:	84aa                	mv	s1,a0
    memset(name, 0, sizeof(name));
ffffffffc020425a:	4581                	li	a1,0
ffffffffc020425c:	8522                	mv	a0,s0
get_proc_name(struct proc_struct *proc) {
ffffffffc020425e:	ec06                	sd	ra,24(sp)
    memset(name, 0, sizeof(name));
ffffffffc0204260:	41f000ef          	jal	ra,ffffffffc0204e7e <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc0204264:	8522                	mv	a0,s0
}
ffffffffc0204266:	6442                	ld	s0,16(sp)
ffffffffc0204268:	60e2                	ld	ra,24(sp)
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc020426a:	0b448593          	addi	a1,s1,180
}
ffffffffc020426e:	64a2                	ld	s1,8(sp)
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc0204270:	463d                	li	a2,15
}
ffffffffc0204272:	6105                	addi	sp,sp,32
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc0204274:	41d0006f          	j	ffffffffc0204e90 <memcpy>

ffffffffc0204278 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc0204278:	00011797          	auipc	a5,0x11
ffffffffc020427c:	23078793          	addi	a5,a5,560 # ffffffffc02154a8 <current>
ffffffffc0204280:	639c                	ld	a5,0(a5)
init_main(void *arg) {
ffffffffc0204282:	1101                	addi	sp,sp,-32
ffffffffc0204284:	e426                	sd	s1,8(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc0204286:	43c4                	lw	s1,4(a5)
init_main(void *arg) {
ffffffffc0204288:	e822                	sd	s0,16(sp)
ffffffffc020428a:	842a                	mv	s0,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc020428c:	853e                	mv	a0,a5
init_main(void *arg) {
ffffffffc020428e:	ec06                	sd	ra,24(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc0204290:	fb9ff0ef          	jal	ra,ffffffffc0204248 <get_proc_name>
ffffffffc0204294:	862a                	mv	a2,a0
ffffffffc0204296:	85a6                	mv	a1,s1
ffffffffc0204298:	00003517          	auipc	a0,0x3
ffffffffc020429c:	97050513          	addi	a0,a0,-1680 # ffffffffc0206c08 <default_pmm_manager+0xff8>
ffffffffc02042a0:	eeffb0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("To U: \"%s\".\n", (const char *)arg);
ffffffffc02042a4:	85a2                	mv	a1,s0
ffffffffc02042a6:	00003517          	auipc	a0,0x3
ffffffffc02042aa:	98a50513          	addi	a0,a0,-1654 # ffffffffc0206c30 <default_pmm_manager+0x1020>
ffffffffc02042ae:	ee1fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
ffffffffc02042b2:	00003517          	auipc	a0,0x3
ffffffffc02042b6:	98e50513          	addi	a0,a0,-1650 # ffffffffc0206c40 <default_pmm_manager+0x1030>
ffffffffc02042ba:	ed5fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    return 0;
}
ffffffffc02042be:	60e2                	ld	ra,24(sp)
ffffffffc02042c0:	6442                	ld	s0,16(sp)
ffffffffc02042c2:	64a2                	ld	s1,8(sp)
ffffffffc02042c4:	4501                	li	a0,0
ffffffffc02042c6:	6105                	addi	sp,sp,32
ffffffffc02042c8:	8082                	ret

ffffffffc02042ca <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc02042ca:	1101                	addi	sp,sp,-32
    if (proc != current) {
ffffffffc02042cc:	00011797          	auipc	a5,0x11
ffffffffc02042d0:	1dc78793          	addi	a5,a5,476 # ffffffffc02154a8 <current>
proc_run(struct proc_struct *proc) {
ffffffffc02042d4:	e426                	sd	s1,8(sp)
    if (proc != current) {
ffffffffc02042d6:	6384                	ld	s1,0(a5)
proc_run(struct proc_struct *proc) {
ffffffffc02042d8:	ec06                	sd	ra,24(sp)
ffffffffc02042da:	e822                	sd	s0,16(sp)
ffffffffc02042dc:	e04a                	sd	s2,0(sp)
    if (proc != current) {
ffffffffc02042de:	02a48c63          	beq	s1,a0,ffffffffc0204316 <proc_run+0x4c>
ffffffffc02042e2:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02042e4:	100027f3          	csrr	a5,sstatus
ffffffffc02042e8:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02042ea:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02042ec:	e3b1                	bnez	a5,ffffffffc0204330 <proc_run+0x66>
            lcr3(next->cr3);
ffffffffc02042ee:	745c                	ld	a5,168(s0)
            current = proc;
ffffffffc02042f0:	00011717          	auipc	a4,0x11
ffffffffc02042f4:	1a873c23          	sd	s0,440(a4) # ffffffffc02154a8 <current>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned int cr3) {
    write_csr(sptbr, SATP32_MODE | (cr3 >> RISCV_PGSHIFT));
ffffffffc02042f8:	80000737          	lui	a4,0x80000
ffffffffc02042fc:	00c7d79b          	srliw	a5,a5,0xc
ffffffffc0204300:	8fd9                	or	a5,a5,a4
ffffffffc0204302:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(next->context));
ffffffffc0204306:	03040593          	addi	a1,s0,48
ffffffffc020430a:	03048513          	addi	a0,s1,48
ffffffffc020430e:	58c000ef          	jal	ra,ffffffffc020489a <switch_to>
    if (flag) {
ffffffffc0204312:	00091863          	bnez	s2,ffffffffc0204322 <proc_run+0x58>
}
ffffffffc0204316:	60e2                	ld	ra,24(sp)
ffffffffc0204318:	6442                	ld	s0,16(sp)
ffffffffc020431a:	64a2                	ld	s1,8(sp)
ffffffffc020431c:	6902                	ld	s2,0(sp)
ffffffffc020431e:	6105                	addi	sp,sp,32
ffffffffc0204320:	8082                	ret
ffffffffc0204322:	6442                	ld	s0,16(sp)
ffffffffc0204324:	60e2                	ld	ra,24(sp)
ffffffffc0204326:	64a2                	ld	s1,8(sp)
ffffffffc0204328:	6902                	ld	s2,0(sp)
ffffffffc020432a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020432c:	aa6fc06f          	j	ffffffffc02005d2 <intr_enable>
        intr_disable();
ffffffffc0204330:	aa8fc0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
        return 1;
ffffffffc0204334:	4905                	li	s2,1
ffffffffc0204336:	bf65                	j	ffffffffc02042ee <proc_run+0x24>

ffffffffc0204338 <find_proc>:
    if (0 < pid && pid < MAX_PID) {
ffffffffc0204338:	0005071b          	sext.w	a4,a0
ffffffffc020433c:	6789                	lui	a5,0x2
ffffffffc020433e:	fff7069b          	addiw	a3,a4,-1
ffffffffc0204342:	17f9                	addi	a5,a5,-2
ffffffffc0204344:	04d7e063          	bltu	a5,a3,ffffffffc0204384 <find_proc+0x4c>
find_proc(int pid) {
ffffffffc0204348:	1141                	addi	sp,sp,-16
ffffffffc020434a:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc020434c:	45a9                	li	a1,10
ffffffffc020434e:	842a                	mv	s0,a0
ffffffffc0204350:	853a                	mv	a0,a4
find_proc(int pid) {
ffffffffc0204352:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204354:	67c000ef          	jal	ra,ffffffffc02049d0 <hash32>
ffffffffc0204358:	02051693          	slli	a3,a0,0x20
ffffffffc020435c:	82f1                	srli	a3,a3,0x1c
ffffffffc020435e:	0000d517          	auipc	a0,0xd
ffffffffc0204362:	10250513          	addi	a0,a0,258 # ffffffffc0211460 <hash_list>
ffffffffc0204366:	96aa                	add	a3,a3,a0
ffffffffc0204368:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc020436a:	a029                	j	ffffffffc0204374 <find_proc+0x3c>
            if (proc->pid == pid) {
ffffffffc020436c:	f2c7a703          	lw	a4,-212(a5) # 1f2c <BASE_ADDRESS-0xffffffffc01fe0d4>
ffffffffc0204370:	00870c63          	beq	a4,s0,ffffffffc0204388 <find_proc+0x50>
ffffffffc0204374:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0204376:	fef69be3          	bne	a3,a5,ffffffffc020436c <find_proc+0x34>
}
ffffffffc020437a:	60a2                	ld	ra,8(sp)
ffffffffc020437c:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc020437e:	4501                	li	a0,0
}
ffffffffc0204380:	0141                	addi	sp,sp,16
ffffffffc0204382:	8082                	ret
    return NULL;
ffffffffc0204384:	4501                	li	a0,0
}
ffffffffc0204386:	8082                	ret
ffffffffc0204388:	60a2                	ld	ra,8(sp)
ffffffffc020438a:	6402                	ld	s0,0(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc020438c:	f2878513          	addi	a0,a5,-216
}
ffffffffc0204390:	0141                	addi	sp,sp,16
ffffffffc0204392:	8082                	ret

ffffffffc0204394 <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204394:	7179                	addi	sp,sp,-48
ffffffffc0204396:	e84a                	sd	s2,16(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204398:	00011917          	auipc	s2,0x11
ffffffffc020439c:	12890913          	addi	s2,s2,296 # ffffffffc02154c0 <nr_process>
ffffffffc02043a0:	00092703          	lw	a4,0(s2)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc02043a4:	f406                	sd	ra,40(sp)
ffffffffc02043a6:	f022                	sd	s0,32(sp)
ffffffffc02043a8:	ec26                	sd	s1,24(sp)
ffffffffc02043aa:	e44e                	sd	s3,8(sp)
ffffffffc02043ac:	e052                	sd	s4,0(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc02043ae:	6785                	lui	a5,0x1
ffffffffc02043b0:	22f75763          	ble	a5,a4,ffffffffc02045de <do_fork+0x24a>
ffffffffc02043b4:	89ae                	mv	s3,a1
ffffffffc02043b6:	84b2                	mv	s1,a2
    if ((proc = alloc_proc()) == NULL) {
ffffffffc02043b8:	df3ff0ef          	jal	ra,ffffffffc02041aa <alloc_proc>
ffffffffc02043bc:	842a                	mv	s0,a0
ffffffffc02043be:	22050263          	beqz	a0,ffffffffc02045e2 <do_fork+0x24e>
    proc->parent = current;//将子进程的父节点设置为当前进程
ffffffffc02043c2:	00011a17          	auipc	s4,0x11
ffffffffc02043c6:	0e6a0a13          	addi	s4,s4,230 # ffffffffc02154a8 <current>
ffffffffc02043ca:	000a3783          	ld	a5,0(s4)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc02043ce:	4509                	li	a0,2
    proc->parent = current;//将子进程的父节点设置为当前进程
ffffffffc02043d0:	f01c                	sd	a5,32(s0)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc02043d2:	fc4fd0ef          	jal	ra,ffffffffc0201b96 <alloc_pages>
    if (page != NULL) {
ffffffffc02043d6:	1e050f63          	beqz	a0,ffffffffc02045d4 <do_fork+0x240>
    return page - pages + nbase;
ffffffffc02043da:	00011797          	auipc	a5,0x11
ffffffffc02043de:	12678793          	addi	a5,a5,294 # ffffffffc0215500 <pages>
ffffffffc02043e2:	6394                	ld	a3,0(a5)
ffffffffc02043e4:	00003797          	auipc	a5,0x3
ffffffffc02043e8:	bd478793          	addi	a5,a5,-1068 # ffffffffc0206fb8 <nbase>
    return KADDR(page2pa(page));
ffffffffc02043ec:	00011717          	auipc	a4,0x11
ffffffffc02043f0:	0a470713          	addi	a4,a4,164 # ffffffffc0215490 <npage>
    return page - pages + nbase;
ffffffffc02043f4:	40d506b3          	sub	a3,a0,a3
ffffffffc02043f8:	6388                	ld	a0,0(a5)
ffffffffc02043fa:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02043fc:	57fd                	li	a5,-1
ffffffffc02043fe:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0204400:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc0204402:	83b1                	srli	a5,a5,0xc
ffffffffc0204404:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204406:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204408:	1ee7ff63          	bleu	a4,a5,ffffffffc0204606 <do_fork+0x272>
    assert(current->mm == NULL);
ffffffffc020440c:	000a3783          	ld	a5,0(s4)
ffffffffc0204410:	00011717          	auipc	a4,0x11
ffffffffc0204414:	0e070713          	addi	a4,a4,224 # ffffffffc02154f0 <va_pa_offset>
ffffffffc0204418:	6318                	ld	a4,0(a4)
ffffffffc020441a:	779c                	ld	a5,40(a5)
ffffffffc020441c:	96ba                	add	a3,a3,a4
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc020441e:	e814                	sd	a3,16(s0)
    assert(current->mm == NULL);
ffffffffc0204420:	1c079363          	bnez	a5,ffffffffc02045e6 <do_fork+0x252>
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc0204424:	6789                	lui	a5,0x2
ffffffffc0204426:	ee078793          	addi	a5,a5,-288 # 1ee0 <BASE_ADDRESS-0xffffffffc01fe120>
ffffffffc020442a:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc020442c:	8626                	mv	a2,s1
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc020442e:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc0204430:	87b6                	mv	a5,a3
ffffffffc0204432:	12048893          	addi	a7,s1,288
ffffffffc0204436:	00063803          	ld	a6,0(a2)
ffffffffc020443a:	6608                	ld	a0,8(a2)
ffffffffc020443c:	6a0c                	ld	a1,16(a2)
ffffffffc020443e:	6e18                	ld	a4,24(a2)
ffffffffc0204440:	0107b023          	sd	a6,0(a5)
ffffffffc0204444:	e788                	sd	a0,8(a5)
ffffffffc0204446:	eb8c                	sd	a1,16(a5)
ffffffffc0204448:	ef98                	sd	a4,24(a5)
ffffffffc020444a:	02060613          	addi	a2,a2,32
ffffffffc020444e:	02078793          	addi	a5,a5,32
ffffffffc0204452:	ff1612e3          	bne	a2,a7,ffffffffc0204436 <do_fork+0xa2>
    proc->tf->gpr.a0 = 0;
ffffffffc0204456:	0406b823          	sd	zero,80(a3)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020445a:	10098e63          	beqz	s3,ffffffffc0204576 <do_fork+0x1e2>
ffffffffc020445e:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204462:	00000797          	auipc	a5,0x0
ffffffffc0204466:	dac78793          	addi	a5,a5,-596 # ffffffffc020420e <forkret>
ffffffffc020446a:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc020446c:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020446e:	100027f3          	csrr	a5,sstatus
ffffffffc0204472:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204474:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204476:	10079f63          	bnez	a5,ffffffffc0204594 <do_fork+0x200>
    if (++ last_pid >= MAX_PID) {
ffffffffc020447a:	00006797          	auipc	a5,0x6
ffffffffc020447e:	bde78793          	addi	a5,a5,-1058 # ffffffffc020a058 <last_pid.1575>
ffffffffc0204482:	439c                	lw	a5,0(a5)
ffffffffc0204484:	6709                	lui	a4,0x2
ffffffffc0204486:	0017851b          	addiw	a0,a5,1
ffffffffc020448a:	00006697          	auipc	a3,0x6
ffffffffc020448e:	bca6a723          	sw	a0,-1074(a3) # ffffffffc020a058 <last_pid.1575>
ffffffffc0204492:	12e55263          	ble	a4,a0,ffffffffc02045b6 <do_fork+0x222>
    if (last_pid >= next_safe) {
ffffffffc0204496:	00006797          	auipc	a5,0x6
ffffffffc020449a:	bc678793          	addi	a5,a5,-1082 # ffffffffc020a05c <next_safe.1574>
ffffffffc020449e:	439c                	lw	a5,0(a5)
ffffffffc02044a0:	00011497          	auipc	s1,0x11
ffffffffc02044a4:	14848493          	addi	s1,s1,328 # ffffffffc02155e8 <proc_list>
ffffffffc02044a8:	06f54063          	blt	a0,a5,ffffffffc0204508 <do_fork+0x174>
        next_safe = MAX_PID;
ffffffffc02044ac:	6789                	lui	a5,0x2
ffffffffc02044ae:	00006717          	auipc	a4,0x6
ffffffffc02044b2:	baf72723          	sw	a5,-1106(a4) # ffffffffc020a05c <next_safe.1574>
ffffffffc02044b6:	4581                	li	a1,0
ffffffffc02044b8:	87aa                	mv	a5,a0
ffffffffc02044ba:	00011497          	auipc	s1,0x11
ffffffffc02044be:	12e48493          	addi	s1,s1,302 # ffffffffc02155e8 <proc_list>
    repeat:
ffffffffc02044c2:	6889                	lui	a7,0x2
ffffffffc02044c4:	882e                	mv	a6,a1
ffffffffc02044c6:	6609                	lui	a2,0x2
        le = list;
ffffffffc02044c8:	00011697          	auipc	a3,0x11
ffffffffc02044cc:	12068693          	addi	a3,a3,288 # ffffffffc02155e8 <proc_list>
ffffffffc02044d0:	6694                	ld	a3,8(a3)
        while ((le = list_next(le)) != list) {
ffffffffc02044d2:	00968f63          	beq	a3,s1,ffffffffc02044f0 <do_fork+0x15c>
            if (proc->pid == last_pid) {
ffffffffc02044d6:	f3c6a703          	lw	a4,-196(a3)
ffffffffc02044da:	08e78963          	beq	a5,a4,ffffffffc020456c <do_fork+0x1d8>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc02044de:	fee7d9e3          	ble	a4,a5,ffffffffc02044d0 <do_fork+0x13c>
ffffffffc02044e2:	fec757e3          	ble	a2,a4,ffffffffc02044d0 <do_fork+0x13c>
ffffffffc02044e6:	6694                	ld	a3,8(a3)
ffffffffc02044e8:	863a                	mv	a2,a4
ffffffffc02044ea:	4805                	li	a6,1
        while ((le = list_next(le)) != list) {
ffffffffc02044ec:	fe9695e3          	bne	a3,s1,ffffffffc02044d6 <do_fork+0x142>
ffffffffc02044f0:	c591                	beqz	a1,ffffffffc02044fc <do_fork+0x168>
ffffffffc02044f2:	00006717          	auipc	a4,0x6
ffffffffc02044f6:	b6f72323          	sw	a5,-1178(a4) # ffffffffc020a058 <last_pid.1575>
ffffffffc02044fa:	853e                	mv	a0,a5
ffffffffc02044fc:	00080663          	beqz	a6,ffffffffc0204508 <do_fork+0x174>
ffffffffc0204500:	00006797          	auipc	a5,0x6
ffffffffc0204504:	b4c7ae23          	sw	a2,-1188(a5) # ffffffffc020a05c <next_safe.1574>
        proc->pid = get_pid();//获取当前进程PID
ffffffffc0204508:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc020450a:	45a9                	li	a1,10
ffffffffc020450c:	2501                	sext.w	a0,a0
ffffffffc020450e:	4c2000ef          	jal	ra,ffffffffc02049d0 <hash32>
ffffffffc0204512:	1502                	slli	a0,a0,0x20
ffffffffc0204514:	0000d797          	auipc	a5,0xd
ffffffffc0204518:	f4c78793          	addi	a5,a5,-180 # ffffffffc0211460 <hash_list>
ffffffffc020451c:	8171                	srli	a0,a0,0x1c
ffffffffc020451e:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0204520:	6510                	ld	a2,8(a0)
ffffffffc0204522:	0d840793          	addi	a5,s0,216
ffffffffc0204526:	6494                	ld	a3,8(s1)
        nr_process ++;//进程数加一
ffffffffc0204528:	00092703          	lw	a4,0(s2)
    prev->next = next->prev = elm;
ffffffffc020452c:	e21c                	sd	a5,0(a2)
ffffffffc020452e:	e51c                	sd	a5,8(a0)
    elm->next = next;
ffffffffc0204530:	f070                	sd	a2,224(s0)
        list_add(&proc_list, &(proc->list_link));//加入进程链表
ffffffffc0204532:	0c840793          	addi	a5,s0,200
    elm->prev = prev;
ffffffffc0204536:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc0204538:	e29c                	sd	a5,0(a3)
        nr_process ++;//进程数加一
ffffffffc020453a:	2705                	addiw	a4,a4,1
ffffffffc020453c:	00011617          	auipc	a2,0x11
ffffffffc0204540:	0af63a23          	sd	a5,180(a2) # ffffffffc02155f0 <proc_list+0x8>
    elm->next = next;
ffffffffc0204544:	e874                	sd	a3,208(s0)
    elm->prev = prev;
ffffffffc0204546:	e464                	sd	s1,200(s0)
ffffffffc0204548:	00011797          	auipc	a5,0x11
ffffffffc020454c:	f6e7ac23          	sw	a4,-136(a5) # ffffffffc02154c0 <nr_process>
    if (flag) {
ffffffffc0204550:	06099a63          	bnez	s3,ffffffffc02045c4 <do_fork+0x230>
    wakeup_proc(proc);
ffffffffc0204554:	8522                	mv	a0,s0
ffffffffc0204556:	3ae000ef          	jal	ra,ffffffffc0204904 <wakeup_proc>
    ret = proc->pid;//返回当前进程的PID
ffffffffc020455a:	4048                	lw	a0,4(s0)
}
ffffffffc020455c:	70a2                	ld	ra,40(sp)
ffffffffc020455e:	7402                	ld	s0,32(sp)
ffffffffc0204560:	64e2                	ld	s1,24(sp)
ffffffffc0204562:	6942                	ld	s2,16(sp)
ffffffffc0204564:	69a2                	ld	s3,8(sp)
ffffffffc0204566:	6a02                	ld	s4,0(sp)
ffffffffc0204568:	6145                	addi	sp,sp,48
ffffffffc020456a:	8082                	ret
                if (++ last_pid >= next_safe) {
ffffffffc020456c:	2785                	addiw	a5,a5,1
ffffffffc020456e:	04c7de63          	ble	a2,a5,ffffffffc02045ca <do_fork+0x236>
ffffffffc0204572:	4585                	li	a1,1
ffffffffc0204574:	bfb1                	j	ffffffffc02044d0 <do_fork+0x13c>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204576:	89b6                	mv	s3,a3
ffffffffc0204578:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc020457c:	00000797          	auipc	a5,0x0
ffffffffc0204580:	c9278793          	addi	a5,a5,-878 # ffffffffc020420e <forkret>
ffffffffc0204584:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0204586:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204588:	100027f3          	csrr	a5,sstatus
ffffffffc020458c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020458e:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204590:	ee0785e3          	beqz	a5,ffffffffc020447a <do_fork+0xe6>
        intr_disable();
ffffffffc0204594:	844fc0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
    if (++ last_pid >= MAX_PID) {
ffffffffc0204598:	00006797          	auipc	a5,0x6
ffffffffc020459c:	ac078793          	addi	a5,a5,-1344 # ffffffffc020a058 <last_pid.1575>
ffffffffc02045a0:	439c                	lw	a5,0(a5)
ffffffffc02045a2:	6709                	lui	a4,0x2
        return 1;
ffffffffc02045a4:	4985                	li	s3,1
ffffffffc02045a6:	0017851b          	addiw	a0,a5,1
ffffffffc02045aa:	00006697          	auipc	a3,0x6
ffffffffc02045ae:	aaa6a723          	sw	a0,-1362(a3) # ffffffffc020a058 <last_pid.1575>
ffffffffc02045b2:	eee542e3          	blt	a0,a4,ffffffffc0204496 <do_fork+0x102>
        last_pid = 1;
ffffffffc02045b6:	4785                	li	a5,1
ffffffffc02045b8:	00006717          	auipc	a4,0x6
ffffffffc02045bc:	aaf72023          	sw	a5,-1376(a4) # ffffffffc020a058 <last_pid.1575>
ffffffffc02045c0:	4505                	li	a0,1
ffffffffc02045c2:	b5ed                	j	ffffffffc02044ac <do_fork+0x118>
        intr_enable();
ffffffffc02045c4:	80efc0ef          	jal	ra,ffffffffc02005d2 <intr_enable>
ffffffffc02045c8:	b771                	j	ffffffffc0204554 <do_fork+0x1c0>
                    if (last_pid >= MAX_PID) {
ffffffffc02045ca:	0117c363          	blt	a5,a7,ffffffffc02045d0 <do_fork+0x23c>
                        last_pid = 1;
ffffffffc02045ce:	4785                	li	a5,1
                    goto repeat;
ffffffffc02045d0:	4585                	li	a1,1
ffffffffc02045d2:	bdcd                	j	ffffffffc02044c4 <do_fork+0x130>
    kfree(proc);
ffffffffc02045d4:	8522                	mv	a0,s0
ffffffffc02045d6:	c80fd0ef          	jal	ra,ffffffffc0201a56 <kfree>
    ret = -E_NO_MEM;
ffffffffc02045da:	5571                	li	a0,-4
    goto fork_out;
ffffffffc02045dc:	b741                	j	ffffffffc020455c <do_fork+0x1c8>
    int ret = -E_NO_FREE_PROC;
ffffffffc02045de:	556d                	li	a0,-5
ffffffffc02045e0:	bfb5                	j	ffffffffc020455c <do_fork+0x1c8>
    ret = -E_NO_MEM;
ffffffffc02045e2:	5571                	li	a0,-4
ffffffffc02045e4:	bfa5                	j	ffffffffc020455c <do_fork+0x1c8>
    assert(current->mm == NULL);
ffffffffc02045e6:	00002697          	auipc	a3,0x2
ffffffffc02045ea:	5f268693          	addi	a3,a3,1522 # ffffffffc0206bd8 <default_pmm_manager+0xfc8>
ffffffffc02045ee:	00001617          	auipc	a2,0x1
ffffffffc02045f2:	28a60613          	addi	a2,a2,650 # ffffffffc0205878 <commands+0x870>
ffffffffc02045f6:	10600593          	li	a1,262
ffffffffc02045fa:	00002517          	auipc	a0,0x2
ffffffffc02045fe:	5f650513          	addi	a0,a0,1526 # ffffffffc0206bf0 <default_pmm_manager+0xfe0>
ffffffffc0204602:	e4ffb0ef          	jal	ra,ffffffffc0200450 <__panic>
ffffffffc0204606:	00001617          	auipc	a2,0x1
ffffffffc020460a:	65a60613          	addi	a2,a2,1626 # ffffffffc0205c60 <default_pmm_manager+0x50>
ffffffffc020460e:	06900593          	li	a1,105
ffffffffc0204612:	00001517          	auipc	a0,0x1
ffffffffc0204616:	67650513          	addi	a0,a0,1654 # ffffffffc0205c88 <default_pmm_manager+0x78>
ffffffffc020461a:	e37fb0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc020461e <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc020461e:	7129                	addi	sp,sp,-320
ffffffffc0204620:	fa22                	sd	s0,304(sp)
ffffffffc0204622:	f626                	sd	s1,296(sp)
ffffffffc0204624:	f24a                	sd	s2,288(sp)
ffffffffc0204626:	84ae                	mv	s1,a1
ffffffffc0204628:	892a                	mv	s2,a0
ffffffffc020462a:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020462c:	4581                	li	a1,0
ffffffffc020462e:	12000613          	li	a2,288
ffffffffc0204632:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0204634:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0204636:	049000ef          	jal	ra,ffffffffc0204e7e <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc020463a:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc020463c:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc020463e:	100027f3          	csrr	a5,sstatus
ffffffffc0204642:	edd7f793          	andi	a5,a5,-291
ffffffffc0204646:	1207e793          	ori	a5,a5,288
ffffffffc020464a:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020464c:	860a                	mv	a2,sp
ffffffffc020464e:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0204652:	00000797          	auipc	a5,0x0
ffffffffc0204656:	b5078793          	addi	a5,a5,-1200 # ffffffffc02041a2 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020465a:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc020465c:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020465e:	d37ff0ef          	jal	ra,ffffffffc0204394 <do_fork>
}
ffffffffc0204662:	70f2                	ld	ra,312(sp)
ffffffffc0204664:	7452                	ld	s0,304(sp)
ffffffffc0204666:	74b2                	ld	s1,296(sp)
ffffffffc0204668:	7912                	ld	s2,288(sp)
ffffffffc020466a:	6131                	addi	sp,sp,320
ffffffffc020466c:	8082                	ret

ffffffffc020466e <do_exit>:
do_exit(int error_code) {
ffffffffc020466e:	1141                	addi	sp,sp,-16
    panic("process exit!!.\n");
ffffffffc0204670:	00002617          	auipc	a2,0x2
ffffffffc0204674:	55060613          	addi	a2,a2,1360 # ffffffffc0206bc0 <default_pmm_manager+0xfb0>
ffffffffc0204678:	16800593          	li	a1,360
ffffffffc020467c:	00002517          	auipc	a0,0x2
ffffffffc0204680:	57450513          	addi	a0,a0,1396 # ffffffffc0206bf0 <default_pmm_manager+0xfe0>
do_exit(int error_code) {
ffffffffc0204684:	e406                	sd	ra,8(sp)
    panic("process exit!!.\n");
ffffffffc0204686:	dcbfb0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc020468a <proc_init>:
    elm->prev = elm->next = elm;
ffffffffc020468a:	00011797          	auipc	a5,0x11
ffffffffc020468e:	f5e78793          	addi	a5,a5,-162 # ffffffffc02155e8 <proc_list>

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0204692:	1101                	addi	sp,sp,-32
ffffffffc0204694:	00011717          	auipc	a4,0x11
ffffffffc0204698:	f4f73e23          	sd	a5,-164(a4) # ffffffffc02155f0 <proc_list+0x8>
ffffffffc020469c:	00011717          	auipc	a4,0x11
ffffffffc02046a0:	f4f73623          	sd	a5,-180(a4) # ffffffffc02155e8 <proc_list>
ffffffffc02046a4:	ec06                	sd	ra,24(sp)
ffffffffc02046a6:	e822                	sd	s0,16(sp)
ffffffffc02046a8:	e426                	sd	s1,8(sp)
ffffffffc02046aa:	e04a                	sd	s2,0(sp)
ffffffffc02046ac:	0000d797          	auipc	a5,0xd
ffffffffc02046b0:	db478793          	addi	a5,a5,-588 # ffffffffc0211460 <hash_list>
ffffffffc02046b4:	00011717          	auipc	a4,0x11
ffffffffc02046b8:	dac70713          	addi	a4,a4,-596 # ffffffffc0215460 <name.1565>
ffffffffc02046bc:	e79c                	sd	a5,8(a5)
ffffffffc02046be:	e39c                	sd	a5,0(a5)
ffffffffc02046c0:	07c1                	addi	a5,a5,16
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc02046c2:	fee79de3          	bne	a5,a4,ffffffffc02046bc <proc_init+0x32>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc02046c6:	ae5ff0ef          	jal	ra,ffffffffc02041aa <alloc_proc>
ffffffffc02046ca:	00011797          	auipc	a5,0x11
ffffffffc02046ce:	dea7b323          	sd	a0,-538(a5) # ffffffffc02154b0 <idleproc>
ffffffffc02046d2:	00011417          	auipc	s0,0x11
ffffffffc02046d6:	dde40413          	addi	s0,s0,-546 # ffffffffc02154b0 <idleproc>
ffffffffc02046da:	12050a63          	beqz	a0,ffffffffc020480e <proc_init+0x184>
        panic("cannot alloc idleproc.\n");
    }

    // check the proc structure
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc02046de:	07000513          	li	a0,112
ffffffffc02046e2:	ab8fd0ef          	jal	ra,ffffffffc020199a <kmalloc>
    memset(context_mem, 0, sizeof(struct context));
ffffffffc02046e6:	07000613          	li	a2,112
ffffffffc02046ea:	4581                	li	a1,0
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc02046ec:	84aa                	mv	s1,a0
    memset(context_mem, 0, sizeof(struct context));
ffffffffc02046ee:	790000ef          	jal	ra,ffffffffc0204e7e <memset>
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context));
ffffffffc02046f2:	6008                	ld	a0,0(s0)
ffffffffc02046f4:	85a6                	mv	a1,s1
ffffffffc02046f6:	07000613          	li	a2,112
ffffffffc02046fa:	03050513          	addi	a0,a0,48
ffffffffc02046fe:	7aa000ef          	jal	ra,ffffffffc0204ea8 <memcmp>
ffffffffc0204702:	892a                	mv	s2,a0

    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc0204704:	453d                	li	a0,15
ffffffffc0204706:	a94fd0ef          	jal	ra,ffffffffc020199a <kmalloc>
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc020470a:	463d                	li	a2,15
ffffffffc020470c:	4581                	li	a1,0
    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc020470e:	84aa                	mv	s1,a0
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc0204710:	76e000ef          	jal	ra,ffffffffc0204e7e <memset>
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);
ffffffffc0204714:	6008                	ld	a0,0(s0)
ffffffffc0204716:	463d                	li	a2,15
ffffffffc0204718:	85a6                	mv	a1,s1
ffffffffc020471a:	0b450513          	addi	a0,a0,180
ffffffffc020471e:	78a000ef          	jal	ra,ffffffffc0204ea8 <memcmp>

    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc0204722:	601c                	ld	a5,0(s0)
ffffffffc0204724:	00011717          	auipc	a4,0x11
ffffffffc0204728:	dd470713          	addi	a4,a4,-556 # ffffffffc02154f8 <boot_cr3>
ffffffffc020472c:	6318                	ld	a4,0(a4)
ffffffffc020472e:	77d4                	ld	a3,168(a5)
ffffffffc0204730:	08e68e63          	beq	a3,a4,ffffffffc02047cc <proc_init+0x142>
        cprintf("alloc_proc() correct!\n");

    }
    
    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0204734:	4709                	li	a4,2
ffffffffc0204736:	e398                	sd	a4,0(a5)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0204738:	00003717          	auipc	a4,0x3
ffffffffc020473c:	8c870713          	addi	a4,a4,-1848 # ffffffffc0207000 <bootstack>
ffffffffc0204740:	eb98                	sd	a4,16(a5)
    idleproc->need_resched = 1;
ffffffffc0204742:	4705                	li	a4,1
ffffffffc0204744:	cf98                	sw	a4,24(a5)
    set_proc_name(idleproc, "idle");
ffffffffc0204746:	00002597          	auipc	a1,0x2
ffffffffc020474a:	54a58593          	addi	a1,a1,1354 # ffffffffc0206c90 <default_pmm_manager+0x1080>
ffffffffc020474e:	853e                	mv	a0,a5
ffffffffc0204750:	acfff0ef          	jal	ra,ffffffffc020421e <set_proc_name>
    nr_process ++;
ffffffffc0204754:	00011797          	auipc	a5,0x11
ffffffffc0204758:	d6c78793          	addi	a5,a5,-660 # ffffffffc02154c0 <nr_process>
ffffffffc020475c:	439c                	lw	a5,0(a5)

    current = idleproc;
ffffffffc020475e:	6018                	ld	a4,0(s0)

    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc0204760:	4601                	li	a2,0
    nr_process ++;
ffffffffc0204762:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc0204764:	00002597          	auipc	a1,0x2
ffffffffc0204768:	53458593          	addi	a1,a1,1332 # ffffffffc0206c98 <default_pmm_manager+0x1088>
ffffffffc020476c:	00000517          	auipc	a0,0x0
ffffffffc0204770:	b0c50513          	addi	a0,a0,-1268 # ffffffffc0204278 <init_main>
    nr_process ++;
ffffffffc0204774:	00011697          	auipc	a3,0x11
ffffffffc0204778:	d4f6a623          	sw	a5,-692(a3) # ffffffffc02154c0 <nr_process>
    current = idleproc;
ffffffffc020477c:	00011797          	auipc	a5,0x11
ffffffffc0204780:	d2e7b623          	sd	a4,-724(a5) # ffffffffc02154a8 <current>
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc0204784:	e9bff0ef          	jal	ra,ffffffffc020461e <kernel_thread>
    if (pid <= 0) {
ffffffffc0204788:	0ca05f63          	blez	a0,ffffffffc0204866 <proc_init+0x1dc>
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc020478c:	badff0ef          	jal	ra,ffffffffc0204338 <find_proc>
    set_proc_name(initproc, "init");
ffffffffc0204790:	00002597          	auipc	a1,0x2
ffffffffc0204794:	53858593          	addi	a1,a1,1336 # ffffffffc0206cc8 <default_pmm_manager+0x10b8>
    initproc = find_proc(pid);
ffffffffc0204798:	00011797          	auipc	a5,0x11
ffffffffc020479c:	d2a7b023          	sd	a0,-736(a5) # ffffffffc02154b8 <initproc>
    set_proc_name(initproc, "init");
ffffffffc02047a0:	a7fff0ef          	jal	ra,ffffffffc020421e <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc02047a4:	601c                	ld	a5,0(s0)
ffffffffc02047a6:	c3c5                	beqz	a5,ffffffffc0204846 <proc_init+0x1bc>
ffffffffc02047a8:	43dc                	lw	a5,4(a5)
ffffffffc02047aa:	efd1                	bnez	a5,ffffffffc0204846 <proc_init+0x1bc>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc02047ac:	00011797          	auipc	a5,0x11
ffffffffc02047b0:	d0c78793          	addi	a5,a5,-756 # ffffffffc02154b8 <initproc>
ffffffffc02047b4:	639c                	ld	a5,0(a5)
ffffffffc02047b6:	cba5                	beqz	a5,ffffffffc0204826 <proc_init+0x19c>
ffffffffc02047b8:	43d8                	lw	a4,4(a5)
ffffffffc02047ba:	4785                	li	a5,1
ffffffffc02047bc:	06f71563          	bne	a4,a5,ffffffffc0204826 <proc_init+0x19c>
}
ffffffffc02047c0:	60e2                	ld	ra,24(sp)
ffffffffc02047c2:	6442                	ld	s0,16(sp)
ffffffffc02047c4:	64a2                	ld	s1,8(sp)
ffffffffc02047c6:	6902                	ld	s2,0(sp)
ffffffffc02047c8:	6105                	addi	sp,sp,32
ffffffffc02047ca:	8082                	ret
    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc02047cc:	73d8                	ld	a4,160(a5)
ffffffffc02047ce:	f33d                	bnez	a4,ffffffffc0204734 <proc_init+0xaa>
ffffffffc02047d0:	f60912e3          	bnez	s2,ffffffffc0204734 <proc_init+0xaa>
        && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0
ffffffffc02047d4:	6394                	ld	a3,0(a5)
ffffffffc02047d6:	577d                	li	a4,-1
ffffffffc02047d8:	1702                	slli	a4,a4,0x20
ffffffffc02047da:	f4e69de3          	bne	a3,a4,ffffffffc0204734 <proc_init+0xaa>
ffffffffc02047de:	4798                	lw	a4,8(a5)
ffffffffc02047e0:	fb31                	bnez	a4,ffffffffc0204734 <proc_init+0xaa>
        && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL
ffffffffc02047e2:	6b98                	ld	a4,16(a5)
ffffffffc02047e4:	fb21                	bnez	a4,ffffffffc0204734 <proc_init+0xaa>
ffffffffc02047e6:	4f98                	lw	a4,24(a5)
ffffffffc02047e8:	2701                	sext.w	a4,a4
ffffffffc02047ea:	f729                	bnez	a4,ffffffffc0204734 <proc_init+0xaa>
ffffffffc02047ec:	7398                	ld	a4,32(a5)
ffffffffc02047ee:	f339                	bnez	a4,ffffffffc0204734 <proc_init+0xaa>
        && idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag
ffffffffc02047f0:	7798                	ld	a4,40(a5)
ffffffffc02047f2:	f329                	bnez	a4,ffffffffc0204734 <proc_init+0xaa>
ffffffffc02047f4:	0b07a703          	lw	a4,176(a5)
ffffffffc02047f8:	8f49                	or	a4,a4,a0
ffffffffc02047fa:	2701                	sext.w	a4,a4
ffffffffc02047fc:	ff05                	bnez	a4,ffffffffc0204734 <proc_init+0xaa>
        cprintf("alloc_proc() correct!\n");
ffffffffc02047fe:	00002517          	auipc	a0,0x2
ffffffffc0204802:	47a50513          	addi	a0,a0,1146 # ffffffffc0206c78 <default_pmm_manager+0x1068>
ffffffffc0204806:	989fb0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc020480a:	601c                	ld	a5,0(s0)
ffffffffc020480c:	b725                	j	ffffffffc0204734 <proc_init+0xaa>
        panic("cannot alloc idleproc.\n");
ffffffffc020480e:	00002617          	auipc	a2,0x2
ffffffffc0204812:	45260613          	addi	a2,a2,1106 # ffffffffc0206c60 <default_pmm_manager+0x1050>
ffffffffc0204816:	18000593          	li	a1,384
ffffffffc020481a:	00002517          	auipc	a0,0x2
ffffffffc020481e:	3d650513          	addi	a0,a0,982 # ffffffffc0206bf0 <default_pmm_manager+0xfe0>
ffffffffc0204822:	c2ffb0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0204826:	00002697          	auipc	a3,0x2
ffffffffc020482a:	4d268693          	addi	a3,a3,1234 # ffffffffc0206cf8 <default_pmm_manager+0x10e8>
ffffffffc020482e:	00001617          	auipc	a2,0x1
ffffffffc0204832:	04a60613          	addi	a2,a2,74 # ffffffffc0205878 <commands+0x870>
ffffffffc0204836:	1a700593          	li	a1,423
ffffffffc020483a:	00002517          	auipc	a0,0x2
ffffffffc020483e:	3b650513          	addi	a0,a0,950 # ffffffffc0206bf0 <default_pmm_manager+0xfe0>
ffffffffc0204842:	c0ffb0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0204846:	00002697          	auipc	a3,0x2
ffffffffc020484a:	48a68693          	addi	a3,a3,1162 # ffffffffc0206cd0 <default_pmm_manager+0x10c0>
ffffffffc020484e:	00001617          	auipc	a2,0x1
ffffffffc0204852:	02a60613          	addi	a2,a2,42 # ffffffffc0205878 <commands+0x870>
ffffffffc0204856:	1a600593          	li	a1,422
ffffffffc020485a:	00002517          	auipc	a0,0x2
ffffffffc020485e:	39650513          	addi	a0,a0,918 # ffffffffc0206bf0 <default_pmm_manager+0xfe0>
ffffffffc0204862:	beffb0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("create init_main failed.\n");
ffffffffc0204866:	00002617          	auipc	a2,0x2
ffffffffc020486a:	44260613          	addi	a2,a2,1090 # ffffffffc0206ca8 <default_pmm_manager+0x1098>
ffffffffc020486e:	1a000593          	li	a1,416
ffffffffc0204872:	00002517          	auipc	a0,0x2
ffffffffc0204876:	37e50513          	addi	a0,a0,894 # ffffffffc0206bf0 <default_pmm_manager+0xfe0>
ffffffffc020487a:	bd7fb0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc020487e <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc020487e:	1141                	addi	sp,sp,-16
ffffffffc0204880:	e022                	sd	s0,0(sp)
ffffffffc0204882:	e406                	sd	ra,8(sp)
ffffffffc0204884:	00011417          	auipc	s0,0x11
ffffffffc0204888:	c2440413          	addi	s0,s0,-988 # ffffffffc02154a8 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc020488c:	6018                	ld	a4,0(s0)
ffffffffc020488e:	4f1c                	lw	a5,24(a4)
ffffffffc0204890:	2781                	sext.w	a5,a5
ffffffffc0204892:	dff5                	beqz	a5,ffffffffc020488e <cpu_idle+0x10>
            schedule();
ffffffffc0204894:	0a2000ef          	jal	ra,ffffffffc0204936 <schedule>
ffffffffc0204898:	bfd5                	j	ffffffffc020488c <cpu_idle+0xe>

ffffffffc020489a <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc020489a:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc020489e:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc02048a2:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc02048a4:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc02048a6:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc02048aa:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc02048ae:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc02048b2:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc02048b6:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc02048ba:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc02048be:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc02048c2:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc02048c6:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc02048ca:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc02048ce:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc02048d2:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc02048d6:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc02048d8:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc02048da:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc02048de:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc02048e2:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc02048e6:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc02048ea:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc02048ee:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc02048f2:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc02048f6:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc02048fa:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc02048fe:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0204902:	8082                	ret

ffffffffc0204904 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc0204904:	411c                	lw	a5,0(a0)
ffffffffc0204906:	4705                	li	a4,1
ffffffffc0204908:	37f9                	addiw	a5,a5,-2
ffffffffc020490a:	00f77563          	bleu	a5,a4,ffffffffc0204914 <wakeup_proc+0x10>
    proc->state = PROC_RUNNABLE;
ffffffffc020490e:	4789                	li	a5,2
ffffffffc0204910:	c11c                	sw	a5,0(a0)
ffffffffc0204912:	8082                	ret
wakeup_proc(struct proc_struct *proc) {
ffffffffc0204914:	1141                	addi	sp,sp,-16
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc0204916:	00002697          	auipc	a3,0x2
ffffffffc020491a:	40a68693          	addi	a3,a3,1034 # ffffffffc0206d20 <default_pmm_manager+0x1110>
ffffffffc020491e:	00001617          	auipc	a2,0x1
ffffffffc0204922:	f5a60613          	addi	a2,a2,-166 # ffffffffc0205878 <commands+0x870>
ffffffffc0204926:	45a5                	li	a1,9
ffffffffc0204928:	00002517          	auipc	a0,0x2
ffffffffc020492c:	43850513          	addi	a0,a0,1080 # ffffffffc0206d60 <default_pmm_manager+0x1150>
wakeup_proc(struct proc_struct *proc) {
ffffffffc0204930:	e406                	sd	ra,8(sp)
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc0204932:	b1ffb0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0204936 <schedule>:
}

void
schedule(void) {
ffffffffc0204936:	1141                	addi	sp,sp,-16
ffffffffc0204938:	e406                	sd	ra,8(sp)
ffffffffc020493a:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020493c:	100027f3          	csrr	a5,sstatus
ffffffffc0204940:	8b89                	andi	a5,a5,2
ffffffffc0204942:	4401                	li	s0,0
ffffffffc0204944:	e3d1                	bnez	a5,ffffffffc02049c8 <schedule+0x92>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0204946:	00011797          	auipc	a5,0x11
ffffffffc020494a:	b6278793          	addi	a5,a5,-1182 # ffffffffc02154a8 <current>
ffffffffc020494e:	0007b883          	ld	a7,0(a5)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0204952:	00011797          	auipc	a5,0x11
ffffffffc0204956:	b5e78793          	addi	a5,a5,-1186 # ffffffffc02154b0 <idleproc>
ffffffffc020495a:	6388                	ld	a0,0(a5)
        current->need_resched = 0;
ffffffffc020495c:	0008ac23          	sw	zero,24(a7) # 2018 <BASE_ADDRESS-0xffffffffc01fdfe8>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0204960:	04a88e63          	beq	a7,a0,ffffffffc02049bc <schedule+0x86>
ffffffffc0204964:	0c888693          	addi	a3,a7,200
ffffffffc0204968:	00011617          	auipc	a2,0x11
ffffffffc020496c:	c8060613          	addi	a2,a2,-896 # ffffffffc02155e8 <proc_list>
        le = last;
ffffffffc0204970:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0204972:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0204974:	4809                	li	a6,2
    return listelm->next;
ffffffffc0204976:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0204978:	00c78863          	beq	a5,a2,ffffffffc0204988 <schedule+0x52>
                if (next->state == PROC_RUNNABLE) {
ffffffffc020497c:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0204980:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc0204984:	01070463          	beq	a4,a6,ffffffffc020498c <schedule+0x56>
                    break;
                }
            }
        } while (le != last);
ffffffffc0204988:	fef697e3          	bne	a3,a5,ffffffffc0204976 <schedule+0x40>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc020498c:	c589                	beqz	a1,ffffffffc0204996 <schedule+0x60>
ffffffffc020498e:	4198                	lw	a4,0(a1)
ffffffffc0204990:	4789                	li	a5,2
ffffffffc0204992:	00f70e63          	beq	a4,a5,ffffffffc02049ae <schedule+0x78>
            next = idleproc;
        }
        next->runs ++;
ffffffffc0204996:	451c                	lw	a5,8(a0)
ffffffffc0204998:	2785                	addiw	a5,a5,1
ffffffffc020499a:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc020499c:	00a88463          	beq	a7,a0,ffffffffc02049a4 <schedule+0x6e>
            proc_run(next);
ffffffffc02049a0:	92bff0ef          	jal	ra,ffffffffc02042ca <proc_run>
    if (flag) {
ffffffffc02049a4:	e419                	bnez	s0,ffffffffc02049b2 <schedule+0x7c>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc02049a6:	60a2                	ld	ra,8(sp)
ffffffffc02049a8:	6402                	ld	s0,0(sp)
ffffffffc02049aa:	0141                	addi	sp,sp,16
ffffffffc02049ac:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc02049ae:	852e                	mv	a0,a1
ffffffffc02049b0:	b7dd                	j	ffffffffc0204996 <schedule+0x60>
}
ffffffffc02049b2:	6402                	ld	s0,0(sp)
ffffffffc02049b4:	60a2                	ld	ra,8(sp)
ffffffffc02049b6:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc02049b8:	c1bfb06f          	j	ffffffffc02005d2 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02049bc:	00011617          	auipc	a2,0x11
ffffffffc02049c0:	c2c60613          	addi	a2,a2,-980 # ffffffffc02155e8 <proc_list>
ffffffffc02049c4:	86b2                	mv	a3,a2
ffffffffc02049c6:	b76d                	j	ffffffffc0204970 <schedule+0x3a>
        intr_disable();
ffffffffc02049c8:	c11fb0ef          	jal	ra,ffffffffc02005d8 <intr_disable>
        return 1;
ffffffffc02049cc:	4405                	li	s0,1
ffffffffc02049ce:	bfa5                	j	ffffffffc0204946 <schedule+0x10>

ffffffffc02049d0 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc02049d0:	9e3707b7          	lui	a5,0x9e370
ffffffffc02049d4:	2785                	addiw	a5,a5,1
ffffffffc02049d6:	02f5053b          	mulw	a0,a0,a5
    return (hash >> (32 - bits));
ffffffffc02049da:	02000793          	li	a5,32
ffffffffc02049de:	40b785bb          	subw	a1,a5,a1
}
ffffffffc02049e2:	00b5553b          	srlw	a0,a0,a1
ffffffffc02049e6:	8082                	ret

ffffffffc02049e8 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02049e8:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02049ec:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02049ee:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02049f2:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02049f4:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02049f8:	f022                	sd	s0,32(sp)
ffffffffc02049fa:	ec26                	sd	s1,24(sp)
ffffffffc02049fc:	e84a                	sd	s2,16(sp)
ffffffffc02049fe:	f406                	sd	ra,40(sp)
ffffffffc0204a00:	e44e                	sd	s3,8(sp)
ffffffffc0204a02:	84aa                	mv	s1,a0
ffffffffc0204a04:	892e                	mv	s2,a1
ffffffffc0204a06:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0204a0a:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0204a0c:	03067e63          	bleu	a6,a2,ffffffffc0204a48 <printnum+0x60>
ffffffffc0204a10:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0204a12:	00805763          	blez	s0,ffffffffc0204a20 <printnum+0x38>
ffffffffc0204a16:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0204a18:	85ca                	mv	a1,s2
ffffffffc0204a1a:	854e                	mv	a0,s3
ffffffffc0204a1c:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0204a1e:	fc65                	bnez	s0,ffffffffc0204a16 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204a20:	1a02                	slli	s4,s4,0x20
ffffffffc0204a22:	020a5a13          	srli	s4,s4,0x20
ffffffffc0204a26:	00002797          	auipc	a5,0x2
ffffffffc0204a2a:	4e278793          	addi	a5,a5,1250 # ffffffffc0206f08 <error_string+0x38>
ffffffffc0204a2e:	9a3e                	add	s4,s4,a5
}
ffffffffc0204a30:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204a32:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0204a36:	70a2                	ld	ra,40(sp)
ffffffffc0204a38:	69a2                	ld	s3,8(sp)
ffffffffc0204a3a:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204a3c:	85ca                	mv	a1,s2
ffffffffc0204a3e:	8326                	mv	t1,s1
}
ffffffffc0204a40:	6942                	ld	s2,16(sp)
ffffffffc0204a42:	64e2                	ld	s1,24(sp)
ffffffffc0204a44:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204a46:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0204a48:	03065633          	divu	a2,a2,a6
ffffffffc0204a4c:	8722                	mv	a4,s0
ffffffffc0204a4e:	f9bff0ef          	jal	ra,ffffffffc02049e8 <printnum>
ffffffffc0204a52:	b7f9                	j	ffffffffc0204a20 <printnum+0x38>

ffffffffc0204a54 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0204a54:	7119                	addi	sp,sp,-128
ffffffffc0204a56:	f4a6                	sd	s1,104(sp)
ffffffffc0204a58:	f0ca                	sd	s2,96(sp)
ffffffffc0204a5a:	e8d2                	sd	s4,80(sp)
ffffffffc0204a5c:	e4d6                	sd	s5,72(sp)
ffffffffc0204a5e:	e0da                	sd	s6,64(sp)
ffffffffc0204a60:	fc5e                	sd	s7,56(sp)
ffffffffc0204a62:	f862                	sd	s8,48(sp)
ffffffffc0204a64:	f06a                	sd	s10,32(sp)
ffffffffc0204a66:	fc86                	sd	ra,120(sp)
ffffffffc0204a68:	f8a2                	sd	s0,112(sp)
ffffffffc0204a6a:	ecce                	sd	s3,88(sp)
ffffffffc0204a6c:	f466                	sd	s9,40(sp)
ffffffffc0204a6e:	ec6e                	sd	s11,24(sp)
ffffffffc0204a70:	892a                	mv	s2,a0
ffffffffc0204a72:	84ae                	mv	s1,a1
ffffffffc0204a74:	8d32                	mv	s10,a2
ffffffffc0204a76:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0204a78:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204a7a:	00002a17          	auipc	s4,0x2
ffffffffc0204a7e:	2fea0a13          	addi	s4,s4,766 # ffffffffc0206d78 <default_pmm_manager+0x1168>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204a82:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204a86:	00002c17          	auipc	s8,0x2
ffffffffc0204a8a:	44ac0c13          	addi	s8,s8,1098 # ffffffffc0206ed0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204a8e:	000d4503          	lbu	a0,0(s10) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0204a92:	02500793          	li	a5,37
ffffffffc0204a96:	001d0413          	addi	s0,s10,1
ffffffffc0204a9a:	00f50e63          	beq	a0,a5,ffffffffc0204ab6 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0204a9e:	c521                	beqz	a0,ffffffffc0204ae6 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204aa0:	02500993          	li	s3,37
ffffffffc0204aa4:	a011                	j	ffffffffc0204aa8 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0204aa6:	c121                	beqz	a0,ffffffffc0204ae6 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0204aa8:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204aaa:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0204aac:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204aae:	fff44503          	lbu	a0,-1(s0)
ffffffffc0204ab2:	ff351ae3          	bne	a0,s3,ffffffffc0204aa6 <vprintfmt+0x52>
ffffffffc0204ab6:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0204aba:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0204abe:	4981                	li	s3,0
ffffffffc0204ac0:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0204ac2:	5cfd                	li	s9,-1
ffffffffc0204ac4:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204ac6:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0204aca:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204acc:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0204ad0:	0ff6f693          	andi	a3,a3,255
ffffffffc0204ad4:	00140d13          	addi	s10,s0,1
ffffffffc0204ad8:	20d5e563          	bltu	a1,a3,ffffffffc0204ce2 <vprintfmt+0x28e>
ffffffffc0204adc:	068a                	slli	a3,a3,0x2
ffffffffc0204ade:	96d2                	add	a3,a3,s4
ffffffffc0204ae0:	4294                	lw	a3,0(a3)
ffffffffc0204ae2:	96d2                	add	a3,a3,s4
ffffffffc0204ae4:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0204ae6:	70e6                	ld	ra,120(sp)
ffffffffc0204ae8:	7446                	ld	s0,112(sp)
ffffffffc0204aea:	74a6                	ld	s1,104(sp)
ffffffffc0204aec:	7906                	ld	s2,96(sp)
ffffffffc0204aee:	69e6                	ld	s3,88(sp)
ffffffffc0204af0:	6a46                	ld	s4,80(sp)
ffffffffc0204af2:	6aa6                	ld	s5,72(sp)
ffffffffc0204af4:	6b06                	ld	s6,64(sp)
ffffffffc0204af6:	7be2                	ld	s7,56(sp)
ffffffffc0204af8:	7c42                	ld	s8,48(sp)
ffffffffc0204afa:	7ca2                	ld	s9,40(sp)
ffffffffc0204afc:	7d02                	ld	s10,32(sp)
ffffffffc0204afe:	6de2                	ld	s11,24(sp)
ffffffffc0204b00:	6109                	addi	sp,sp,128
ffffffffc0204b02:	8082                	ret
    if (lflag >= 2) {
ffffffffc0204b04:	4705                	li	a4,1
ffffffffc0204b06:	008a8593          	addi	a1,s5,8
ffffffffc0204b0a:	01074463          	blt	a4,a6,ffffffffc0204b12 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0204b0e:	26080363          	beqz	a6,ffffffffc0204d74 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0204b12:	000ab603          	ld	a2,0(s5)
ffffffffc0204b16:	46c1                	li	a3,16
ffffffffc0204b18:	8aae                	mv	s5,a1
ffffffffc0204b1a:	a06d                	j	ffffffffc0204bc4 <vprintfmt+0x170>
            goto reswitch;
ffffffffc0204b1c:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0204b20:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204b22:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204b24:	b765                	j	ffffffffc0204acc <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0204b26:	000aa503          	lw	a0,0(s5)
ffffffffc0204b2a:	85a6                	mv	a1,s1
ffffffffc0204b2c:	0aa1                	addi	s5,s5,8
ffffffffc0204b2e:	9902                	jalr	s2
            break;
ffffffffc0204b30:	bfb9                	j	ffffffffc0204a8e <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204b32:	4705                	li	a4,1
ffffffffc0204b34:	008a8993          	addi	s3,s5,8
ffffffffc0204b38:	01074463          	blt	a4,a6,ffffffffc0204b40 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0204b3c:	22080463          	beqz	a6,ffffffffc0204d64 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0204b40:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0204b44:	24044463          	bltz	s0,ffffffffc0204d8c <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0204b48:	8622                	mv	a2,s0
ffffffffc0204b4a:	8ace                	mv	s5,s3
ffffffffc0204b4c:	46a9                	li	a3,10
ffffffffc0204b4e:	a89d                	j	ffffffffc0204bc4 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0204b50:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204b54:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0204b56:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0204b58:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0204b5c:	8fb5                	xor	a5,a5,a3
ffffffffc0204b5e:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204b62:	1ad74363          	blt	a4,a3,ffffffffc0204d08 <vprintfmt+0x2b4>
ffffffffc0204b66:	00369793          	slli	a5,a3,0x3
ffffffffc0204b6a:	97e2                	add	a5,a5,s8
ffffffffc0204b6c:	639c                	ld	a5,0(a5)
ffffffffc0204b6e:	18078d63          	beqz	a5,ffffffffc0204d08 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0204b72:	86be                	mv	a3,a5
ffffffffc0204b74:	00000617          	auipc	a2,0x0
ffffffffc0204b78:	38c60613          	addi	a2,a2,908 # ffffffffc0204f00 <etext+0x28>
ffffffffc0204b7c:	85a6                	mv	a1,s1
ffffffffc0204b7e:	854a                	mv	a0,s2
ffffffffc0204b80:	240000ef          	jal	ra,ffffffffc0204dc0 <printfmt>
ffffffffc0204b84:	b729                	j	ffffffffc0204a8e <vprintfmt+0x3a>
            lflag ++;
ffffffffc0204b86:	00144603          	lbu	a2,1(s0)
ffffffffc0204b8a:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204b8c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204b8e:	bf3d                	j	ffffffffc0204acc <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0204b90:	4705                	li	a4,1
ffffffffc0204b92:	008a8593          	addi	a1,s5,8
ffffffffc0204b96:	01074463          	blt	a4,a6,ffffffffc0204b9e <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0204b9a:	1e080263          	beqz	a6,ffffffffc0204d7e <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0204b9e:	000ab603          	ld	a2,0(s5)
ffffffffc0204ba2:	46a1                	li	a3,8
ffffffffc0204ba4:	8aae                	mv	s5,a1
ffffffffc0204ba6:	a839                	j	ffffffffc0204bc4 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0204ba8:	03000513          	li	a0,48
ffffffffc0204bac:	85a6                	mv	a1,s1
ffffffffc0204bae:	e03e                	sd	a5,0(sp)
ffffffffc0204bb0:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0204bb2:	85a6                	mv	a1,s1
ffffffffc0204bb4:	07800513          	li	a0,120
ffffffffc0204bb8:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204bba:	0aa1                	addi	s5,s5,8
ffffffffc0204bbc:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0204bc0:	6782                	ld	a5,0(sp)
ffffffffc0204bc2:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0204bc4:	876e                	mv	a4,s11
ffffffffc0204bc6:	85a6                	mv	a1,s1
ffffffffc0204bc8:	854a                	mv	a0,s2
ffffffffc0204bca:	e1fff0ef          	jal	ra,ffffffffc02049e8 <printnum>
            break;
ffffffffc0204bce:	b5c1                	j	ffffffffc0204a8e <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204bd0:	000ab603          	ld	a2,0(s5)
ffffffffc0204bd4:	0aa1                	addi	s5,s5,8
ffffffffc0204bd6:	1c060663          	beqz	a2,ffffffffc0204da2 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0204bda:	00160413          	addi	s0,a2,1
ffffffffc0204bde:	17b05c63          	blez	s11,ffffffffc0204d56 <vprintfmt+0x302>
ffffffffc0204be2:	02d00593          	li	a1,45
ffffffffc0204be6:	14b79263          	bne	a5,a1,ffffffffc0204d2a <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204bea:	00064783          	lbu	a5,0(a2)
ffffffffc0204bee:	0007851b          	sext.w	a0,a5
ffffffffc0204bf2:	c905                	beqz	a0,ffffffffc0204c22 <vprintfmt+0x1ce>
ffffffffc0204bf4:	000cc563          	bltz	s9,ffffffffc0204bfe <vprintfmt+0x1aa>
ffffffffc0204bf8:	3cfd                	addiw	s9,s9,-1
ffffffffc0204bfa:	036c8263          	beq	s9,s6,ffffffffc0204c1e <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0204bfe:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204c00:	18098463          	beqz	s3,ffffffffc0204d88 <vprintfmt+0x334>
ffffffffc0204c04:	3781                	addiw	a5,a5,-32
ffffffffc0204c06:	18fbf163          	bleu	a5,s7,ffffffffc0204d88 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0204c0a:	03f00513          	li	a0,63
ffffffffc0204c0e:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204c10:	0405                	addi	s0,s0,1
ffffffffc0204c12:	fff44783          	lbu	a5,-1(s0)
ffffffffc0204c16:	3dfd                	addiw	s11,s11,-1
ffffffffc0204c18:	0007851b          	sext.w	a0,a5
ffffffffc0204c1c:	fd61                	bnez	a0,ffffffffc0204bf4 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0204c1e:	e7b058e3          	blez	s11,ffffffffc0204a8e <vprintfmt+0x3a>
ffffffffc0204c22:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204c24:	85a6                	mv	a1,s1
ffffffffc0204c26:	02000513          	li	a0,32
ffffffffc0204c2a:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204c2c:	e60d81e3          	beqz	s11,ffffffffc0204a8e <vprintfmt+0x3a>
ffffffffc0204c30:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204c32:	85a6                	mv	a1,s1
ffffffffc0204c34:	02000513          	li	a0,32
ffffffffc0204c38:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204c3a:	fe0d94e3          	bnez	s11,ffffffffc0204c22 <vprintfmt+0x1ce>
ffffffffc0204c3e:	bd81                	j	ffffffffc0204a8e <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204c40:	4705                	li	a4,1
ffffffffc0204c42:	008a8593          	addi	a1,s5,8
ffffffffc0204c46:	01074463          	blt	a4,a6,ffffffffc0204c4e <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc0204c4a:	12080063          	beqz	a6,ffffffffc0204d6a <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0204c4e:	000ab603          	ld	a2,0(s5)
ffffffffc0204c52:	46a9                	li	a3,10
ffffffffc0204c54:	8aae                	mv	s5,a1
ffffffffc0204c56:	b7bd                	j	ffffffffc0204bc4 <vprintfmt+0x170>
ffffffffc0204c58:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0204c5c:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c60:	846a                	mv	s0,s10
ffffffffc0204c62:	b5ad                	j	ffffffffc0204acc <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0204c64:	85a6                	mv	a1,s1
ffffffffc0204c66:	02500513          	li	a0,37
ffffffffc0204c6a:	9902                	jalr	s2
            break;
ffffffffc0204c6c:	b50d                	j	ffffffffc0204a8e <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0204c6e:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0204c72:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0204c76:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c78:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0204c7a:	e40dd9e3          	bgez	s11,ffffffffc0204acc <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0204c7e:	8de6                	mv	s11,s9
ffffffffc0204c80:	5cfd                	li	s9,-1
ffffffffc0204c82:	b5a9                	j	ffffffffc0204acc <vprintfmt+0x78>
            goto reswitch;
ffffffffc0204c84:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0204c88:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c8c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204c8e:	bd3d                	j	ffffffffc0204acc <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0204c90:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0204c94:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c98:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0204c9a:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0204c9e:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204ca2:	fcd56ce3          	bltu	a0,a3,ffffffffc0204c7a <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0204ca6:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0204ca8:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0204cac:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0204cb0:	0196873b          	addw	a4,a3,s9
ffffffffc0204cb4:	0017171b          	slliw	a4,a4,0x1
ffffffffc0204cb8:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0204cbc:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0204cc0:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0204cc4:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204cc8:	fcd57fe3          	bleu	a3,a0,ffffffffc0204ca6 <vprintfmt+0x252>
ffffffffc0204ccc:	b77d                	j	ffffffffc0204c7a <vprintfmt+0x226>
            if (width < 0)
ffffffffc0204cce:	fffdc693          	not	a3,s11
ffffffffc0204cd2:	96fd                	srai	a3,a3,0x3f
ffffffffc0204cd4:	00ddfdb3          	and	s11,s11,a3
ffffffffc0204cd8:	00144603          	lbu	a2,1(s0)
ffffffffc0204cdc:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204cde:	846a                	mv	s0,s10
ffffffffc0204ce0:	b3f5                	j	ffffffffc0204acc <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0204ce2:	85a6                	mv	a1,s1
ffffffffc0204ce4:	02500513          	li	a0,37
ffffffffc0204ce8:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0204cea:	fff44703          	lbu	a4,-1(s0)
ffffffffc0204cee:	02500793          	li	a5,37
ffffffffc0204cf2:	8d22                	mv	s10,s0
ffffffffc0204cf4:	d8f70de3          	beq	a4,a5,ffffffffc0204a8e <vprintfmt+0x3a>
ffffffffc0204cf8:	02500713          	li	a4,37
ffffffffc0204cfc:	1d7d                	addi	s10,s10,-1
ffffffffc0204cfe:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0204d02:	fee79de3          	bne	a5,a4,ffffffffc0204cfc <vprintfmt+0x2a8>
ffffffffc0204d06:	b361                	j	ffffffffc0204a8e <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0204d08:	00002617          	auipc	a2,0x2
ffffffffc0204d0c:	2a060613          	addi	a2,a2,672 # ffffffffc0206fa8 <error_string+0xd8>
ffffffffc0204d10:	85a6                	mv	a1,s1
ffffffffc0204d12:	854a                	mv	a0,s2
ffffffffc0204d14:	0ac000ef          	jal	ra,ffffffffc0204dc0 <printfmt>
ffffffffc0204d18:	bb9d                	j	ffffffffc0204a8e <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0204d1a:	00002617          	auipc	a2,0x2
ffffffffc0204d1e:	28660613          	addi	a2,a2,646 # ffffffffc0206fa0 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc0204d22:	00002417          	auipc	s0,0x2
ffffffffc0204d26:	27f40413          	addi	s0,s0,639 # ffffffffc0206fa1 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204d2a:	8532                	mv	a0,a2
ffffffffc0204d2c:	85e6                	mv	a1,s9
ffffffffc0204d2e:	e032                	sd	a2,0(sp)
ffffffffc0204d30:	e43e                	sd	a5,8(sp)
ffffffffc0204d32:	0cc000ef          	jal	ra,ffffffffc0204dfe <strnlen>
ffffffffc0204d36:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0204d3a:	6602                	ld	a2,0(sp)
ffffffffc0204d3c:	01b05d63          	blez	s11,ffffffffc0204d56 <vprintfmt+0x302>
ffffffffc0204d40:	67a2                	ld	a5,8(sp)
ffffffffc0204d42:	2781                	sext.w	a5,a5
ffffffffc0204d44:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0204d46:	6522                	ld	a0,8(sp)
ffffffffc0204d48:	85a6                	mv	a1,s1
ffffffffc0204d4a:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204d4c:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0204d4e:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204d50:	6602                	ld	a2,0(sp)
ffffffffc0204d52:	fe0d9ae3          	bnez	s11,ffffffffc0204d46 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204d56:	00064783          	lbu	a5,0(a2)
ffffffffc0204d5a:	0007851b          	sext.w	a0,a5
ffffffffc0204d5e:	e8051be3          	bnez	a0,ffffffffc0204bf4 <vprintfmt+0x1a0>
ffffffffc0204d62:	b335                	j	ffffffffc0204a8e <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc0204d64:	000aa403          	lw	s0,0(s5)
ffffffffc0204d68:	bbf1                	j	ffffffffc0204b44 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc0204d6a:	000ae603          	lwu	a2,0(s5)
ffffffffc0204d6e:	46a9                	li	a3,10
ffffffffc0204d70:	8aae                	mv	s5,a1
ffffffffc0204d72:	bd89                	j	ffffffffc0204bc4 <vprintfmt+0x170>
ffffffffc0204d74:	000ae603          	lwu	a2,0(s5)
ffffffffc0204d78:	46c1                	li	a3,16
ffffffffc0204d7a:	8aae                	mv	s5,a1
ffffffffc0204d7c:	b5a1                	j	ffffffffc0204bc4 <vprintfmt+0x170>
ffffffffc0204d7e:	000ae603          	lwu	a2,0(s5)
ffffffffc0204d82:	46a1                	li	a3,8
ffffffffc0204d84:	8aae                	mv	s5,a1
ffffffffc0204d86:	bd3d                	j	ffffffffc0204bc4 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0204d88:	9902                	jalr	s2
ffffffffc0204d8a:	b559                	j	ffffffffc0204c10 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0204d8c:	85a6                	mv	a1,s1
ffffffffc0204d8e:	02d00513          	li	a0,45
ffffffffc0204d92:	e03e                	sd	a5,0(sp)
ffffffffc0204d94:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0204d96:	8ace                	mv	s5,s3
ffffffffc0204d98:	40800633          	neg	a2,s0
ffffffffc0204d9c:	46a9                	li	a3,10
ffffffffc0204d9e:	6782                	ld	a5,0(sp)
ffffffffc0204da0:	b515                	j	ffffffffc0204bc4 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0204da2:	01b05663          	blez	s11,ffffffffc0204dae <vprintfmt+0x35a>
ffffffffc0204da6:	02d00693          	li	a3,45
ffffffffc0204daa:	f6d798e3          	bne	a5,a3,ffffffffc0204d1a <vprintfmt+0x2c6>
ffffffffc0204dae:	00002417          	auipc	s0,0x2
ffffffffc0204db2:	1f340413          	addi	s0,s0,499 # ffffffffc0206fa1 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204db6:	02800513          	li	a0,40
ffffffffc0204dba:	02800793          	li	a5,40
ffffffffc0204dbe:	bd1d                	j	ffffffffc0204bf4 <vprintfmt+0x1a0>

ffffffffc0204dc0 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204dc0:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0204dc2:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204dc6:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204dc8:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204dca:	ec06                	sd	ra,24(sp)
ffffffffc0204dcc:	f83a                	sd	a4,48(sp)
ffffffffc0204dce:	fc3e                	sd	a5,56(sp)
ffffffffc0204dd0:	e0c2                	sd	a6,64(sp)
ffffffffc0204dd2:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0204dd4:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204dd6:	c7fff0ef          	jal	ra,ffffffffc0204a54 <vprintfmt>
}
ffffffffc0204dda:	60e2                	ld	ra,24(sp)
ffffffffc0204ddc:	6161                	addi	sp,sp,80
ffffffffc0204dde:	8082                	ret

ffffffffc0204de0 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0204de0:	00054783          	lbu	a5,0(a0)
ffffffffc0204de4:	cb91                	beqz	a5,ffffffffc0204df8 <strlen+0x18>
    size_t cnt = 0;
ffffffffc0204de6:	4781                	li	a5,0
        cnt ++;
ffffffffc0204de8:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0204dea:	00f50733          	add	a4,a0,a5
ffffffffc0204dee:	00074703          	lbu	a4,0(a4)
ffffffffc0204df2:	fb7d                	bnez	a4,ffffffffc0204de8 <strlen+0x8>
    }
    return cnt;
}
ffffffffc0204df4:	853e                	mv	a0,a5
ffffffffc0204df6:	8082                	ret
    size_t cnt = 0;
ffffffffc0204df8:	4781                	li	a5,0
}
ffffffffc0204dfa:	853e                	mv	a0,a5
ffffffffc0204dfc:	8082                	ret

ffffffffc0204dfe <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204dfe:	c185                	beqz	a1,ffffffffc0204e1e <strnlen+0x20>
ffffffffc0204e00:	00054783          	lbu	a5,0(a0)
ffffffffc0204e04:	cf89                	beqz	a5,ffffffffc0204e1e <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0204e06:	4781                	li	a5,0
ffffffffc0204e08:	a021                	j	ffffffffc0204e10 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204e0a:	00074703          	lbu	a4,0(a4)
ffffffffc0204e0e:	c711                	beqz	a4,ffffffffc0204e1a <strnlen+0x1c>
        cnt ++;
ffffffffc0204e10:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204e12:	00f50733          	add	a4,a0,a5
ffffffffc0204e16:	fef59ae3          	bne	a1,a5,ffffffffc0204e0a <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0204e1a:	853e                	mv	a0,a5
ffffffffc0204e1c:	8082                	ret
    size_t cnt = 0;
ffffffffc0204e1e:	4781                	li	a5,0
}
ffffffffc0204e20:	853e                	mv	a0,a5
ffffffffc0204e22:	8082                	ret

ffffffffc0204e24 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0204e24:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0204e26:	0585                	addi	a1,a1,1
ffffffffc0204e28:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0204e2c:	0785                	addi	a5,a5,1
ffffffffc0204e2e:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0204e32:	fb75                	bnez	a4,ffffffffc0204e26 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0204e34:	8082                	ret

ffffffffc0204e36 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204e36:	00054783          	lbu	a5,0(a0)
ffffffffc0204e3a:	0005c703          	lbu	a4,0(a1)
ffffffffc0204e3e:	cb91                	beqz	a5,ffffffffc0204e52 <strcmp+0x1c>
ffffffffc0204e40:	00e79c63          	bne	a5,a4,ffffffffc0204e58 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0204e44:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204e46:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0204e4a:	0585                	addi	a1,a1,1
ffffffffc0204e4c:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204e50:	fbe5                	bnez	a5,ffffffffc0204e40 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204e52:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0204e54:	9d19                	subw	a0,a0,a4
ffffffffc0204e56:	8082                	ret
ffffffffc0204e58:	0007851b          	sext.w	a0,a5
ffffffffc0204e5c:	9d19                	subw	a0,a0,a4
ffffffffc0204e5e:	8082                	ret

ffffffffc0204e60 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0204e60:	00054783          	lbu	a5,0(a0)
ffffffffc0204e64:	cb91                	beqz	a5,ffffffffc0204e78 <strchr+0x18>
        if (*s == c) {
ffffffffc0204e66:	00b79563          	bne	a5,a1,ffffffffc0204e70 <strchr+0x10>
ffffffffc0204e6a:	a809                	j	ffffffffc0204e7c <strchr+0x1c>
ffffffffc0204e6c:	00b78763          	beq	a5,a1,ffffffffc0204e7a <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0204e70:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0204e72:	00054783          	lbu	a5,0(a0)
ffffffffc0204e76:	fbfd                	bnez	a5,ffffffffc0204e6c <strchr+0xc>
    }
    return NULL;
ffffffffc0204e78:	4501                	li	a0,0
}
ffffffffc0204e7a:	8082                	ret
ffffffffc0204e7c:	8082                	ret

ffffffffc0204e7e <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0204e7e:	ca01                	beqz	a2,ffffffffc0204e8e <memset+0x10>
ffffffffc0204e80:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0204e82:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0204e84:	0785                	addi	a5,a5,1
ffffffffc0204e86:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0204e8a:	fec79de3          	bne	a5,a2,ffffffffc0204e84 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0204e8e:	8082                	ret

ffffffffc0204e90 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0204e90:	ca19                	beqz	a2,ffffffffc0204ea6 <memcpy+0x16>
ffffffffc0204e92:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0204e94:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0204e96:	0585                	addi	a1,a1,1
ffffffffc0204e98:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0204e9c:	0785                	addi	a5,a5,1
ffffffffc0204e9e:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0204ea2:	fec59ae3          	bne	a1,a2,ffffffffc0204e96 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0204ea6:	8082                	ret

ffffffffc0204ea8 <memcmp>:
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
ffffffffc0204ea8:	c21d                	beqz	a2,ffffffffc0204ece <memcmp+0x26>
        if (*s1 != *s2) {
ffffffffc0204eaa:	00054783          	lbu	a5,0(a0)
ffffffffc0204eae:	0005c703          	lbu	a4,0(a1)
ffffffffc0204eb2:	962a                	add	a2,a2,a0
ffffffffc0204eb4:	00f70963          	beq	a4,a5,ffffffffc0204ec6 <memcmp+0x1e>
ffffffffc0204eb8:	a829                	j	ffffffffc0204ed2 <memcmp+0x2a>
ffffffffc0204eba:	00054783          	lbu	a5,0(a0)
ffffffffc0204ebe:	0005c703          	lbu	a4,0(a1)
ffffffffc0204ec2:	00e79863          	bne	a5,a4,ffffffffc0204ed2 <memcmp+0x2a>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
ffffffffc0204ec6:	0505                	addi	a0,a0,1
ffffffffc0204ec8:	0585                	addi	a1,a1,1
    while (n -- > 0) {
ffffffffc0204eca:	fea618e3          	bne	a2,a0,ffffffffc0204eba <memcmp+0x12>
    }
    return 0;
ffffffffc0204ece:	4501                	li	a0,0
}
ffffffffc0204ed0:	8082                	ret
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204ed2:	40e7853b          	subw	a0,a5,a4
ffffffffc0204ed6:	8082                	ret
