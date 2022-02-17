all: test

build:
	docker build -t tmp-$(notdir $(CURDIR)) .

test: build
	test/run.sh tmp-$(notdir $(CURDIR))
