import pandas as pd
import numpy as np
import os
from datetime import date, timedelta
import requests
from bs4 import BeautifulSoup
import yfinance as yf

def rus(days):
    try:
        date_range = [(date.today() - timedelta(days)).strftime('%d.%m.%Y'), date.today().strftime('%d.%m.%Y')]
    except TypeError:
        print('Количество дней ретро-периода указано некорректно, укажите целое число без кавычек.')
    else:
        url = f'http://www.cbr.ru/currency_base/dynamics/?UniDbQuery.Posted=True&UniDbQuery.so=1&UniDbQuery.mode=1&UniDbQuery.date_req1=&UniDbQuery.date_req2=&UniDbQuery.VAL_NM_RQ=R01239&UniDbQuery.From={date_range[0]}&UniDbQuery.To={date_range[1]}'
    
        try:
            res = requests.get(url)
        except:
            print('Ошибка Интернет-подключения, проверьте связь.')
        else:
            soup = BeautifulSoup(res.text, 'lxml')
            dates = list(map(lambda x: pd.to_datetime(x, format='%d.%m.%Y'), [tag.text for tag in soup.find_all("td")][1::3]))
            course = list(map(lambda x: float('.'.join(x.split(','))), [tag.text for tag in soup.find_all("td")][3::3]))
            eur = pd.DataFrame({'EURRUB': course}, index=dates)

            date_range = [(date.today() - timedelta(days)).strftime('%Y-%m-%d'), date.today().strftime('%Y-%m-%d')]
            oil = yf.Ticker("BZ=F").history(start=date_range[0], end=date_range[1])['Close'].rename('OIL')
            usd = yf.Ticker("EURUSD=X").history(start=date_range[0], end=date_range[1])['Close'].rename('EURUSD=X')

            dbc = pd.concat([oil, usd, eur], axis=1, join='inner').sort_index(ascending=False)

            roll = dbc.rolling(30, min_periods=1)
            dbc['EURUSD_mov_avrg'] = roll.mean()['EURUSD=X']
            dbc['OIL_mov_avrg'] = roll.mean()['OIL']
            dbc['EURRUB_mov_avrg'] = roll.mean()['EURRUB']

            dbc['prod_cost'] = ((dbc['OIL_mov_avrg'] * 16) / dbc['EURUSD_mov_avrg']) + 400

            dbc['price_B(RUB)'] = dbc['prod_cost'] * 1.38 * 0.95 * dbc['EURRUB_mov_avrg']
            dbc.to_excel('rus_client.xlsx')

            return dbc
