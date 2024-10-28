import re
from pathlib import Path
from typing import List, Optional


def extract_doc_links_from_readme(readme_content: str) -> List[str]:
    """Extract documentation file paths from readme table in order."""
    # Find all markdown links to docs/*.md files
    doc_links = re.findall(r"\[.*?\]\((docs/.*?\.md)\)", readme_content)
    # Remove duplicates while preserving order
    return list(dict.fromkeys(doc_links))


def get_relative_link(file_path: str) -> str:
    """Convert docs/file.md to file.md for relative linking within docs folder."""
    return Path(file_path).name


def add_navigation_links(
    content: str, prev_file: Optional[str], next_file: Optional[str]
) -> str:
    """Add navigation links to the content."""
    navigation = []

    if prev_file:
        prev_name = Path(prev_file).stem.replace("_", " ").title()
        prev_link = get_relative_link(prev_file)
        navigation.append(f"[← Previous: {prev_name}]({prev_link})")
    if next_file:
        next_name = Path(next_file).stem.replace("_", " ").title()
        next_link = get_relative_link(next_file)
        navigation.append(f"[Next: {next_name} →]({next_link})")

    if not navigation:
        return content

    nav_text = " | ".join(navigation)

    # Check if content already has navigation links
    if "← Previous:" in content or "Next:" in content:
        # Replace existing navigation
        content = re.sub(r"\[← Previous:.*?\n", "", content)
        content = re.sub(r"\[Next:.*?\n", "", content)

    # Add navigation at the top and bottom
    nav_block = f"\n{nav_text}\n"
    return f"{nav_block}\n{content.strip()}\n{nav_block}\n"


def process_documentation_files(readme_path: Path):
    """Process all documentation files and add navigation links."""
    # Read README
    readme_content = readme_path.read_text()

    # Get ordered list of doc files
    doc_files = extract_doc_links_from_readme(readme_content)

    # Process each file
    for i, current_file in enumerate(doc_files):
        current_path = readme_path.parent / current_file

        if not current_path.exists():
            print(f"Warning: {current_file} not found")
            continue

        prev_file = doc_files[i - 1] if i > 0 else None
        next_file = doc_files[i + 1] if i < len(doc_files) - 1 else None

        content = current_path.read_text()
        updated_content = add_navigation_links(content, prev_file, next_file)

        # Write updated content
        current_path.write_text(updated_content)
        print(f"Updated {current_file}")


if __name__ == "__main__":
    readme_path = Path("README.md")
    process_documentation_files(readme_path)
