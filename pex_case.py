'''
Pex.com - Youtube Video Analytics case assignment
##### Submitted by: Rachit Mishra #####

The goal of this challenge is three fold:
1- convey basic mastery of SQL
2- convey basic mastery of communicating analytical findings
3- demonstrate your attention to detail and ability to think creatively by finding insights without guidance
'''


import pandas as pd
import sqlite3
import pyodbc
#name of data source(in SQL Server) - pex_case
connect = pyodbc.connect('DRIVER={SQL Server}; SERVER=LAPTOP-8V487H0M;DATABASE=pex_case')
cursor = connect.cursor()
cursor.execute("SELECT top 10  m.gid FROM meta m")
for row in cursor.fetchall():
    print(row)
## Connection with SQL Server and pex_case database established##

'''
Creating the history database to be pushed into the sql server

1. Reading the .csv file as a pandas dataframe
2. Appending the column names as provided in the data description as header row
'''
#reading the history.csv file
history = pd.read_csv('analyst_challenge_data_history.csv',
                      low_memory=False, header=None)
#appending the column names
history.columns = ['gid', 'views', 'likes', 'dislikes', 'comments', 'updated_at']


'''
Creating a SQLALCHEMY engine to connect with our SQL Server
and the pex_case database there

Using df.to_sql() function to push the table in chunks so as to avoid memory error
'''
import sqlalchemy
from sqlalchemy import create_engine
import urllib
params = urllib.parse.quote(("DRIVER={SQL Server}; SERVER=LAPTOP-8V487H0M;DATABASE=pex_case"))
engine = create_engine("mssql+pyodbc:///?odbc_connect=%s" % params)

history = pd.read_csv('analyst_challenge_data_history.csv')
df = pd.DataFrame(history)

df.to_sql('history',
          con=engine,
          chunksize=100000)


'''
 ANALYZING & Drawing Insights --- 
 pex_case.sql already has all the solutions and insights.
 This is the .py file emulating those steps in a similar fashion
 in a similar .sql environment 
'''
####
'''Query 1 - Total number of views 
   accrued within each category'''
####
query1 ="SELECT category_id, sum(views) as total_views_accrued " \
       "FROM meta, history " \
       "where meta.gid = history.gid " \
       "group by category_id"
cursor.execute(query1)
result = cursor.fetchall()
result

####
'''Query 2 - graph of daily views 
   for an 'average' video within each category

Approach: 
1. Start of with dealing with both categories separately
2. Extracting category_id, average of views on a day-to-day basis
3. To get the avg. views on day to day basis, make use of CONVERT()
   to extract the date part from the sql server time stamp   
4. Write the fetched result in a .csv file 
5. Use Excel to generate the insights showing the trends
   over the course of 7 documented dates  
'''
####

############
'''
For Category 10, average views on a day to day basis
'''
############
query2 = "select category_id," \
         "avg(views) as avg_views, CONVERT(VARCHAR(10), updated_at, 120) as updated_at_date " \
         "from meta m inner join history h " \
         "on m.gid = h.gid " \
         "where category_id = 10" \
         "group by category_id, CONVERT(VARCHAR(10), updated_at, 120) "
cursor.execute(query2)
result = cursor.fetchall()
result

# writing the results in a temporary .csv file
column_names = [i[0] for i in cursor.description]

import csv
fp = open('category10-new.csv', 'w')
myFile = csv.writer(fp, lineterminator='\n')
myFile.writerow(column_names)
myFile.writerows(result)
fp.close()

############
'''
For Category 20, average views on a day to day basis
'''
############

query3 = "select count(*), category_id," \
         "avg(views) as avg_views, CONVERT(VARCHAR(10), updated_at, 120) as updated_at_date " \
         "from meta m inner join history h " \
         "on m.gid = h.gid " \
         "where category_id = 20" \
         "group by category_id, CONVERT(VARCHAR(10), updated_at, 120) "

cursor.execute(query3)
result2 = cursor.fetchall()
result2

column_names = [i[0] for i in cursor.description]

import csv
fp = open('category20-new.csv', 'w')
myFile = csv.writer(fp, lineterminator='\n')
myFile.writerow(column_names)
myFile.writerows(result2)
fp.close()

########################
'''
Query 3: how many videos within each category have < 1k views, 
       1-10K, 10-100K, 100k-1M, 1M+ views
	'''
########################

query4="select Bracket, category_id, count(*) as total_videos " \
       "from (" \
       "select h.gid, category_id, " \
       "   case " \
       "	 when views<=1000 THEN '1'" \
       "	 when (views >1000 and views <=10000) THEN '2'" \
       "	 when (views >10000 and views <=100000) THEN '3'" \
       "	 when (views >100000 and views <=1000000) THEN '4'" \
       "	 when views >1000000 THEN '5'" \
       "	 END AS Bracket " \
       "from meta m inner join history h " \
       "on m.gid = h.gid " \
       "where m.gid = h.gid) as T " \
       "group by category_id, Bracket " \
       "order by category_id, total_videos desc; "
cursor.execute(query4)
result = cursor.fetchall()
result



############################# End of pex_case.py ######################