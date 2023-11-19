
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
#include <memlayout.h>

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    la sp, bootstacktop
    80200000:	00003117          	auipc	sp,0x3
    80200004:	00010113          	mv	sp,sp

    tail kern_init
    80200008:	0040006f          	j	8020000c <kern_init>

000000008020000c <kern_init>:
#include <sbi.h>
int kern_init(void) __attribute__((noreturn));

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    8020000c:	00003517          	auipc	a0,0x3
    80200010:	ffc50513          	addi	a0,a0,-4 # 80203008 <edata>
    80200014:	00003617          	auipc	a2,0x3
    80200018:	ff460613          	addi	a2,a2,-12 # 80203008 <edata>
int kern_init(void) {
    8020001c:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
    8020001e:	4581                	li	a1,0
    80200020:	8e09                	sub	a2,a2,a0
int kern_init(void) {
    80200022:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
    80200024:	096000ef          	jal	ra,802000ba <memset>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    80200028:	00000597          	auipc	a1,0x0
    8020002c:	4b858593          	addi	a1,a1,1208 # 802004e0 <sbi_console_putchar+0x1c>
    80200030:	00000517          	auipc	a0,0x0
    80200034:	4d050513          	addi	a0,a0,1232 # 80200500 <sbi_console_putchar+0x3c>
    80200038:	020000ef          	jal	ra,80200058 <cprintf>
   while (1)
        ;
    8020003c:	a001                	j	8020003c <kern_init+0x30>

000000008020003e <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
    8020003e:	1141                	addi	sp,sp,-16
    80200040:	e022                	sd	s0,0(sp)
    80200042:	e406                	sd	ra,8(sp)
    80200044:	842e                	mv	s0,a1
    cons_putc(c);
    80200046:	046000ef          	jal	ra,8020008c <cons_putc>
    (*cnt)++;
    8020004a:	401c                	lw	a5,0(s0)
}
    8020004c:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    8020004e:	2785                	addiw	a5,a5,1
    80200050:	c01c                	sw	a5,0(s0)
}
    80200052:	6402                	ld	s0,0(sp)
    80200054:	0141                	addi	sp,sp,16
    80200056:	8082                	ret

0000000080200058 <cprintf>:
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
    80200058:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    8020005a:	02810313          	addi	t1,sp,40 # 80203028 <edata+0x20>
int cprintf(const char *fmt, ...) {
    8020005e:	f42e                	sd	a1,40(sp)
    80200060:	f832                	sd	a2,48(sp)
    80200062:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200064:	862a                	mv	a2,a0
    80200066:	004c                	addi	a1,sp,4
    80200068:	00000517          	auipc	a0,0x0
    8020006c:	fd650513          	addi	a0,a0,-42 # 8020003e <cputch>
    80200070:	869a                	mv	a3,t1
int cprintf(const char *fmt, ...) {
    80200072:	ec06                	sd	ra,24(sp)
    80200074:	e0ba                	sd	a4,64(sp)
    80200076:	e4be                	sd	a5,72(sp)
    80200078:	e8c2                	sd	a6,80(sp)
    8020007a:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    8020007c:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    8020007e:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200080:	0b8000ef          	jal	ra,80200138 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    80200084:	60e2                	ld	ra,24(sp)
    80200086:	4512                	lw	a0,4(sp)
    80200088:	6125                	addi	sp,sp,96
    8020008a:	8082                	ret

000000008020008c <cons_putc>:

/* cons_init - initializes the console devices */
void cons_init(void) {}

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    8020008c:	0ff57513          	andi	a0,a0,255
    80200090:	4340006f          	j	802004c4 <sbi_console_putchar>

0000000080200094 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
    80200094:	c185                	beqz	a1,802000b4 <strnlen+0x20>
    80200096:	00054783          	lbu	a5,0(a0)
    8020009a:	cf89                	beqz	a5,802000b4 <strnlen+0x20>
    size_t cnt = 0;
    8020009c:	4781                	li	a5,0
    8020009e:	a021                	j	802000a6 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
    802000a0:	00074703          	lbu	a4,0(a4)
    802000a4:	c711                	beqz	a4,802000b0 <strnlen+0x1c>
        cnt ++;
    802000a6:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    802000a8:	00f50733          	add	a4,a0,a5
    802000ac:	fef59ae3          	bne	a1,a5,802000a0 <strnlen+0xc>
    }
    return cnt;
}
    802000b0:	853e                	mv	a0,a5
    802000b2:	8082                	ret
    size_t cnt = 0;
    802000b4:	4781                	li	a5,0
}
    802000b6:	853e                	mv	a0,a5
    802000b8:	8082                	ret

00000000802000ba <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    802000ba:	ca01                	beqz	a2,802000ca <memset+0x10>
    802000bc:	962a                	add	a2,a2,a0
    char *p = s;
    802000be:	87aa                	mv	a5,a0
        *p ++ = c;
    802000c0:	0785                	addi	a5,a5,1
    802000c2:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    802000c6:	fec79de3          	bne	a5,a2,802000c0 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    802000ca:	8082                	ret

00000000802000cc <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    802000cc:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802000d0:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    802000d2:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802000d6:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    802000d8:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    802000dc:	f022                	sd	s0,32(sp)
    802000de:	ec26                	sd	s1,24(sp)
    802000e0:	e84a                	sd	s2,16(sp)
    802000e2:	f406                	sd	ra,40(sp)
    802000e4:	e44e                	sd	s3,8(sp)
    802000e6:	84aa                	mv	s1,a0
    802000e8:	892e                	mv	s2,a1
    802000ea:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    802000ee:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
    802000f0:	03067e63          	bleu	a6,a2,8020012c <printnum+0x60>
    802000f4:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    802000f6:	00805763          	blez	s0,80200104 <printnum+0x38>
    802000fa:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    802000fc:	85ca                	mv	a1,s2
    802000fe:	854e                	mv	a0,s3
    80200100:	9482                	jalr	s1
        while (-- width > 0)
    80200102:	fc65                	bnez	s0,802000fa <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    80200104:	1a02                	slli	s4,s4,0x20
    80200106:	020a5a13          	srli	s4,s4,0x20
    8020010a:	00000797          	auipc	a5,0x0
    8020010e:	58e78793          	addi	a5,a5,1422 # 80200698 <error_string+0x38>
    80200112:	9a3e                	add	s4,s4,a5
}
    80200114:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200116:	000a4503          	lbu	a0,0(s4)
}
    8020011a:	70a2                	ld	ra,40(sp)
    8020011c:	69a2                	ld	s3,8(sp)
    8020011e:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200120:	85ca                	mv	a1,s2
    80200122:	8326                	mv	t1,s1
}
    80200124:	6942                	ld	s2,16(sp)
    80200126:	64e2                	ld	s1,24(sp)
    80200128:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    8020012a:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
    8020012c:	03065633          	divu	a2,a2,a6
    80200130:	8722                	mv	a4,s0
    80200132:	f9bff0ef          	jal	ra,802000cc <printnum>
    80200136:	b7f9                	j	80200104 <printnum+0x38>

0000000080200138 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    80200138:	7119                	addi	sp,sp,-128
    8020013a:	f4a6                	sd	s1,104(sp)
    8020013c:	f0ca                	sd	s2,96(sp)
    8020013e:	e8d2                	sd	s4,80(sp)
    80200140:	e4d6                	sd	s5,72(sp)
    80200142:	e0da                	sd	s6,64(sp)
    80200144:	fc5e                	sd	s7,56(sp)
    80200146:	f862                	sd	s8,48(sp)
    80200148:	f06a                	sd	s10,32(sp)
    8020014a:	fc86                	sd	ra,120(sp)
    8020014c:	f8a2                	sd	s0,112(sp)
    8020014e:	ecce                	sd	s3,88(sp)
    80200150:	f466                	sd	s9,40(sp)
    80200152:	ec6e                	sd	s11,24(sp)
    80200154:	892a                	mv	s2,a0
    80200156:	84ae                	mv	s1,a1
    80200158:	8d32                	mv	s10,a2
    8020015a:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    8020015c:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
    8020015e:	00000a17          	auipc	s4,0x0
    80200162:	3aaa0a13          	addi	s4,s4,938 # 80200508 <sbi_console_putchar+0x44>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
    80200166:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    8020016a:	00000c17          	auipc	s8,0x0
    8020016e:	4f6c0c13          	addi	s8,s8,1270 # 80200660 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200172:	000d4503          	lbu	a0,0(s10)
    80200176:	02500793          	li	a5,37
    8020017a:	001d0413          	addi	s0,s10,1
    8020017e:	00f50e63          	beq	a0,a5,8020019a <vprintfmt+0x62>
            if (ch == '\0') {
    80200182:	c521                	beqz	a0,802001ca <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200184:	02500993          	li	s3,37
    80200188:	a011                	j	8020018c <vprintfmt+0x54>
            if (ch == '\0') {
    8020018a:	c121                	beqz	a0,802001ca <vprintfmt+0x92>
            putch(ch, putdat);
    8020018c:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    8020018e:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    80200190:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200192:	fff44503          	lbu	a0,-1(s0)
    80200196:	ff351ae3          	bne	a0,s3,8020018a <vprintfmt+0x52>
    8020019a:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    8020019e:	02000793          	li	a5,32
        lflag = altflag = 0;
    802001a2:	4981                	li	s3,0
    802001a4:	4801                	li	a6,0
        width = precision = -1;
    802001a6:	5cfd                	li	s9,-1
    802001a8:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
    802001aa:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
    802001ae:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
    802001b0:	fdd6069b          	addiw	a3,a2,-35
    802001b4:	0ff6f693          	andi	a3,a3,255
    802001b8:	00140d13          	addi	s10,s0,1
    802001bc:	20d5e563          	bltu	a1,a3,802003c6 <vprintfmt+0x28e>
    802001c0:	068a                	slli	a3,a3,0x2
    802001c2:	96d2                	add	a3,a3,s4
    802001c4:	4294                	lw	a3,0(a3)
    802001c6:	96d2                	add	a3,a3,s4
    802001c8:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    802001ca:	70e6                	ld	ra,120(sp)
    802001cc:	7446                	ld	s0,112(sp)
    802001ce:	74a6                	ld	s1,104(sp)
    802001d0:	7906                	ld	s2,96(sp)
    802001d2:	69e6                	ld	s3,88(sp)
    802001d4:	6a46                	ld	s4,80(sp)
    802001d6:	6aa6                	ld	s5,72(sp)
    802001d8:	6b06                	ld	s6,64(sp)
    802001da:	7be2                	ld	s7,56(sp)
    802001dc:	7c42                	ld	s8,48(sp)
    802001de:	7ca2                	ld	s9,40(sp)
    802001e0:	7d02                	ld	s10,32(sp)
    802001e2:	6de2                	ld	s11,24(sp)
    802001e4:	6109                	addi	sp,sp,128
    802001e6:	8082                	ret
    if (lflag >= 2) {
    802001e8:	4705                	li	a4,1
    802001ea:	008a8593          	addi	a1,s5,8
    802001ee:	01074463          	blt	a4,a6,802001f6 <vprintfmt+0xbe>
    else if (lflag) {
    802001f2:	26080363          	beqz	a6,80200458 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
    802001f6:	000ab603          	ld	a2,0(s5)
    802001fa:	46c1                	li	a3,16
    802001fc:	8aae                	mv	s5,a1
    802001fe:	a06d                	j	802002a8 <vprintfmt+0x170>
            goto reswitch;
    80200200:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    80200204:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
    80200206:	846a                	mv	s0,s10
            goto reswitch;
    80200208:	b765                	j	802001b0 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
    8020020a:	000aa503          	lw	a0,0(s5)
    8020020e:	85a6                	mv	a1,s1
    80200210:	0aa1                	addi	s5,s5,8
    80200212:	9902                	jalr	s2
            break;
    80200214:	bfb9                	j	80200172 <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200216:	4705                	li	a4,1
    80200218:	008a8993          	addi	s3,s5,8
    8020021c:	01074463          	blt	a4,a6,80200224 <vprintfmt+0xec>
    else if (lflag) {
    80200220:	22080463          	beqz	a6,80200448 <vprintfmt+0x310>
        return va_arg(*ap, long);
    80200224:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
    80200228:	24044463          	bltz	s0,80200470 <vprintfmt+0x338>
            num = getint(&ap, lflag);
    8020022c:	8622                	mv	a2,s0
    8020022e:	8ace                	mv	s5,s3
    80200230:	46a9                	li	a3,10
    80200232:	a89d                	j	802002a8 <vprintfmt+0x170>
            err = va_arg(ap, int);
    80200234:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200238:	4719                	li	a4,6
            err = va_arg(ap, int);
    8020023a:	0aa1                	addi	s5,s5,8
            if (err < 0) {
    8020023c:	41f7d69b          	sraiw	a3,a5,0x1f
    80200240:	8fb5                	xor	a5,a5,a3
    80200242:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200246:	1ad74363          	blt	a4,a3,802003ec <vprintfmt+0x2b4>
    8020024a:	00369793          	slli	a5,a3,0x3
    8020024e:	97e2                	add	a5,a5,s8
    80200250:	639c                	ld	a5,0(a5)
    80200252:	18078d63          	beqz	a5,802003ec <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
    80200256:	86be                	mv	a3,a5
    80200258:	00000617          	auipc	a2,0x0
    8020025c:	4f060613          	addi	a2,a2,1264 # 80200748 <error_string+0xe8>
    80200260:	85a6                	mv	a1,s1
    80200262:	854a                	mv	a0,s2
    80200264:	240000ef          	jal	ra,802004a4 <printfmt>
    80200268:	b729                	j	80200172 <vprintfmt+0x3a>
            lflag ++;
    8020026a:	00144603          	lbu	a2,1(s0)
    8020026e:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
    80200270:	846a                	mv	s0,s10
            goto reswitch;
    80200272:	bf3d                	j	802001b0 <vprintfmt+0x78>
    if (lflag >= 2) {
    80200274:	4705                	li	a4,1
    80200276:	008a8593          	addi	a1,s5,8
    8020027a:	01074463          	blt	a4,a6,80200282 <vprintfmt+0x14a>
    else if (lflag) {
    8020027e:	1e080263          	beqz	a6,80200462 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
    80200282:	000ab603          	ld	a2,0(s5)
    80200286:	46a1                	li	a3,8
    80200288:	8aae                	mv	s5,a1
    8020028a:	a839                	j	802002a8 <vprintfmt+0x170>
            putch('0', putdat);
    8020028c:	03000513          	li	a0,48
    80200290:	85a6                	mv	a1,s1
    80200292:	e03e                	sd	a5,0(sp)
    80200294:	9902                	jalr	s2
            putch('x', putdat);
    80200296:	85a6                	mv	a1,s1
    80200298:	07800513          	li	a0,120
    8020029c:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    8020029e:	0aa1                	addi	s5,s5,8
    802002a0:	ff8ab603          	ld	a2,-8(s5)
            goto number;
    802002a4:	6782                	ld	a5,0(sp)
    802002a6:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
    802002a8:	876e                	mv	a4,s11
    802002aa:	85a6                	mv	a1,s1
    802002ac:	854a                	mv	a0,s2
    802002ae:	e1fff0ef          	jal	ra,802000cc <printnum>
            break;
    802002b2:	b5c1                	j	80200172 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
    802002b4:	000ab603          	ld	a2,0(s5)
    802002b8:	0aa1                	addi	s5,s5,8
    802002ba:	1c060663          	beqz	a2,80200486 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
    802002be:	00160413          	addi	s0,a2,1
    802002c2:	17b05c63          	blez	s11,8020043a <vprintfmt+0x302>
    802002c6:	02d00593          	li	a1,45
    802002ca:	14b79263          	bne	a5,a1,8020040e <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802002ce:	00064783          	lbu	a5,0(a2)
    802002d2:	0007851b          	sext.w	a0,a5
    802002d6:	c905                	beqz	a0,80200306 <vprintfmt+0x1ce>
    802002d8:	000cc563          	bltz	s9,802002e2 <vprintfmt+0x1aa>
    802002dc:	3cfd                	addiw	s9,s9,-1
    802002de:	036c8263          	beq	s9,s6,80200302 <vprintfmt+0x1ca>
                    putch('?', putdat);
    802002e2:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    802002e4:	18098463          	beqz	s3,8020046c <vprintfmt+0x334>
    802002e8:	3781                	addiw	a5,a5,-32
    802002ea:	18fbf163          	bleu	a5,s7,8020046c <vprintfmt+0x334>
                    putch('?', putdat);
    802002ee:	03f00513          	li	a0,63
    802002f2:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802002f4:	0405                	addi	s0,s0,1
    802002f6:	fff44783          	lbu	a5,-1(s0)
    802002fa:	3dfd                	addiw	s11,s11,-1
    802002fc:	0007851b          	sext.w	a0,a5
    80200300:	fd61                	bnez	a0,802002d8 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
    80200302:	e7b058e3          	blez	s11,80200172 <vprintfmt+0x3a>
    80200306:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    80200308:	85a6                	mv	a1,s1
    8020030a:	02000513          	li	a0,32
    8020030e:	9902                	jalr	s2
            for (; width > 0; width --) {
    80200310:	e60d81e3          	beqz	s11,80200172 <vprintfmt+0x3a>
    80200314:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    80200316:	85a6                	mv	a1,s1
    80200318:	02000513          	li	a0,32
    8020031c:	9902                	jalr	s2
            for (; width > 0; width --) {
    8020031e:	fe0d94e3          	bnez	s11,80200306 <vprintfmt+0x1ce>
    80200322:	bd81                	j	80200172 <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200324:	4705                	li	a4,1
    80200326:	008a8593          	addi	a1,s5,8
    8020032a:	01074463          	blt	a4,a6,80200332 <vprintfmt+0x1fa>
    else if (lflag) {
    8020032e:	12080063          	beqz	a6,8020044e <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
    80200332:	000ab603          	ld	a2,0(s5)
    80200336:	46a9                	li	a3,10
    80200338:	8aae                	mv	s5,a1
    8020033a:	b7bd                	j	802002a8 <vprintfmt+0x170>
    8020033c:	00144603          	lbu	a2,1(s0)
            padc = '-';
    80200340:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
    80200344:	846a                	mv	s0,s10
    80200346:	b5ad                	j	802001b0 <vprintfmt+0x78>
            putch(ch, putdat);
    80200348:	85a6                	mv	a1,s1
    8020034a:	02500513          	li	a0,37
    8020034e:	9902                	jalr	s2
            break;
    80200350:	b50d                	j	80200172 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
    80200352:	000aac83          	lw	s9,0(s5)
            goto process_precision;
    80200356:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    8020035a:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
    8020035c:	846a                	mv	s0,s10
            if (width < 0)
    8020035e:	e40dd9e3          	bgez	s11,802001b0 <vprintfmt+0x78>
                width = precision, precision = -1;
    80200362:	8de6                	mv	s11,s9
    80200364:	5cfd                	li	s9,-1
    80200366:	b5a9                	j	802001b0 <vprintfmt+0x78>
            goto reswitch;
    80200368:	00144603          	lbu	a2,1(s0)
            padc = '0';
    8020036c:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
    80200370:	846a                	mv	s0,s10
            goto reswitch;
    80200372:	bd3d                	j	802001b0 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
    80200374:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
    80200378:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    8020037c:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    8020037e:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    80200382:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    80200386:	fcd56ce3          	bltu	a0,a3,8020035e <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
    8020038a:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    8020038c:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
    80200390:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
    80200394:	0196873b          	addw	a4,a3,s9
    80200398:	0017171b          	slliw	a4,a4,0x1
    8020039c:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
    802003a0:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
    802003a4:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
    802003a8:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    802003ac:	fcd57fe3          	bleu	a3,a0,8020038a <vprintfmt+0x252>
    802003b0:	b77d                	j	8020035e <vprintfmt+0x226>
            if (width < 0)
    802003b2:	fffdc693          	not	a3,s11
    802003b6:	96fd                	srai	a3,a3,0x3f
    802003b8:	00ddfdb3          	and	s11,s11,a3
    802003bc:	00144603          	lbu	a2,1(s0)
    802003c0:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
    802003c2:	846a                	mv	s0,s10
    802003c4:	b3f5                	j	802001b0 <vprintfmt+0x78>
            putch('%', putdat);
    802003c6:	85a6                	mv	a1,s1
    802003c8:	02500513          	li	a0,37
    802003cc:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    802003ce:	fff44703          	lbu	a4,-1(s0)
    802003d2:	02500793          	li	a5,37
    802003d6:	8d22                	mv	s10,s0
    802003d8:	d8f70de3          	beq	a4,a5,80200172 <vprintfmt+0x3a>
    802003dc:	02500713          	li	a4,37
    802003e0:	1d7d                	addi	s10,s10,-1
    802003e2:	fffd4783          	lbu	a5,-1(s10)
    802003e6:	fee79de3          	bne	a5,a4,802003e0 <vprintfmt+0x2a8>
    802003ea:	b361                	j	80200172 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    802003ec:	00000617          	auipc	a2,0x0
    802003f0:	34c60613          	addi	a2,a2,844 # 80200738 <error_string+0xd8>
    802003f4:	85a6                	mv	a1,s1
    802003f6:	854a                	mv	a0,s2
    802003f8:	0ac000ef          	jal	ra,802004a4 <printfmt>
    802003fc:	bb9d                	j	80200172 <vprintfmt+0x3a>
                p = "(null)";
    802003fe:	00000617          	auipc	a2,0x0
    80200402:	33260613          	addi	a2,a2,818 # 80200730 <error_string+0xd0>
            if (width > 0 && padc != '-') {
    80200406:	00000417          	auipc	s0,0x0
    8020040a:	32b40413          	addi	s0,s0,811 # 80200731 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
    8020040e:	8532                	mv	a0,a2
    80200410:	85e6                	mv	a1,s9
    80200412:	e032                	sd	a2,0(sp)
    80200414:	e43e                	sd	a5,8(sp)
    80200416:	c7fff0ef          	jal	ra,80200094 <strnlen>
    8020041a:	40ad8dbb          	subw	s11,s11,a0
    8020041e:	6602                	ld	a2,0(sp)
    80200420:	01b05d63          	blez	s11,8020043a <vprintfmt+0x302>
    80200424:	67a2                	ld	a5,8(sp)
    80200426:	2781                	sext.w	a5,a5
    80200428:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
    8020042a:	6522                	ld	a0,8(sp)
    8020042c:	85a6                	mv	a1,s1
    8020042e:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200430:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    80200432:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200434:	6602                	ld	a2,0(sp)
    80200436:	fe0d9ae3          	bnez	s11,8020042a <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020043a:	00064783          	lbu	a5,0(a2)
    8020043e:	0007851b          	sext.w	a0,a5
    80200442:	e8051be3          	bnez	a0,802002d8 <vprintfmt+0x1a0>
    80200446:	b335                	j	80200172 <vprintfmt+0x3a>
        return va_arg(*ap, int);
    80200448:	000aa403          	lw	s0,0(s5)
    8020044c:	bbf1                	j	80200228 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
    8020044e:	000ae603          	lwu	a2,0(s5)
    80200452:	46a9                	li	a3,10
    80200454:	8aae                	mv	s5,a1
    80200456:	bd89                	j	802002a8 <vprintfmt+0x170>
    80200458:	000ae603          	lwu	a2,0(s5)
    8020045c:	46c1                	li	a3,16
    8020045e:	8aae                	mv	s5,a1
    80200460:	b5a1                	j	802002a8 <vprintfmt+0x170>
    80200462:	000ae603          	lwu	a2,0(s5)
    80200466:	46a1                	li	a3,8
    80200468:	8aae                	mv	s5,a1
    8020046a:	bd3d                	j	802002a8 <vprintfmt+0x170>
                    putch(ch, putdat);
    8020046c:	9902                	jalr	s2
    8020046e:	b559                	j	802002f4 <vprintfmt+0x1bc>
                putch('-', putdat);
    80200470:	85a6                	mv	a1,s1
    80200472:	02d00513          	li	a0,45
    80200476:	e03e                	sd	a5,0(sp)
    80200478:	9902                	jalr	s2
                num = -(long long)num;
    8020047a:	8ace                	mv	s5,s3
    8020047c:	40800633          	neg	a2,s0
    80200480:	46a9                	li	a3,10
    80200482:	6782                	ld	a5,0(sp)
    80200484:	b515                	j	802002a8 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
    80200486:	01b05663          	blez	s11,80200492 <vprintfmt+0x35a>
    8020048a:	02d00693          	li	a3,45
    8020048e:	f6d798e3          	bne	a5,a3,802003fe <vprintfmt+0x2c6>
    80200492:	00000417          	auipc	s0,0x0
    80200496:	29f40413          	addi	s0,s0,671 # 80200731 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020049a:	02800513          	li	a0,40
    8020049e:	02800793          	li	a5,40
    802004a2:	bd1d                	j	802002d8 <vprintfmt+0x1a0>

00000000802004a4 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802004a4:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    802004a6:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802004aa:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    802004ac:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802004ae:	ec06                	sd	ra,24(sp)
    802004b0:	f83a                	sd	a4,48(sp)
    802004b2:	fc3e                	sd	a5,56(sp)
    802004b4:	e0c2                	sd	a6,64(sp)
    802004b6:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    802004b8:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    802004ba:	c7fff0ef          	jal	ra,80200138 <vprintfmt>
}
    802004be:	60e2                	ld	ra,24(sp)
    802004c0:	6161                	addi	sp,sp,80
    802004c2:	8082                	ret

00000000802004c4 <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
    802004c4:	00003797          	auipc	a5,0x3
    802004c8:	b3c78793          	addi	a5,a5,-1220 # 80203000 <bootstacktop>
    __asm__ volatile (
    802004cc:	6398                	ld	a4,0(a5)
    802004ce:	4781                	li	a5,0
    802004d0:	88ba                	mv	a7,a4
    802004d2:	852a                	mv	a0,a0
    802004d4:	85be                	mv	a1,a5
    802004d6:	863e                	mv	a2,a5
    802004d8:	00000073          	ecall
    802004dc:	87aa                	mv	a5,a0
}
    802004de:	8082                	ret
