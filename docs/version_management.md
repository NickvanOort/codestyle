# Python version management

# Table of Contents

- [Managing python versions](#Managing-python-versions)

* [Managing python versions](#Managing-python-versions)

![python versions xkcd](https://imgs.xkcd.com/comics/python_environment.png)

Unfortunately, Python is a language that does not have a robust dependency management as a default. The result is that over the years, a lot of different tools have accumulated in different attempts to solve this problem.

While you can get pretty far by at random combining `pip install`, `conda install`, at some point beginners will typically end up with something that is as broken as the above comic.

We are trying to learn you a robust Python style, where you do not learn tools that you will have to unlearn at the moment you are growing into more demanding projects.

To obtain this goal of robustness, we encourage you follow this philosophy:

- manage your Python versions with rye
- manage your dependencies with a tool that uses the `pyproject.toml` file, such as rye (or pdm or poetry)
- for every project, make a virtualenv (eiter with rye or with `python -m venv .venv`)
- split dependencies into two minimal categories: development and production

## Managing python versions

When developing in Python, unfortunately there is not a culture of backwards compatibility. Even though Python 3 is released in 2008, there are still projects that are only compatible with Python 2.7. This is a problem, because Python 2.7 is no longer supported since 2020.

But even within the minor versions, there are problems. If you want to use the latest version of SciPy, you will need at least Python 3.9. In practice, this means you could want to use the latest python 3.11 for your own project, but you might have issues with dependencies and might need to downgrade to 3.10 or even 3.9 to get everything working. Currently, python 3.12 is out but I'm still not able to use it because some essential packages I use are not yet working with 3.12. Unfortunate, we know, but that is why they created new languages like [julia](https://julialang.org/) that have a syntax comparable to Python, but with fixes for some of the most basic problems with python (among which: a 10-100x speedup, native package management that works, no need for a C/C+ backend, etc). [rust](https://www.rust-lang.org/) even guarantees that your code will always compile with new versions of the language.

Anyway, Python is still relevant and we use Python in this course, which means it is a smart idea 💡 to use a python version manager. We recommend [uv](https://docs.astral.sh/uv/).

To install it, you can use to automatic installer if you are using bash on any unix system (linux or mac):

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

or for windows, check the [documentation](https://docs.astral.sh/uv/getting-started/installation/)

You can read more about how to manage python versions with `uv` in their [docs](https://docs.astral.sh/uv/guides/install-python/)

In general:

- pick uv instead of pip, it's about 10x faster
- pick python 3.11 as a default. Rye will make it easy to install other versions if you need them.
