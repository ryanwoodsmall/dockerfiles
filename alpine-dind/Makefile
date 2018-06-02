include ../common/common.mak

IMAGENAME = $(shell basename $(PWD))
IMAGETAG  = latest

FULLTAG = $(IMAGEVENDOR)/$(IMAGENAME):$(IMAGETAG)

all:
	@echo make build - builds $(FULLTAG) image
	@echo make clean - stops, kills, removes $(IMAGENAME) and $(FULLTAG)
	@echo make run - build $(FULLTAG) and run $(IMAGENAME) detached

run:
	docker run -d --privileged --network host --name $(IMAGENAME) --volume /lib/modules:/lib/modules:ro $(FULLTAG)

build:
	docker build --pull --tag $(FULLTAG) .

clean:
	docker stop $(IMAGENAME) || true
	docker kill $(IMAGENAME) || true
	docker rm $(IMAGENAME) || true
	docker image rm $(FULLTAG) || true
