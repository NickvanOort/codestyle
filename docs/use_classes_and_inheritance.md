[← Previous: Pydantic](pydantic.md) | [Next: Git Basics →](git_basics.md)

[← Previous: Pydantic](pydantic.md) | [Next: Git Basics →](git_basics.md)

# Table of Contents

- [Classes and inheritance](#Classes-and-inheritance)
  - [dataclass](#dataclass)
  - [the `__init__` method](#the-%60__init__%60-method)
  - [Adding optional parameters](#Adding-optional-parameters)
  - [More dunder methods](#More-dunder-methods)
  - [Inheritance](#Inheritance)

# Classes and inheritance

NOTE: this is a very basic introduction into classes, dundermethods and inheritance. If you want to understand the concept a bit better, this is a nice place to start. If you have experience with the concept of classes and would like to see it in action in a more complex environment, you will find more challenge in notebook `02_classes_and_functions.ipynb`

## dataclass

Python has a native `dataclass` since 3.7
It is ideal to specify some data. Let's imagine we are starting a zoo:

```python
from dataclasses import dataclass

@dataclass
class Lion:
    food : str
```

We can now make an instance of the `Lion` class. Let's create a `Lion` named alex that eats `steak`

```python
alex = Lion(food="steak")
```

`alex` is now an object. It is an instance of the class `Lion`. The class specifies the general idea, in our case: a `Lion` is an object that has a single feature, which is `food` and `food` is a string. Obviously, that is very simple and basic, but we are trying to keep things as simple as possible for now.

In this specific case, we have `alex` and that is a `Lion` with a specific preference for food:

```python
alex.food
# Output: 'steak'
```

## the `__init__` method

the `@dataclass` wrapper is there to make life easier. It's the same as this:

```python
class Lion:
    def __init__(self, food: str) -> None:
        self.food = food
```

But that is a lot more [boilerplate](https://en.wikipedia.org/wiki/Boilerplate_code) code...

Now, we want to make our class more complex, such that we can also feed the `Lion`

```python
class Lion:
    def __init__(self, food: str) -> None:
        self.food = food
    
    def give_food(self):
        print(f"The lion eats the {self.food}")

leeuw = Lion(food="steak")
leeuw.give_food()
# Output: The lion eats the steak
```

And, as our zoo is expanding, we add another lion

```python
fred = Lion(food="ham")
fred.give_food()
# Output: The lion eats the ham
```

As you can see, we have two different animals with their own preferences, while both are `Lion`

```python
alex.food, fred.food
# Output: ('steak', 'ham')
```

We go on expanding, and add an optimal time for feeding. Let's make it so that the optimal feeding time is generated at random at the moment the `Lion` is created. At the moment the `Lion` is created, the `__init__` method is always called. That is a one-time-event at the moment of initialization.

Once it is created, the properties of `Lion` stay the same (unless we actively change them)

```python
import numpy as np
class Lion:
    def __init__(self, food: str) -> None:
        self.food = food
        self.time: int = np.random.randint(9, 17)
    
    def give_food(self):
        print(f"The lion eats the {self.food}")
    
    def ideal_feeding_time(self) -> str:
        return f"{self.time}h"

alex = Lion(food="steak")
```

```python
alex.ideal_feeding_time()
# Output: '15h'
```

## Adding optional parameters

Because we want to have the option to train the lion for a specific time of our own choosing,
we add `time` as an `Optional` parameter with a `None` default.

```python
from typing import Optional
class Lion:
    def __init__(self, food: str, time: Optional[int] = None) -> None:
        self.food = food
        if time == None:
            time = np.random.randint(9, 17)
        self.time: int = time
    
    def give_food(self):
        print(f"The lion eats the {self.food}")
    
    def ideal_feeding_time(self) -> str:
        return f"{self.time}h"

alex = Lion(food="ham", time=8)
alex.ideal_feeding_time()
# Output: '8h'
```

## More dunder methods

Let's add the dunder methods `__len__` and `__getitem__`, because `Lion` can now have multiple prefered foods.

> In Python, dunder methods are methods that allow instances of a class to interact with the built-in functions and operators of the language. The word "dunder" comes from "double underscore", because the names of dunder methods start and end with two underscores, for example `__str__` or `__add__`. Typically, dunder methods are not invoked directly by the programmer. [source](https://mathspp.com/blog/pydonts/dunder-methods)

`__len__` returns the number of foods.
`__getitem__` returns a food by using and index `idx`

```python
from typing import List
class Lion:
    def __init__(self, food: List[str], time: Optional[int] = None) -> None:
        self.food = food
        if time == None:
            time = np.random.randint(9, 17)
        self.time: int = time
    
    def give_food(self) -> None:
        print(f"The lion enjoys {len(self)} items")
    
    def __getitem__(self, idx: int) -> str:
        return self.food[idx]

    def __len__(self) -> int:
        return len(self.food)

    def ideal_feeding_time(self) -> str:
        return f"{self.time}h"

alex = Lion(["steak", "sushi"], time=9)
alex.give_food()
# Output: The lion enjoys 2 items
alex[1], len(alex)
# Output: ('sushi', 2)
```

So, what is happening here? The `__get_item__` method is called whenever you do `object[index]`, so in our case, when we create a `Lion` object `alex`, when we do `alex[1]` whatever is between the brackets is sent as an argument to the `__get_item__` method. We have specified that the argument is passed on to `self.food`.

The same thing is happening with `len`: when we call `len(object)`, under the hood the method `__len__` is called. We specified this for our `Lion` class at the return values of `len(self.food)`, but we could have defined it any way we like.

## Inheritance

Let's say we want to add another class, `BabyLion`. The only thing we want to change is that you
can pet a `BabyLion`, while a grown up `Lion` should not have that method.

Instead of retyping everything (which we could, but is not smart as it makes things much harder to maintain in the long run), we can simply inherit a parent class like this:

```python
class BabyLion(Lion):
    def pet(self):
        print("miauw")
        
simba = BabyLion(food = ["biefstuk"], time = 11)
simba.give_food()
# Output: The lion enjoys 1 items
simba.ideal_feeding_time()
# Output: 11

[← Previous: Pydantic](pydantic.md) | [Next: Git Basics →](git_basics.md)
```

As you can see, everything is still there!
Our `BabyLion` has inherited all methods from lion: `__init__`, `give_food`, `__get_item__`, `__len__` and `ideal_feeding_time`.

We just added a new method on top of that, `pet`:

```python
simba.pet()
# Output: miauw
```

[← Previous: Pydantic](pydantic.md) | [Next: Git Basics →](git_basics.md)
