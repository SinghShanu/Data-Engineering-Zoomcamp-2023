#!/usr/bin/env python
# coding: utf-8

import os, sys
import argparse
from time import time
from datetime import timedelta
import pandas as pd
from sqlalchemy import create_engine
from prefect import flow, task
from prefect.tasks import task_input_hash
import logging, traceback
from prefect_sqlalchemy import SqlAlchemyConnector

@flow(name="Main Ingestion Flow")
def main_flow():
    parser = argparse.ArgumentParser(description='Ingest CSV data to Postgres')
    #parser.add_argument('--user', required=True, help='user name for postgres')
    #parser.add_argument('--password', required=True, help='password for postgres')
    #parser.add_argument('--host', required=True, help='host for postgres')
    #parser.add_argument('--port', required=True, help='port for postgres')
    #parser.add_argument('--db', required=True, help='database name for postgres')
    parser.add_argument('--table_name', required=True, help='name of the table where we will write the results to')
    parser.add_argument('--url', required=True, help='url of the csv file')
    args = parser.parse_args()
    
    if args:
        raw_data = extract_data(args.url)
        data = transform_data(raw_data)
        ingest_data(args.table_name, data)
    else:
        print("Issues with passed arguments. Please check and rerun the program with correct arguments")
        sys.exit()

@task(log_prints=True, retries=3, cache_key_fn=task_input_hash, cache_expiration=timedelta(days=1))
def extract_data(url:str) -> pd.DataFrame:
    # the backup files are gzipped, and it's important to keep the correct extension
    # for pandas to be able to open the file
    if url.endswith('.csv.gz'):
        csv_name = 'output.csv.gz'
    else:
        csv_name = 'output.csv'

    os.system(f"wget {url} -O {csv_name}")
    df = pd.read_csv(csv_name, low_memory=False)
    return df   

@task(log_prints=True)
def transform_data(df: pd.DataFrame) -> pd.DataFrame:
    print(f"Pre: missing passenger count: {df['passenger_count'].isin([0]).sum()}")
    df = df[df['passenger_count'] != 0]
    print(f"Post: missing passenger count: {df['passenger_count'].isin([0]).sum()}")
    return df

@task(log_prints=True, retries=1)
def ingest_data(table_name:str, df:pd.DataFrame) -> None:
    
    #postgres_url = f"postgresql://{user}:{password}@{host}:{port}/{db}"
    connection_block = SqlAlchemyConnector.load("postgres-connector")

    #engine = create_engine(postgres_url)
    df.tpep_pickup_datetime = pd.to_datetime(df.tpep_pickup_datetime)
    df.tpep_dropoff_datetime = pd.to_datetime(df.tpep_dropoff_datetime)
    
    with connection_block.get_connection(begin=False) as engine:
        df.head(n=0).to_sql(name=table_name, con=engine, if_exists='replace')

        try:
            t_start = time()
            df.to_sql(name=table_name, con=engine, if_exists='append')
            t_end = time()
            print('inserted all rows, took %.3f second' % (t_end - t_start))
        except Exception as e:
            logging.error(traceback.format_exc())
            sys.exit()
   
if __name__ == '__main__':
    main_flow()