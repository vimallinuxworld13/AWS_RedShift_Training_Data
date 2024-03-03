--Check distribution style of tables
-- 0 - Even
-- 1 - Key
-- 8 - ALL

select relname, reldiststyle from pg_class
where relname like 'city';

select relname, reldiststyle from pg_class
where relname like 'sales';

select relname, reldiststyle from pg_class
where relname like 'listing';


/*
--Distribution Style Syntax Examples

create table alldiststyle (col1 int)
diststyle all;

create table evendiststyle (col1 int)
diststyle even;

create table keydiststyle (col1 int)
diststyle key distkey (col1);

select relname, reldiststyle from pg_class
where relname like '%diststyle';
*/

--Analyze fields in the table
select * from pg_table_def where tablename = 'listing'
select * from pg_table_def where tablename = 'sales'
select * from pg_table_def where tablename = 'date'


--Sample query for analyzing query plan to study impact of distribution style
explain
select lastname, catname, venuename, venuecity, venuestate, eventname,
month, sum(pricepaid) as buyercost, max(totalprice) as maxtotalprice
from category join event on category.catid = event.catid
join venue on venue.venueid = event.venueid
join sales on sales.eventid = event.eventid
join listing on sales.listid = listing.listid
join date on sales.dateid = date.dateid
join users on users.userid = sales.buyerid
group by lastname, catname, venuename, venuecity, venuestate, eventname, month
having sum(pricepaid)>9999
order by catname, buyercost desc;

--Query to find column id based on ordinal position. 
--Column ids start with 0 and ordinal position start with 1.
SELECT a.attnum AS ordinal_position,
         a.attname AS column_name,
         t.typname AS data_type,
         a.attlen AS character_maximum_length,
         a.atttypmod AS modifier,
         a.attnotnull AS notnull,
         a.atthasdef AS hasdefault
    FROM pg_class c,
         pg_attribute a,
         pg_type t
   WHERE c.relname = 'sales' --'listing', 'date'
     AND a.attnum > 0
     AND a.attrelid = c.oid
     AND a.atttypid = t.oid
ORDER BY a.attnum;


--Check the data distribution with min and max range on each node slices for listing and sales table - listid column only.
select trim(name) as table, slice, sum(num_values) as rows, min(minvalue),
max(maxvalue)
from svv_diskusage
where (name in ('listing') and col =0) OR (name in ('sales') and col =1)
group by name, slice
order by slice, name;

--Check the data distribution with min and max range on each node slices for date and sales table - dateid column only.
select trim(name) as table, slice, sum(num_values) as rows, min(minvalue),
max(maxvalue)
from svv_diskusage
where (name in ('date') and col =0) OR (name in ('sales') and col =5)
group by name, slice
order by slice, name;

--Create a date_copy table with ALL Distribution Style and populate with data from date table
CREATE TABLE public.date_copy
(
	dateid SMALLINT NOT NULL SORTKEY,
	caldate DATE NOT NULL,
	day CHAR(3) NOT NULL,
	week SMALLINT NOT NULL,
	month CHAR(5) NOT NULL,
	qtr CHAR(5) NOT NULL,
	year SMALLINT NOT NULL,
	holiday BOOLEAN DEFAULT false
) 
diststyle all;

INSERT INTO DATE_COPY
SELECT * FROM DATE

ANALYZE DATE_COPY

--Create users_copy table in the same way as above
CREATE TABLE public.users_copy
(
	userid INTEGER NOT NULL ENCODE delta SORTKEY,
	username CHAR(8) ENCODE lzo,
	firstname VARCHAR(30) ENCODE text32k,
	lastname VARCHAR(30) ENCODE text32k,
	city VARCHAR(30) ENCODE text32k,
	state CHAR(2),
	email VARCHAR(100) ENCODE lzo,
	phone CHAR(14) ENCODE lzo,
	likesports BOOLEAN,
	liketheatre BOOLEAN,
	likeconcerts BOOLEAN,
	likejazz BOOLEAN,
	likeclassical BOOLEAN,
	likeopera BOOLEAN,
	likerock BOOLEAN,
	likevegas BOOLEAN,
	likebroadway BOOLEAN,
	likemusicals BOOLEAN
) diststyle all;

INSERT INTO USERS_COPY
SELECT * FROM USERS

ANALYZE USERS_COPY

--Sample query for analyzing query plan after changing distribution style in date_copy table
explain
select lastname, catname, venuename, venuecity, venuestate, eventname,
month, sum(pricepaid) as buyercost, max(totalprice) as maxtotalprice
from category join event on category.catid = event.catid
join venue on venue.venueid = event.venueid
join sales on sales.eventid = event.eventid
join listing on sales.listid = listing.listid
join date_copy on sales.dateid = date_copy.dateid --date table replaced with date_copy
join users_copy on users_copy.userid = sales.buyerid
group by lastname, catname, venuename, venuecity, venuestate, eventname, month
having sum(pricepaid)>9999
order by catname, buyercost desc;

--A copy of full date_copy table is stored on one of the node slices of each node
select trim(name) as table, slice, sum(num_values) as rows, min(minvalue),
max(maxvalue)
from svv_diskusage
where (name in ('date_copy') and col =0) OR (name in ('sales') and col =5)
group by name, slice
order by slice, name;
