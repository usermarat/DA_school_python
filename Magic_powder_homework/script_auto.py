import pandas as pd
import numpy as np
import os
from script_ddp import ddp
from script_total import total

def auto(customers):
    dbc = pd.read_excel('cur_oil.xlsx', index_col='Date')
    dbc.fillna(method="bfill", inplace=True)

    roll = dbc.rolling(30, min_periods=1)
    dbc['EURUSD_mov_avrg'] = roll.mean()['EURUSD=X']
    dbc['OIL_mov_avrg'] = roll.mean()['OIL']

    dbc['prod_cost'] = ((dbc['OIL_mov_avrg'] * 16) / dbc['EURUSD_mov_avrg']) + 400

    marginA_oct2018 = 1600 / dbc['2018-10']['prod_cost'].mean()
    marginA_nov2018 = 1550 / dbc['2018-11']['prod_cost'].mean()
    marginA_feb2019 = 1600 / dbc['2019-02']['prod_cost'].mean()
    
    dbc_mean = dbc.resample('M').mean()
    dbc_mean['margin_A'] = list(np.nan for i in range(len(dbc_mean)))
    dbc_mean.loc['2018-10-31', 'margin_A'] = marginA_oct2018
    dbc_mean.loc['2018-11-30', 'margin_A'] = marginA_nov2018
    dbc_mean.loc['2019-02-28', 'margin_A'] = marginA_feb2019

    dbc_mean['margin_A'].interpolate(method='linear', limit_direction='both', inplace=True)
    dbc['margin_A'] = list(np.nan for i in range(len(dbc)))

    for month, val in dbc_mean['margin_A'].to_dict().items():
        for i in dbc.index:
            if (i + pd.offsets.MonthEnd()) == month:
                dbc.loc[i, 'margin_A'] = val

    dbc['price_B'] = dbc['prod_cost'] * dbc['margin_A'] * 0.95
    
    EU_LOGISTIC_COST_EUR = 30 
    CN_LOGISTIC_COST_USD = 130
    discounts = {'up to 100': 0.01, 
                 'up to 300': 0.05, 
                 '300 plus': 0.1}
    
    ddp(dbc, customers, EU_LOGISTIC_COST_EUR, CN_LOGISTIC_COST_USD)
    total(customers, discounts)
    
