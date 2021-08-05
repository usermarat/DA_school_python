import pandas as pd
import numpy as np
import os

def total(customers, discounts):
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
