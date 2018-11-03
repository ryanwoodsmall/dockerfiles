USERNAME  = ryanwoodsmall
IMAGENAME = $(USERNAME)/$(shell basename $(PWD))
TAG       = latest
PORT      = 4200

.phony: all clean

all: clean
	docker build --tag $(IMAGENAME):$(TAG) --force-rm .

run:
	docker run -i -t --rm -p $(PORT):$(PORT) $(IMAGENAME):$(TAG) || echo -n

clean:
	docker image ls | grep -q "$(IMAGENAME).*$(TAG)" && docker rmi $(IMAGENAME):$(TAG) || echo -n
