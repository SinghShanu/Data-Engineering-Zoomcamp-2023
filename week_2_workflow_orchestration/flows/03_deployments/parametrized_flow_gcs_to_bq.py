from pathlib import Path
import pandas as pd
from prefect import flow, task
from prefect_gcp.cloud_storage import GcsBucket
from prefect_gcp import GcpCredentials

@task()
def extract_from_gcs(color: str, year: int, month: int) -> Path:
    """Download trip data from GCS"""
    
    gcs_path = f"data/{color}/{color}_tripdata_{year}-{month:02}.parquet"
    gcs_block = GcsBucket.load("zoom-gcs")
    gcs_block.get_directory(
        from_path=gcs_path,
        local_path=f"."
    )
    return Path(f"{gcs_path}")

@task()
def transform(path: Path) -> pd.DataFrame:
    """Data Cleaning Example"""
    df = pd.read_parquet(path=path)
    #print(f"Pre: passenger count: {df['passenger_count'].isna().sum()}")
    #df['passenger_count'].fillna(0, inplace=True)
    #print(f"Post: passenger count: {df['passenger_count'].isna().sum()}")
    return df

@task()
def write_bq(df: pd.DataFrame) -> None:
    """Write df to bigquery"""

    gcp_credentials_block = GcpCredentials.load("zoom-gcp-creds")

    df.to_gbq(
        destination_table='dezoomcamp.ny_taxi_rides',
        project_id='our-tract-375019',
        credentials=gcp_credentials_block.get_credentials_from_service_account(),
        chunksize=500_000,
        if_exists="append"
    )

@flow(log_prints=True)
def etl_gcs_to_bq(year: int, month: int, color: str) -> None:
    """Main ETL Flow"""

    path = extract_from_gcs(color, year, month)
    df = transform(path)
    write_bq(df)

@flow(log_prints=True)
def etl_parent_flow(
    months: list = [1, 2], year: int = 2021, color: str="yellow"
):
    for month in months:
        etl_gcs_to_bq(year, month, color)

if __name__=='__main__':
    color="yellow"
    months = [2, 3]
    year = 2019
    etl_parent_flow(months, year, color)

