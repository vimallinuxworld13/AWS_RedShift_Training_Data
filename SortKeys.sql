CREATE DATABASE SSB --(STAR SCHEMA BENCHMARK)

--Change the active database to SSB

--Create tables

CREATE TABLE part
(
p_partkey INTEGER NOT NULL,
p_name VARCHAR(22) NOT NULL,
p_mfgr VARCHAR(6) NOT NULL,
p_category VARCHAR(7) NOT NULL,
p_brand1 VARCHAR(9) NOT NULL,
p_color VARCHAR(11) NOT NULL,
p_type VARCHAR(25) NOT NULL,
p_size INTEGER NOT NULL,
p_container VARCHAR(10) NOT NULL
);
CREATE TABLE supplier
(
s_suppkey INTEGER NOT NULL,
s_name VARCHAR(25) NOT NULL,
s_address VARCHAR(25) NOT NULL,
s_city VARCHAR(10) NOT NULL,
s_nation VARCHAR(15) NOT NULL,
s_region VARCHAR(12) NOT NULL,
s_phone VARCHAR(15) NOT NULL
);
CREATE TABLE customer
(
c_custkey INTEGER NOT NULL,
c_name VARCHAR(25) NOT NULL,
c_address VARCHAR(25) NOT NULL,
c_city VARCHAR(10) NOT NULL,
c_nation VARCHAR(15) NOT NULL,
c_region VARCHAR(12) NOT NULL,
c_phone VARCHAR(15) NOT NULL,
c_mktsegment VARCHAR(10) NOT NULL
);
CREATE TABLE dwdate
(
d_datekey INTEGER NOT NULL,
d_date VARCHAR(19) NOT NULL,
d_dayofweek VARCHAR(10) NOT NULL,
d_month VARCHAR(10) NOT NULL,
d_year INTEGER NOT NULL,
d_yearmonthnum INTEGER NOT NULL,
d_yearmonth VARCHAR(8) NOT NULL,
d_daynuminweek INTEGER NOT NULL,
d_daynuminmonth INTEGER NOT NULL,
d_daynuminyear INTEGER NOT NULL,
d_monthnuminyear INTEGER NOT NULL,
d_weeknuminyear INTEGER NOT NULL,
d_sellingseason VARCHAR(13) NOT NULL,
d_lastdayinweekfl VARCHAR(1) NOT NULL,
d_lastdayinmonthfl VARCHAR(1) NOT NULL,
d_holidayfl VARCHAR(1) NOT NULL,
d_weekdayfl VARCHAR(1) NOT NULL
);
CREATE TABLE lineorder
(
lo_orderkey INTEGER NOT NULL,
lo_linenumber INTEGER NOT NULL,
lo_custkey INTEGER NOT NULL,
lo_partkey INTEGER NOT NULL,
lo_suppkey INTEGER NOT NULL,
lo_orderdate INTEGER NOT NULL,
lo_orderpriority VARCHAR(15) NOT NULL,
lo_shippriority VARCHAR(1) NOT NULL,
lo_quantity INTEGER NOT NULL,
lo_extendedprice INTEGER NOT NULL,
lo_ordertotalprice INTEGER NOT NULL,
lo_discount INTEGER NOT NULL,
lo_revenue INTEGER NOT NULL,
lo_supplycost INTEGER NOT NULL,
lo_tax INTEGER NOT NULL,
lo_commitdate INTEGER NOT NULL,
lo_shipmode VARCHAR(10) NOT NULL
);

--Copy data using Redshift Role ARN

copy customer from 's3://awssampledbuswest2/ssbgz/customer'
credentials 'aws_access_key_id=<Your-Access-Key-ID>;aws_secret_access_key=<Your-Secret-Access-Key>'
gzip compupdate off region 'us-west-2';

copy dwdate from 's3://awssampledbuswest2/ssbgz/dwdate'
credentials 'aws_access_key_id=<Your-Access-Key-ID>;aws_secret_access_key=<Your-Secret-Access-Key>'
gzip compupdate off region 'us-west-2';

copy lineorder from 's3://awssampledbuswest2/ssbgz/lineorder'
credentials 'aws_access_key_id=<Your-Access-Key-ID>;aws_secret_access_key=<Your-Secret-Access-Key>'
gzip compupdate off region 'us-west-2';

copy part from 's3://awssampledbuswest2/ssbgz/part'
credentials 'aws_access_key_id=<Your-Access-Key-ID>;aws_secret_access_key=<Your-Secret-Access-Key>'
gzip compupdate off region 'us-west-2';

copy supplier from 's3://awssampledbuswest2/ssbgz/supplier'
credentials 'aws_access_key_id=<Your-Access-Key-ID>;aws_secret_access_key=<Your-Secret-Access-Key>'
gzip compupdate off region 'us-west-2';

--Create a denormalized table that contains data about customers and revenue

create table cust_sales_date as
(select c_custkey, c_nation, c_region, c_mktsegment, d_date::date, lo_revenue
from customer, lineorder, dwdate
where lo_custkey = c_custkey
and lo_orderdate = dwdate.d_datekey
and lo_revenue > 0);

--Row count of cust_sales_date table

select count(*) from cust_sales_date;

--First row of cust_sales_date table

select * from cust_sales_date limit 1;

--Create three tables - each one with a different type of sort keys

create table cust_sales_date_single
sortkey (c_custkey)
as select * from cust_sales_date;

create table cust_sales_date_compound
compound sortkey (c_custkey, c_region, c_mktsegment, d_date)
as select * from cust_sales_date;

create table cust_sales_date_interleaved
interleaved sortkey (c_custkey, c_region, c_mktsegment, d_date)
as select * from cust_sales_date;

--Test a query that restricts on the c_custkey column, which is the first column in the sort key for
--each table. Execute the following queries.
-- Query 1

select max(lo_revenue), min(lo_revenue)
from cust_sales_date_single
where c_custkey < 100000;

select max(lo_revenue), min(lo_revenue)
from cust_sales_date_compound
where c_custkey < 100000;

select max(lo_revenue), min(lo_revenue)
from cust_sales_date_interleaved
where c_custkey < 100000;

--Test a query that restricts on the c_region column, which is the second column in the sort key for
--the compound and interleaved keys. Execute the following queries.
-- Query 2

select max(lo_revenue), min(lo_revenue)
from cust_sales_date_single
where c_region = 'ASIA'
and c_mktsegment = 'FURNITURE';

select max(lo_revenue), min(lo_revenue)
from cust_sales_date_compound
where c_region = 'ASIA'
and c_mktsegment = 'FURNITURE';

select max(lo_revenue), min(lo_revenue)
from cust_sales_date_interleaved
where c_region = 'ASIA'
and c_mktsegment = 'FURNITURE';

--Test a query that restricts on both the c_region column and the c_mktsegment column. Execute
--the following queries.
-- Query 3

select max(lo_revenue), min(lo_revenue)
from cust_sales_date_single
where d_date between '01/01/1996' and '01/14/1996'
and c_mktsegment = 'FURNITURE'
and c_region = 'ASIA';

select max(lo_revenue), min(lo_revenue)
from cust_sales_date_compound
where d_date between '01/01/1996' and '01/14/1996'
and c_mktsegment = 'FURNITURE'
and c_region = 'ASIA';

select max(lo_revenue), min(lo_revenue)
from cust_sales_date_interleaved
where d_date between '01/01/1996' and '01/14/1996'
and c_mktsegment = 'FURNITURE'
and c_region = 'ASIA';