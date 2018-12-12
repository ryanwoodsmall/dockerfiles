include ../common/common.mak

IMAGENAME = $(shell basename $(PWD))
IMAGETAG  = latest

CONFIGURENAME = $(IMAGENAME)-configure

BUILDTAG = $(IMAGEVENDOR)/$(IMAGENAME)-build:$(IMAGETAG)
CONFIGURETAG = $(IMAGEVENDOR)/$(CONFIGURENAME):$(IMAGETAG)
FULLTAG = $(IMAGEVENDOR)/$(IMAGENAME):$(IMAGETAG)

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
	@echo make run - build $(FULLTAG) and run $(IMAGENAME) detached
	@echo make verify - verify rpms

# XXX - use --shm-size=2gb or similar here?
run:
	docker run --detach --privileged --name $(IMAGENAME) --volume /dev/shm:/dev/shm --publish $(ORACLEPORT):$(ORACLEPORT) --publish $(ORACLEHTTPPORT):$(ORACLEHTTPPORT) $(FULLTAG)

# XXX - need to split out configure/stop/start stuff
#  docker stop $(CONFIGURENAME) || true
#  docker kill $(CONFIGURENAME) || true
#  docker rm $(CONFIGURENAME) || true
#  docker image rm $(BUILDTAG) || true
#  docker image rm $(CONFIGURETAG) || true
#  docker build --compress --pull --force-rm --tag $(BUILDTAG) .
#  docker run --privileged --volume /dev/shm:/dev/shm --name $(CONFIGURENAME) $(BUILDTAG) /configure.sh
#  docker commit --change='CMD ["/startup.sh"]' $(FULLTAG) $(CONFIGURENAME)
build: verify
	# - < Dockerfile
	docker build --compress --pull --force-rm --tag $(FULLTAG) .

verify:
	sha256sum files/rpm/oracle-database-preinstall-$(ORACLEVER)-$(ORACLERPMVER)-$(ORACLERPMREL).$(ORACLEDIST).$(ORACLEARCH).rpm | grep -q '^$(ORACLEPREINSTALLSHA256) '
	sha256sum files/rpm/oracle-database-$(ORACLEED)-$(ORACLEVER)-$(ORACLERPMVER)-$(ORACLERPMREL).$(ORACLEARCH).rpm | grep -q '^$(ORACLEDBSHA256) '
