import pandas as pd
import numpy as np
import os
from datetime import date, timedelta
import requests
from bs4 import BeautifulSoup
import yfinance as yf
from script_rus_except import rus

def ddp_mod(customers, days):
    with pd.ExcelWriter('clients.xlsx', engine='xlsxwriter') as writer:
        for client in customers:
            if customers[client]['location'] == 'RUS':
                df = rus(days)
            else:
                date_range = [(date.today() - timedelta(days)).strftime('%Y-%m-%d'), date.today().strftime('%Y-%m-%d')]
                oil = yf.Ticker("BZ=F").history(start=date_range[0], end=date_range[1])['Close'].rename('OIL')
                usd = yf.Ticker("EURUSD=X").history(start=date_range[0], end=date_range[1])['Close'].rename('EURUSD=X')
                dbc = pd.concat([oil, usd], axis=1, join='inner').sort_index(ascending=False)
                roll = dbc.rolling(30, min_periods=1)
                dbc['EURUSD_mov_avrg'] = roll.mean()['EURUSD=X']
                dbc['OIL_mov_avrg'] = roll.mean()['OIL']
                dbc['prod_cost'] = ((dbc['OIL_mov_avrg'] * 16) / dbc['EURUSD_mov_avrg']) + 400
                dbc['price_B'] = dbc['prod_cost'] * 1.38 * 0.95
                df = dbc[['EURUSD=X', 'OIL', 'EURUSD_mov_avrg', 'OIL_mov_avrg', 'prod_cost', 'price_B']].copy()
            if customers[client]['location'] == 'EU':
                df['DDP'] = dbc['price_B'] + 30
            elif customers[client]['location'] == 'CN':
                df['DDP'] = dbc['price_B'] + 130 / dbc['EURUSD_mov_avrg']
            else:
                df['DDP'] = df['price_B(RUB)']
            df.to_excel(writer, sheet_name=str(client))
            
def total_mod(customers):
    discounts = {'up to 100': 0.01, 
                 'up to 300': 0.05, 
                 '300 plus': 0.1}
    if os.path.exists('для_клиентов/') == False:
        os.mkdir('для_клиентов')
    for client in customers:
        df = pd.read_excel('clients.xlsx', sheet_name=client)
        if customers[client]['comment'] == 'moving_average':
            if (customers[client]['volumes'] * 30) <= 100:
                discount = 1 - float(discounts['up to 100'])
            elif (customers[client]['volumes'] * 30) > 300:
                discount = 1 - float(discounts['300 plus'])
            else:
                discount = 1 - float(discounts['up to 300'])
            df['Total'] = df['DDP'] * customers[client]['volumes'] * discount
        else:
            if customers[client]['volumes'] <= 100:
                discount = 1 - float(discounts['up to 100'])
            elif customers[client]['volumes'] > 300:
                discount = 1 - float(discounts['300 plus'])
            else:
                discount = 1 - float(discounts['up to 300'])
            df['Total'] = df['DDP'] * (customers[client]['volumes'] / 30) * discount
        df.to_excel(f'для_клиентов/{client}.xlsx', index=False)
