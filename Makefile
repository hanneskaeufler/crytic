SHARDS_BIN ?= $(shell which shards)
SHARD_BIN ?= ../../bin

bin/crytic:
	$(SHARDS_BIN) build $(CRFLAGS)

bin: bin/crytic
	mkdir -p $(SHARD_BIN)
	cp ./bin/crytic $(SHARD_BIN)
