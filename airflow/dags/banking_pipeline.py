from datetime import datetime, timedelta
from pathlib import Path
import csv
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.bash import BashOperator
from airflow.providers.snowflake.hooks.snowflake import SnowflakeHook

SNOWFLAKE_CONN_ID = "snowflake_conn"
DATA_PATH = Path("/opt/airflow/data")
DATABASE = "CAPSTONE_DB"
SCHEMA = "RAW"
STAGE = "CAPSTONE_STAGE"
TABLE = "RAW_BANKING_DATA"
FILE_FORMAT = "CAPSTONE_DB.RAW.CSV_FORMAT"

def load_csv_files():
    hook = SnowflakeHook(
        snowflake_conn_id=SNOWFLAKE_CONN_ID
    )
    conn = hook.get_conn()
    cursor = conn.cursor()
    try:

        files = list(DATA_PATH.glob("*.csv"))
        if not files:
            print("No CSV files found.")
            return

        print(f"Found {len(files)} CSV file(s).")
        for file in files:
            print(f"Found: {file.name}")

        first_file = files[0]
        with open( first_file, "r", encoding="utf-8-sig", newline="") as f:
            reader = csv.reader(f)
            columns = next(reader)

        columns = [column.strip().upper()for column in columns]
        print("CSV columns:")
        print(columns)

        column_sql = ", ".join(
            f'"{column}" VARCHAR'
            for column in columns)
        create_table_sql = f"""
        CREATE TABLE IF NOT EXISTS
        {DATABASE}.{SCHEMA}.{TABLE}
        ({column_sql},
          _LOADED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP())"""
        cursor.execute(create_table_sql)

        for file in files:
            print(f"\nProcessing: {file.name}")
            put_sql = f"""
            PUT 'file://{file}'
            @{DATABASE}.{SCHEMA}.{STAGE}
            AUTO_COMPRESS=FALSE
            OVERWRITE=FALSE"""
            cursor.execute(put_sql)
            print(f"Uploaded to stage: {file.name}")

        target_columns = ", ".join(f'"{column}"' for column in columns)
        select_columns = ", ".join(f"${i}" for i in range(1, len(columns) + 1))

        copy_sql = f"""
        COPY INTO {DATABASE}.{SCHEMA}.{TABLE}
        ({target_columns},
          _LOADED_AT)
        FROM
        (SELECT
            {select_columns},
            CURRENT_TIMESTAMP()
        FROM @{DATABASE}.{SCHEMA}.{STAGE})
        FILE_FORMAT = (FORMAT_NAME = '{FILE_FORMAT}')
        PATTERN = '.*[.]csv'
        ON_ERROR = 'ABORT_STATEMENT'
        FORCE = FALSE
        """
        cursor.execute(copy_sql)
        results = cursor.fetchall()
        for result in results:
            print(result)
    finally:
        cursor.close()
        conn.close()

default_args = {
    "retries": 3,
    "retry_delay": timedelta(minutes=1),
}

with DAG(
    dag_id="banking_raw_ingestion",
    default_args=default_args,
    start_date=datetime(2026, 1, 1),
    schedule=None,
    catchup=False,
    tags=[ "banking", "snowflake", "dbt", "incremental"],
) as dag:

    load_raw_data = PythonOperator(
        task_id="load_csv_to_raw",
        python_callable=load_csv_files,)

    dbt_staging = BashOperator(
        task_id="dbt_staging",
        bash_command="""
        cd "/opt/airflow/dbt/analytics"
        dbt build \
          --project-dir "/opt/airflow/dbt/analytics" \
          --profiles-dir "/home/airflow/.dbt" \
          --select "path:models/staging"
        """,
    )

    dbt_snapshot = BashOperator(
    task_id="dbt_snapshot",
    bash_command="""
    cd "/opt/airflow/dbt/analytics"
    dbt snapshot \
      --project-dir "/opt/airflow/dbt/analytics" \
      --profiles-dir "/home/airflow/.dbt"
    """,
)

    dbt_core = BashOperator(
        task_id="dbt_core",
        bash_command="""
        cd "/opt/airflow/dbt/analytics"
        dbt build \
          --project-dir "/opt/airflow/dbt/analytics" \
          --profiles-dir "/home/airflow/.dbt" \
          --select "path:models/intermediate"
        """,
    )

    dbt_mart = BashOperator(
        task_id="dbt_mart",
        bash_command="""
        cd /opt/airflow/dbt/analytics
        dbt build \
          --project-dir /opt/airflow/dbt/analytics \
          --profiles-dir /home/airflow/.dbt \
          --select "path:models/mart"
        """,
    )
    load_raw_data >> dbt_staging >> dbt_snapshot >> dbt_core >> dbt_mart