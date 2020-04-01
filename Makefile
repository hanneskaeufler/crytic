SHARDS_BIN ?= $(shell which shards)
SHARD_BIN ?= ../../bin
CRYSTAL_VERSION ?= 0.33.0

build: bin/crytic
bin/crytic:
	$(SHARDS_BIN) build -Dpreview_mt $(CRFLAGS)

bin: build
	mkdir -p $(SHARD_BIN)
	cp ./bin/crytic $(SHARD_BIN)

run:
	docker run --rm -it -v "$(shell pwd):/src" -w /src crystallang/crystal:0.32.0 /bin/sh -c "$(CMD)"

test-unit:
	docker run --rm -it -v "$(shell pwd):/src" -w /src crystallang/crystal:$(CRYSTAL_VERSION) /bin/sh -c "./bin/test-unit"

test:
	docker run --rm -it -v "$(shell pwd):/src" -w /src crystallang/crystal:$(CRYSTAL_VERSION) /bin/sh -c "./bin/test"

docs:
	docker run --rm -it -v "$(shell pwd):/src" -w /src crystallang/crystal:$(CRYSTAL_VERSION) /bin/sh -c "./bin/generate-docs"

.PHONY: docs test test-unit
