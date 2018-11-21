/*****************************************************************************************************
******************************************************************************************************
Pex Analyst Technical Challenge


The goal of this challenge is three fold:
1- convey basic mastery of SQL
2- convey basic mastery of communicating analytical findings
3- demonstrate your attention to detail and ability to think creatively by finding insights without guidance


Challenge:
Download the two YouTube data sets 'meta' and 'history' from https://drive.google.com/open?id=1Com5I4BCp7WsSCg8IKRKocXXjDwHFs6B
   (the csv files do not have headers. The Data Schemas outlined below match the order of the columns in their respective tables)
Leverage SQL to manipulate the data and Google Sheets for further transformation and display.
Explore the data sets to answer the 3 specific questions posed below and provide whatever other insights you can.

Specific questions to answer:
	1 - total views accrued within each category
	2 - graph of daily views for an 'average' video within each category
	3 - how many videos within each category have < 1k views, 1-10K, 10-100K, 100k-1M, 1M+ views
	(additionally please provide any other insights you find relevant)

Delivery:
Create a google sheet to communicate your findings.
Document your underlying SQL in a separate .sql file
email both of these deliverables to james@pex.com

Challenge notes:
There are not intended to be any 'gotcha' elements to this. There is no specific insight or hidden trap we're expecting you to find. 
Simply explore the data, and manipulate it to develop what insights you think valuable. 
There is no time limit for this work, but it is not intended to be a multi-day project. 
Beyond your initial work to get set up in whatever SQL environment you choose an afternoon of work should be sufficient to complete the challenge. 
If you prefer to present your findings via a power point slide deck or equavlent as opposed to a google sheet, then feel free to do so. There are not 'bonus' points
for a presentation method other than the google sheet I recommended. It's simply your preference on how you find it easiest to communicate findings. 


Data Schemas:
meta:
	gid - unique identifier of the YouTube video
	user_id - unique identifier of the user who uploaded the video
	category_id - numeric id denoting the YouTube category the video was uploaded to. 10 = music, 20 = gaming
	created_at - timestamp when video was uploaded to YouTube
	duration - length of the video in seconds
	PRIMARY KEY - gid

history:
	gid - unique identifier of the YouTube video
	views - number of views the video had accrued at the time of this data update
	likes - number of likes the video had accrued at the time of this data update
	dislikes - number of dislikes the video had accrued at the time of this data update
	comments - number of comments the video had accrued at the time of this data update
	updated_at - timestamp of the data update for this video
	PRIMARY KEY - gid, updated_at

note on GID:
	Not needed for this challenge, but if you are curious you can use the gid to pull up the actual video on YouTube
	by taking a the string of the gid following 'YT:' and pasting it at the end of https://www.youtube.com/watch?v=
	E.g., to watch the video for gid = YT:d8O6SoPOkAk go to https://www.youtube.com/watch?v=d8O6SoPOkAk

******************************************************************************************************
******************************************************************************************************/


/*
download datasets
*/
-- download the two csv files at
https://drive.google.com/open?id=1Com5I4BCp7WsSCg8IKRKocXXjDwHFs6B
Note that the two csv files do not contain headers. The columns in the csv files allign with the order I described them in the schemas above. 

/*
Optional tools to leverage in the challenge

These are not necessary, but if you don't have access to a SQL environment (required for this assignment) 
or access to a text editor (not required but possibly useful), then leverage the links and instructions below
*/

-- a text editor can prove helpful when working on this assignment. 
-- Sublime Text is a great option, and can be dowload here:
https://www.sublimetext.com/3


-- if you have access to a sql environment then feel free to use what you are already familiar with
-- if you don't have access to a sql environment then you can download SQLite for free at
https://www.sqlite.org/download.html

-- sqlite documentation
https://www.sqlite.org/cli.html




/***
****

SQLite GUIDANCE

This challenge is not intended to require any knowledge of SQLite. SQLite is simply a free way to run SQL on your local machine.
Therefore, if you do use SQLite for this challenge we've provided a number of helpful resources below to streamline your work. 
We want to avoid spending undue time learning the specifics of SQLite, and instead let you get to the challenge itself 

****
***/

/*
Getting started and importing data
*/

-- after installing sqlite open terminal (mac) or the command prompt (PC)
-- Start the sqlite3 program by typing "sqlite3" at the command prompt
> sqlite3
-- this creates a temporary database which is then deleted when the "sqlite3" program exits.



-- to import the data execute the following
> create table meta(gid TEXT PRIMARY KEY, user_id TEXT, category_id INT, created_at TEXT, duration INT);
> create table history(gid TEXT, views int, likes int, dislikes int, comments int, updated_at TEXT, PRIMARY KEY(gid, updated_at));
> .mode csv
> .import [file path to analyst_challenge_data_meta.csv] meta
> .import [file path to analyst_challenge_data_history.csv] history

-- Optional: adjust how data will be displayed for easier reading. Additional display options can be found in the sqlite documentation
> .header on
> .mode column

-- check data imported successfully
> SELECT * FROM meta limit 1;
> SELECT count(*) FROM meta; -- should have 622,715 rows

> SELECT * FROM history limit 1;
> SELECT count(*) FROM history; -- should have 4,037,178 rows


/*
helpful SQLite notes
*/

--writing and executing SQL queries in sqlite 
Make sure you type a semicolon at the end of each SQL command! 
The sqlite3 program looks for a semicolon to know when your SQL command is complete. 
If you omit the semicolon, sqlite3 will give you a continuation prompt and wait for you to enter more text 
to be added to the current SQL command. This feature allows you to enter SQL commands that span multiple lines.
Example:

sqlite> CREATE TABLE tbl2 (
   ...>   f1 varchar(30) primary key,
   ...>   f2 text,
   ...>   f3 real
   ...> );
sqlite>

--exiting sqlite
Terminate the sqlite3 program by typing your system End-Of-File character (usually a Control-D). 


--terminate long running sql
Use the interrupt character (usually a Control-C) to stop a long-running SQL statement.


--formatting outputs
.header on --this adds column headers to each output
.mode column --this formats outputs in most readable format in my opinion. You can try other .mode options described in the sqlite documentation
.mdoe csv --mode to set before importing/exporting csv


-- exporting results to csv example
> .mode csv
> .once /Users/James/Desktop/testoutput.csv
> SELECT * FROM meta limit 1;
-- the results of the single sql command executed immediately after envoking the .once command will be written to the file provided with the .once command
-- note that if you output to a txt file already created then the file's current content will be overwritten by the new output


-- example executing SQL code you've written in a txt editor such as Sublime Text
.read /Users/James/Desktop/testSQLscript.sql
-- you may also find it easier to write lengthier SQL in a text editor then paste it into your sqlite command line to run


-- Dates in SQLite
sqlite does not support typical date data types, so they are stored as Text. 
To translate the date columns to another format such as 'YYYY-MM-DD' you will need to use a text funciton such as substr(): 




