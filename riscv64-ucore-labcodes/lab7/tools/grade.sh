#!/bin/sh

verbose=false
if [ "x$1" = "x-v" ]; then
    verbose=true
    out=/dev/stdout
    err=/dev/stderr
else
    out=/dev/null
    err=/dev/null
fi

## make & makeopts
if gmake --version > /dev/null 2>&1; then
    make=gmake;
else
    make=make;
fi

makeopts="--quiet --no-print-directory -j"

make_print() {
    echo `$make $makeopts print-$1`
}

## command tools
awk='awk'
bc='bc'
date='date'
grep='grep'
rm='rm -f'
sed='sed'

## symbol table
sym_table='obj/kernel.sym'

## gdb & gdbopts
gdb="$(make_print GDB)"
gdbport='1234'

gdb_in="$(make_print GRADE_GDB_IN)"

## qemu & qemuopts
qemu="$(make_print qemu)"

qemu_out="$(make_print GRADE_QEMU_OUT)"

if $qemu -nographic -help | grep -q '^-gdb'; then
    qemugdb="-gdb tcp::$gdbport"
else
    qemugdb="-s -p $gdbport"
fi

## default variables
default_timeout=30
default_pts=5

pts=5
part=0
part_pos=0
total=0
total_pos=0

## default functions
update_score() {
    total=`expr $total + $part`
    total_pos=`expr $total_pos + $part_pos`
    part=0
    part_pos=0
}

get_time() {
    echo `$date +%s.%N 2> /dev/null`
}

show_part() {
    echo "Part $1 Score: $part/$part_pos"
    echo
    update_score
}

show_final() {
    update_score
    echo "Total Score: $total/$total_pos"
    if [ $total -lt $total_pos ]; then
        exit 1
    fi
}

show_time() {
    t1=$(get_time)
    time=`echo "scale=1; ($t1-$t0)/1" | $sed 's/.N/.0/g' | $bc 2> /dev/null`
    echo "(${time}s)"
}

show_build_tag() {
    echo "$1:" | $awk '{printf "%-24s ", $0}'
}

show_check_tag() {
    echo "$1:" | $awk '{printf "  -%-40s  ", $0}'
}

show_msg() {
    echo $1
    shift
    if [ $# -gt 0 ]; then
        echo -e "$@" | awk '{printf "   %s\n", $0}'
        echo
    fi
}

pass() {
    show_msg OK "$@"
    part=`expr $part + $pts`
    part_pos=`expr $part_pos + $pts`
}

fail() {
    show_msg WRONG "$@"
    part_pos=`expr $part_pos + $pts`
}

run_qemu() {
    # Run qemu with serial output redirected to $qemu_out. If $brkfun is non-empty,
    # wait until $brkfun is reached or $timeout expires, then kill QEMU
    qemuextra=
    if [ "$brkfun" ]; then
        qemuextra="-S $qemugdb"
    fi

    if [ -z "$timeout" ] || [ $timeout -le 0 ]; then
        timeout=$default_timeout;
    fi

    t0=$(get_time)
    (
        ulimit -t $timeout
        exec $qemu -nographic $qemuopts -serial file:$qemu_out -monitor null -no-reboot $qemuextra
    ) > $out 2> $err &
    pid=$!

    # wait for QEMU to start
    sleep 1

    if [ -n "$brkfun" ]; then
        # find the address of the kernel $brkfun function
        brkaddr=`$grep " $brkfun\$" $sym_table | $sed -e's/ .*$//g'`
        brkaddr_phys=`echo $brkaddr | sed "s/^c0/00/g"`
        (
            echo "target remote localhost:$gdbport"
            echo "break *0x$brkaddr"
            if [ "$brkaddr" != "$brkaddr_phys" ]; then
                echo "break *0x$brkaddr_phys"
            fi
            echo "continue"
        ) > $gdb_in

        $gdb -batch -nx -x $gdb_in > /dev/null 2>&1

        # make sure that QEMU is dead
        # on OS X, exiting gdb doesn't always exit qemu
        kill $pid > /dev/null 2>&1
    fi
}

build_run() {
    # usage: build_run <tag> <args>
    show_build_tag "$1"
    shift

    if $verbose; then
        echo "$make $@ ..."
    fi
    $make $makeopts $@ 'DEFS+=-DDEBUG_GRADE' > $out 2> $err

    if [ $? -ne 0 ]; then
        echo $make $@ failed
        exit 1
    fi

    # now run qemu and save the output
    run_qemu

    show_time

    cp $qemu_out .`echo $tag | tr '[:upper:]' '[:lower:]' | sed 's/ /_/g'`.log
}

check_result() {
    # usage: check_result <tag> <check> <check args...>
    show_check_tag "$1"
    shift

    # give qemu some time to run (for asynchronous mode)
    if [ ! -s $qemu_out ]; then
        sleep 4
    fi

    if [ ! -s $qemu_out ]; then
        fail > /dev/null
        echo 'no $qemu_out'
    else
        check=$1
        shift
        $check "$@"
    fi
}

check_regexps() {
    okay=yes
    not=0
    reg=0
    error=
    for i do
        if [ "x$i" = "x!" ]; then
            not=1
        elif [ "x$i" = "x-" ]; then
            reg=1
        else
            if [ $reg -ne 0 ]; then
                $grep '-E' "^$i\$" $qemu_out > /dev/null
            else
                $grep '-F' "$i" $qemu_out > /dev/null
            fi
            found=$(($? == 0))
            if [ $found -eq $not ]; then
                if [ $found -eq 0 ]; then
                    msg="!! error: missing '$i'"
                else
                    msg="!! error: got unexpected line '$i'"
                fi
                okay=no
                if [ -z "$error" ]; then
                    error="$msg"
                else
                    error="$error\n$msg"
                fi
            fi
            not=0
            reg=0
        fi
    done
    if [ "$okay" = "yes" ]; then
        pass
    else
        fail "$error"
        if $verbose; then
            exit 1
        fi
    fi
}

run_test() {
    # usage: run_test [-tag <tag>] [-prog <prog>] [-Ddef...] [-check <check>] checkargs ...
    tag=
    prog=
    check=check_regexps
    while true; do
        select=
        case $1 in
            -tag|-prog)
                select=`expr substr $1 2 ${#1}`
                eval $select='$2'
                ;;
        esac
        if [ -z "$select" ]; then
            break
        fi
        shift
        shift
    done
    defs=
    while expr "x$1" : "x-D.*" > /dev/null; do
        defs="DEFS+='$1' $defs"
        shift
    done
    if [ "x$1" = "x-check" ]; then
        check=$2
        shift
        shift
    fi

    if [ -z "$prog" ]; then
        $make $makeopts touch > /dev/null 2>&1
        args="$defs"
    else
        if [ -z "$tag" ]; then
            tag="$prog"
        fi
        args="build-$prog $defs"
    fi

    build_run "$tag" "$args"

    check_result 'check result' "$check" "$@"
}

quick_run() {
    # usage: quick_run <tag> [-Ddef...]
    tag="$1"
    shift
    defs=
    while expr "x$1" : "x-D.*" > /dev/null; do
        defs="DEFS+='$1' $defs"
        shift
    done

    $make $makeopts touch > /dev/null 2>&1
    build_run "$tag" "$defs"
}

quick_check() {
    # usage: quick_check <tag> checkargs ...
    tag="$1"
    shift
    check_result "$tag" check_regexps "$@"
}

## kernel image
osimg=$(make_print ucoreimg)

## swap image
swapimg=$(make_print swapimg)

## set default qemu-options
qemuopts="-machine virt -nographic -bios default -device loader,file=bin/ucore.img,addr=0x80200000"

## set break-function, default is readline
brkfun=readline

default_check() {
    pts=40
    check_regexps "$@"

    pts=10
    quick_check 'check output'                                  \
    'memory management: default_pmm_manager'                      \
    'check_alloc_page() succeeded!'                             \
    'check_pgdir() succeeded!'                                  \
    'check_boot_pgdir() succeeded!'				\
    'kmalloc_init() succeeded!'                             \
    'check_vma_struct() succeeded!'                             \
    'page fault at 0x00000100: K/W'                             \
    'check_pgfault() succeeded!'                                \
    'check_vmm() succeeded.'					\
    'page fault at 0x00001000: K/W'            \
    'page fault at 0x00002000: K/W'            \
    'page fault at 0x00003000: K/W'            \
    'page fault at 0x00004000: K/W'            \
    'write Virt Page e in fifo_check_swap'			\
    'page fault at 0x00005000: K/W'		\
    'page fault at 0x00001000: K/W'		\
    'page fault at 0x00002000: K/W'		\
    'page fault at 0x00003000: K/W'		\
    'page fault at 0x00004000: K/W'		\
    'check_swap() succeeded!'					\
    '++ setup timer interrupts'
}

## check now!!
run_test -prog 'matrix'      -check default_check             \
        'Iter 1, No.0 philosopher_sema is thinking'                  \
        'Iter 1, No.1 philosopher_sema is thinking'                  \
        'Iter 1, No.2 philosopher_sema is thinking'                  \
        'Iter 1, No.3 philosopher_sema is thinking'                  \
        'Iter 1, No.4 philosopher_sema is thinking'                  \
        'Iter 1, No.0 philosopher_sema is eating'                  \
        'Iter 1, No.1 philosopher_sema is eating'                  \
        'Iter 1, No.2 philosopher_sema is eating'                  \
        'Iter 1, No.3 philosopher_sema is eating'                  \
        'Iter 1, No.4 philosopher_sema is eating'                  \
        'No.0 philosopher_sema quit'                                \
        'No.1 philosopher_sema quit'                                \
        'No.2 philosopher_sema quit'                                \
        'No.3 philosopher_sema quit'                                \
        'No.4 philosopher_sema quit'                                \
        'Iter 1, No.0 philosopher_condvar is thinking'                  \
        'Iter 1, No.1 philosopher_condvar is thinking'                  \
        'Iter 1, No.2 philosopher_condvar is thinking'                  \
        'Iter 1, No.3 philosopher_condvar is thinking'                  \
        'Iter 1, No.4 philosopher_condvar is thinking'                  \
        'Iter 1, No.0 philosopher_condvar is eating'                  \
        'Iter 1, No.1 philosopher_condvar is eating'                  \
        'Iter 1, No.2 philosopher_condvar is eating'                  \
        'Iter 1, No.3 philosopher_condvar is eating'                  \
        'Iter 1, No.4 philosopher_condvar is eating'                  \
	'phi_test_condvar: state_condvar[0] will eating'              \
	'phi_test_condvar: signal self_cv[0]'                         \
        'phi_test_condvar: state_condvar[1] will eating'              \
	'phi_test_condvar: signal self_cv[1]'                         \
	'phi_test_condvar: state_condvar[2] will eating'              \
	'phi_test_condvar: signal self_cv[2]'                         \
        'phi_test_condvar: state_condvar[3] will eating'              \
	'phi_test_condvar: signal self_cv[3]'                         \
	'phi_test_condvar: state_condvar[4] will eating'              \
	'phi_test_condvar: signal self_cv[4]'                         \
      - 'cond_signal begin: cvp.*, cvp->count.*, cvp->owner->next_count.*'  \
      - 'cond_signal end: cvp.*, cvp->count.*, cvp->owner->next_count.*'    \
      - 'cond_wait begin:  cvp.*, cvp->count.*, cvp->owner->next_count.*'   \
      - 'cond_wait end:  cvp.*, cvp->count.*, cvp->owner->next_count.*'     \
        'No.0 philosopher_condvar quit'                                \
        'No.1 philosopher_condvar quit'                                \
        'No.2 philosopher_condvar quit'                                \
        'No.3 philosopher_condvar quit'                                \
        'No.4 philosopher_condvar quit'                                \
      - 'kernel_execve: pid = ., name = "matrix".*'              \
        'fork ok.'                                              \
        'pid 13 done!.'                                         \
        'pid 17 done!.'                                         \
        'pid 23 done!.'                                         \
        'matrix pass.'                                          \
        'all user-mode processes have quit.'                    \
        'init check memory pass.'                               \

## print final-score
show_final
