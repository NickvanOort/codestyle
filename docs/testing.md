[← Previous: Encapsulation](encapsulation.md) | [Next: Open Closed →](open_closed.md)

# Table of Contents

- [Testing in Software Development](#Testing-in-Software-Development)
  - [Motivation for Testing](#Motivation-for-Testing)
  - [Types of Tests](#Types-of-Tests)
    - [Unit Tests](#Unit-Tests)
    - [Integration Tests](#Integration-Tests)
    - [Other Types](#Other-Types)
  - [Moving Beyond Jupyter Notebooks for Testing](#Moving-Beyond-Jupyter-Notebooks-for-Testing)
    - [Limitations of Testing in Notebooks](#Limitations-of-Testing-in-Notebooks)
    - [Benefits of Using pytest](#Benefits-of-Using-pytest)
  - [Example: Testing a CSV Handler](#Example:-Testing-a-CSV-Handler)
    - [Testing in a Notebook (Limited Approach)](<#Testing-in-a-Notebook-(Limited-Approach)>)
    - [Testing with pytest (Better Approach)](<#Testing-with-pytest-(Better-Approach)>)
  - [Pytest Basics](#Pytest-Basics)
    - [Setting Up a Tests Folder](#Setting-Up-a-Tests-Folder)
  - [Testing Folder Structure and Naming Conventions](#Testing-Folder-Structure-and-Naming-Conventions)
    - [Naming Conventions for pytest](#Naming-Conventions-for-pytest)
  - [Fixtures in pytest](#Fixtures-in-pytest)
    - [What are Fixtures?](#What-are-Fixtures?)
    - [How to Use Fixtures](#How-to-Use-Fixtures)
    - [Fixture Scope](#Fixture-Scope)
    - [Cleanup with Fixtures](#Cleanup-with-Fixtures)
    - [Built-in Fixtures](#Built-in-Fixtures)
    - [Writing Tests for the CSV Handler](#Writing-Tests-for-the-CSV-Handler)
    - [Using Temporary Files and Directories](#Using-Temporary-Files-and-Directories)
  - [Using Mock Objects and Monkeypatching](#Using-Mock-Objects-and-Monkeypatching)
    - [Monkeypatching with pytest](#Monkeypatching-with-pytest)
    - [Using the unittest.mock Library](#Using-the-unittest.mock-Library)
    - [Example: Testing Error Handling with Mocks](#Example:-Testing-Error-Handling-with-Mocks)
    - [Example: Mocking Network Requests](#Example:-Mocking-Network-Requests)
    - [Benefits of Mocking](#Benefits-of-Mocking)
  - [Testing Edge Cases](#Testing-Edge-Cases)
    - [Examples of Edge Cases for the CSV Handler:](#Examples-of-Edge-Cases-for-the-CSV-Handler:)
  - [Using pytest-cov for Coverage Analysis](#Using-pytest-cov-for-Coverage-Analysis)
    - [Installation](#Installation)
    - [Basic Usage](#Basic-Usage)
    - [Configuration in pyproject.toml](#Configuration-in-pyproject.toml)
    - [Understanding Coverage Reports](#Understanding-Coverage-Reports)
    - [Interpreting Coverage Results](#Interpreting-Coverage-Results)
  - [Property-Based Testing with Hypothesis](#Property-Based-Testing-with-Hypothesis)
    - [Installation](#Installation)
    - [Why Hypothesis is Valuable for Data Science](#Why-Hypothesis-is-Valuable-for-Data-Science)
    - [Example: Testing a Simple Calculator](#Example:-Testing-a-Simple-Calculator)
    - [Understanding the Power of Hypothesis](#Understanding-the-Power-of-Hypothesis)
    - [Finding Floating-Point Issues](#Finding-Floating-Point-Issues)
    - [Adding Tolerance for Floating-Point Comparisons](#Adding-Tolerance-for-Floating-Point-Comparisons)
  - [Conclusion](#Conclusion)

# Testing in Software Development

## Motivation for Testing

Testing is a critical aspect of software development that ensures your code works as expected. It provides several key benefits:

1. **Bug Detection**: Tests help identify bugs early in the development cycle when they are less costly to fix.
1. **Code Quality**: Well-tested code tends to be better designed as it forces you to think about your code's structure and interactions.
1. **Refactoring Confidence**: Tests provide a safety net that allows you to refactor or enhance your code with confidence.
1. **Documentation**: Tests serve as living documentation, demonstrating how your code should be used.
1. **Time Savings**: While writing tests requires an initial time investment, it saves significant time in the long run by preventing bugs and simplifying debugging.

## Types of Tests

### Unit Tests

Unit tests focus on testing individual components or functions in isolation. They verify that each part of your code works correctly on its own.

**Characteristics**:

- Fast execution
- Test small, isolated pieces of code
- Mock dependencies to ensure isolation
- Should be numerous and cover many edge cases

### Integration Tests

Integration tests verify that different components work together correctly. They test the interactions between units or modules.

**Characteristics**:

- Test interactions between components
- Often involve real dependencies (databases, file systems, etc.)
- Slower than unit tests
- Detect issues that unit tests might miss

### Other Types

- **Functional Tests**: Test entire features from a user's perspective
- **End-to-End Tests**: Test the entire application flow
- **Performance Tests**: Evaluate system performance under various conditions
- **Regression Tests**: Ensure that new changes don't break existing functionality

## Moving Beyond Jupyter Notebooks for Testing

While Jupyter notebooks are excellent for exploratory data analysis and prototyping, they have limitations for systematic testing:

### Limitations of Testing in Notebooks

- Tests are often manual and not easily repeatable
- Difficult to automate
- Cell execution order can lead to hidden dependencies
- Hard, bordering on impossible, to integrate into pipelines
- State can persist between executions, obscuring issues

### Benefits of Using pytest

- Automated test execution
- Consistent environment for each test
- Easy to run all tests with a single command
- Integration with CI/CD pipelines
- Rich ecosystem of plugins

## Example: Testing a CSV Handler

Consider a simple class that saves and loads data to/from CSV files:

```python
# csv_handler.py
import pandas as pd

class CSVHandler:
    def __init__(self, filepath=None):
        self.filepath = filepath
        self.data = None
        
    def load(self, filepath=None):
        """Load data from a CSV file."""
        path = filepath or self.filepath
        if not path:
            raise ValueError("Filepath must be provided")
        self.data = pd.read_csv(path)
        return self.data
        
    def save(self, data=None, filepath=None):
        """Save data to a CSV file."""
        path = filepath or self.filepath
        if not path:
            raise ValueError("Filepath must be provided")
        df = data if data is not None else self.data
        if df is None:
            raise ValueError("No data to save")
        df.to_csv(path, index=False)
        return True
```

### Testing in a Notebook (Limited Approach)

```python
# In a Jupyter notebook
import pandas as pd
from csv_handler import CSVHandler

# Create test data
test_data = pd.DataFrame({'A': [1, 2, 3], 'B': ['a', 'b', 'c']})

# Test saving
handler = CSVHandler('test.csv')
handler.save(test_data)
print("Save successful")

# Test loading
loaded_data = handler.load()
print("Load successful")
print(loaded_data)

# Check if data is the same
assert test_data.equals(loaded_data), "Data doesn't match!"
print("Data verification successful")

# What about edge cases? What if the file doesn't exist?
# What if the data is empty?
# What if the filepath is None?
# Hard to systematically test all these cases in a notebook
```

### Testing with pytest (Better Approach)

## Pytest Basics

### Setting Up a Tests Folder

The standard structure for a Python project with tests:

```
my_project/
├── csv_handler/
│   ├── __init__.py
│   └── csv_handler.py
├── tests/
│   ├── __init__.py
│   └── test_csv_handler.py
└── pyproject.toml
```

## Testing Folder Structure and Naming Conventions

### Naming Conventions for pytest

pytest relies on naming conventions to automatically discover and run tests:

#### Test Files

- Test files must start with `test_` or end with `_test.py`
- Examples: `test_csv_handler.py` or `csv_handler_test.py`

#### Test Functions

- Test functions must start with `test_`
- Example: `test_save_and_load()`, `test_empty_dataframe()`

#### Test Classes

- Test classes must start with `Test`
- Must not have an `__init__` method
- Example: `TestCSVHandler`

#### Test Methods in Classes

- Test methods in classes must start with `test_`
- Example: `def test_save_functionality(self):`

```python
# Example of a test class
class TestCSVHandler:
    def test_save_functionality(self):
        # Test code here
        pass
        
    def test_load_functionality(self):
        # Test code here
        pass
```

#### Fixture Functions

- Fixture functions typically have descriptive names without a special prefix
- Example: `sample_data()`, `db_connection()`

These naming conventions are crucial because pytest uses them to automatically discover tests. Without following these conventions, pytest won't find and execute your tests.

## Fixtures in pytest

Fixtures in pytest provide a way to set up preconditions for tests and share resources between tests. They help avoid repetitive setup code and make tests more maintainable.

### What are Fixtures?

Fixtures are functions decorated with `@pytest.fixture` that:

- Create and return test data or resources (like database connections, test objects, etc.)
- Can perform setup before tests run and cleanup after tests complete
- Can be easily shared across multiple test functions

### How to Use Fixtures

1. **Define a fixture**:

```python
@pytest.fixture
def sample_data():
    """Provide sample DataFrame for tests."""
    return pd.DataFrame({'A': [1, 2, 3], 'B': ['a', 'b', 'c']})
```

2. **Use the fixture in test functions** by adding it as a parameter:

```python
def test_save_and_load(tmp_path, sample_data):
    # The sample_data fixture is automatically passed to this test
    handler = CSVHandler(str(tmp_path / "test.csv"))
    handler.save(sample_data)
    # Rest of the test...
```

### Fixture Scope

You can control how often fixtures are created with the `scope` parameter:

```python
@pytest.fixture(scope="function")  # Default: recreated for each test
@pytest.fixture(scope="class")     # Created once per test class
@pytest.fixture(scope="module")    # Created once per test module
@pytest.fixture(scope="session")   # Created once per test session
```

### Cleanup with Fixtures

Fixtures can handle cleanup using the `yield` statement:

```python
@pytest.fixture
def database_connection():
    # Setup
    conn = connect_to_database()
    yield conn  # Provide the resource to the test
    # Cleanup (executed after the test completes)
    conn.close()
```

### Built-in Fixtures

pytest provides several built-in fixtures like `tmp_path` and `monkeypatch` that are extremely useful for testing:

```python
def test_with_tempdir(tmp_path):
    # tmp_path is a Path object to a temporary directory
    filepath = tmp_path / "data.csv"
    # The directory and file will be automatically removed after the test
```

### Writing Tests for the CSV Handler

```python
# tests/test_csv_handler.py
import pytest
import pandas as pd
import os
from csv_handler import CSVHandler

@pytest.fixture
def sample_data():
    """Fixture to provide sample DataFrame for tests."""
    return pd.DataFrame({'A': [1, 2, 3], 'B': ['a', 'b', 'c']})

def test_save_and_load(tmp_path, sample_data):
    """Test saving and loading functionality."""
    # Create a temporary file path
    filepath = tmp_path / "test.csv"
    
    # Initialize handler
    handler = CSVHandler(str(filepath))
    
    # Save data
    handler.save(sample_data)
    
    # Verify file exists
    assert os.path.exists(filepath)
    
    # Load data
    loaded_data = handler.load()
    
    # Verify data is the same
    assert sample_data.equals(loaded_data)

def test_save_without_filepath(sample_data):
    """Test saving without providing a filepath."""
    handler = CSVHandler()
    with pytest.raises(ValueError) as excinfo:
        handler.save(sample_data)
    assert "Filepath must be provided" in str(excinfo.value)

def test_load_nonexistent_file():
    """Test loading a file that doesn't exist."""
    handler = CSVHandler("nonexistent_file.csv")
    with pytest.raises(FileNotFoundError):
        handler.load()

def test_save_without_data():
    """Test saving without providing data."""
    handler = CSVHandler("test.csv")
    with pytest.raises(ValueError) as excinfo:
        handler.save()
    assert "No data to save" in str(excinfo.value)
```

### Using Temporary Files and Directories

Pytest provides built-in fixtures for creating temporary files and directories that are automatically cleaned up after tests:

- `tmp_path`: Provides a temporary directory for the test
- `tmp_path_factory`: Allows creation of temporary directories that persist across multiple tests

Example:

```python
def test_multiple_files(tmp_path, sample_data):
    """Test handling multiple files."""
    # Create multiple files
    file1 = tmp_path / "file1.csv"
    file2 = tmp_path / "file2.csv"
    
    # Initialize handler
    handler = CSVHandler()
    
    # Save to different files
    handler.save(sample_data, str(file1))
    
    # Modify data
    modified_data = sample_data.copy()
    modified_data['A'] = [4, 5, 6]
    handler.save(modified_data, str(file2))
    
    # Load from first file
    loaded1 = handler.load(str(file1))
    assert sample_data.equals(loaded1)
    
    # Load from second file
    loaded2 = handler.load(str(file2))
    assert modified_data.equals(loaded2)
```

## Using conftest.py for Shared Fixtures

The `conftest.py` file is a special file in pytest that allows you to define fixtures that are accessible across multiple test files without importing them.

### Project Structure with conftest.py

```
my_project/
├── csv_handler/
│   ├── __init__.py
│   └── csv_handler.py
├── tests/
│   ├── __init__.py
│   ├── conftest.py          # Shared fixtures for all tests
│   ├── test_csv_handler.py
│   └── advanced/
│       ├── conftest.py      # Additional fixtures for advanced tests
│       └── test_features.py
└── pyproject.toml
```

The `conftest.py` file can be placed at different levels in the directory structure. Fixtures in a parent directory's `conftest.py` are available to all tests in that directory and its subdirectories.

### Creating a conftest.py File

Place this file in your tests directory or any parent directory:

```python
# tests/conftest.py
import pytest
import pandas as pd
import os

@pytest.fixture(scope="session")
def sample_data():
    """Provide sample DataFrame for all tests."""
    return pd.DataFrame({'A': [1, 2, 3], 'B': ['a', 'b', 'c']})

@pytest.fixture(scope="function")
def csv_handler():
    """Provide a fresh CSVHandler instance for each test."""
    from csv_handler import CSVHandler
    return CSVHandler()

@pytest.fixture(scope="session")
def test_config():
    """Provide test configuration for all tests."""
    return {
        "max_rows": 1000,
        "default_encoding": "utf-8",
        "allowed_extensions": [".csv", ".tsv"]
    }
```

### Using conftest Fixtures

These fixtures are automatically discovered by pytest and can be used in any test file:

```python
# tests/test_csv_handler.py
def test_save_functionality(tmp_path, csv_handler, sample_data):
    # Use fixtures from conftest.py without imports
    filepath = tmp_path / "test.csv"
    csv_handler.save(sample_data, str(filepath))
    assert os.path.exists(filepath)

# tests/test_advanced_features.py
def test_encoding_handling(csv_handler, test_config):
    # Use the same fixtures in different test files
    assert csv_handler.default_encoding == test_config["default_encoding"]
```

so you only need to add `sample_data` as an argument, an pytest will handle that the proper function or object is provided.

### Benefits of conftest.py

1. **Reduced Duplication**: Define fixtures once, use them everywhere
1. **Automatic Discovery**: No imports needed in test files
1. **Hierarchical Structure**: Can have multiple conftest.py files in different directories
1. **Test Organization**: Keep test setup code separate from test logic

## Using Mock Objects and Monkeypatching

When testing code that interacts with external systems (like files, databases, or APIs), it's often beneficial to replace these interactions with mock objects. This allows you to test your code without depending on external resources and simulate various scenarios.

### Monkeypatching with pytest

The `monkeypatch` fixture allows you to temporarily modify attributes, classes, or functions during a test:

```python
def test_load_with_monkeypatch(monkeypatch, sample_data):
    """Test loading with monkeypatched pandas read_csv function."""
    # Create a mock function that returns our sample data instead of reading a file
    def mock_read_csv(filepath):
        return sample_data
    
    # Replace pandas.read_csv with our mock function
    monkeypatch.setattr(pd, "read_csv", mock_read_csv)
    
    # Now when our handler calls pd.read_csv, it will use our mock function
    handler = CSVHandler("dummy_path.csv")
    loaded_data = handler.load()
    
    # Verify our mock was used by checking the returned data
    assert loaded_data.equals(sample_data)
```

### Using the unittest.mock Library

For more complex mocking scenarios, pytest works well with Python's `unittest.mock` library:

```python
from unittest.mock import Mock, patch

def test_save_with_mock():
    """Test save method by mocking pandas DataFrame."""
    # Create a mock DataFrame
    mock_df = Mock()
    
    # Create our handler
    handler = CSVHandler("test.csv")
    
    # Call save with the mock DataFrame
    handler.save(mock_df)
    
    # Verify that to_csv was called on our mock DataFrame with the right arguments
    mock_df.to_csv.assert_called_once_with("test.csv", index=False)
```

### Example: Testing Error Handling with Mocks

Suppose our CSVHandler needs to handle corrupted CSV files:

```python
def test_corrupted_file_handling(monkeypatch):
    """Test that the handler properly handles corrupted CSV files."""
    # Create a mock function that raises a pandas error
    def mock_read_csv(filepath):
        raise pd.errors.ParserError("Error tokenizing data. C error: EOF inside string starting at row 1")
    
    # Replace pandas.read_csv with our mock function
    monkeypatch.setattr(pd, "read_csv", mock_read_csv)
    
    # Create our handler
    handler = CSVHandler("corrupted.csv")
    
    # Verify that the appropriate exception is raised
    with pytest.raises(pd.errors.ParserError):
        handler.load()
```

### Example: Mocking Network Requests

If our CSVHandler could load data from a URL:

```python
# Add to CSVHandler class
def load_from_url(self, url):
    """Load CSV data from a URL."""
    response = requests.get(url)
    response.raise_for_status()  # Raise exception for HTTP errors
    self.data = pd.read_csv(io.StringIO(response.text))
    return self.data
```

We can test this without making actual network requests:

```python
@patch('requests.get')
def test_load_from_url(mock_get):
    """Test loading CSV data from a URL without making actual requests."""
    # Create a mock response
    mock_response = Mock()
    mock_response.text = "A,B\n1,a\n2,b\n3,c"
    mock_response.raise_for_status = Mock()  # Mock the raise_for_status method
    
    # Configure the mock get function to return our mock response
    mock_get.return_value = mock_response
    
    # Create our handler and call load_from_url
    handler = CSVHandler()
    data = handler.load_from_url("https://example.com/data.csv")
    
    # Verify requests.get was called with the correct URL
    mock_get.assert_called_once_with("https://example.com/data.csv")
    
    # Verify the data was correctly parsed
    assert len(data) == 3
    assert list(data.columns) == ['A', 'B']
```

### Benefits of Mocking

1. **Faster tests**: No waiting for file I/O or network calls
1. **More reliable tests**: Not affected by external factors
1. **Complete test coverage**: Test error conditions difficult to reproduce in real environments
1. **Isolated tests**: Test your code, not dependencies

## Testing Edge Cases

Edge cases are unusual inputs or conditions that might cause your code to fail. Testing them is crucial for robust software.

### Examples of Edge Cases for the CSV Handler:

```python
def test_empty_dataframe(tmp_path):
    """Test saving and loading an empty DataFrame."""
    filepath = tmp_path / "empty.csv"
    empty_df = pd.DataFrame()
    
    handler = CSVHandler(str(filepath))
    handler.save(empty_df)
    
    loaded = handler.load()
    assert loaded.empty
    
def test_special_characters(tmp_path):
    """Test handling data with special characters."""
    filepath = tmp_path / "special.csv"
    special_df = pd.DataFrame({
        'A': [1, 2, 3],
        'B': ['a,b', 'c"d', 'e\nf']
    })
    
    handler = CSVHandler(str(filepath))
    handler.save(special_df)
    
    loaded = handler.load()
    assert special_df.equals(loaded)

def test_large_dataframe(tmp_path):
    """Test with a large DataFrame."""
    filepath = tmp_path / "large.csv"
    large_df = pd.DataFrame({
        'A': range(10000),
        'B': ['x' * (i % 100) for i in range(10000)]
    })
    
    handler = CSVHandler(str(filepath))
    handler.save(large_df)
    
    loaded = handler.load()
    assert large_df.equals(loaded)
```

## Using pytest-cov for Coverage Analysis

pytest-cov is a plugin that measures code coverage during test execution. It helps identify parts of your code that aren't being tested.

### Installation

```bash
uv install pytest-cov
```

### Basic Usage

```bash
pytest --cov=csv_handler
```

### Configuration in pyproject.toml

```toml
[tool.pytest.ini_options]
addopts = "--cov=csv_handler --cov-report=term --cov-report=html"

[tool.coverage.run]
source = ["csv_handler"]
omit = ["*/__init__.py"]

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "def __repr__",
    "raise NotImplementedError",
    "if __name__ == .__main__.:",
    "pass",
    "raise ImportError",
]
```

### Understanding Coverage Reports

Coverage reports provide metrics on:

- **Statement coverage**: Percentage of statements executed
- **Branch coverage**: Percentage of conditional branches executed
- **Function coverage**: Percentage of functions called
- **Line coverage**: Percentage of lines executed

A high coverage percentage doesn't guarantee bug-free code, but low coverage definitely indicates inadequate testing.

### Interpreting Coverage Results

```
----------- coverage: platform linux, python 3.9.5-final-0 -----------
Name                     Stmts   Miss  Cover
--------------------------------------------
csv_handler/__init__.py      1      0   100%
csv_handler/csv_handler.py  20      0   100%
--------------------------------------------
TOTAL                       21      0   100%
```

This shows that all lines in our code have been executed during tests, but it doesn't guarantee that all possible scenarios have been tested.

## Property-Based Testing with Hypothesis

Hypothesis is a powerful library for property-based testing. Instead of writing tests with specific examples, you define properties that should hold true for any input, and Hypothesis automatically generates test cases.

### Installation

```bash
uv install hypothesis
```

### Why Hypothesis is Valuable for Data Science

1. **Automated Edge Case Discovery**: Hypothesis finds edge cases you might not think of
1. **Exhaustive Testing**: Tests a wider range of inputs than you would manually write
1. **Reproducibility**: Failed tests can be reproduced exactly
1. **Shrinking**: When a test fails, Hypothesis finds the simplest example that still fails

### Example: Testing a Simple Calculator

Consider a calculator class with basic operations:

```python
# calculator.py
class Calculator:
    def add(self, a, b):
        return a + b
    
    def subtract(self, a, b):
        return a - b
    
    def multiply(self, a, b):
        return a * b
    
    def divide(self, a, b):
        if b == 0:
            raise ValueError("Cannot divide by zero")
        return a / b
```

### Understanding the Power of Hypothesis

Let's consider a simple property of addition: commutativity. This means that you expect that the order of addition doesnt matter, so a+b=b+a should alway be true, for every number.

**Traditional Testing Approach:**

```python
def test_addition_commutative_traditional():
    calc = Calculator()
    # Test a few specific examples
    assert calc.add(2, 3) == calc.add(3, 2)
    assert calc.add(0, 5) == calc.add(5, 0)
    assert calc.add(-1, 7) == calc.add(7, -1)
```

This works, but it only tests three specific cases. What about decimals? Large numbers? What about values that might trigger floating-point precision issues?

**Property-Based Testing with Hypothesis:**

Instead of choosing specific examples, we can define the *property* we want to test and let Hypothesis generate hundreds of test cases automatically:

### Finding Floating-Point Issues

Let's examine what happens when we test commutativity without using `pytest.approx`:

```python
@given(st.floats(allow_nan=False, allow_infinity=False), 
       st.floats(allow_nan=False, allow_infinity=False))
def test_add_commutative_strict(a, b):
    """Test that addition is commutative: a + b == b + a."""
    calc = Calculator()
    # Compare directly without approximation
    assert calc.add(a, b) == calc.add(b, a)
```

When you run this test, Hypothesis will quickly find cases where it fails due to floating-point precision issues. For example, with very large numbers, the exact equality check fails even though mathematically the operation is commutative.

### Adding Tolerance for Floating-Point Comparisons

Instead of using `pytest.approx`, we can implement our own comparison with an explicit epsilon value:

```python
@given(st.floats(allow_nan=False, allow_infinity=False, min_value=-1e15, max_value=1e15), 
       st.floats(allow_nan=False, allow_infinity=False, min_value=-1e15, max_value=1e15))
def test_add_commutative_with_epsilon(a, b):
    """Test that addition is commutative within floating-point tolerance."""
    calc = Calculator()
    
    # Calculate both directions
    result1 = calc.add(a, b)
    result2 = calc.add(b, a)
    
    # For very large numbers, use relative epsilon
    if abs(a) > 1e10 or abs(b) > 1e10:
        # Relative tolerance (1e-10 means 0.0000000001% difference allowed)
        epsilon = abs(result1) * 1e-10
    else:
        # Absolute tolerance for smaller numbers
        epsilon = 1e-10
    
    # Check if the difference is within epsilon
    assert abs(result1 - result2) <= epsilon, f"Failed: |{result1} - {result2}| > {epsilon}"
```

This approach:

1. Explicitly sets bounds on the input values to avoid overflow
1. Uses a relative tolerance for large numbers
1. Uses an absolute tolerance for smaller numbers
1. Provides a helpful error message showing the actual difference

## Conclusion

Testing is a crucial aspect of software development, especially in data science where results need to be reliable. By leveraging tools like pytest, pytest-cov, and Hypothesis, you can:

1. Automate testing to catch bugs early
1. Ensure code works correctly across a range of inputs
1. Confidently refactor and improve your code
1. Document expected behavior
1. Find edge cases you might not have considered

Remember that testing is an investment that pays off by saving debugging time and increasing confidence in your code's correctness.

You can find more on testing in the [MADS-deployment](https://github.com/raoulg/MADS-deployment) course, specifically lesson `3-testing`. Over there, you can check out the presentation (in the folder `presentations` and find some working code (eg tests for the calculator example) and some exercises.

[← Previous: Encapsulation](encapsulation.md) | [Next: Open Closed →](open_closed.md)
