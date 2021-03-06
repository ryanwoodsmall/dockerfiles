#
# XXX
#  need to limit cpu count to 2 or 3: --cpuset-cpus=0,1,2
#  need to limit mem to first numa node: --cpuset-mems=0
#
# config works fine on a d-1541 (8c/16t) w/128GB, non numa
# breaks setting pga/sga on a dual e5-2640v4 (2x10c/20t) w/128GB, numa
#
include ../common/common.mak

IMAGENAME = $(shell basename $(PWD))
IMAGETAG  = latest

CONFIGURENAME = $(IMAGENAME)-configure

BUILDTAG = $(IMAGEVENDOR)/$(IMAGENAME)-build:$(IMAGETAG)
FULLTAG = $(IMAGEVENDOR)/$(IMAGENAME):$(IMAGETAG)

DOCKERRUNOPTS = --privileged --shm-size=2gb --cpuset-cpus=0,1 --cpuset-mems=0

ORACLEVER = 18c
ORACLEED = xe
ORACLERPMVER = 1.0
ORACLERPMREL = 1
ORACLEDIST = el7
ORACLEARCH = x86_64
ORACLEDBSHA256 = 308c044444342b9a3a8d332c68b12c540edf933dc8162d8eda3225e662433f1b
ORACLEPREINSTALLSHA256 = 462b2253e0e012e8211d1b6ceac0c66ecb636de1c7a27ca6a1419e3cb64d160d
ORACLEPORT = 1521
ORACLEHTTPPORT = 5500

all:
	@echo make build - builds $(FULLTAG) image
	@echo make clean - cleans up intermediate tags $(BUILDTAG) and containers $(CONFIGURENAME)
	@echo make logs - tail logs in running $(IMAGENAME) container
	@echo make run - build $(FULLTAG) and run $(IMAGENAME) detached
	@echo make shell - start a shell in running $(IMAGENAME) container
	@echo make verify - verify rpms

run:
	docker image ls | awk '{print $$1":"$$2}' | grep "^$(FULLTAG)$$"
	docker run --restart always --detach $(DOCKERRUNOPTS) --name $(IMAGENAME) --publish $(ORACLEPORT):$(ORACLEPORT) --publish $(ORACLEHTTPPORT):$(ORACLEHTTPPORT) $(FULLTAG)

shell:
	docker ps | awk '{print $$NF}' | grep "^$(IMAGENAME)$$"
	docker exec -it $(IMAGENAME) bash -il

logs:
	docker ps | awk '{print $$NF}' | grep "^$(IMAGENAME)$$"
	docker logs --follow $(IMAGENAME)

clean:
	docker stop $(CONFIGURENAME) || true
	docker kill $(CONFIGURENAME) || true
	docker rm --force $(CONFIGURENAME) || true
	docker image rm --force $(BUILDTAG) || true

verify:
	sha256sum files/rpm/oracle-database-preinstall-$(ORACLEVER)-$(ORACLERPMVER)-$(ORACLERPMREL).$(ORACLEDIST).$(ORACLEARCH).rpm | awk '{print $$1}' | grep -q '^$(ORACLEPREINSTALLSHA256)$$'
	sha256sum files/rpm/oracle-database-$(ORACLEED)-$(ORACLEVER)-$(ORACLERPMVER)-$(ORACLERPMREL).$(ORACLEARCH).rpm | awk '{print $$1}' | grep -q '^$(ORACLEDBSHA256)$$'

build: verify clean
	docker build --compress --pull --force-rm --tag $(BUILDTAG) .
	docker run $(DOCKERRUNOPTS) --name $(CONFIGURENAME) $(BUILDTAG) /configure.sh
	docker export $(CONFIGURENAME) | docker import --change='CMD ["/startup.sh"]' - $(FULLTAG)
