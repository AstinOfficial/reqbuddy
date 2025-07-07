import os
import warnings
from typing import List, Optional

def get_requirement(
    requirements_path: Optional[str] = None,
    strip_versions: bool = False,
    deduplicate: bool = True
) -> Optional[List[str]]:
    """
    Reads a requirements.txt file and returns a list of dependencies.

    Parameters:
    ----------
    requirements_path : str or None
        Path to the requirements.txt file. If None, looks for it in the current directory.
    strip_versions : bool
        If True, strips version specifiers (e.g., 'requests==2.0' → 'requests')
    deduplicate : bool
        If True, removes duplicate packages

    Returns:
    -------
    list[str] or None
        List of requirement lines or None if file not found.
    """
    if requirements_path is None:
        requirements_path = os.path.join(os.getcwd(), "requirements.txt")

    if not os.path.exists(requirements_path):
        warnings.warn(f"'{requirements_path}' not found.")
        return None

    try:
        with open(requirements_path, "r", encoding="utf-8") as f:
            lines = f.read().splitlines()
    except UnicodeDecodeError:
        with open(requirements_path, "r", encoding="latin-1") as f:
            lines = f.read().splitlines()

    requirements = []
    seen = set()
    version_operators = ["==", ">=", "<=", "~=", "!=", ">", "<"]

    for line in lines:
        line = line.strip()
        if not line or line.startswith("#"):
            continue

        # Remove inline comments
        if " #" in line:
            line = line.split(" #", 1)[0].strip()

        # Strip version if required
        name = line
        if strip_versions:
            for op in version_operators:
                if op in line:
                    name = line.split(op, 1)[0].strip()
                    break
            line = name

        if deduplicate and name in seen:
            continue

        seen.add(name)
        requirements.append(line)

    return requirements