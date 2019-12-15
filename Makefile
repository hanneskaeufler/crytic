SHARDS_BIN ?= $(shell which shards)
SHARD_BIN ?= ../../bin

build: bin/crytic
bin/crytic:
	$(SHARDS_BIN) build $(CRFLAGS)

bin: build
	mkdir -p $(SHARD_BIN)
	cp ./bin/crytic $(SHARD_BIN)

test-unit:
	docker run --rm -it -v "$(shell pwd):/src" -w /src crystallang/crystal:0.32.0 /bin/sh -c "./bin/test-unit"

test:
	docker run --rm -it -v "$(shell pwd):/src" -w /src crystallang/crystal:0.32.0 /bin/sh -c "./bin/test"
