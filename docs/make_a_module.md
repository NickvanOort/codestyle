# Python Project Structure Guide

Beginners like jupyter notebooks because of the interactivity and short feedback loops.
However, they have a lot of downsides, too;

- it's often not clear which notebooks to run in which order
- you dont typically want to tell your client to run notebooks
- notebooks are harder to interact with in automated way

Jupyter notebooks are a nice solution for a teaching context, but they should be left
behind in a production context. So, at some point, you need to grow up beyond just
notebooks and learn how to create a python module.

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
from mymodule.main import some_function

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

When you add this to your `pyproject.toml`:

```toml
[project.scripts]
mymodule = "mymodule.main:main"
```

This creates a command-line script that you can run from anywhere. Let's break down how it works:

```
mymodule        = "mymodule.main:main"
^                 ^        ^     ^
|                 |        |     |
Command name      Module   File  Function
```

- Left side (mymodule): The command name you'll type in your terminal
- Right side ("mymodule.main:main"): Where to find the code to run
- Before the colon: Python import path to the file
- After the colon: Function name to call

## How to Use It

First, install your package:
`pip install -e .` or, with rye, doing `rye sync` install your package.
Now you can run your code by just typing:
`mymodule`

## Multiple Scripts

You can define multiple entry points:

```toml
[project.scripts]
mymodule = "mymodule.main:main"
mymodule-init = "mymodule.commands:initialize"
mymodule-cleanup = "mymodule.commands:cleanup"
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

What Does This Do?
When Python runs a file, it sets special variables. One of them is __name__:

When you run the file directly: __name__ = '__main__'
When you import the file: __name__ = the module's name

This means that if you have control over what should be done if you run it directly,
versus what happens when you just import.

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
