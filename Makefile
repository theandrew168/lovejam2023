.POSIX:
.SUFFIXES:

.PHONY: default
default: build

.PHONY: build
build:
	zip -o khet.love main.lua conf.lua font/* sounds*

.PHONY: run
run:
	love .

.PHONY: clean
clean:
	rm *.love
