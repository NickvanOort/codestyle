
.PHONY: build build-pip

build:
	rye sync
	lefthook install

build-pip:
	pip install .
	lefthook install

