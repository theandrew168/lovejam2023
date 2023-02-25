.POSIX:
.SUFFIXES:

.PHONY: default
default: build

.PHONY: build
build:
	zip -o khet.love *.lua font/* music/*

.PHONY: web
web: build
	love.js -c -t Khet khet.love web/

.PHONY: serve
serve: web
	python3 -m http.server -d web/ -b 127.0.0.1 5000

.PHONY: run
run: build
	love khet.love

.PHONY: clean
clean:
	rm -fr *.love web/
