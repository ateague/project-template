#!/bin/bash
# License: See license file
# Author: Alan H Teague

if [ $# -lt 2 ] || [ $# -gt 3 ]; then
	echo "Usage: $0 <project name> <short description> {language=python}"
	exit
fi
if [ -z "$3" ]; then
	lang="python"
else
	lang=$3
fi
if [ "$lang" != "python" ]; then
	echo "Only python is currently supported. Cancelling."
	exit
fi
if [ -d "$1" ]; then
	echo "Directory $1 already exists. Cancelling."
	exit
fi
if [[ ! "$1" =~ ^[a-zA-Z0-9_]+$ ]]; then
	echo "Project names should only contain alphanumeric and underscores. Cancelling."
fi

read -p "Creating $lang project named $1. Continue? (Y/n) " yn
yn=${yn:-y}
case $yn in
	[Yy]* ) echo "... creating project";;
	[Nn]* ) echo "... cancelling"; exit;;
	* ) echo "... no choice is a choice, cancelling"; exit;;
esac

######
# PYTHON
######

# Create project directory
mkdir $1
cd $1

# Create virtual environment
python3 -m venv .venv

#######
# Create project level files
#######

cat <<END > setup.py
from setuptools import setup
setup(use_scm_version=True, setup_cfg="setup.cfg")
END

cat <<END > setup.cfg
[metadata]
name = $1
version = 0.1
author = $USER
description = $2
long_description = file: README.md
long_description_content_type = text/markdown
license = MIT

[options]
packages = find:
install_requires =
	pytest
python_requires=>=3.9

[tools:pytest]
testpaths = tests
END

# Create the README
cat <<END > README.md
# $1

$2

## Overview

TBD: More detailed overview, purposes, key features

## Installation

TBD: Installation instructions

## Usage

TBD: Examples and code snippets etc

## Development

TBD: Instructions for setting up development env for contributing

## Credits

TBD: Third party libraries, references, contributors, etc

## License

TBD: Specify license
END

#######
# Setup code stuff
#######
mkdir $1
touch $1/__init__.py

cat <<END > $1/main.py
from $1.module1 import func1
from $1.class1 import Class1

def main(arg: int) -> int:
	print("$2")
	return arg

if __name__ == "__main__":
	main(1)
END

cat <<END > $1/module1.py
def func1(arg: int) -> int:
	print("module1.func1 of $1")
	return arg
END

cat <<END > $1/class1.py
class Class1:
	class_attr1 = "value"

	def __init__(self, arg1):
		self.inst_attr1 = arg1

	@staticmethod
	def static_method(arg: int) -> int:
		return arg * 2

	@classmethod
	def class_method(self, arg: int) -> int:
		print("Class1.class_method of $1:", Class1.class_attr1)
		return arg

	def inst_method(self, arg: int) -> int:
		print("Class1.inst_method of $1:", Class1.class_attr1, self.inst_attr1)
		return arg
END

#######
# Setup test stuff
#######
mkdir tests
touch tests/__init__.py
cat <<END > tests/test_main.py
import pytest
from $1.main import main

def test_main():
	result = main(2)
	assert result == 2
END

cat <<END > tests/test_module1.py
import pytest
import $1.module1 as module1

@pytest.mark.parametrize("arg, expected", [(1, 1), (2, 2), (3, 3)])
def test_func1(arg, expected):
	result = module1.func1(arg)
	assert result == expected
END

cat <<END > tests/test_class1.py
import pytest
from $1.class1 import Class1

@pytest.fixture
def my_instance():
	obj = Class1(1)
	yield obj
	del obj

class TestClass:
	def test_inst_method(self, my_instance):
		result = my_instance.inst_method(2)
		assert result == 2

	def test_class_method(self, my_instance):
		result = my_instance.class_method(3)
		assert result == 3

	@pytest.mark.parametrize("arg, expected", [(1, 2), (2, 4), (3,6)])
	def test_static_method(self, arg, expected):
		result = Class1.static_method(arg)
		assert result == expected
END

#######
# Setup version control
#######
cat <<END > .gitignore
__pycache__
.venv
END

git init
git add --all
git commit -m "Project $1 created"

echo
source .venv/bin/activate
pip install pytest
pip install --editable .
deactivate
