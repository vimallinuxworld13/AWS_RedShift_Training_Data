--Create Table city and city_new
create table city
(
id varchar(20), 
Country varchar(20),
State varchar(20),
City varchar(20),
Amount varchar(20) 
)

create table city_new 
(
Id int,
Country varchar(20),
State varchar(20),
City varchar(20),
Amount decimal (5,2)
)

--Test whether CityData file can be loaded in both tables
--NOLOAD Data Load Operation Parameter
--CSV Data Format Parameter

copy city (ID, Country, State, City, Amount) --Column Mapping Parameter
from 's3://my-city-data/CityData.csv'
iam_role '<insert IAM Role ARN here>'
csv NOLOAD

copy city_new (ID, Country, State, City, Amount) --Column Mapping Parameter
from 's3://my-city-data/CityData.csv'
iam_role '<insert IAM Role ARN here>'
csv NOLOAD

--Load CityData.csv file in both tables
--STL_LOAD_ERRORS for checking data load errors

copy city (ID, Country, State, City, Amount)
from 's3://my-city-data/CityData.csv'
iam_role '<insert IAM Role ARN here>'
csv

select * from city

copy city_new (ID, Country, State, City, Amount)
from 's3://my-city-data/CityData.csv'
iam_role '<insert IAM Role ARN here>'
csv

select top 1 * from stl_load_errors order by starttime desc
select top 1 * from stl_loaderror_detail order by starttime desc

truncate table city

--IGNOREHEADER Data Conversion Parameter

copy city (ID, Country, State, City, Amount)
from 's3://my-city-data/CityData.csv'
iam_role '<insert IAM Role ARN here>'
csv
IGNOREHEADER 1

select * from city

copy city_new (ID, Country, State, City, Amount)
from 's3://my-city-data/CityData.csv'
iam_role '<insert IAM Role ARN here>'
csv
IGNOREHEADER 1

select * from city_new

truncate table city_new

--Load all CityData prefix files

copy city_new (ID, Country, State, City, Amount)
from 's3://my-city-data/CityData'
iam_role '<insert IAM Role ARN here>'
csv
IGNOREHEADER 1

select * from city_new

truncate table city_new

--BLANKASNULL Data Conversion Parameter

copy city_new (ID, Country, State, City, Amount)
from 's3://my-city-data/CityData'
iam_role '<insert IAM Role ARN here>'
csv
BLANKSASNULL IGNOREHEADER 1

select * from city_new

truncate table city_new

--Load data from manifest file CityData.manifest using manifest parameter
copy city_new (ID, Country, State, City, Amount)
from 's3://my-city-data/Manifest/CityData.manifest'
iam_role '<insert IAM Role ARN here>'
csv manifest
BLANKSASNULL IGNOREHEADER 1

select * from city_new

--Check number of nodes and slices
select * from stv_slices

--Returns information to track or troubleshoot a data load.
-- This table records the progress of each data file as it is loaded into 
--a database table.
--Check node slice that loaded the data
select * from stl_load_commits

truncate table city_new

--Load data from a compressed GZIP file

copy city_new (ID, Country, State, City, Amount)
from 's3://my-city-data/Bzip/CityData.csv.gz'
iam_role '<insert IAM Role ARN here>'
csv GZIP
BLANKSASNULL IGNOREHEADER 1

select * from city_new

--Amazon Redshift copy examples URL
--https://docs.aws.amazon.com/redshift/latest/dg/r_COPY_command_examples.html
