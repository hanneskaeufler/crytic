SHARDS_BIN ?= $(shell which shards)
SHARD_BIN ?= ../../bin

build: bin/crytic
bin/crytic:
	$(SHARDS_BIN) build $(CRFLAGS)

bin: build
	mkdir -p $(SHARD_BIN)
	cp ./bin/crytic $(SHARD_BIN)
