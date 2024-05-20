SHARDS_BIN ?= $(shell which shards)
SHARD_BIN ?= ../../bin
CRYSTAL_VERSION ?= 1.12.1

build: bin/crytic
bin/crytic:
	$(SHARDS_BIN) build $(CRFLAGS)

bin: build
	mkdir -p $(SHARD_BIN)
	cp ./bin/crytic $(SHARD_BIN)

test-unit:
	docker run --rm -it -v "$(shell pwd):/src" -w /src crystallang/crystal:$(CRYSTAL_VERSION) /bin/sh -c "./bin/test-unit"

test:
	docker run --rm -it -v "$(shell pwd):/src" -w /src crystallang/crystal:$(CRYSTAL_VERSION) /bin/sh -c "./bin/test"

docs:
	docker run --rm -it -v "$(shell pwd):/src" -w /src crystallang/crystal:$(CRYSTAL_VERSION) /bin/sh -c "./bin/generate-docs"

.PHONY: docs test test-unit
