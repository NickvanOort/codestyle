# Python Project Structure Guide

## Basic Project Structure

A typical Python project structure looks like this:

```
myproject/            # Project root
|- .venv/             # Virtual environment directory
|- src/               # Source code directory
|  |- mymodule/       # Your actual module
|  |  |- __init__.py  # Makes the directory a Python package
|  |  |- main.py      # Main application code
|  |  |- utils.py     # Additional modules
|- tests/             # Test files
|- README.md          # Project documentation
|- pyproject.toml     # Project dependencies
```

## Key Components

### `__init__.py`

This file makes a directory a Python package. It can be empty or explicitly declare public APIs:

```python
# src/mymodule/__init__.py
from .main import some_function

# Explicitly declare public API
__version__ = "0.1.0"
```

## pyproject.toml

Modern Python projects use pyproject.toml (PEP 621) for project metadata and build configuration:

```toml
[project]
name = "mymodule"
version = "0.1.0"
description = "My Python module"
requires-python = ">=3.8"
dependencies = [
    "requests>=2.28.0",
]

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project.scripts]
mymodule = "mymodule.main:main"
```

## main.py

Main application logic with a clear entry point:

```python
# src/mymodule/main.py
def main():
    print("Running main function")

if __name__ == '__main__':
    main()
```

# Importing Between Files

## Best Practice Imports

```python
# Absolute import (preferred over relative)
from src.mymodule.utils import helper_function

# Relative import (from same directory)
from .utils import helper_function

# Import specific functions (always preferred over 'import *')
from src.mymodule.constants import (
    DEFAULT_TIMEOUT,
    MAX_RETRIES,
)
```

# Running Your Code

## Method 1: Direct Python Execution

Run this command from your terminal, from the root of your project.

```bash
# From project root
python src/mymodule/main.py
```

DON'T do this - will cause import issues

```bash
cd src/mymodule
python main.py  # This breaks imports!
```

## Method 2: Module Mode (-m flag)

```bash
# From project root
python -m src.mymodule.main
```

The -m flag treats the path as a module path, not a file path. This helps Python correctly resolve imports.

# Common Issues and Solutions

## 1. Import Errors

```bash
Error: ModuleNotFoundError: No module named 'src'
```

## Common causes:

- Running from wrong directory
- Missing __init__.py files
- Module not installed or not in Python path
- venv not activated

Solutions:

```bash
# Always run from project root
cd /path/to/myproject
source .venv/bin/activate
python -m src.mymodule.main
```

## 2. Virtual Environment Setup

Creating a venv with vanilla Python:

```bash
# From project root
python -m venv .venv

# Activate it
# Windows
.venv\Scripts\activate
# Unix/MacOS
source .venv/bin/activate
```

or with rye:

```bash
rye init myproject # creates folder structure
cd myproject
rye sync  # syncs pyproject.toml file with .venv , activates .venv
```

# Project Examples

## simple script

```
project/
|- src/
|  |- script.py
|- .venv/
|- pyproject.toml
```

## Basic Package

```
project/
|- src/
|  |- mypackage/
|  |  |- __init__.py
|  |  |- main.py
|- .venv/
|- README.md
|- pyproject.toml
```

## Full Application

```
project/
|- src/
|  |- myapp/
|  |  |- __init__.py
|  |  |- main.py
|  |  |- utils/
|  |  |  |- __init__.py
|  |  |  |- filehandler.py
|  |  |  |- preprocessing.py
|- tests/
|  |- test_main.py
|- .venv/
|- README.md
|- pyproject.toml
```
