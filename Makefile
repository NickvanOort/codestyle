.PHONY: build build-pip install-hooks help

# Variables
ORPHANS_SCRIPT := find_orphans.sh
LINK_SCRIPT := link_generator.py
HOOKS_DIR := .lefthook/pre-commit
HOOKS_ORPHANS := $(HOOKS_DIR)/$(ORPHANS_SCRIPT)
HOOKS_LINKS := $(HOOKS_DIR)/$(LINK_SCRIPT)

# Default target
.DEFAULT_GOAL := help

# Help target - shows available commands
help:
	@echo "Available commands:"
	@echo "  make build        - Set up development environment using uv"
	@echo "  make build-pip    - Set up development environment using pip"

# Main build targets
build:
	@echo "Setting up development environment with uv..."
	uv sync
	$(MAKE) install-hooks

build-pip:
	@echo "Setting up development environment with pip..."
	pip install .
	$(MAKE) install-hooks

# Hook installation
install-hooks:
	@echo "Setting up git hooks..."
	. .venv/bin/activate && lefthook add -d pre-commit
	chmod +x $(ORPHANS_SCRIPT)
	@if [ ! -f "$(HOOKS_ORPHANS)" ] || [ "$(ORPHANS_SCRIPT)" -nt "$(HOOKS_ORPHANS)" ]; then \
		echo "Copying $(ORPHANS_SCRIPT) to hooks directory..."; \
		cp $(ORPHANS_SCRIPT) $(HOOKS_DIR)/; \
	else \
		echo "$(HOOKS_ORPHANS) is up to date"; \
	fi
	chmod +x $(LINK_SCRIPT)
	@if [ ! -f "$(HOOKS_ORPHANS)" ] || [ "$(LINK_SCRIPT)" -nt "$(HOOKS_LINKS)" ]; then \
		echo "Copying $(LINK_SCRIPT) to hooks directory..."; \
		cp $(LINK_SCRIPT) $(HOOKS_DIR)/; \
	else \
		echo "$(HOOKS_LINKS) is up to date"; \
	fi
	. .venv/bin/activate && lefthook install
