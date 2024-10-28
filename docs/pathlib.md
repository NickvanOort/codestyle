[← Previous: Never Hardcode](never_hardcode.md) | [Next: Loguru →](loguru.md)

Instead of using `os.path`, use `pathlib.Path`.
see the [pathlib docs](https://docs.python.org/3/library/pathlib.html) for more information.

It is less clunky. Compare:

```python
import os

filepath = os.path.join(os.path.expanduser("~"), "data", "file.txt")
```

with

```python
from pathlib import Path

filepath = Path.home() / "data" / "file.txt"
```

If we want the filename without the suffix, with `os` we would need to do something like:

```python
basefile = os.path.splittext(os.path.basename(filepath))[0]
suffix = os.path.splittext(os.path.basename(filepath))[-1]
```

where as pathlib would give us:

```python
basefile = filepath.stem
suffix = filepath.suffix
```

In addition, pathlib has a lot of other useful methods, like [`glob`](https://docs.python.org/3/library/glob.html) and [`rglob`](https://docs.python.org/3/library/pathlib.html#pathlib.Path.rglob).
Example of using glob:

```python
from pathlib import Path

for filepath in Path.home().glob("*.txt"):
    print(filepath)
```

This will print all the files in your home directory that end with .txt.

There is always a lot of confusion about paths for people that start with programming. So make sure to check [path.md](path.md), in addition to checking if a path exists:

```python
path = Path("path/to/file.txt")

if not path.exists():
    print(f"File {path} does not exist!")
```

[← Previous: Never Hardcode](never_hardcode.md) | [Next: Loguru →](loguru.md)
