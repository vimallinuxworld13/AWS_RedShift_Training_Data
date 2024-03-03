--Default Encoding

create table cartesian_venue_default(
venueid smallint not null distkey sortkey,
venuename varchar(100),
venuecity varchar(30),
venuestate char(2),
venueseats integer);

select "column", type, encoding
from pg_table_def
where tablename = 'cartesian_venue_default'

insert into cartesian_venue_default
select venueid, venuename, venuecity, venuestate, venueseats
from venue, listing;

analyze compression cartesian_venue_default

--Raw Encoding

create table cartesian_venue_raw(
venueid smallint not null distkey sortkey encode raw,
venuename varchar(100) encode raw,
venuecity varchar(30) encode raw,
venuestate char(2) encode raw,
venueseats integer encode raw);

select "column", type, encoding
from pg_table_def
where tablename = 'cartesian_venue_raw' 

insert into cartesian_venue_raw
select venueid, venuename, venuecity, venuestate, venueseats
from venue, listing;

analyze compression cartesian_venue_raw

--Zstd Encoding recommended by Analyze command

create table cartesian_venue_zstd(
venueid smallint not null distkey sortkey encode zstd,
venuename varchar(100) encode zstd,
venuecity varchar(30) encode zstd,
venuestate char(2) encode zstd,
venueseats integer encode zstd);

select "column", type, encoding
from pg_table_def
where tablename = 'cartesian_venue_zstd' 

insert into cartesian_venue_zstd
select venueid, venuename, venuecity, venuestate, venueseats
from venue, listing;

analyze compression cartesian_venue_zstd