[← Previous: Dependencies Management](dependencies_management.md) | [Next: Add A Readme →](add_a_readme.md)

# Table of Contents

- [Organize your folders](#Organize-your-folders)
  - [Motivation](#Motivation)
  - [Datafolder](#Datafolder)
  - [notebooks vs source code](#notebooks-vs-source-code)

# Organize your folders

## Motivation

The text below is copied from [cookiecutter-data-science](https://cookiecutter-data-science.drivendata.org/opinions/) and is an excellent motivation for why we want to organize our code, especially in data science projects:

> The most important features of a quality data analysis are correctness and reproducibility—anyone should be able to re-run your analysis using only your code and raw data and produce the same final products. The best way to ensure correctness is to test your analysis code. The best way to ensure reproducibility is to treat your data analysis pipeline as a directed acyclic graph (DAG). This means each step of your analysis is a node in a directed graph with no loops. You can run through the graph forwards to recreate any analysis output, or you can trace backwards from an output to examine the combination of code and data that created it.

You want your code to be reproducable; that is the `science` part of `data science`: you create hypotheses and set up repeatable experiments to confirm or deny them.

Some of their guidelines are:

- raw data is immutable
- data should not be kept in source control
- notebooks are for exploration, source files for repetition
- refactor the good parts into source code
- keep your modeling / visualisations organized
- build from the environment up (i prefer `uv`, see
- adapt from a consistent default

If some of these dont seem clear, I invite you to follow the [link](https://drivendata.github.io/cookiecutter-data-science/) and read more details.

Their project translates these guidelines into what is called a cookiecutter: a default template with a folder structure and some basic files.
While you could use their setup, it turns out that even templates are highly personal. `uv` has different commands to initialize a project, just run `uv init --help` to get an overview of the different templates.

While there is some flexibility, a well-defined, standard project structure means that a newcomer can begin to understand an analysis without digging in to extensive documentation. It also means that they don't necessarily have to read 100% of the code before knowing where to look for very specific things.

This general structure should have these components:

## Datafolder

Add a specific datafolder. You can do that like this

```markdown
├── data/
│   ├── raw
│   └── processed
```

Such that you clearly separate unprocessed and processed data.

Another common approach looks like this:

```markdown
├── data/
│   ├── assets
│   └── artefacts
```

Which is inspired by the `design science` methodology: `assets` is data you get, the `artefacts` are the output of your process.

## notebooks vs source code

Separate your code into the exploration phase where you use notebooks, and a consolidation phase where you have moved the good parts of the exploration from a notebook or script into source code. A convention is to use a `dev` folder (for the developer) for exploration and communication, and a `src` folder for source code, which will form a proper module.

```markdown
├── dev/
|   ├── notebooks
│   └── scripts
├── src/
│   ├── __init__.py
│   └── main.py
```

More info about setting up your project can be found in [make a module](make_a_module.md)

[← Previous: Dependencies Management](dependencies_management.md) | [Next: Add A Readme →](add_a_readme.md)
