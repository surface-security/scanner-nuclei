all: test

build:
	docker build -t tmp-$(notdir $(CURDIR)) .

cleantest:
	rm -fr test/output

test: cleantest
	go run main.go --output test/output/ -t ssl/detect-ssl-issuer.yaml -- test/input/input.txt

dockertest: cleantest build
	test/run.sh tmp-$(notdir $(CURDIR))
