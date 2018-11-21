/* Pex.com - Video Analytics case assignment 
##### Submitted by: Rachit Mishra #####

The goal of this challenge is three fold:
1- convey basic mastery of SQL
2- convey basic mastery of communicating analytical findings
3- demonstrate your attention to detail and ability to think creatively by finding insights without guidance

*/ 

/** Specifying some necessary imports 
1. Importing the META table
2. Importing the History table **/ 

/* 1. Creating the META table - using bulk insert to import directly from .csv file */ 
use pex_case;
create table meta
      (gid nvarchar(100) PRIMARY KEY NOT NULL, 
			user_id text, 
			category_id INT, 
			created_at TEXT, duration INT);

bulk insert meta
from 'C:\Punisher\1 UTD\Resume\kaam reloaded\Matthew\data engg\PexCase\analyst_challenge_data_history.csv'
with
(
rowterminator = '0x0a', 
fieldterminator = ',',
KEEPNULLS
)

/* To import the history table from the provided .csv, I created a SQL 
environment in Python using SQLALCHEMY, sqlite3 and PYODBC, setting up a connection to this SQL Server
and the pex_case database that I have created. The enormity of the history.csv file made me tend to
python to get more flexibility and convenience with the import process. I made use of pandas' dataframe
capabilities to push the .csv into SQL server as a table. 

<refer to PEX_CASE.py python file provided with this submission> 

*/

/** Testing connections **/
use pex_case;
select count(*) from history_new;
select count(*) from history;
select count(*) from meta;

/* ANALYZING & Drawing Insights --- For each insight, I have made a backup in the .py file 
           running the same query in the SQL environment created in python using SQLALCHEMY's engine.
		   I did this to dump some intermediate tables into CSVs or quickly load them into dataframes 
		   on python to get more flexiblity with the analysis */ 

/*** Query 1 - Total number of views accrued within each category ***/
SELECT category_id, sum(views) as total_views_accrued
FROM meta m inner join history_new h
on m.gid = h.gid
group by category_id;
/*** Query 1 - Total number of views accrued within each category ***/


/***Query 2 - graph of daily views 
   for an 'average' video within each category

Approach: 
1. Start of with dealing with both categories separately
2. Extracting category_id, average of views on a day-to-day basis
3. To get the avg. views on day to day basis, make use of CONVERT()
   to extract the date part from the sql server time stamp   
4. Write the fetched result in a .csv file(refer to pex_case.py) 
5. Use Excel to generate the insights(trendlines) showing the trends
   over the course of 7 documented dates
6. Check the .ppt file for insights  
***/ 

select category_id,
         avg(views) as avg_views, CONVERT(VARCHAR(10), updated_at, 120) as updated_at_date 
         from meta m inner join history h 
         on m.gid = h.gid 
         where category_id = 10 /*the same has been done for category_id = 20 */
         group by category_id, CONVERT(VARCHAR(10), updated_at, 120);

/***Query 2 - graph of daily views 
   for an 'average' video within each category  ***/ 


/***
Query 3: how many videos within each category have < 1k views, 
       1-10K, 10-100K, 100k-1M, 1M+ views?

Approach: Using CASE statements to partition differetn ranges into different 'BRACKETS'

Bracket |  Range
1       |   <1k
2       |  1-10k
3       |  10-100k
4       |  100k-1M
5       |    1M+
***/

select Bracket, category_id, count(*) as total_videos
       from (
       select h.gid, category_id,
          case
       	 when views<=1000 THEN '1'
       	 when (views >1000 and views <=10000) THEN '2'
       	 when (views >10000 and views <=100000) THEN '3'
       	 when (views >100000 and views <=1000000) THEN '4'
       	 when views >1000000 THEN '5'
       	 END AS Bracket
       from meta m inner join history h
       on m.gid = h.gid
       where m.gid = h.gid) as T
       group by category_id, Bracket
       order by category_id, total_videos desc;


/** Additional Insights/delivarables from this point **/ 

/* Insight 4/Query 4: 
            sentiment_ratio - A ratio of likes to dislikes is a key KPI in 
			determining the general viewer sentiment towards the content(music/gaming). 
		    Grouping this w.r.t different categories adds more depth to the insights. 

			However, sentiment_ratio alone isn't enough to assess the performance of a video 
			because a video might barely have 300 views and still have a sentiment ratio of;
			for instance 10(10 likes to 1 dislike). 
			Hence, I grouped the sentiment_ratio w.r.t each Bracket that we created from the previous
			insight/query. A combination of sentiment_ration with the Bracket in which that video lies 
			is a much better indicator
*/ 

select T2.gid, category_id, Bracket, sentiment_ratio 
from (
	select T.gid, Bracket, category_id, count(*) as total_videos, sentiment_ratio
		from (
		select h.gid, category_id, (likes/dislikes) as sentiment_ratio,
			   case 
				 when views<=1000 THEN '1'
				 when (views >1000 and views <=10000) THEN '2'
				 when (views >10000 and views <=100000) THEN '3'
				 when (views >100000 and views <=1000000) THEN '4'
				 when views >1000000 THEN '5'
				 END AS Bracket
	from meta m inner join history h 
	on m.gid = h.gid
	where m.gid = h.gid) as T
	group by T.gid, category_id, Bracket, sentiment_ratio) as T2
where category_id=10  /*switch to 20 to change category*/
group by T2.gid, category_id, Bracket, sentiment_ratio 
order by sentiment_ratio desc; 

/*** Insight 5/ Query 5: 
       User_Engagement: Monitoring the volume of comments alongside sentiment_ratio. 
	                    Inclusion of the duration metric helps in getting an idea about the
						correlation between the two features - duration and user_engagement(if any)
	   
	   Crucial observations:
	     1. Preliminary observation reveals Gaming(40 million+) generates more user engagement
		  than it's other counterpart - Music(23 million+)
		
		 2. Some videos have no user engagements(characterized by NULL values). A closer 
		 look at these videos revealed that many are either taken off/not available 
		  or were live streams that have now went offline. Hence, no user engagement.
		  Can filter the data to select videos with atleast 10, 100 or 500 comments
		 
		 3. Duration has little to no effect on user engagement. I ran a few different cases 
		 and tried various combinations of sentiment_ration, duration and user_engagement to arrive at that
		 conclusion
***/ 
select category_id, sum(comments) as user_engagement
	from meta m 
	inner join history h
	on m.gid = h.gid 
	group by category_id 
	order by user_engagement desc;

select h.gid, category_id, (likes/dislikes) as sentiment_ratio, duration, sum(comments) as user_engagement 
	from meta m 
	inner join history h
	on m.gid = h.gid
	where category_id = 10 and h.comments>100
	group by category_id, h.gid, (likes/dislikes), duration
	order by user_engagement, duration desc; 


/* Pex.com - Video Analytics case assignment 
##### Submitted by: Rachit Mishra #####
  ##################### End of pex_case.sql file ##############
         #######   #########  ##########   ######### */ 
