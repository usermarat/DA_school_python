import pandas as pd
import numpy as np

def ddp(dbc, customers, EU, CN):
    with pd.ExcelWriter('clients.xlsx', engine='xlsxwriter') as writer:
        for client in customers:
            df = dbc[['EURUSD=X', 'OIL', 'EURUSD_mov_avrg', 'OIL_mov_avrg', 'prod_cost', 'price_B']].copy()
            if customers[client]['location'] == 'EU':
                df['DDP'] = dbc['price_B'] + EU
            else:
                df['DDP'] = dbc['price_B'] + CN / dbc['EURUSD_mov_avrg']
            df.to_excel(writer, sheet_name=str(client))
