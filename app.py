import os
import pyodbc
from flask import Flask

database = "[DATABASE-NAME]"
username = "[USER-NAME]"
password = "[USER-NAME-PASSWORD]"
server = "[CLOUD-SQL-PRIVATE-IP]"
query = "[QUERY-TO-ISSUE-TO-DB];"
driver = "{ODBC Driver 17 for SQL Server}" #Notice that if you want to use another driver you'd need to modify the Dockerfile accordingly

app = Flask(__name__)

@app.route('/')
def get_msssql_data():
    result_list = [] #List to store query result to print it as HTML
    print('Connecting to the database')
    cnxn = pyodbc.connect('DRIVER='+driver+';SERVER='+server+';DATABASE='+database+';UID='+username+';PWD='+ password)
    print('Creating the cursor')
    cursor = cnxn.cursor()
    print('Attempting to execute query')
    cursor.execute(query)
    row = cursor.fetchone()
    while row:
        result_list.append(str(row))
        row = cursor.fetchone()
    cursor.close()
    cnxn.close()
    return("<p>" + "</p><p>".join(result_list) + "</p>")

if __name__ == "__main__":
    app.run(debug=True,host='0.0.0.0',port=int(os.environ.get('PORT', 8080)))
