--The following example creates a database named TICKIT and gives ownership to the user DWUSER:
create database DDLTest
with owner awsuser;

--Query the PG_DATABASE_INFO catalog table to view details about databases.
select datname, datdba, datconnlimit
from pg_database_info
where datdba > 1;

--The following example creates a schema named US_SALES and gives ownership to the user DWUSER:
create schema us_sales authorization awsuser;

--To view the new schema, query the PG_NAMESPACE catalog table as shown following:
select nspname as schema, usename as owner
from pg_namespace, pg_user
where pg_namespace.nspowner = pg_user.usesysid
and pg_user.usename ='awsuser';

--The following example either creates the US_SALES schema, or does nothing and returns a message if it
--already exists:
create schema if not exists us_sales;

--If you specify a table name that begins with '# ', the table will be created as a temporary
--table. The following is an example:
create table #newtable (id int);
select * from #newtable
--In the following example, the database name is tickit , the schema name is public, and the table name 
--is test.
create table tickit.public.test (c1 int);

--The following example creates a table called EVENT_BACKUP for the EVENT table:
create table event_backup as select * from event;

--To specify an MD5 password, follow these steps:
--1. Concatenate the password and user name.
--For example, for password ez and user user1, the concatenated string is ezuser1.

--2. Convert the concatenated string into a 32-character MD5 hash string. You can use Amazon Redshift MD5
--Function and the concatenation operator ( || ) to return a 32-character MD5-hash string.
select md5('ez' || 'user1');

--3. Concatenate 'md5' in front of the MD5 hash string and provide the concatenated string as the
--md5hash argument.
create user user1 password 'md5153c434b4b77c89e6b94f12c5393af5b';

--4. Log on to the database using the user name and password. 
--For this example, log on as user1 with password ez.

--The following command creates a user account named dbuser, with the password "abcD1234", database
--creation privileges, and a connection limit of 30.
create user dbuser with password 'abcD1234' createdb connection limit 30;

--Query the PG_USER_INFO catalog table to view details about a database user.
select * from pg_user_info;

--In the following example, the account password is valid until April 24, 2018.
create user dbuser with password 'abcD1234' valid until '208-04-24';

--The following example creates a user with a case-sensitive password that contains special characters.
create user newman with password '@AbC4321!';

--The following statement returns an error.
create view myevent as select eventname from event
with no schema binding;

--The following statement executes successfully.
create view myevent as select eventname from public.event
with no schema binding;

--To create a late-binding view, include the WITH NO SCHEMA BINDING clause. The following example
--creates a view with no schema binding.
create view event_vw as select * from public.event
with no schema binding;
select * from event_vw limit 1;

--The following example shows that you can alter an underlying table without recreating the view.
alter table event rename column eventname to title;
select * from event_vw limit 1;

--The following command creates a view called myevent from a table called EVENT.
create view myevent as select eventname from event
where eventname = 'LeAnn Rimes';

--The following example creates a user group named ADMIN_GROUP with a single user ADMIN:
create group admin_group with user admin;

--The following example would drop the DDLTest database and all the objects in it
drop database DDLTest
