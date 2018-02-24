include ../../common/common.mak

IMAGENAME  = $(shell basename $(shell dirname $(shell pwd)))
IMAGESHORT = rsel
IMAGEVER   = $(shell basename $(shell pwd))
IMAGEVERNO = $(shell echo $(IMAGEVER) | sed s/$(IMAGESHORT)//g)
IMAGEURL   = http://ftp.$(IMAGENAME).org/pub/el6-staging/rootfs/$(IMAGEVER)-minimal.tar.xz
IMAGEFILE  = $(shell basename $(IMAGEURL))

.PHONY: all clean

all:
	curl -k -L -o $(IMAGEFILE) $(IMAGEURL)
	docker build --force-rm --tag $(IMAGEVENDOR)/$(IMAGENAME):$(IMAGEVER) --tag $(IMAGEVENDOR)/$(IMAGENAME):$(IMAGEVERNO) --tag $(IMAGEVENDOR)/$(IMAGENAME):latest .

clean:
	rm -f $(IMAGEFILE)
