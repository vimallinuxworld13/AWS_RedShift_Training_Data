--This command would fail if your IAM role does not have S3 Write Access
--Attach AmazonS3FullAccess policy to the IAM Role associated with Redshift
unload ('select * from city_new')
TO 's3://sid-city-data/Unload/'
iam_role '<insert IAM Role ARN here>'

--Switch parallel loading to off
unload ('select * from city_new')
TO 's3://sid-city-data/Unload/'
iam_role '<insert IAM Role ARN here>'
PARALLEL OFF

--Switch overwriting of files on
unload ('select * from city_new')
TO 's3://sid-city-data/Unload/'
iam_role '<insert IAM Role ARN here>'
ALLOWOVERWRITE
PARALLEL OFF

--Specify delimiter style as tab-delimited
unload ('select * from city_new')
TO 's3://sid-city-data/Unload/'
iam_role '<insert IAM Role ARN here>'
DELIMITER AS '\t'
ALLOWOVERWRITE
PARALLEL OFF

--Create manifest and compress file in GZIP format
unload ('select * from city_new')
TO 's3://sid-city-data/Unload/'
iam_role '<insert IAM Role ARN here>'
MANIFEST
DELIMITER AS '\t'
GZIP
ALLOWOVERWRITE
PARALLEL OFF

--Unload examples link
--https://docs.aws.amazon.com/redshift/latest/dg/r_UNLOAD_command_examples.html
