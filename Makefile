.POSIX:
.SUFFIXES:

.PHONY: default
default: build

.PHONY: build
build:
	zip -o khet.love main.lua conf.lua global.lua state/* font/* sounds/*

.PHONY: run
run: build
	love khet.love

.PHONY: clean
clean:
	rm *.love
