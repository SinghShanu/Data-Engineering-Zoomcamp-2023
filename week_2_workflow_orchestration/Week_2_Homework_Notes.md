Week 2 Homework
The goal of this homework is to familiarise users with workflow orchestration and observation.

-----------------------------------------------------------------------------------------------------------------------------------------------
Question 1. Load January 2020 data
Using the etl_web_to_gcs.py flow that loads taxi data into GCS as a guide, create a flow that loads the green taxi CSV dataset for January 2020 into GCS and run it. Look at the logs to find out how many rows the dataset has.

How many rows does that dataset have?

447,770
766,792
299,234
822,132

Solution: Submitted via google forms
Logs generated while running script etl_web_to_gcs.py
==============================
python flows/02_gcp/etl_web_to_gcs.py
18:20:17.541 | INFO    | prefect.engine - Created flow run 'amiable-bullfinch' for flow 'etl-web-to-gcs'
18:20:17.696 | INFO    | Flow run 'amiable-bullfinch' - Created task run 'fetch-b4598a4a-0' for task 'fetch'
18:20:17.699 | INFO    | Flow run 'amiable-bullfinch' - Executing 'fetch-b4598a4a-0' immediately...
/home/shanu/data-engineering-zoomcamp/week_2_workflow_orchestration/flows/02_gcp/etl_web_to_gcs.py:14: DtypeWarning: Columns (3) have mixed types. Specify dtype option on import or set low_memory=False.
  df = pd.read_csv(dataset_url)
18:20:21.463 | INFO    | Task run 'fetch-b4598a4a-0' - Finished in state Completed()
18:20:21.498 | INFO    | Flow run 'amiable-bullfinch' - Created task run 'clean-b9fd7e03-0' for task 'clean'
18:20:21.499 | INFO    | Flow run 'amiable-bullfinch' - Executing 'clean-b9fd7e03-0' immediately...
18:20:21.744 | INFO    | Task run 'clean-b9fd7e03-0' - columns: VendorID                        float64
lpep_pickup_datetime     datetime64[ns]
lpep_dropoff_datetime    datetime64[ns]
store_and_fwd_flag               object
RatecodeID                      float64
PULocationID                      int64
DOLocationID                      int64
passenger_count                 float64
trip_distance                   float64
fare_amount                     float64
extra                           float64
mta_tax                         float64
tip_amount                      float64
tolls_amount                    float64
ehail_fee                       float64
improvement_surcharge           float64
total_amount                    float64
payment_type                    float64
trip_type                       float64
congestion_surcharge            float64
dtype: object
18:20:21.747 | INFO    | Task run 'clean-b9fd7e03-0' - rows: 447770
18:20:21.785 | INFO    | Task run 'clean-b9fd7e03-0' - Finished in state Completed()
18:20:21.817 | INFO    | Flow run 'amiable-bullfinch' - Created task run 'write_local-f322d1be-0' for task 'write_local'
18:20:21.819 | INFO    | Flow run 'amiable-bullfinch' - Executing 'write_local-f322d1be-0' immediately...
18:20:23.419 | INFO    | Task run 'write_local-f322d1be-0' - Finished in state Completed()
18:20:23.452 | INFO    | Flow run 'amiable-bullfinch' - Created task run 'write_gcs-1145c921-0' for task 'write_gcs'
18:20:23.453 | INFO    | Flow run 'amiable-bullfinch' - Executing 'write_gcs-1145c921-0' immediately...
18:20:23.583 | INFO    | Task run 'write_gcs-1145c921-0' - Getting bucket 'de-zoomcamp-2023'.
18:20:23.905 | INFO    | Task run 'write_gcs-1145c921-0' - Uploading from 'data/green/green_tripdata_2020-01.parquet' to the bucket 'de-zoomcamp-2023' path 'data/green/green_tripdata_2020-01.parquet'.
18:20:24.050 | INFO    | Task run 'write_gcs-1145c921-0' - Finished in state Completed()
18:20:24.087 | INFO    | Flow run 'amiable-bullfinch' - Finished in state Completed('All states completed.')

-------------------------------------------------------------------------------------------------------------------------------------------------

Question 2. Scheduling with Cron
Cron is a common scheduling specification for workflows.

Using the flow in etl_web_to_gcs.py, create a deployment to run on the first of every month at 5am UTC. What’s the cron schedule for that?

0 5 1 * *
0 0 5 1 *
5 * 1 0 *
* * 5 1 0

Solution: submitted via google forms

CLI Commands and output generated while building and applying deployment
Deployment YAML file: etl_web_to_gcs-deployment.yaml
==============================
prefect deployment build -n ETL_WEB_TO_GCS_CRON_1 --cron '0 5 1 * *' flows/02_gcp/etl_web_to_gcs.py:etl_web_to_gcs 
Found flow 'etl-web-to-gcs'
Default '.prefectignore' file written to 
/home/shanu/data-engineering-zoomcamp/week_2_workflow_orchestration/.prefectignore
Deployment YAML created at 
'/home/shanu/data-engineering-zoomcamp/week_2_workflow_orchestration/etl_web_to_gcs-deployment.yaml'.
Deployment storage None does not have upload capabilities; no files uploaded.  Pass --skip-upload to suppress this 
warning.
(de-week-2) shanu@de-zoomcamp-2023:~/data-engineering-zoomcamp/week_2_workflow_orchestration$ prefect deployment apply etl_web_to_gcs-deployment.yaml
Successfully loaded 'ETL_WEB_TO_GCS_CRON_1'
Deployment 'etl-web-to-gcs/ETL_WEB_TO_GCS_CRON_1' successfully created with id '113fb7dc-c5cb-47b9-adb6-696fd2406c8e'.
View Deployment in UI: http://127.0.0.1:4200/deployments/deployment/113fb7dc-c5cb-47b9-adb6-696fd2406c8e

To execute flow runs from this deployment, start an agent that pulls work from the 'default' work queue:
$ prefect agent start -q 'default'

--------------------------------------------------------------------------------------------------------------------------------------------------

Question 3. Loading data to BigQuery
Using etl_gcs_to_bq.py as a starting point, modify the script for extracting data from GCS and loading it into BigQuery. This new script should not fill or remove rows with missing values. (The script is really just doing the E and L parts of ETL).

The main flow should print the total number of rows processed by the script. Set the flow decorator to log the print statement.

Parametrize the entrypoint flow to accept a list of months, a year, and a taxi color.

Make any other necessary changes to the code for it to function as required.

Create a deployment for this flow to run in a local subprocess with local flow code storage (the defaults).

Make sure you have the parquet data files for Yellow taxi data for Feb. 2019 and March 2019 loaded in GCS. Run your deployment to append this data to your BiqQuery table. How many rows did your flow code process?

14,851,920
12,282,990
27,235,753
11,338,483

Solution: submitted via google forms

=======================================
refer to the code file "parametrized_flow_gcs_to_bq.py" under flows/02_deployments directory for python code

CLI Commands and output generated while building and applying deployment
Deployment file: etl_parent_flow-deployment.yaml
=============================
prefect deployment build 
flows/03_deployments/parametrized_flow_gcs_to_bq.py:etl_parent_flow -n ETL_GCS_TO_BQ_PARAMETERIZED
Found flow 'etl-parent-flow'
Deployment YAML created at 
'/home/shanu/data-engineering-zoomcamp/week_2_workflow_orchestration/etl_parent_flow-deployment.yaml'.
Deployment storage None does not have upload capabilities; no files uploaded.  Pass --skip-upload to suppress this 
warning.
(de-week-2) shanu@de-zoomcamp-2023:~/data-engineering-zoomcamp/week_2_workflow_orchestration$ prefect deployment apply etl_parent_flow-deployment.yaml
Successfully loaded 'ETL_GCS_TO_BQ_PARAMETERIZED'
Deployment 'etl-parent-flow/ETL_GCS_TO_BQ_PARAMETERIZED' successfully created with id 
'a1c689ed-be82-4a28-ba92-6e4fdbe079d4'.
View Deployment in UI: http://127.0.0.1:4200/deployments/deployment/a1c689ed-be82-4a28-ba92-6e4fdbe079d4

To execute flow runs from this deployment, start an agent that pulls work from the 'default' work queue:
$ prefect agent start -q 'default'

image.png

-------------------------------------------------------------------------------------------------------------------------------------------------

Question 4. Github Storage Block
Using the web_to_gcs script from the videos as a guide, you want to store your flow code in a GitHub repository for collaboration with your team. Prefect can look in the GitHub repo to find your flow code and read it. Create a GitHub storage block from the UI or in Python code and use that in your Deployment instead of storing your flow code locally or baking your flow code into a Docker image.

Note that you will have to push your code to GitHub, Prefect will not push it for you.

Run your deployment in a local subprocess (the default if you don’t specify an infrastructure). Use the Green taxi data for the month of November 2020.

How many rows were processed by the script?

88,019
192,297
88,605
190,225

Solution: submitted via google forms
Deployment file: etl_web_to_gcs-deployment.yaml
parameters: {"months":[11], "year": 2020, "color": "green"}

--------------------------------------------------------------------------------------------------------------------------------------------------

Question 5. Email or Slack notifications
Q5. It’s often helpful to be notified when something with your dataflow doesn’t work as planned. Choose one of the options below for creating email or slack notifications.

The hosted Prefect Cloud lets you avoid running your own server and has Automations that allow you to get notifications when certain events occur or don’t occur.

Create a free forever Prefect Cloud account at app.prefect.cloud and connect your workspace to it following the steps in the UI when you sign up.

Set up an Automation that will send yourself an email when a flow run completes. Run the deployment used in Q4 for the Green taxi data for April 2019. Check your email to see the notification.

Alternatively, use a Prefect Cloud Automation or a self-hosted Orion server Notification to get notifications in a Slack workspace via an incoming webhook.

Join my temporary Slack workspace with this link. 400 people can use this link and it expires in 90 days.

In the Prefect Cloud UI create an Automation or in the Prefect Orion UI create a Notification to send a Slack message when a flow run enters a Completed state. Here is the Webhook URL to use: https://hooks.slack.com/services/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

Test the functionality.

Alternatively, you can grab the webhook URL from your own Slack workspace and Slack App that you create.

How many rows were processed by the script?

125,268
377,922
728,390
514,392

Solution: submitted via google forms

-----------------------------------------------------------------------------------------------------------------------------------------------

Question 6. Secrets
Prefect Secret blocks provide secure, encrypted storage in the database and obfuscation in the UI. Create a secret block in the UI that stores a fake 10-digit password to connect to a third-party service. Once you’ve created your block in the UI, how many characters are shown as asterisks (*) on the next page of the UI?

5
6
8
10

Solution: submitted via google forms
-------------------------------------------------------------------------------------------------------------------------------------------------
