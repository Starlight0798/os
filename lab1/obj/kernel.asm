
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
#include <memlayout.h>

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    la sp, bootstacktop
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp

    tail kern_init
    80200008:	0040006f          	j	8020000c <kern_init>

000000008020000c <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    8020000c:	00004517          	auipc	a0,0x4
    80200010:	00450513          	addi	a0,a0,4 # 80204010 <edata>
    80200014:	00004617          	auipc	a2,0x4
    80200018:	01460613          	addi	a2,a2,20 # 80204028 <end>
int kern_init(void) {
    8020001c:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
    8020001e:	8e09                	sub	a2,a2,a0
    80200020:	4581                	li	a1,0
int kern_init(void) {
    80200022:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
    80200024:	5f0000ef          	jal	ra,80200614 <memset>

    cons_init();  // init the console
    80200028:	152000ef          	jal	ra,8020017a <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002c:	00001597          	auipc	a1,0x1
    80200030:	a4c58593          	addi	a1,a1,-1460 # 80200a78 <etext+0x6>
    80200034:	00001517          	auipc	a0,0x1
    80200038:	a6450513          	addi	a0,a0,-1436 # 80200a98 <etext+0x26>
    8020003c:	036000ef          	jal	ra,80200072 <cprintf>
    print_kerninfo();
    80200040:	066000ef          	jal	ra,802000a6 <print_kerninfo>

    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
    80200044:	146000ef          	jal	ra,8020018a <idt_init>
    
    __asm__ volatile (
    80200048:	30200073          	mret
    8020004c:	9002                	ebreak
    	"mret\n"
    	"ebreak\n"
    );

    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt
    8020004e:	0e8000ef          	jal	ra,80200136 <clock_init>

    intr_enable();  // enable irq interrupt
    80200052:	132000ef          	jal	ra,80200184 <intr_enable>
    
    while (1)
        ;
    80200056:	a001                	j	80200056 <kern_init+0x4a>

0000000080200058 <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
    80200058:	1141                	addi	sp,sp,-16
    8020005a:	e022                	sd	s0,0(sp)
    8020005c:	e406                	sd	ra,8(sp)
    8020005e:	842e                	mv	s0,a1
    cons_putc(c);
    80200060:	11c000ef          	jal	ra,8020017c <cons_putc>
    (*cnt)++;
    80200064:	401c                	lw	a5,0(s0)
}
    80200066:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    80200068:	2785                	addiw	a5,a5,1
    8020006a:	c01c                	sw	a5,0(s0)
}
    8020006c:	6402                	ld	s0,0(sp)
    8020006e:	0141                	addi	sp,sp,16
    80200070:	8082                	ret

0000000080200072 <cprintf>:
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
    80200072:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    80200074:	02810313          	addi	t1,sp,40 # 80204028 <end>
int cprintf(const char *fmt, ...) {
    80200078:	f42e                	sd	a1,40(sp)
    8020007a:	f832                	sd	a2,48(sp)
    8020007c:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    8020007e:	862a                	mv	a2,a0
    80200080:	004c                	addi	a1,sp,4
    80200082:	00000517          	auipc	a0,0x0
    80200086:	fd650513          	addi	a0,a0,-42 # 80200058 <cputch>
    8020008a:	869a                	mv	a3,t1
int cprintf(const char *fmt, ...) {
    8020008c:	ec06                	sd	ra,24(sp)
    8020008e:	e0ba                	sd	a4,64(sp)
    80200090:	e4be                	sd	a5,72(sp)
    80200092:	e8c2                	sd	a6,80(sp)
    80200094:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    80200096:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    80200098:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    8020009a:	5f8000ef          	jal	ra,80200692 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    8020009e:	60e2                	ld	ra,24(sp)
    802000a0:	4512                	lw	a0,4(sp)
    802000a2:	6125                	addi	sp,sp,96
    802000a4:	8082                	ret

00000000802000a6 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
    802000a6:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
    802000a8:	00001517          	auipc	a0,0x1
    802000ac:	9f850513          	addi	a0,a0,-1544 # 80200aa0 <etext+0x2e>
void print_kerninfo(void) {
    802000b0:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000b2:	fc1ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000b6:	00000597          	auipc	a1,0x0
    802000ba:	f5658593          	addi	a1,a1,-170 # 8020000c <kern_init>
    802000be:	00001517          	auipc	a0,0x1
    802000c2:	a0250513          	addi	a0,a0,-1534 # 80200ac0 <etext+0x4e>
    802000c6:	fadff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000ca:	00001597          	auipc	a1,0x1
    802000ce:	9a858593          	addi	a1,a1,-1624 # 80200a72 <etext>
    802000d2:	00001517          	auipc	a0,0x1
    802000d6:	a0e50513          	addi	a0,a0,-1522 # 80200ae0 <etext+0x6e>
    802000da:	f99ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000de:	00004597          	auipc	a1,0x4
    802000e2:	f3258593          	addi	a1,a1,-206 # 80204010 <edata>
    802000e6:	00001517          	auipc	a0,0x1
    802000ea:	a1a50513          	addi	a0,a0,-1510 # 80200b00 <etext+0x8e>
    802000ee:	f85ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000f2:	00004597          	auipc	a1,0x4
    802000f6:	f3658593          	addi	a1,a1,-202 # 80204028 <end>
    802000fa:	00001517          	auipc	a0,0x1
    802000fe:	a2650513          	addi	a0,a0,-1498 # 80200b20 <etext+0xae>
    80200102:	f71ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
    80200106:	00004597          	auipc	a1,0x4
    8020010a:	32158593          	addi	a1,a1,801 # 80204427 <end+0x3ff>
    8020010e:	00000797          	auipc	a5,0x0
    80200112:	efe78793          	addi	a5,a5,-258 # 8020000c <kern_init>
    80200116:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020011a:	43f7d593          	srai	a1,a5,0x3f
}
    8020011e:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200120:	3ff5f593          	andi	a1,a1,1023
    80200124:	95be                	add	a1,a1,a5
    80200126:	85a9                	srai	a1,a1,0xa
    80200128:	00001517          	auipc	a0,0x1
    8020012c:	a1850513          	addi	a0,a0,-1512 # 80200b40 <etext+0xce>
}
    80200130:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200132:	f41ff06f          	j	80200072 <cprintf>

0000000080200136 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    80200136:	1141                	addi	sp,sp,-16
    80200138:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
    8020013a:	02000793          	li	a5,32
    8020013e:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    80200142:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200146:	67e1                	lui	a5,0x18
    80200148:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    8020014c:	953e                	add	a0,a0,a5
    8020014e:	0ed000ef          	jal	ra,80200a3a <sbi_set_timer>
}
    80200152:	60a2                	ld	ra,8(sp)
    ticks = 0;
    80200154:	00004797          	auipc	a5,0x4
    80200158:	ec07b623          	sd	zero,-308(a5) # 80204020 <ticks>
    cprintf("++ setup timer interrupts\n");
    8020015c:	00001517          	auipc	a0,0x1
    80200160:	a1450513          	addi	a0,a0,-1516 # 80200b70 <etext+0xfe>
}
    80200164:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
    80200166:	f0dff06f          	j	80200072 <cprintf>

000000008020016a <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    8020016a:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    8020016e:	67e1                	lui	a5,0x18
    80200170:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    80200174:	953e                	add	a0,a0,a5
    80200176:	0c50006f          	j	80200a3a <sbi_set_timer>

000000008020017a <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
    8020017a:	8082                	ret

000000008020017c <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    8020017c:	0ff57513          	andi	a0,a0,255
    80200180:	09f0006f          	j	80200a1e <sbi_console_putchar>

0000000080200184 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
    80200184:	100167f3          	csrrsi	a5,sstatus,2
    80200188:	8082                	ret

000000008020018a <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    8020018a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    8020018e:	00000797          	auipc	a5,0x0
    80200192:	3aa78793          	addi	a5,a5,938 # 80200538 <__alltraps>
    80200196:	10579073          	csrw	stvec,a5
}
    8020019a:	8082                	ret

000000008020019c <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    8020019c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    8020019e:	1141                	addi	sp,sp,-16
    802001a0:	e022                	sd	s0,0(sp)
    802001a2:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001a4:	00001517          	auipc	a0,0x1
    802001a8:	b6450513          	addi	a0,a0,-1180 # 80200d08 <etext+0x296>
void print_regs(struct pushregs *gpr) {
    802001ac:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001ae:	ec5ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001b2:	640c                	ld	a1,8(s0)
    802001b4:	00001517          	auipc	a0,0x1
    802001b8:	b6c50513          	addi	a0,a0,-1172 # 80200d20 <etext+0x2ae>
    802001bc:	eb7ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001c0:	680c                	ld	a1,16(s0)
    802001c2:	00001517          	auipc	a0,0x1
    802001c6:	b7650513          	addi	a0,a0,-1162 # 80200d38 <etext+0x2c6>
    802001ca:	ea9ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001ce:	6c0c                	ld	a1,24(s0)
    802001d0:	00001517          	auipc	a0,0x1
    802001d4:	b8050513          	addi	a0,a0,-1152 # 80200d50 <etext+0x2de>
    802001d8:	e9bff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001dc:	700c                	ld	a1,32(s0)
    802001de:	00001517          	auipc	a0,0x1
    802001e2:	b8a50513          	addi	a0,a0,-1142 # 80200d68 <etext+0x2f6>
    802001e6:	e8dff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001ea:	740c                	ld	a1,40(s0)
    802001ec:	00001517          	auipc	a0,0x1
    802001f0:	b9450513          	addi	a0,a0,-1132 # 80200d80 <etext+0x30e>
    802001f4:	e7fff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001f8:	780c                	ld	a1,48(s0)
    802001fa:	00001517          	auipc	a0,0x1
    802001fe:	b9e50513          	addi	a0,a0,-1122 # 80200d98 <etext+0x326>
    80200202:	e71ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    80200206:	7c0c                	ld	a1,56(s0)
    80200208:	00001517          	auipc	a0,0x1
    8020020c:	ba850513          	addi	a0,a0,-1112 # 80200db0 <etext+0x33e>
    80200210:	e63ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    80200214:	602c                	ld	a1,64(s0)
    80200216:	00001517          	auipc	a0,0x1
    8020021a:	bb250513          	addi	a0,a0,-1102 # 80200dc8 <etext+0x356>
    8020021e:	e55ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    80200222:	642c                	ld	a1,72(s0)
    80200224:	00001517          	auipc	a0,0x1
    80200228:	bbc50513          	addi	a0,a0,-1092 # 80200de0 <etext+0x36e>
    8020022c:	e47ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    80200230:	682c                	ld	a1,80(s0)
    80200232:	00001517          	auipc	a0,0x1
    80200236:	bc650513          	addi	a0,a0,-1082 # 80200df8 <etext+0x386>
    8020023a:	e39ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    8020023e:	6c2c                	ld	a1,88(s0)
    80200240:	00001517          	auipc	a0,0x1
    80200244:	bd050513          	addi	a0,a0,-1072 # 80200e10 <etext+0x39e>
    80200248:	e2bff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    8020024c:	702c                	ld	a1,96(s0)
    8020024e:	00001517          	auipc	a0,0x1
    80200252:	bda50513          	addi	a0,a0,-1062 # 80200e28 <etext+0x3b6>
    80200256:	e1dff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    8020025a:	742c                	ld	a1,104(s0)
    8020025c:	00001517          	auipc	a0,0x1
    80200260:	be450513          	addi	a0,a0,-1052 # 80200e40 <etext+0x3ce>
    80200264:	e0fff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    80200268:	782c                	ld	a1,112(s0)
    8020026a:	00001517          	auipc	a0,0x1
    8020026e:	bee50513          	addi	a0,a0,-1042 # 80200e58 <etext+0x3e6>
    80200272:	e01ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    80200276:	7c2c                	ld	a1,120(s0)
    80200278:	00001517          	auipc	a0,0x1
    8020027c:	bf850513          	addi	a0,a0,-1032 # 80200e70 <etext+0x3fe>
    80200280:	df3ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    80200284:	604c                	ld	a1,128(s0)
    80200286:	00001517          	auipc	a0,0x1
    8020028a:	c0250513          	addi	a0,a0,-1022 # 80200e88 <etext+0x416>
    8020028e:	de5ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    80200292:	644c                	ld	a1,136(s0)
    80200294:	00001517          	auipc	a0,0x1
    80200298:	c0c50513          	addi	a0,a0,-1012 # 80200ea0 <etext+0x42e>
    8020029c:	dd7ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    802002a0:	684c                	ld	a1,144(s0)
    802002a2:	00001517          	auipc	a0,0x1
    802002a6:	c1650513          	addi	a0,a0,-1002 # 80200eb8 <etext+0x446>
    802002aa:	dc9ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    802002ae:	6c4c                	ld	a1,152(s0)
    802002b0:	00001517          	auipc	a0,0x1
    802002b4:	c2050513          	addi	a0,a0,-992 # 80200ed0 <etext+0x45e>
    802002b8:	dbbff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002bc:	704c                	ld	a1,160(s0)
    802002be:	00001517          	auipc	a0,0x1
    802002c2:	c2a50513          	addi	a0,a0,-982 # 80200ee8 <etext+0x476>
    802002c6:	dadff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002ca:	744c                	ld	a1,168(s0)
    802002cc:	00001517          	auipc	a0,0x1
    802002d0:	c3450513          	addi	a0,a0,-972 # 80200f00 <etext+0x48e>
    802002d4:	d9fff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002d8:	784c                	ld	a1,176(s0)
    802002da:	00001517          	auipc	a0,0x1
    802002de:	c3e50513          	addi	a0,a0,-962 # 80200f18 <etext+0x4a6>
    802002e2:	d91ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002e6:	7c4c                	ld	a1,184(s0)
    802002e8:	00001517          	auipc	a0,0x1
    802002ec:	c4850513          	addi	a0,a0,-952 # 80200f30 <etext+0x4be>
    802002f0:	d83ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002f4:	606c                	ld	a1,192(s0)
    802002f6:	00001517          	auipc	a0,0x1
    802002fa:	c5250513          	addi	a0,a0,-942 # 80200f48 <etext+0x4d6>
    802002fe:	d75ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    80200302:	646c                	ld	a1,200(s0)
    80200304:	00001517          	auipc	a0,0x1
    80200308:	c5c50513          	addi	a0,a0,-932 # 80200f60 <etext+0x4ee>
    8020030c:	d67ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    80200310:	686c                	ld	a1,208(s0)
    80200312:	00001517          	auipc	a0,0x1
    80200316:	c6650513          	addi	a0,a0,-922 # 80200f78 <etext+0x506>
    8020031a:	d59ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    8020031e:	6c6c                	ld	a1,216(s0)
    80200320:	00001517          	auipc	a0,0x1
    80200324:	c7050513          	addi	a0,a0,-912 # 80200f90 <etext+0x51e>
    80200328:	d4bff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    8020032c:	706c                	ld	a1,224(s0)
    8020032e:	00001517          	auipc	a0,0x1
    80200332:	c7a50513          	addi	a0,a0,-902 # 80200fa8 <etext+0x536>
    80200336:	d3dff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    8020033a:	746c                	ld	a1,232(s0)
    8020033c:	00001517          	auipc	a0,0x1
    80200340:	c8450513          	addi	a0,a0,-892 # 80200fc0 <etext+0x54e>
    80200344:	d2fff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    80200348:	786c                	ld	a1,240(s0)
    8020034a:	00001517          	auipc	a0,0x1
    8020034e:	c8e50513          	addi	a0,a0,-882 # 80200fd8 <etext+0x566>
    80200352:	d21ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200356:	7c6c                	ld	a1,248(s0)
}
    80200358:	6402                	ld	s0,0(sp)
    8020035a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    8020035c:	00001517          	auipc	a0,0x1
    80200360:	c9450513          	addi	a0,a0,-876 # 80200ff0 <etext+0x57e>
}
    80200364:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200366:	d0dff06f          	j	80200072 <cprintf>

000000008020036a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    8020036a:	1141                	addi	sp,sp,-16
    8020036c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    8020036e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    80200370:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    80200372:	00001517          	auipc	a0,0x1
    80200376:	c9650513          	addi	a0,a0,-874 # 80201008 <etext+0x596>
void print_trapframe(struct trapframe *tf) {
    8020037a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    8020037c:	cf7ff0ef          	jal	ra,80200072 <cprintf>
    print_regs(&tf->gpr);
    80200380:	8522                	mv	a0,s0
    80200382:	e1bff0ef          	jal	ra,8020019c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    80200386:	10043583          	ld	a1,256(s0)
    8020038a:	00001517          	auipc	a0,0x1
    8020038e:	c9650513          	addi	a0,a0,-874 # 80201020 <etext+0x5ae>
    80200392:	ce1ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    80200396:	10843583          	ld	a1,264(s0)
    8020039a:	00001517          	auipc	a0,0x1
    8020039e:	c9e50513          	addi	a0,a0,-866 # 80201038 <etext+0x5c6>
    802003a2:	cd1ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    802003a6:	11043583          	ld	a1,272(s0)
    802003aa:	00001517          	auipc	a0,0x1
    802003ae:	ca650513          	addi	a0,a0,-858 # 80201050 <etext+0x5de>
    802003b2:	cc1ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b6:	11843583          	ld	a1,280(s0)
}
    802003ba:	6402                	ld	s0,0(sp)
    802003bc:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003be:	00001517          	auipc	a0,0x1
    802003c2:	caa50513          	addi	a0,a0,-854 # 80201068 <etext+0x5f6>
}
    802003c6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003c8:	cabff06f          	j	80200072 <cprintf>

00000000802003cc <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    802003cc:	11853783          	ld	a5,280(a0)
    802003d0:	577d                	li	a4,-1
    802003d2:	8305                	srli	a4,a4,0x1
    802003d4:	8ff9                	and	a5,a5,a4
    switch (cause) {
    802003d6:	472d                	li	a4,11
    802003d8:	08f76063          	bltu	a4,a5,80200458 <interrupt_handler+0x8c>
    802003dc:	00000717          	auipc	a4,0x0
    802003e0:	7b070713          	addi	a4,a4,1968 # 80200b8c <etext+0x11a>
    802003e4:	078a                	slli	a5,a5,0x2
    802003e6:	97ba                	add	a5,a5,a4
    802003e8:	439c                	lw	a5,0(a5)
    802003ea:	97ba                	add	a5,a5,a4
    802003ec:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003ee:	00001517          	auipc	a0,0x1
    802003f2:	8ca50513          	addi	a0,a0,-1846 # 80200cb8 <etext+0x246>
    802003f6:	c7dff06f          	j	80200072 <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003fa:	00001517          	auipc	a0,0x1
    802003fe:	89e50513          	addi	a0,a0,-1890 # 80200c98 <etext+0x226>
    80200402:	c71ff06f          	j	80200072 <cprintf>
            cprintf("User software interrupt\n");
    80200406:	00001517          	auipc	a0,0x1
    8020040a:	85250513          	addi	a0,a0,-1966 # 80200c58 <etext+0x1e6>
    8020040e:	c65ff06f          	j	80200072 <cprintf>
            cprintf("Supervisor software interrupt\n");
    80200412:	00001517          	auipc	a0,0x1
    80200416:	86650513          	addi	a0,a0,-1946 # 80200c78 <etext+0x206>
    8020041a:	c59ff06f          	j	80200072 <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
    8020041e:	00001517          	auipc	a0,0x1
    80200422:	8ca50513          	addi	a0,a0,-1846 # 80200ce8 <etext+0x276>
    80200426:	c4dff06f          	j	80200072 <cprintf>
void interrupt_handler(struct trapframe *tf) {
    8020042a:	1141                	addi	sp,sp,-16
    8020042c:	e406                	sd	ra,8(sp)
            clock_set_next_event();
    8020042e:	d3dff0ef          	jal	ra,8020016a <clock_set_next_event>
            ticks++;
    80200432:	00004717          	auipc	a4,0x4
    80200436:	bee70713          	addi	a4,a4,-1042 # 80204020 <ticks>
    8020043a:	631c                	ld	a5,0(a4)
    8020043c:	0785                	addi	a5,a5,1
    8020043e:	00004697          	auipc	a3,0x4
    80200442:	bef6b123          	sd	a5,-1054(a3) # 80204020 <ticks>
            if(ticks%TICK_NUM == 0){
    80200446:	631c                	ld	a5,0(a4)
    80200448:	06400713          	li	a4,100
    8020044c:	02e7f7b3          	remu	a5,a5,a4
    80200450:	c791                	beqz	a5,8020045c <interrupt_handler+0x90>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    80200452:	60a2                	ld	ra,8(sp)
    80200454:	0141                	addi	sp,sp,16
    80200456:	8082                	ret
            print_trapframe(tf);
    80200458:	f13ff06f          	j	8020036a <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
    8020045c:	06400593          	li	a1,100
    80200460:	00001517          	auipc	a0,0x1
    80200464:	87850513          	addi	a0,a0,-1928 # 80200cd8 <etext+0x266>
    80200468:	c0bff0ef          	jal	ra,80200072 <cprintf>
            	PRINT_NUM++;
    8020046c:	00004797          	auipc	a5,0x4
    80200470:	ba478793          	addi	a5,a5,-1116 # 80204010 <edata>
    80200474:	439c                	lw	a5,0(a5)
            	if(PRINT_NUM == 10){
    80200476:	4729                	li	a4,10
            	PRINT_NUM++;
    80200478:	0017869b          	addiw	a3,a5,1
    8020047c:	00004617          	auipc	a2,0x4
    80200480:	b8d62a23          	sw	a3,-1132(a2) # 80204010 <edata>
            	if(PRINT_NUM == 10){
    80200484:	fce697e3          	bne	a3,a4,80200452 <interrupt_handler+0x86>
}
    80200488:	60a2                	ld	ra,8(sp)
    8020048a:	0141                	addi	sp,sp,16
            	   sbi_shutdown();
    8020048c:	5ca0006f          	j	80200a56 <sbi_shutdown>

0000000080200490 <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
    80200490:	11853783          	ld	a5,280(a0)
    80200494:	472d                	li	a4,11
    80200496:	02f76863          	bltu	a4,a5,802004c6 <exception_handler+0x36>
    8020049a:	4705                	li	a4,1
    8020049c:	00f71733          	sll	a4,a4,a5
    802004a0:	6785                	lui	a5,0x1
    802004a2:	17cd                	addi	a5,a5,-13
    802004a4:	8ff9                	and	a5,a5,a4
    802004a6:	ef99                	bnez	a5,802004c4 <exception_handler+0x34>
void exception_handler(struct trapframe *tf) {
    802004a8:	1141                	addi	sp,sp,-16
    802004aa:	e022                	sd	s0,0(sp)
    802004ac:	e406                	sd	ra,8(sp)
    802004ae:	00877793          	andi	a5,a4,8
    802004b2:	842a                	mv	s0,a0
    802004b4:	e3b1                	bnez	a5,802004f8 <exception_handler+0x68>
    802004b6:	8b11                	andi	a4,a4,4
    802004b8:	eb09                	bnez	a4,802004ca <exception_handler+0x3a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    802004ba:	6402                	ld	s0,0(sp)
    802004bc:	60a2                	ld	ra,8(sp)
    802004be:	0141                	addi	sp,sp,16
            print_trapframe(tf);
    802004c0:	eabff06f          	j	8020036a <print_trapframe>
    802004c4:	8082                	ret
    802004c6:	ea5ff06f          	j	8020036a <print_trapframe>
            cprintf("Exception type:Illegal instruction \n");
    802004ca:	00000517          	auipc	a0,0x0
    802004ce:	6f650513          	addi	a0,a0,1782 # 80200bc0 <etext+0x14e>
    802004d2:	ba1ff0ef          	jal	ra,80200072 <cprintf>
            cprintf("Illegal instruction exception at 0x%016llx\n", tf->epc);//采用0x%016llx格式化字符串，用于打印16位十六进制数，这个位置是异常指令的地址,以tf->epc作为参数。
    802004d6:	10843583          	ld	a1,264(s0)
    802004da:	00000517          	auipc	a0,0x0
    802004de:	70e50513          	addi	a0,a0,1806 # 80200be8 <etext+0x176>
    802004e2:	b91ff0ef          	jal	ra,80200072 <cprintf>
            tf->epc += 4;//指令长度都为4个字节
    802004e6:	10843783          	ld	a5,264(s0)
}
    802004ea:	60a2                	ld	ra,8(sp)
            tf->epc += 4;//指令长度都为4个字节
    802004ec:	0791                	addi	a5,a5,4
    802004ee:	10f43423          	sd	a5,264(s0)
}
    802004f2:	6402                	ld	s0,0(sp)
    802004f4:	0141                	addi	sp,sp,16
    802004f6:	8082                	ret
            cprintf("Exception type: breakpoint \n");
    802004f8:	00000517          	auipc	a0,0x0
    802004fc:	72050513          	addi	a0,a0,1824 # 80200c18 <etext+0x1a6>
    80200500:	b73ff0ef          	jal	ra,80200072 <cprintf>
            cprintf("ebreak caught at 0x%016llx\n", tf->epc);
    80200504:	10843583          	ld	a1,264(s0)
    80200508:	00000517          	auipc	a0,0x0
    8020050c:	73050513          	addi	a0,a0,1840 # 80200c38 <etext+0x1c6>
    80200510:	b63ff0ef          	jal	ra,80200072 <cprintf>
            tf->epc += 2;//ebreak指令长度为2个字节，为了4字节对齐
    80200514:	10843783          	ld	a5,264(s0)
}
    80200518:	60a2                	ld	ra,8(sp)
            tf->epc += 2;//ebreak指令长度为2个字节，为了4字节对齐
    8020051a:	0789                	addi	a5,a5,2
    8020051c:	10f43423          	sd	a5,264(s0)
}
    80200520:	6402                	ld	s0,0(sp)
    80200522:	0141                	addi	sp,sp,16
    80200524:	8082                	ret

0000000080200526 <trap>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    80200526:	11853783          	ld	a5,280(a0)
    8020052a:	0007c463          	bltz	a5,80200532 <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
    8020052e:	f63ff06f          	j	80200490 <exception_handler>
        interrupt_handler(tf);
    80200532:	e9bff06f          	j	802003cc <interrupt_handler>
	...

0000000080200538 <__alltraps>:
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
    80200538:	14011073          	csrw	sscratch,sp
    8020053c:	712d                	addi	sp,sp,-288
    8020053e:	e002                	sd	zero,0(sp)
    80200540:	e406                	sd	ra,8(sp)
    80200542:	ec0e                	sd	gp,24(sp)
    80200544:	f012                	sd	tp,32(sp)
    80200546:	f416                	sd	t0,40(sp)
    80200548:	f81a                	sd	t1,48(sp)
    8020054a:	fc1e                	sd	t2,56(sp)
    8020054c:	e0a2                	sd	s0,64(sp)
    8020054e:	e4a6                	sd	s1,72(sp)
    80200550:	e8aa                	sd	a0,80(sp)
    80200552:	ecae                	sd	a1,88(sp)
    80200554:	f0b2                	sd	a2,96(sp)
    80200556:	f4b6                	sd	a3,104(sp)
    80200558:	f8ba                	sd	a4,112(sp)
    8020055a:	fcbe                	sd	a5,120(sp)
    8020055c:	e142                	sd	a6,128(sp)
    8020055e:	e546                	sd	a7,136(sp)
    80200560:	e94a                	sd	s2,144(sp)
    80200562:	ed4e                	sd	s3,152(sp)
    80200564:	f152                	sd	s4,160(sp)
    80200566:	f556                	sd	s5,168(sp)
    80200568:	f95a                	sd	s6,176(sp)
    8020056a:	fd5e                	sd	s7,184(sp)
    8020056c:	e1e2                	sd	s8,192(sp)
    8020056e:	e5e6                	sd	s9,200(sp)
    80200570:	e9ea                	sd	s10,208(sp)
    80200572:	edee                	sd	s11,216(sp)
    80200574:	f1f2                	sd	t3,224(sp)
    80200576:	f5f6                	sd	t4,232(sp)
    80200578:	f9fa                	sd	t5,240(sp)
    8020057a:	fdfe                	sd	t6,248(sp)
    8020057c:	14001473          	csrrw	s0,sscratch,zero
    80200580:	100024f3          	csrr	s1,sstatus
    80200584:	14102973          	csrr	s2,sepc
    80200588:	143029f3          	csrr	s3,stval
    8020058c:	14202a73          	csrr	s4,scause
    80200590:	e822                	sd	s0,16(sp)
    80200592:	e226                	sd	s1,256(sp)
    80200594:	e64a                	sd	s2,264(sp)
    80200596:	ea4e                	sd	s3,272(sp)
    80200598:	ee52                	sd	s4,280(sp)

    move  a0, sp
    8020059a:	850a                	mv	a0,sp
    jal trap
    8020059c:	f8bff0ef          	jal	ra,80200526 <trap>

00000000802005a0 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    802005a0:	6492                	ld	s1,256(sp)
    802005a2:	6932                	ld	s2,264(sp)
    802005a4:	10049073          	csrw	sstatus,s1
    802005a8:	14191073          	csrw	sepc,s2
    802005ac:	60a2                	ld	ra,8(sp)
    802005ae:	61e2                	ld	gp,24(sp)
    802005b0:	7202                	ld	tp,32(sp)
    802005b2:	72a2                	ld	t0,40(sp)
    802005b4:	7342                	ld	t1,48(sp)
    802005b6:	73e2                	ld	t2,56(sp)
    802005b8:	6406                	ld	s0,64(sp)
    802005ba:	64a6                	ld	s1,72(sp)
    802005bc:	6546                	ld	a0,80(sp)
    802005be:	65e6                	ld	a1,88(sp)
    802005c0:	7606                	ld	a2,96(sp)
    802005c2:	76a6                	ld	a3,104(sp)
    802005c4:	7746                	ld	a4,112(sp)
    802005c6:	77e6                	ld	a5,120(sp)
    802005c8:	680a                	ld	a6,128(sp)
    802005ca:	68aa                	ld	a7,136(sp)
    802005cc:	694a                	ld	s2,144(sp)
    802005ce:	69ea                	ld	s3,152(sp)
    802005d0:	7a0a                	ld	s4,160(sp)
    802005d2:	7aaa                	ld	s5,168(sp)
    802005d4:	7b4a                	ld	s6,176(sp)
    802005d6:	7bea                	ld	s7,184(sp)
    802005d8:	6c0e                	ld	s8,192(sp)
    802005da:	6cae                	ld	s9,200(sp)
    802005dc:	6d4e                	ld	s10,208(sp)
    802005de:	6dee                	ld	s11,216(sp)
    802005e0:	7e0e                	ld	t3,224(sp)
    802005e2:	7eae                	ld	t4,232(sp)
    802005e4:	7f4e                	ld	t5,240(sp)
    802005e6:	7fee                	ld	t6,248(sp)
    802005e8:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    802005ea:	10200073          	sret

00000000802005ee <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
    802005ee:	c185                	beqz	a1,8020060e <strnlen+0x20>
    802005f0:	00054783          	lbu	a5,0(a0)
    802005f4:	cf89                	beqz	a5,8020060e <strnlen+0x20>
    size_t cnt = 0;
    802005f6:	4781                	li	a5,0
    802005f8:	a021                	j	80200600 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
    802005fa:	00074703          	lbu	a4,0(a4)
    802005fe:	c711                	beqz	a4,8020060a <strnlen+0x1c>
        cnt ++;
    80200600:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    80200602:	00f50733          	add	a4,a0,a5
    80200606:	fef59ae3          	bne	a1,a5,802005fa <strnlen+0xc>
    }
    return cnt;
}
    8020060a:	853e                	mv	a0,a5
    8020060c:	8082                	ret
    size_t cnt = 0;
    8020060e:	4781                	li	a5,0
}
    80200610:	853e                	mv	a0,a5
    80200612:	8082                	ret

0000000080200614 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    80200614:	ca01                	beqz	a2,80200624 <memset+0x10>
    80200616:	962a                	add	a2,a2,a0
    char *p = s;
    80200618:	87aa                	mv	a5,a0
        *p ++ = c;
    8020061a:	0785                	addi	a5,a5,1
    8020061c:	feb78fa3          	sb	a1,-1(a5) # fff <BASE_ADDRESS-0x801ff001>
    while (n -- > 0) {
    80200620:	fec79de3          	bne	a5,a2,8020061a <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    80200624:	8082                	ret

0000000080200626 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    80200626:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    8020062a:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    8020062c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    80200630:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    80200632:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    80200636:	f022                	sd	s0,32(sp)
    80200638:	ec26                	sd	s1,24(sp)
    8020063a:	e84a                	sd	s2,16(sp)
    8020063c:	f406                	sd	ra,40(sp)
    8020063e:	e44e                	sd	s3,8(sp)
    80200640:	84aa                	mv	s1,a0
    80200642:	892e                	mv	s2,a1
    80200644:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    80200648:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
    8020064a:	03067e63          	bleu	a6,a2,80200686 <printnum+0x60>
    8020064e:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    80200650:	00805763          	blez	s0,8020065e <printnum+0x38>
    80200654:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    80200656:	85ca                	mv	a1,s2
    80200658:	854e                	mv	a0,s3
    8020065a:	9482                	jalr	s1
        while (-- width > 0)
    8020065c:	fc65                	bnez	s0,80200654 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    8020065e:	1a02                	slli	s4,s4,0x20
    80200660:	020a5a13          	srli	s4,s4,0x20
    80200664:	00001797          	auipc	a5,0x1
    80200668:	bac78793          	addi	a5,a5,-1108 # 80201210 <error_string+0x38>
    8020066c:	9a3e                	add	s4,s4,a5
}
    8020066e:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200670:	000a4503          	lbu	a0,0(s4)
}
    80200674:	70a2                	ld	ra,40(sp)
    80200676:	69a2                	ld	s3,8(sp)
    80200678:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    8020067a:	85ca                	mv	a1,s2
    8020067c:	8326                	mv	t1,s1
}
    8020067e:	6942                	ld	s2,16(sp)
    80200680:	64e2                	ld	s1,24(sp)
    80200682:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    80200684:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
    80200686:	03065633          	divu	a2,a2,a6
    8020068a:	8722                	mv	a4,s0
    8020068c:	f9bff0ef          	jal	ra,80200626 <printnum>
    80200690:	b7f9                	j	8020065e <printnum+0x38>

0000000080200692 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    80200692:	7119                	addi	sp,sp,-128
    80200694:	f4a6                	sd	s1,104(sp)
    80200696:	f0ca                	sd	s2,96(sp)
    80200698:	e8d2                	sd	s4,80(sp)
    8020069a:	e4d6                	sd	s5,72(sp)
    8020069c:	e0da                	sd	s6,64(sp)
    8020069e:	fc5e                	sd	s7,56(sp)
    802006a0:	f862                	sd	s8,48(sp)
    802006a2:	f06a                	sd	s10,32(sp)
    802006a4:	fc86                	sd	ra,120(sp)
    802006a6:	f8a2                	sd	s0,112(sp)
    802006a8:	ecce                	sd	s3,88(sp)
    802006aa:	f466                	sd	s9,40(sp)
    802006ac:	ec6e                	sd	s11,24(sp)
    802006ae:	892a                	mv	s2,a0
    802006b0:	84ae                	mv	s1,a1
    802006b2:	8d32                	mv	s10,a2
    802006b4:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    802006b6:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
    802006b8:	00001a17          	auipc	s4,0x1
    802006bc:	9c4a0a13          	addi	s4,s4,-1596 # 8020107c <etext+0x60a>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
    802006c0:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802006c4:	00001c17          	auipc	s8,0x1
    802006c8:	b14c0c13          	addi	s8,s8,-1260 # 802011d8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006cc:	000d4503          	lbu	a0,0(s10)
    802006d0:	02500793          	li	a5,37
    802006d4:	001d0413          	addi	s0,s10,1
    802006d8:	00f50e63          	beq	a0,a5,802006f4 <vprintfmt+0x62>
            if (ch == '\0') {
    802006dc:	c521                	beqz	a0,80200724 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006de:	02500993          	li	s3,37
    802006e2:	a011                	j	802006e6 <vprintfmt+0x54>
            if (ch == '\0') {
    802006e4:	c121                	beqz	a0,80200724 <vprintfmt+0x92>
            putch(ch, putdat);
    802006e6:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006e8:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    802006ea:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006ec:	fff44503          	lbu	a0,-1(s0)
    802006f0:	ff351ae3          	bne	a0,s3,802006e4 <vprintfmt+0x52>
    802006f4:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    802006f8:	02000793          	li	a5,32
        lflag = altflag = 0;
    802006fc:	4981                	li	s3,0
    802006fe:	4801                	li	a6,0
        width = precision = -1;
    80200700:	5cfd                	li	s9,-1
    80200702:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
    80200704:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
    80200708:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
    8020070a:	fdd6069b          	addiw	a3,a2,-35
    8020070e:	0ff6f693          	andi	a3,a3,255
    80200712:	00140d13          	addi	s10,s0,1
    80200716:	20d5e563          	bltu	a1,a3,80200920 <vprintfmt+0x28e>
    8020071a:	068a                	slli	a3,a3,0x2
    8020071c:	96d2                	add	a3,a3,s4
    8020071e:	4294                	lw	a3,0(a3)
    80200720:	96d2                	add	a3,a3,s4
    80200722:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    80200724:	70e6                	ld	ra,120(sp)
    80200726:	7446                	ld	s0,112(sp)
    80200728:	74a6                	ld	s1,104(sp)
    8020072a:	7906                	ld	s2,96(sp)
    8020072c:	69e6                	ld	s3,88(sp)
    8020072e:	6a46                	ld	s4,80(sp)
    80200730:	6aa6                	ld	s5,72(sp)
    80200732:	6b06                	ld	s6,64(sp)
    80200734:	7be2                	ld	s7,56(sp)
    80200736:	7c42                	ld	s8,48(sp)
    80200738:	7ca2                	ld	s9,40(sp)
    8020073a:	7d02                	ld	s10,32(sp)
    8020073c:	6de2                	ld	s11,24(sp)
    8020073e:	6109                	addi	sp,sp,128
    80200740:	8082                	ret
    if (lflag >= 2) {
    80200742:	4705                	li	a4,1
    80200744:	008a8593          	addi	a1,s5,8
    80200748:	01074463          	blt	a4,a6,80200750 <vprintfmt+0xbe>
    else if (lflag) {
    8020074c:	26080363          	beqz	a6,802009b2 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
    80200750:	000ab603          	ld	a2,0(s5)
    80200754:	46c1                	li	a3,16
    80200756:	8aae                	mv	s5,a1
    80200758:	a06d                	j	80200802 <vprintfmt+0x170>
            goto reswitch;
    8020075a:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    8020075e:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
    80200760:	846a                	mv	s0,s10
            goto reswitch;
    80200762:	b765                	j	8020070a <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
    80200764:	000aa503          	lw	a0,0(s5)
    80200768:	85a6                	mv	a1,s1
    8020076a:	0aa1                	addi	s5,s5,8
    8020076c:	9902                	jalr	s2
            break;
    8020076e:	bfb9                	j	802006cc <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200770:	4705                	li	a4,1
    80200772:	008a8993          	addi	s3,s5,8
    80200776:	01074463          	blt	a4,a6,8020077e <vprintfmt+0xec>
    else if (lflag) {
    8020077a:	22080463          	beqz	a6,802009a2 <vprintfmt+0x310>
        return va_arg(*ap, long);
    8020077e:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
    80200782:	24044463          	bltz	s0,802009ca <vprintfmt+0x338>
            num = getint(&ap, lflag);
    80200786:	8622                	mv	a2,s0
    80200788:	8ace                	mv	s5,s3
    8020078a:	46a9                	li	a3,10
    8020078c:	a89d                	j	80200802 <vprintfmt+0x170>
            err = va_arg(ap, int);
    8020078e:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200792:	4719                	li	a4,6
            err = va_arg(ap, int);
    80200794:	0aa1                	addi	s5,s5,8
            if (err < 0) {
    80200796:	41f7d69b          	sraiw	a3,a5,0x1f
    8020079a:	8fb5                	xor	a5,a5,a3
    8020079c:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802007a0:	1ad74363          	blt	a4,a3,80200946 <vprintfmt+0x2b4>
    802007a4:	00369793          	slli	a5,a3,0x3
    802007a8:	97e2                	add	a5,a5,s8
    802007aa:	639c                	ld	a5,0(a5)
    802007ac:	18078d63          	beqz	a5,80200946 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
    802007b0:	86be                	mv	a3,a5
    802007b2:	00001617          	auipc	a2,0x1
    802007b6:	b0e60613          	addi	a2,a2,-1266 # 802012c0 <error_string+0xe8>
    802007ba:	85a6                	mv	a1,s1
    802007bc:	854a                	mv	a0,s2
    802007be:	240000ef          	jal	ra,802009fe <printfmt>
    802007c2:	b729                	j	802006cc <vprintfmt+0x3a>
            lflag ++;
    802007c4:	00144603          	lbu	a2,1(s0)
    802007c8:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
    802007ca:	846a                	mv	s0,s10
            goto reswitch;
    802007cc:	bf3d                	j	8020070a <vprintfmt+0x78>
    if (lflag >= 2) {
    802007ce:	4705                	li	a4,1
    802007d0:	008a8593          	addi	a1,s5,8
    802007d4:	01074463          	blt	a4,a6,802007dc <vprintfmt+0x14a>
    else if (lflag) {
    802007d8:	1e080263          	beqz	a6,802009bc <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
    802007dc:	000ab603          	ld	a2,0(s5)
    802007e0:	46a1                	li	a3,8
    802007e2:	8aae                	mv	s5,a1
    802007e4:	a839                	j	80200802 <vprintfmt+0x170>
            putch('0', putdat);
    802007e6:	03000513          	li	a0,48
    802007ea:	85a6                	mv	a1,s1
    802007ec:	e03e                	sd	a5,0(sp)
    802007ee:	9902                	jalr	s2
            putch('x', putdat);
    802007f0:	85a6                	mv	a1,s1
    802007f2:	07800513          	li	a0,120
    802007f6:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    802007f8:	0aa1                	addi	s5,s5,8
    802007fa:	ff8ab603          	ld	a2,-8(s5)
            goto number;
    802007fe:	6782                	ld	a5,0(sp)
    80200800:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
    80200802:	876e                	mv	a4,s11
    80200804:	85a6                	mv	a1,s1
    80200806:	854a                	mv	a0,s2
    80200808:	e1fff0ef          	jal	ra,80200626 <printnum>
            break;
    8020080c:	b5c1                	j	802006cc <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
    8020080e:	000ab603          	ld	a2,0(s5)
    80200812:	0aa1                	addi	s5,s5,8
    80200814:	1c060663          	beqz	a2,802009e0 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
    80200818:	00160413          	addi	s0,a2,1
    8020081c:	17b05c63          	blez	s11,80200994 <vprintfmt+0x302>
    80200820:	02d00593          	li	a1,45
    80200824:	14b79263          	bne	a5,a1,80200968 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200828:	00064783          	lbu	a5,0(a2)
    8020082c:	0007851b          	sext.w	a0,a5
    80200830:	c905                	beqz	a0,80200860 <vprintfmt+0x1ce>
    80200832:	000cc563          	bltz	s9,8020083c <vprintfmt+0x1aa>
    80200836:	3cfd                	addiw	s9,s9,-1
    80200838:	036c8263          	beq	s9,s6,8020085c <vprintfmt+0x1ca>
                    putch('?', putdat);
    8020083c:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    8020083e:	18098463          	beqz	s3,802009c6 <vprintfmt+0x334>
    80200842:	3781                	addiw	a5,a5,-32
    80200844:	18fbf163          	bleu	a5,s7,802009c6 <vprintfmt+0x334>
                    putch('?', putdat);
    80200848:	03f00513          	li	a0,63
    8020084c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020084e:	0405                	addi	s0,s0,1
    80200850:	fff44783          	lbu	a5,-1(s0)
    80200854:	3dfd                	addiw	s11,s11,-1
    80200856:	0007851b          	sext.w	a0,a5
    8020085a:	fd61                	bnez	a0,80200832 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
    8020085c:	e7b058e3          	blez	s11,802006cc <vprintfmt+0x3a>
    80200860:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    80200862:	85a6                	mv	a1,s1
    80200864:	02000513          	li	a0,32
    80200868:	9902                	jalr	s2
            for (; width > 0; width --) {
    8020086a:	e60d81e3          	beqz	s11,802006cc <vprintfmt+0x3a>
    8020086e:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    80200870:	85a6                	mv	a1,s1
    80200872:	02000513          	li	a0,32
    80200876:	9902                	jalr	s2
            for (; width > 0; width --) {
    80200878:	fe0d94e3          	bnez	s11,80200860 <vprintfmt+0x1ce>
    8020087c:	bd81                	j	802006cc <vprintfmt+0x3a>
    if (lflag >= 2) {
    8020087e:	4705                	li	a4,1
    80200880:	008a8593          	addi	a1,s5,8
    80200884:	01074463          	blt	a4,a6,8020088c <vprintfmt+0x1fa>
    else if (lflag) {
    80200888:	12080063          	beqz	a6,802009a8 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
    8020088c:	000ab603          	ld	a2,0(s5)
    80200890:	46a9                	li	a3,10
    80200892:	8aae                	mv	s5,a1
    80200894:	b7bd                	j	80200802 <vprintfmt+0x170>
    80200896:	00144603          	lbu	a2,1(s0)
            padc = '-';
    8020089a:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
    8020089e:	846a                	mv	s0,s10
    802008a0:	b5ad                	j	8020070a <vprintfmt+0x78>
            putch(ch, putdat);
    802008a2:	85a6                	mv	a1,s1
    802008a4:	02500513          	li	a0,37
    802008a8:	9902                	jalr	s2
            break;
    802008aa:	b50d                	j	802006cc <vprintfmt+0x3a>
            precision = va_arg(ap, int);
    802008ac:	000aac83          	lw	s9,0(s5)
            goto process_precision;
    802008b0:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    802008b4:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
    802008b6:	846a                	mv	s0,s10
            if (width < 0)
    802008b8:	e40dd9e3          	bgez	s11,8020070a <vprintfmt+0x78>
                width = precision, precision = -1;
    802008bc:	8de6                	mv	s11,s9
    802008be:	5cfd                	li	s9,-1
    802008c0:	b5a9                	j	8020070a <vprintfmt+0x78>
            goto reswitch;
    802008c2:	00144603          	lbu	a2,1(s0)
            padc = '0';
    802008c6:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
    802008ca:	846a                	mv	s0,s10
            goto reswitch;
    802008cc:	bd3d                	j	8020070a <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
    802008ce:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
    802008d2:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    802008d6:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    802008d8:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    802008dc:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    802008e0:	fcd56ce3          	bltu	a0,a3,802008b8 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
    802008e4:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    802008e6:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
    802008ea:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
    802008ee:	0196873b          	addw	a4,a3,s9
    802008f2:	0017171b          	slliw	a4,a4,0x1
    802008f6:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
    802008fa:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
    802008fe:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
    80200902:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    80200906:	fcd57fe3          	bleu	a3,a0,802008e4 <vprintfmt+0x252>
    8020090a:	b77d                	j	802008b8 <vprintfmt+0x226>
            if (width < 0)
    8020090c:	fffdc693          	not	a3,s11
    80200910:	96fd                	srai	a3,a3,0x3f
    80200912:	00ddfdb3          	and	s11,s11,a3
    80200916:	00144603          	lbu	a2,1(s0)
    8020091a:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
    8020091c:	846a                	mv	s0,s10
    8020091e:	b3f5                	j	8020070a <vprintfmt+0x78>
            putch('%', putdat);
    80200920:	85a6                	mv	a1,s1
    80200922:	02500513          	li	a0,37
    80200926:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    80200928:	fff44703          	lbu	a4,-1(s0)
    8020092c:	02500793          	li	a5,37
    80200930:	8d22                	mv	s10,s0
    80200932:	d8f70de3          	beq	a4,a5,802006cc <vprintfmt+0x3a>
    80200936:	02500713          	li	a4,37
    8020093a:	1d7d                	addi	s10,s10,-1
    8020093c:	fffd4783          	lbu	a5,-1(s10)
    80200940:	fee79de3          	bne	a5,a4,8020093a <vprintfmt+0x2a8>
    80200944:	b361                	j	802006cc <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    80200946:	00001617          	auipc	a2,0x1
    8020094a:	96a60613          	addi	a2,a2,-1686 # 802012b0 <error_string+0xd8>
    8020094e:	85a6                	mv	a1,s1
    80200950:	854a                	mv	a0,s2
    80200952:	0ac000ef          	jal	ra,802009fe <printfmt>
    80200956:	bb9d                	j	802006cc <vprintfmt+0x3a>
                p = "(null)";
    80200958:	00001617          	auipc	a2,0x1
    8020095c:	95060613          	addi	a2,a2,-1712 # 802012a8 <error_string+0xd0>
            if (width > 0 && padc != '-') {
    80200960:	00001417          	auipc	s0,0x1
    80200964:	94940413          	addi	s0,s0,-1719 # 802012a9 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200968:	8532                	mv	a0,a2
    8020096a:	85e6                	mv	a1,s9
    8020096c:	e032                	sd	a2,0(sp)
    8020096e:	e43e                	sd	a5,8(sp)
    80200970:	c7fff0ef          	jal	ra,802005ee <strnlen>
    80200974:	40ad8dbb          	subw	s11,s11,a0
    80200978:	6602                	ld	a2,0(sp)
    8020097a:	01b05d63          	blez	s11,80200994 <vprintfmt+0x302>
    8020097e:	67a2                	ld	a5,8(sp)
    80200980:	2781                	sext.w	a5,a5
    80200982:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
    80200984:	6522                	ld	a0,8(sp)
    80200986:	85a6                	mv	a1,s1
    80200988:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
    8020098a:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    8020098c:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    8020098e:	6602                	ld	a2,0(sp)
    80200990:	fe0d9ae3          	bnez	s11,80200984 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200994:	00064783          	lbu	a5,0(a2)
    80200998:	0007851b          	sext.w	a0,a5
    8020099c:	e8051be3          	bnez	a0,80200832 <vprintfmt+0x1a0>
    802009a0:	b335                	j	802006cc <vprintfmt+0x3a>
        return va_arg(*ap, int);
    802009a2:	000aa403          	lw	s0,0(s5)
    802009a6:	bbf1                	j	80200782 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
    802009a8:	000ae603          	lwu	a2,0(s5)
    802009ac:	46a9                	li	a3,10
    802009ae:	8aae                	mv	s5,a1
    802009b0:	bd89                	j	80200802 <vprintfmt+0x170>
    802009b2:	000ae603          	lwu	a2,0(s5)
    802009b6:	46c1                	li	a3,16
    802009b8:	8aae                	mv	s5,a1
    802009ba:	b5a1                	j	80200802 <vprintfmt+0x170>
    802009bc:	000ae603          	lwu	a2,0(s5)
    802009c0:	46a1                	li	a3,8
    802009c2:	8aae                	mv	s5,a1
    802009c4:	bd3d                	j	80200802 <vprintfmt+0x170>
                    putch(ch, putdat);
    802009c6:	9902                	jalr	s2
    802009c8:	b559                	j	8020084e <vprintfmt+0x1bc>
                putch('-', putdat);
    802009ca:	85a6                	mv	a1,s1
    802009cc:	02d00513          	li	a0,45
    802009d0:	e03e                	sd	a5,0(sp)
    802009d2:	9902                	jalr	s2
                num = -(long long)num;
    802009d4:	8ace                	mv	s5,s3
    802009d6:	40800633          	neg	a2,s0
    802009da:	46a9                	li	a3,10
    802009dc:	6782                	ld	a5,0(sp)
    802009de:	b515                	j	80200802 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
    802009e0:	01b05663          	blez	s11,802009ec <vprintfmt+0x35a>
    802009e4:	02d00693          	li	a3,45
    802009e8:	f6d798e3          	bne	a5,a3,80200958 <vprintfmt+0x2c6>
    802009ec:	00001417          	auipc	s0,0x1
    802009f0:	8bd40413          	addi	s0,s0,-1859 # 802012a9 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802009f4:	02800513          	li	a0,40
    802009f8:	02800793          	li	a5,40
    802009fc:	bd1d                	j	80200832 <vprintfmt+0x1a0>

00000000802009fe <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009fe:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    80200a00:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200a04:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    80200a06:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200a08:	ec06                	sd	ra,24(sp)
    80200a0a:	f83a                	sd	a4,48(sp)
    80200a0c:	fc3e                	sd	a5,56(sp)
    80200a0e:	e0c2                	sd	a6,64(sp)
    80200a10:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    80200a12:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    80200a14:	c7fff0ef          	jal	ra,80200692 <vprintfmt>
}
    80200a18:	60e2                	ld	ra,24(sp)
    80200a1a:	6161                	addi	sp,sp,80
    80200a1c:	8082                	ret

0000000080200a1e <sbi_console_putchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
    80200a1e:	00003797          	auipc	a5,0x3
    80200a22:	5e278793          	addi	a5,a5,1506 # 80204000 <bootstacktop>
    __asm__ volatile (
    80200a26:	6398                	ld	a4,0(a5)
    80200a28:	4781                	li	a5,0
    80200a2a:	88ba                	mv	a7,a4
    80200a2c:	852a                	mv	a0,a0
    80200a2e:	85be                	mv	a1,a5
    80200a30:	863e                	mv	a2,a5
    80200a32:	00000073          	ecall
    80200a36:	87aa                	mv	a5,a0
}
    80200a38:	8082                	ret

0000000080200a3a <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
    80200a3a:	00003797          	auipc	a5,0x3
    80200a3e:	5de78793          	addi	a5,a5,1502 # 80204018 <SBI_SET_TIMER>
    __asm__ volatile (
    80200a42:	6398                	ld	a4,0(a5)
    80200a44:	4781                	li	a5,0
    80200a46:	88ba                	mv	a7,a4
    80200a48:	852a                	mv	a0,a0
    80200a4a:	85be                	mv	a1,a5
    80200a4c:	863e                	mv	a2,a5
    80200a4e:	00000073          	ecall
    80200a52:	87aa                	mv	a5,a0
}
    80200a54:	8082                	ret

0000000080200a56 <sbi_shutdown>:


void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
    80200a56:	00003797          	auipc	a5,0x3
    80200a5a:	5b278793          	addi	a5,a5,1458 # 80204008 <SBI_SHUTDOWN>
    __asm__ volatile (
    80200a5e:	6398                	ld	a4,0(a5)
    80200a60:	4781                	li	a5,0
    80200a62:	88ba                	mv	a7,a4
    80200a64:	853e                	mv	a0,a5
    80200a66:	85be                	mv	a1,a5
    80200a68:	863e                	mv	a2,a5
    80200a6a:	00000073          	ecall
    80200a6e:	87aa                	mv	a5,a0
    80200a70:	8082                	ret
