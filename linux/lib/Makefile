# needed environment variables
# (shold be set by the reconos toolchain)
# CROSS_COMPILE
CC = $(CROSS_COMPILE)gcc
AR = $(CROSS_COMPILE)ar
HOST_CC = gcc
HOST_AR = ar

OBJS := reconos.o hwt_delegate.o legacy_os_calls/mbox.o legacy_os_calls/rqueue.o arch/arch_$(RECONOS_ARCH)_linux.o

CFLAGS = -O2 -g -Wall -D"RECONOS_MMU_true" -D"RECONOS_ARCH_$(RECONOS_ARCH)" -D"RECONOS_OS_linux"

all: libreconos.a

libreconos.a: $(OBJS)
	$(AR) -rcsv libreconos.a $(OBJS)

clean:
	rm -f *.o *.a
	rm -f legacy_os_calls/*.o
	rm -f arch/*.o

HOST_OBJS = $(patsubst %.o,%.host.o,$(OBJS))

libreconos_host.a: $(HOST_OBJS)
	$(HOST_AR) -rcsv $@ $(HOST_OBJS)

%.host.o: %.c
	$(HOST_CC) -c $(CFLAGS) $< -o $@
