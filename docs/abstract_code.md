[← Previous: Use Classes And Inheritance](use_classes_and_inheritance.md) | [Next: Git Basics →](git_basics.md)

# Table of Contents

- [Refactoring Guide: Eliminating Hardcoding](#Refactoring-Guide:-Eliminating-Hardcoding)
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

# Refactoring Guide: Make your code more abstract

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
            q=5,  # Hardcoded number of categories. This makes the code way more complex!
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

## Why This Is Bad

Hardcoded values create several problems:

1. **Poor Maintainability**: If you need to change something (like a column name), you have to find all instances throughout the code.

1. **Limited Reusability**: The code is tightly coupled to specific data. It can't be easily repurposed for other datasets.

1. **Difficulty in Testing**: Hardcoded values make it harder to test with different inputs.

1. **Increases Technical Debt**: As the codebase grows, the effort to update becomes exponentially larger.

1. **Reduced Readability**: Intent is hidden among implementation details.

## The Plan: Better Design Principles

We'll apply these principles to improve the code:

1. **Single Responsibility Principle (SRP)**: Each class should have only one reason to change.

1. **Configuration Over Code**: Settings should be managed separately from behavior.

1. **Inheritance for Reuse**: Create base classes that can be extended for specific needs.

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


# we will need this for every plot
class PlotSettings(BaseModel):
    """Base settings for plotting."""
    title: str = ""
    xlabel: str = ""
    ylabel: str = ""
    figsize: tuple = (10, 6)
    rotation: int = 0
    legend_title: Optional[str] = None

# and this for some. So we inherit.
class ColoredPlotSettings(PlotSettings):
    """Settings for plots with color palettes."""
    color_palette: str = "coolwarm"


# this is for a specific plot we want to make
class LoyaltySettings(BaseModel):
    """Settings for loyalty calculations."""
    author_column: str = "author"
    message_column: str = "message"
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
        # this is an improvement! Beforehand, we simply had "5"
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
    
    def get_figure(self):
        """Return the figure, creating it if needed."""
        if self.fig is None:
            self.create_figure()
        return self.fig
```

### 3. Create a Specialized Plot Class

Now we are going to make an extended case, something we might not want to do EVERY time, but more than once.
Still it is a good idea to make it more abstract.
We simply inherit from `BasePlot` and extend it.

```python
class ColoredBarPlot(BasePlot):
    """Bar plot that extends BasePlot with color options."""
    def __init__(self, settings: ColoredPlotSettings):
        super().__init__(settings)
        self.settings = settings  # Store the more specific settings type
        self.rotation = 0  # Default rotation value
        
    def set_rotation(self, rotation: int):
        """Set the rotation for x-axis labels."""
        self.rotation = rotation
        return self
        
    def plot(self, data: pd.DataFrame, x_column: str, y_column: str, hue_column: Optional[str] = None):
        """Create a bar plot using the provided data and settings."""
        self.create_figure()
        
        # IMPROVEMENT: We leverage inheritance here - all the base plot settings
        # are already applied by the parent class's create_figure method
        
        # IMPROVEMENT: We don't hardcode the plot type either - by creating a specialized
        # class, we can easily make other plot types without duplicating code
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

### 4. Using the New Components

Now it is time to stitch everything together. This is what we do for a specific plot:

```python
class LoyaltyAnalyzer:
    """Analyseert de loyaliteit van auteurs op basis van berichtenactiviteit."""
    def __init__(self, config: dict, processed_dir: Path):
        # ABSTRACTION: Instead of hardcoding strings throughout the code,
        # we initialize settings objects that capture the concept of what
        # we're trying to do at a more abstract level
        self.loyalty_settings = LoyaltySettings()
        self.plot_settings = ColoredPlotSettings(
            title="Loyalty Score per Author",
            xlabel="Author",
            ylabel="Loyalty Score",
            legend_title="Loyalty Categorie"
        )
        
        # ... other initialization ...
        
    def calculate_loyalty(self):
        """Calculate loyalty scores without hardcoding."""
        # ... calculation code ...
        
        # ABSTRACTION: We reference column names from settings
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
            q=self.loyalty_settings.num_categories, # note how this was hardcoded before
            labels=self.loyalty_settings.categories
        )
    
    def plot_loyalty(self):
        """Generate a bar plot using the plot classes."""
        if self.author_stats is None:
            # Handle error...
            return None
        
        # ABSTRACTION: We create a plot object using our settings
        # The plotting logic is encapsulated in its own class
        plotter = ColoredBarPlot(self.plot_settings)
        
        # Set rotation specifically for this plot
        plotter.set_rotation(45)
        
        # ABSTRACTION: We use column names from settings
        # rather than hardcoding them here
        fig = plotter.plot(
            data=self.author_stats,
            x_column=self.loyalty_settings.author_column,
            y_column="loyalty_score",
            hue_column="loyalty_category"
        )
        
        return fig
```

## Benefits of This Approach

1. **Configurability**: All settings are managed in one place and can be easily changed.

1. **Reusability**: The `BasePlot` class can be reused for many different visualization needs.

1. **Extensibility**: New plot types can be created by inheriting from `BasePlot`.

1. **Clarity**: The code's intent is clearer because implementation details are separated from business logic.

1. **Maintainability**: Changing a setting requires modifying only one line of code.

In general: more abstraction!

## Example: Creating a New Plot Type

Here's how easy it is to create a completely different visualization using our abstraction:

```python
class TimeSeriesPlot(BasePlot):
    """Plot for showing data over time."""
    def __init__(self, settings: ColoredPlotSettings):
        super().__init__(settings)
        self.marker = 'o'  # Default marker style
        
    def set_marker(self, marker: str):
        """Set the marker style for data points."""
        self.marker = marker
        return self
        
    def plot(self, data: pd.DataFrame, time_column: str, value_column: str, group_column: str):
        self.create_figure()
        
        # REUSE: We've already set up the figure, labels, and title in BasePlot
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
time_plot_settings = ColoredPlotSettings(
    title="Trends Over Time",
    xlabel="Date",
    ylabel="Value",
    legend_title="Group"
)

# Create the plot object
plotter = TimeSeriesPlot(time_plot_settings)

# Configure specific properties for this plot
plotter.set_marker('*')

# Generate the plot with our data
fig = plotter.plot(
    data=time_series_data,
    time_column="date",
    value_column="score",
    group_column="group"
)

# We can now use the exact same structure for ANY kind of time series data,
# not just loyalty scores!
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
