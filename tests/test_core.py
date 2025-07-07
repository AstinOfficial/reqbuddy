import os
import tempfile
from reqbuddy import get_requirement

def write_temp_requirements(contents: str) -> str:
    fd, path = tempfile.mkstemp(text=True)
    with open(path, "w") as f:
        f.write(contents)
    return path

def test_basic_reading():
    path = write_temp_requirements("flask==2.0.0\nrequests")
    result = get_requirement(path)
    assert result == ["flask==2.0.0", "requests"]

def test_strip_versions():
    path = write_temp_requirements("flask==2.0.0\nrequests>=2.0")
    result = get_requirement(path, strip_versions=True)
    assert result == ["flask", "requests"]

def test_deduplicate():
    path = write_temp_requirements("flask\nflask\nrequests")
    result = get_requirement(path, deduplicate=True)
    assert result == ["flask", "requests"]

def test_comments_and_blanks():
    path = write_temp_requirements("# comment\n\nflask>=2.0  # inline\n")
    result = get_requirement(path)
    assert result == ["flask>=2.0"]
