"""
main.py
~~~~~~~
"""
import os
import sys
from pathlib import Path
import file_reader

DATA_PATH = os.path.join(Path(__file__).resolve().parent, 'data')
file_name = os.path.join(DATA_PATH, 'traffic.csv')
print(f'{os.path.isfile(file_name)=}')

reader = file_reader.CSVReader(b",", file_name)
reader.open_file()
reader.read_file()

contents = reader.get_contents()

print(f'{type(contents)=}\n{contents=}')
reader.close_file()
