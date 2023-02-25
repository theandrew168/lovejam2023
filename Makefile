.POSIX:
.SUFFIXES:

.PHONY: default
default: build

.PHONY: build
build:
	zip -o khet.love *.lua font/* music/*

.PHONY: run
run: build
	love khet.love

.PHONY: clean
clean:
	rm *.love
