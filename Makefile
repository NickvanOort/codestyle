
.PHONY: build build-pip

build:
	rye sync
	chmod +x find_orphans.sh
	lefthook add -d pre-commit
	cp find_orphans.sh .lefthook/pre-commit/
	lefthook install

build-pip:
	pip install .
	chmod +x find_orphans.sh
	lefthook add -d pre-commit
	cp find_orphans.sh .lefthook/pre-commit/
	lefthook install

