# Cloud Run Fully Managed to Cloud SQL SQL Server

Example usage of how to achieve a connection from Cloud Run Fully Managed to Cloud SQL SQL server using Python and pyodbc.

**Motivation**: the official [Python Cloud SQL drivers](https://docs.microsoft.com/en-us/sql/connect/python/python-driver-for-sql-server?view=sql-server-linux-2017) rely on some specific system dependencies that cannot be easily specified in other Google Cloud Platform serverless products that use the Python Runtime, such as [Cloud Functions](https://cloud.google.com/functions/docs/concepts/python-runtime) and therefore exploring how to achieve this connection using the flexibility of running your own container to specify all these dependencies makes Cloud Run a good candidate. Since the latest [pymssql](https://pypi.org/project/pymssql/#history) dates from 2018, I decided to use [pyodbc](https://pypi.org/project/pyodbc/#history) that seems to be kept updated regularly.

**Notes**: the following procedure is currently based on the following sections with the Google Cloud Platform official documentation [[1]](https://cloud.google.com/sql/docs/sqlserver/connect-run#private-ip) and [[2]](https://cloud.google.com/run/docs/quickstarts/build-and-deploy#python), please refer to both sections of the documentation in the case you encounter further difficulties or to check if there are any updates that might change the instructions left on the following section. *Notice that for the time being you can only connect to a Cloud SQL SQL Server instance using the instance's Private IP using a Cloud Run service*.

**Instructions**:
1. [Create a Cloud SQL SQL Server instance with Private IP enabled](https://cloud.google.com/sql/docs/sqlserver/configure-private-ip#new-private-instance) or [assign a Private IP to an existing instance](https://cloud.google.com/sql/docs/sqlserver/configure-private-ip#existing-private-instance) if it's NOT hosted on a Shared VPC (notice that it's indispensible that you configure [Private Service Access](https://cloud.google.com/sql/docs/sqlserver/configure-private-services-access) in order to be able to assign the Private IP to the Cloud SQL instance).

2. On the Cloud SQL SQL server instance: [create a database and upload data](https://cloud.google.com/sql/docs/sqlserver/quickstart#create-a-database-and-upload-data) to it.

3. Create a [Serverless VPC Access Connector](https://cloud.google.com/vpc/docs/configure-serverless-vpc-access#creating_a_connector) in order to ensure the connection between your Cloud Run service and the Cloud SQL SQL Server instance.

4. Clone this repository to a local folder on your development environment, open the `app.py` file and modify the following values according to your specific requirements:

```
database = "[DATABASE-NAME]" #(e.g. testdb)
username = "[USER-NAME]" #(e.g. sqlserver)
password = "[USER-NAME-PASSWORD]" #(e.g. changeme)
server = "[CLOUD-SQL-PRIVATE-IP]" #(e.g. 10.1.11.23)
query = "[QUERY-TO-ISSUE-TO-DB]" #(e.g. SELECT * FROM Persons;) if you have a table names Persons in the DB
```

5. As stated on [this step](https://cloud.google.com/run/docs/quickstarts/build-and-deploy#containerizing) of the Cloud Run quickstart. A `Dockerfile` has already been provided in order to containerize the application and upload it to Container Registry using the following commmand within the folder where you cloned the repository:

```
gcloud builds submit --tag gcr.io/[PROJECT-ID]/[IMAGE-NAME]
```

6. Run the following command to deploy the Cloud Run service: 

```
gcloud beta run deploy [SERVICE-NAME] --image gcr.io/[PROJECT-ID]/[IMAGE-NAME] \
                                      --vpc-connector [SERVERLESS-VPC-ACCES-CONNECTOR-NAME] \
                                      --region [SAME-REGION-AS-CLOUD-SQL-INSTANCE] \
                                      --platform managed --port 8080 --allow-unauthenticated \
                                      --add-cloudsql-instances [CLOUD-SQL-INSTANCE-NAME]
```

6.

**Acknowledgement**: The current Dockerfile being used within this repository is an adaptation of the answers provided from the following StackOverflow [post](https://stackoverflow.com/questions/46405777/connect-docker-python-to-sql-server-with-pyodbc).
