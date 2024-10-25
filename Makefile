.PHONY: build build-pip install-hooks help

# Variables
ORPHANS_SCRIPT := find_orphans.sh
HOOKS_DIR := .lefthook/pre-commit
HOOKS_SCRIPT := $(HOOKS_DIR)/$(ORPHANS_SCRIPT)

# Default target
.DEFAULT_GOAL := help

# Help target - shows available commands
help:
	@echo "Available commands:"
	@echo "  make build        - Set up development environment using rye"
	@echo "  make build-pip    - Set up development environment using pip"

# Main build targets
build:
	@echo "Setting up development environment with rye..."
	rye sync
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
	@if [ ! -f "$(HOOKS_SCRIPT)" ] || [ "$(ORPHANS_SCRIPT)" -nt "$(HOOKS_SCRIPT)" ]; then \
		echo "Copying $(ORPHANS_SCRIPT) to hooks directory..."; \
		cp $(ORPHANS_SCRIPT) $(HOOKS_DIR)/; \
	else \
		echo "$(HOOKS_SCRIPT) is up to date"; \
	fi
	. .venv/bin/activate && lefthook install
