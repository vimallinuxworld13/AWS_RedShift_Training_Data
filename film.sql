create database DTO

create table film (
film_id integer,
language_id smallint,
original_language_id smallint,
rental_duration smallint default 3,
rental_rate numeric(4,2) default 4.99,
length smallint,
replacement_cost real default 25.00);

--Attempt to Insert an Integer That is Out of Range
--The following example attempts to insert the value 33000 into a SMALLINT column.
insert into film(language_id) values(33000);
--The range for SMALLINT is -32768 to +32767, so Amazon Redshift returns an error.

--Insert a Decimal Value into an Integer Column
--The following example inserts the a decimal value into an INT column.
insert into film(language_id) values(1.5);
select * from film
--This value is inserted but rounded up to the integer value 2.

--Insert a Decimal That Succeeds Because Its Scale Is Rounded
--The following example inserts a decimal value that has higher precision that the column.
insert into film(rental_rate) values(35.512);
select * from film
--In this case, the value 35.51 is inserted into the column.

--Attempt to Insert a Decimal Value That Is Out of Range
--In this case, the value 350.10 is out of range. The number of digits for values in DECIMAL columns is
--equal to the column's precision minus its scale (4 minus 2 for the RENTAL_RATE column). In other words,
--the allowed range for a DECIMAL(4,2) column is -99.99 through 99.99.
insert into film(rental_rate) values (350.10);

--Insert Variable-Precision Values into a REAL Column
--The following example inserts variable-precision values into a REAL column.
insert into film(replacement_cost) values(1999.99);
insert into film(replacement_cost) values(19999.99);
select replacement_cost from film;

--The value 19999.99 is converted to 20000 to meet the 6-digit precision requirement for the column.
--The value 1999.99 is loaded as is.

create table address(
address_id integer,
address1 varchar(100),
address2 varchar(50),
district varchar(20),
city_name char(20),
state char(2),
postal_code char(5)
);

--Because ADDRESS1 is a VARCHAR column, the trailing blanks in the second inserted address are
--semantically insignificant. In other words, these two inserted addresses match.
insert into address(address1) values('9516 Magnolia Boulevard');
insert into address(address1) values('9516 Magnolia Boulevard ');
select count(*) from address
where address1='9516 Magnolia Boulevard';
--If the ADDRESS1 column were a CHAR column and the same values were inserted, the COUNT(*) query
--would recognize the character strings as the same and return 2.

--The LENGTH function recognizes trailing blanks in VARCHAR columns:
select length(address1) from address;

--Character strings are not truncated to fit the declared width of the column:
insert into address(city_name) values('City of South San Francisco');

--A workaround for this problem is to cast the value to the size of the column:
insert into address(city_name)
values('City of South San Francisco'::char(20));
select * from address
--To view a list of supported time zone names, execute the following command.
select pg_timezone_names();

--To view a list of supported time zone abbreviations, execute the following command.
select pg_timezone_abbrevs();

--TIMESTAMPTZ columns store values with up to a maximum of 6 digits of precision for fractional seconds.
--If you insert a date into a TIMESTAMPTZ column, or a date with a partial time stamp, the value is
--implicitly converted into a full time stamp value with default values (00) for missing hours, minutes, and
--seconds. TIMESTAMPTZ values are UTC in user tables.

--Insert dates that have different formats and display the output:
create table datetable (start_date date, end_date date);
insert into datetable values ('2008-06-01','2008-12-31');
insert into datetable values ('Jun 1,2008','20081231');
select * from datetable order by 1;

--If you insert a time stamp value into a DATE column, the time portion is ignored and only the date
--loaded.
--If you insert a date into a TIMESTAMP or TIMESTAMPTZ column, the time defaults to midnight. For
--example, if you insert the literal 20081231, the stored value is 2008-12-31 00:00:00.

--Insert timestamps that have different formats and display the output:
create table tstamp(timeofday timestamp, timeofdaytz timestamptz);
insert into tstamp values('Jun 1,2008 09:59:59', 'Jun 1,2008 09:59:59 EST' );
insert into tstamp values('Dec 31,2008 18:20','Dec 31,2008 18:20');
insert into tstamp values('Jun 1,2008 09:59:59 EST', 'Jun 1,2008 09:59:59');

--Examples of today and now
select today()
select dateadd(day,1,'today');
select dateadd(day,1,'now');

--The following examples show a series of calculations with different interval values.
--Add 1 second to the specified date:
select caldate + interval '1 second' as dateplus from date
where caldate='12-31-2008';

--Add 1 minute to the specified date:
select caldate + interval '1 minute' as dateplus from date
where caldate='12-31-2008';

--Add 3 hours and 35 minutes to the specified date:
select caldate + interval '3 hours, 35 minutes' as dateplus from date
where caldate='12-31-2008';

--Add 52 weeks to the specified date:
select caldate + interval '52 weeks' as dateplus from date
where caldate='12-31-2008';

--Add 1 week, 1 hour, 1 minute, and 1 second to the specified date:
select caldate + interval '1w, 1h, 1m, 1s' as dateplus from date
where caldate='12-31-2008';

--Add 12 hours (half a day) to the specified date:
select caldate + interval '0.5 days' as dateplus from date
where caldate='12-31-2008';

--You could use a BOOLEAN column to store an "Active/Inactive" state for each customer in a CUSTOMER table:
--If no default value (true or false) is specified in the CREATE TABLE statement, inserting a default value
--means inserting a null.
create table customer(
custid int,
active_flag boolean default true);

insert into customer values(100, default);
select * from customer;

--In this example, the query selects users from the USERS table who like sports but do not like theatre:
select firstname, lastname, likesports, liketheatre
from users
where likesports is true and liketheatre is false
order by userid limit 10;

--This example selects users from the USERS table for whom is it unknown whether they like rock music:
select firstname, lastname, likerock
from users
where likerock is unknown
order by userid limit 10;

--The following example returns USERID and USERNAME from the USERS table where the user likes both
--Las Vegas and sports:
select userid, username from users
where likevegas = 1 and likesports = 1
order by userid;

--The next example returns the USERID and USERNAME from the USERS table where the user likes Las
--Vegas, or sports, or both. This query returns all of the output from the previous example plus the users
--who like only Las Vegas or sports.
select userid, username from users
where likevegas = 1 or likesports = 1
order by userid;

--The following query uses parentheses around the OR condition to find venues in New York or California
--where Macbeth was performed. Removing the parentheses in this example changes the logic and results of the query.
select distinct venuename, venuecity
from venue join event on venue.venueid=event.venueid
where (venuestate = 'NY' or venuestate = 'CA') and eventname='Macbeth'
order by 2,1;

--The following example uses the NOT operator:
select * from category
where not catid=1
order by 1;

--The following example uses a NOT condition followed by an AND condition:
select * from category
where (not catid=1) and catgroup='Sports'
order by catid;

--The following example finds all cities whose names start with "E":
select distinct city from users
where city like 'E%' order by city;

--The following example finds users whose last name contains "ten" :
select distinct lastname from users
where lastname like '%ten%' order by lastname;

--The following example finds cities whose third and fourth characters are "ea". The command uses ILIKE
--to demonstrate case insensitivity:
select distinct city from users where city ilike '__EA%' order by city;

--The following example uses the default escape string (\\) to search for strings that include "_":
select tablename, "column" from pg_table_def
where "column" like '%start\\_%'
limit 5;

--The following example specifies '^' as the escape character, then uses the escape character to search for
--strings that include "_":
select tablename, "column" from pg_table_def
where "column" like '%start^_%' escape '^'
limit 5;

--The following example finds all cities whose names contain "E" or "H":
select distinct city from users
where city similar to '%E%|%H%' order by city;

--The following example uses the default escape string ('\\') to search for strings that include "_":
select tablename, "column" from pg_table_def
where "column" similar to '%start\\_%'
limit 5;

--The following example specifies '^' as the escape string, then uses the escape string to search for strings
--that include "_":
select tablename, "column" from pg_table_def
where "column" similar to '%start^_%' escape '^'
limit 5;

--The following example finds all cities whose names contain E or H:
select distinct city from users
where city ~ '.*E.*|.*H.*' order by city;

--The following example uses the escape string ('\\') to search for strings that include a period.
select venuename from venue
where venuename ~ '.*\\..*';

--The following example counts how many transactions registered sales of either 2, 3, or 4 tickets:
select count(*) from sales
where qtysold between 2 and 4;

--The range condition includes the begin and end values.
select min(dateid), max(dateid) from sales
where dateid between 1900 and 1910;

--The first expression in a range condition must be the lesser value and the second expression the greater
--value. The following example will always return zero rows due to the values of the expressions:
select count(*) from sales
where qtysold between 4 and 2;

--However, applying the NOT modifier will invert the logic and produce a count of all rows:
select count(*) from sales
where qtysold not between 4 and 2;

--The following query returns a list of venues with 20000 to 50000 seats:
select venueid, venuename, venueseats from venue
where venueseats between 20000 and 50000
order by venueseats desc;

--This example indicates how many times the SALES table contains null in the QTYSOLD field:
select count(*) from sales
where qtysold is null;

--This example returns all date identifiers, one time each, for each date that had a sale of any kind:
select dateid from date
where exists (
select 1 from sales
where date.dateid = sales.dateid
)
order by dateid;
