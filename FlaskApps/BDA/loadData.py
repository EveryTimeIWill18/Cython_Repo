import os
import numpy as np
import pandas as pd
import json
class GenRandData(object):
    """
    generate some random data
    to test out the Flask app.
    """
    def __init__(self, rows: int, cols: int):
        self.random_mtx_rows = np.random.randint(0, 10000, rows)
        self.random_mtx_cols = np.random.randint(0, 10000, cols)
        self.df = pd.DataFrame({'rows': self.random_mtx_rows, 'cols':self.random_mtx_cols})

df1 = GenRandData(3,3).df
print(json.dumps(df1.to_dict(orient='records'), indent=2))
#print(df1.to_json(orient='columns'))
