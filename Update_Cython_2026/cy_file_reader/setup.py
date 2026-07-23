"""
setup.py
~~~~~~~~
To compile, copy-paste the following into the terminal:

python3.12 setup.py build_ext --inplace

Please change the Python version to the one you are using.
"""
import os
import sys
from pathlib import Path
from setuptools import setup, find_packages
from Cython.Build import cythonize

BASE_DIR = Path(__file__).resolve().parent
pyx_pattern = os.path.join(BASE_DIR, "src", "cython_src", "*.pyx")
SRC_DIR = os.path.join(BASE_DIR, 'src')

setup(
    name='CyModels',
    version='0.1.0',
    packages=find_packages(),
    ext_modules=cythonize(
        module_list=pyx_pattern,
        compiler_directives={"language_level": "3", "embedsignature": True},
        include_path=[SRC_DIR]
    )
)
