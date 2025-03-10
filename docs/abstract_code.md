[← Previous: Use Classes And Inheritance](use_classes_and_inheritance.md) | [Next: Git Basics →](git_basics.md)

# Table of Contents

- [Make your code more abstract: Refactoring Guide](#Make-your-code-more-abstract:-Refactoring-Guide)
  - [The Problem: Hardcoded Values without abstraction](#The-Problem:-Hardcoded-Values-without-abstraction)
  - [Why This Is Bad](#Why-This-Is-Bad)
  - [The Plan: Better Design Principles](#The-Plan:-Better-Design-Principles)
  - [The Solution](#The-Solution)
    - [1. Create Settings Models using Pydantic](#1.-Create-Settings-Models-using-Pydantic)
    - [2. Create a Base Plot Class](#2.-Create-a-Base-Plot-Class)
    - [3. Create a Specialized Plot Class](#3.-Create-a-Specialized-Plot-Class)
    - [4. Using the New Components](#4.-Using-the-New-Components)
  - [Benefits of This Approach](#Benefits-of-This-Approach)
  - [Example: Creating a New Plot Type](#Example:-Creating-a-New-Plot-Type)
  - [The Power of Abstraction](#The-Power-of-Abstraction)
  - [Conclusion](#Conclusion)

# Make your code more abstract: Refactoring Guide

## The Problem: Hardcoded Values without abstraction

Let's look at some problematic code:

```python
# Original LoyaltyAnalyzer class (simplified)
class LoyaltyAnalyzer:
    def __init__(self, config: dict, processed_dir: Path):
        self.config = config
        self.processed_dir = processed_dir
        self.data_file = self.processed_dir / self.config["current"]
        self.df = None
        self.author_stats = None
    
    def calculate_loyalty(self):
        # Hardcoded column names
        self.author_stats = self.df.groupby("author").agg(
            message_count=("message", "count"),
            first_message=("timestamp", "min"),
            last_message=("timestamp", "max")
        ).reset_index()
        
        # Hardcoded category labels
        self.author_stats["loyalty_category"] = pd.qcut(
            self.author_stats["loyalty_score"],
            # Hardcoded number of categories. This makes the code way more complex!
            # this is 5 because the number of labels is 5, which is a bad idea
            q=5,  
            labels=[
                "Niet Loyaal",
                "Minder Loyaal",
                "Gemiddeld Loyaal",
                "Boven Gemiddeld Loyaal",
                "Loyaal"
            ]
        )
    
    def plot_loyalty(self):
        # Hardcoded plot settings
        fig, ax = plt.subplots(figsize=(10, 6))
        sns.barplot(
            data=self.author_stats,
            x="author",  # Hardcoded column name
            y="loyalty_score",  # Hardcoded column name
            hue="loyalty_category",  # Hardcoded column name
            palette="coolwarm",  # Hardcoded color palette
            ax=ax
        )
        ax.set_xlabel("Author")  # Hardcoded label
        ax.set_ylabel("Loyalty Score")  # Hardcoded label
        ax.set_title("Loyalty Score per Author\n(Combinatie van deelnameperiode en aantal berichten)")  # Hardcoded title
        plt.xticks(rotation=45)  # Hardcoded rotation
        ax.legend(title="Loyalty Categorie")  # Hardcoded legend title
        plt.tight_layout()
        return fig
```

While it is nice that there is a class (see [use classes](use_classes_and_inheritance.md) and that there is a config that specifies the file, this is code that can only be used once.
The code is very specific, only for THIS usecase, and it is nearly impossible to use the code for anything else than this specific plot. For the next plot, the developper will probably need to write a completely new class. And if he doesnt change his style of writing code, he will keep on creating classes for EVERY new plot.

In addition to that, for every detail he wants to change (eg even a change in title) the developper will need to dive into the code, and change it again.

This code lacks abstraction.

## Why This Is Bad

Hardcoded values create several problems:

1. **Poor Maintainability**: If you need to change something (like a column name), you have to find all instances throughout the code.

1. **Limited Reusability**: The code is tightly coupled to specific data. It can't be easily repurposed for other datasets.

1. **Difficulty in Testing**: Hardcoded values make it harder to test with different inputs.

1. **Increases Technical Debt**: As the codebase grows, the effort to update becomes exponentially larger.

1. **Reduced Readability**: Intent is hidden among implementation details.

In general, this is code that seems fast, but causes a lot of lost time.

## The Plan: Better Design Principles

We'll apply these principles to improve the code:

1. **More abstraction** In general, we will need to think about how this code can be made more abstract. What do we probably want to do, every time we are going to make a plot?

1. **Single Responsibility Principle (SRP)**: Each class should have only one reason to change. This makes the cognitive overload of what is going on much lower. The current code is too complex because it tries to do everything at once.

1. **Configuration Over Code**: This setup is overloaded with highly specific details. Settings should be managed separately from behavior, with ABSTRACT configs! So, dont create a settings object with config.title_for_category_plot, but simply use config.title, and specify the goal when you create the object.

1. **Inheritance for Reuse**: This code has a lot of things we will probably want to repeat over and over agian. Create general base classes that can be inhereted and extended for specific needs.

1. **Eliminate Hardcoding**: Move all hardcoded values into configuration objects.

Overall, the code will be more abstract. Instead of solving THIS problem, you think about: what is it that I will want to do over and over again? So, setting a xlabel, setting a title... Ok, then we need to abstract that!

## The Solution

### 1. Create Settings Models using Pydantic

After thinking about how to abstract your work, lets implement these ideas:

```python
from pydantic import BaseModel
from typing import List, Optional
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns


# First, lets think about what EVERY plot needs
class PlotSettings(BaseModel):
    """Base settings for plotting."""
    title: str = ""
    xlabel: str = ""
    ylabel: str = ""
    figsize: tuple = (10, 6)
    rotation: int = 0
    legend_title: Optional[str] = None

# then, we can extend the settings with additional conig.
# this inherits everything from PlotSettings, plus a color_palette
class ColoredPlotSettings(PlotSettings):
    """Settings for plots with color palettes."""
    color_palette: str = "coolwarm"


# this is for a specific plot we want to make
# The difference is, if we want to change details, like
# column names or the number of categories, we can configure everything
# in a single place. We will set some defaults, but it is easy to change the settings
# when creating a settings instance
class LoyaltySettings(BaseModel):
    """Settings for loyalty calculations."""
    author_column: str = "author"
    message_column: str = "message"
    y_column="loyalty_score",
    hue="loyalty_category"
    timestamp_column: str = "timestamp"
    categories: List[str] = [
        "Niet Loyaal",
        "Minder Loyaal",
        "Gemiddeld Loyaal",
        "Boven Gemiddeld Loyaal",
        "Loyaal"
    ]
    
    @property
    def num_categories(self) -> int:
        """Derive number of categories from the list length."""
        # IMPROVEMENT Beforehand, we simply had a hardcoded "5"
        # but what if the number of categories would change?
        # then we would have needed to change both the 
        # list of categories, AND we would need to think
        # about searching for every place where we put "5" as the length
        # of the list!!
        return len(self.categories)
```

### 2. Create a Base Plot Class

This is what we are going to do over and over again. So, lets abstract it.
This will save us a lot of time, plus, it will make your code much easier to read and understand.

```python
class BasePlot:
    """Base class for creating plots."""
    def __init__(self, settings: PlotSettings):
        self.settings = settings
        self.fig = None
        self.ax = None
        
    def create_figure(self):
        """Create a figure and configure it based on settings."""
        # IMPROVEMENT: Instead of hardcoding figsize=(10, 6) everywhere,
        # we use the value from settings
        self.fig, self.ax = plt.subplots(figsize=self.settings.figsize)
        
        # IMPROVEMENT: Instead of repeating these calls in every plotting function,
        # we centralize them here once
        self.ax.set_xlabel(self.settings.xlabel)
        self.ax.set_ylabel(self.settings.ylabel)
        self.ax.set_title(self.settings.title)
        
        # IMPROVEMENT: Legend settings are now configurable
        if self.settings.legend_title is not None:
            self.ax.legend(title=self.settings.legend_title)
            
        plt.tight_layout()
        return self.fig, self.ax
    
        # this helps us use the figure in other classes
        # this is the Open-Closed principle;
        # make code CLOSED for modification (is essence, we will probably never 
        # need to modify the BasePlot class) but OPEN for extension if we want to
        # add more features
    def get_figure(self):
        """Return the figure, creating it if needed."""
        if self.fig is None:
            self.create_figure()
        return self.fig
```

### 3. Create a Specialized Plot Class

Now we are going to make an extended case, something we might not want to do EVERY time, but more than once. Still it is a good idea to make it more abstract.
We simply inherit from `BasePlot` and extend it.

```python
class ColoredBarPlot(BasePlot):
    """Bar plot that extends BasePlot with color options."""
    def __init__(self, settings: ColoredPlotSettings):
        super().__init__(settings) # we pass the settings to the BasePlot
        self.rotation = 0  # We add a default rotation value
        
    def set_rotation(self, rotation: int):
        """Set the rotation for x-axis labels."""
        # however, we make it easy to modify this later on
        # this is a good idea if you expect this setting needs 
        # a lot of modification later on for different cases
        self.rotation = rotation
        return self
        
    def plot(self, data: pd.DataFrame, x_column: str, y_column: str, hue_column: Optional[str] = None):
        """Create a bar plot using the provided data and settings."""
        # this uses the BasePlot basic figure, creating the baseplot
        self.create_figure()
        
        # IMPROVEMENT: We leverage inheritance here - all the base plot settings
        # are already applied by the parent class's create_figure method!
        
        # IMPROVEMENT: in the base class we don't hardcode the plot type either - 
        # by creating a specialized class, we can easily make 
        # other plot types without duplicating much code
        sns.barplot(
            data=data,
            x=x_column,
            y=y_column,
            hue=hue_column,
            palette=self.settings.color_palette,
            ax=self.ax
        )
        
        # Apply rotation (specific to this plot type)
        plt.xticks(rotation=self.rotation)
        
        return self.fig
```

The code so far is abstract enough to make lots and lots of plots!
In essence, all you have to do is play around with the settings, different columns etc, but
you will not need to change the ColoredBarPlot class as long as you are making
colored bar plots!

Compare this to the code we started with, where the user would be stuck with creating
new classes over and over and over again, for every new idea!

### 4. Using the New Components

Now it is time to stitch everything together, and we are now going to make an actual plot.

```python

# This is the place where we modify the plot with actual values
settings = ColoredPlotSettings(
            title="Loyalty Score per Author",
            xlabel="Author",
            ylabel="Loyalty Score",
            legend_title="Loyalty Categorie"
        )

class LoyaltyAnalyzer:
    """Analyseert de loyaliteit van auteurs op basis van berichtenactiviteit."""
    def __init__(self, settings: ColoredPlotSettings):
        # ABSTRACTION: Instead of hardcoding strings throughout the code,
        # we initialize settings objects that capture the concept of what
        # we're trying to do at a more abstract level
        self.plot_settings = settings

        # you could choose to add these settings too as an argument,
        # or you could add an additional method for setting or modifying these
        # def set_loyalty(settings : LoyaltySettings) etc.
        # this is dependend on your actual usecase
        self.loyalty_settings = LoyaltySettings()
        
        # ... other initialization ...
        
    def calculate_loyalty(self):
        """Calculate loyalty scores without hardcoding."""
        # ... calculation code ...
        
        # ABSTRACTION: We reference column names from settings instead of hardcoding!
        # This means we can change a column name in ONE place
        # rather than hunting for all occurrences in the code!
        self.author_stats = self.df.groupby(self.loyalty_settings.author_column).agg(
            message_count=(self.loyalty_settings.message_column, "count"),
            first_message=(self.loyalty_settings.timestamp_column, "min"),
            last_message=(self.loyalty_settings.timestamp_column, "max")
        ).reset_index()
        
        # ABSTRACTION: Categories are now defined as a concept
        # rather than as literal strings scattered throughout the code
        self.author_stats["loyalty_category"] = pd.qcut(
            self.author_stats["loyalty_score"],
            # note how the value of q was hardcoded before
            # now, it is inferred automatically!
            q=self.loyalty_settings.num_categories, 
            labels=self.loyalty_settings.categories
        )
    
    def plot_loyalty(self):
        """Generate a bar plot using the plot classes."""
        if self.author_stats is None:
            # Handle error...
            return None
        
        # ABSTRACTION: We create a plot object using our settings
        # The plotting logic is encapsulated in its own class
        # so we can focus here on the logic of the analysis
        # instead of the plotting details
        plotter = ColoredBarPlot(self.plot_settings)
        
        # Set rotation specifically for this plot
        plotter.set_rotation(45)
        
        # ABSTRACTION: We use column names from settings
        # rather than hardcoding them here
        fig = plotter.plot(
            data=self.author_stats,
            x_column=self.loyalty_settings.author_column,
            y_column=self.loyalty_settings.y_column,
            hue_column=self.loyalty_settings.hue
        )
        
        return fig
```

## Benefits of This Approach

1. **Configurability**: All settings are managed in one place where you expect them and can be easily changed. You could gather all settingsobject in a separate `settings.py` or `config.py` file.

1. **Reusability**: The `BasePlot` class can be reused for many different visualization needs.

1. **Extensibility**: New plot types can be created by inheriting from `BasePlot` and adding new features.

1. **Clarity**: The code's intent is clearer because implementation details are separated from business logic. The code is easier to read and understand because it isnt code for THIS case, but for general barplots.

1. **Maintainability**: Changing a setting requires modifying only one line of code instead of hunting for every place where you might have used the column name, or even worse, where you might have specified the length of the list but changed the list. It is very much not obvious that the one value is inferred from the other, and only adds unnecessary complexity.

In general: more abstraction!

## Example: Creating a New Plot Type

While it might seems as more work to set up your code like this, it actually makes your life much easier. Here's how easy it is to create a completely different visualization using our abstraction:

```python
class TimeSeriesPlot(BasePlot):
    """Plot for showing data over time."""
    def __init__(self, settings: ColoredPlotSettings):
        super().__init__(settings)
        # lets say we want to add something new to the defaults
        self.marker = 'o'  # Default marker style
        
    def set_marker(self, marker: str):
        """Set the marker style for data points."""
        # make it eaiser to change, because it is not directly in the general settings
        self.marker = marker
        return self
        
    def plot(self, data: pd.DataFrame, time_column: str, value_column: str, group_column: str):
        self.create_figure()
        # REUSE: We've already set up the figure, labels, and title in BasePlot!
        # Now we just need to add the specific visualization
        
        # Create a different type of visualization
        for name, group in data.groupby(group_column):
            self.ax.plot(
                group[time_column], 
                group[value_column],
                marker=self.marker,
                label=name
            )
            
        return self.fig

# Usage - this demonstrates how abstract the code has become
# we dont need to specify 
# ax.set_title("Loyalty Score per Author") etc somewhere deep in the class,
# and keep on rewriting and rewriting our class.
# we just make a new instance of our settings, because it was 
# to be expected that we need a title for every plot!
time_plot_settings = ColoredPlotSettings(
    title="Trends Over Time",
    xlabel="Date",
    ylabel="Value",
    legend_title="Group"
)

# Create the plot object
plotter = TimeSeriesPlot(time_plot_settings)

# Configure specific properties for this plot
# again, note how different it is to change your mind;
# the initial approach was to build a new car for every destination.
# now, we have a generic car that is suitable for most situations,
# we just need to handle the dashboard to configure our "roadtrip"
plotter.set_marker('*')

# Generate the plot with our data
fig = plotter.plot(
    data=time_series_data,
    time_column="date",
    value_column="score",
    group_column="group"
)

# We can now use the exact same structures for ANY kind of time series data,
# not just loyalty scores or category plots!
```

## The Power of Abstraction

What we've accomplished here is creating abstractions for:

1. **Plot Settings**: General configuration separated from specific implementations
1. **Base Plot Behavior**: Common plotting code in a base class
1. **Specialized Plots**: Extensions that add specific functionality while inheriting common behavior
1. **Data Configuration**: Column names and other data-specific settings isolated

This exemplifies the principle of abstraction: we've created representations that capture the essential features of plots and configuration while hiding the implementation details.

## Conclusion

By eliminating hardcoding and applying proper design principles, you've created code that is:

1. More maintainable
1. More reusable
1. Easier to extend
1. More robust to changes

This approach might seem like more work initially, but it saves significant time and effort in the long run as your codebase grows and requirements change.

[← Previous: Use Classes And Inheritance](use_classes_and_inheritance.md) | [Next: Git Basics →](git_basics.md)
