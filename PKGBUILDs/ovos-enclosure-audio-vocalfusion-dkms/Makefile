obj-m += vocalfusion-soundcard.o
KDIR := /lib/modules/$(KVER)/build
PWD := $(shell pwd)

all:
	$(MAKE) -C $(KDIR) M=$(PWD) modules
	
clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean