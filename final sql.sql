CREATE DATABASE IF NOT EXISTS nyc;

-- Create a copy of the table so that the original data is available for reference
--    CREATE TABLE nycaccidents2020_original SELECT * FROM
 --   nycaccidents2020;

DROP TABLE IF EXISTS nycaccidents2020;
CREATE TABLE nycaccidents2020 SELECT * FROM
    nycaccidents2020_original;
-- Data Cleaning
-- Replace blank values in `zip code` column to null values
UPDATE nycaccidents2020 
SET `zip code` = NULL
WHERE `zip code` = '';

-- Find the number of null values in `zip code`
SELECT COUNT(*)
FROM nycaccidents2020
WHERE `zip code` IS NULL;

-- We can fill the null records `zip code` column by reffering to the `latitude`, `longitude` and `location` columns.
-- The zip code will be same for the same lat and long values.
SELECT a.latitude, a.longitude, a.`zip code`, b.latitude, b.longitude, b.`zip code`,
    ifnull(a.`zip code`, b.`zip code`) as `zip code`
FROM nycaccidents2020 a
JOIN nycaccidents2020 b USING (location)
WHERE a.`zip code` IS NULL AND b.`zip code` IS NOT NULL;
        
UPDATE nycaccidents2020 AS a
JOIN
    (SELECT DISTINCT
        location, `zip code`
FROM nycaccidents2020
WHERE `zip code` IS NOT NULL) AS b
	USING (location) 
SET a.`zip code` = b.`zip code`
WHERE a.`zip code` IS NULL;
    
-- Some locations do not have zip code details.
-- We used a python script to fetch these details and imported it to MySQL.
-- This data was added as a new table 'locations_frompython'
-- Let's update the null zip codes in nycaccidents2020 using the details in new table.
UPDATE nycaccidents2020 n
JOIN locations_frompython l
	USING (location) 
SET n.`zip code` = l.`zip code`
WHERE n.`zip code` IS NULL;

-- Zip code 111354 has been mistyped in some columns(Found out after examinig the other columns).
-- It needs to be changed to 11354
UPDATE nycaccidents2020 
SET `zip code` = 11354
WHERE `zip code` = 111354;

UPDATE nycaccidents2020 
SET `zip code` = NULL
WHERE `zip code` = 'New York';


-- Manually updating empty borough values
UPDATE nycaccidents2020 
SET borough = 'BRONX'
WHERE      `zip code` BETWEEN 10452 AND 10475
        OR `zip code` = 11235
        OR `zip code` = 10451 AND borough = '';

UPDATE nycaccidents2020 
SET borough = 'MANHATTAN'
WHERE      `zip code` BETWEEN 10001 AND 10007
        OR `zip code` BETWEEN 10009 AND 10014
        OR `zip code` BETWEEN 10016 AND 10023
        OR `zip code` BETWEEN 10024 AND 10040
        OR `zip code` = 10044
        OR `zip code` = 10065
        OR `zip code` = 10115
        OR `zip code` = 10128
        OR `zip code` = 10155
        OR `zip code` = 10162
        OR `zip code` = 10280 AND borough = '';

UPDATE nycaccidents2020 
SET borough = 'STATEN ISLAND'
WHERE      `zip code` LIKE '%10314%'
        OR `zip code` BETWEEN 10301 AND 10310
        OR `zip code` = 10312 AND borough = '';

UPDATE nycaccidents2020 
SET borough = 'QUEENS'
WHERE      `zip code` BETWEEN 11004 AND 11005
        OR `zip code` BETWEEN 11101 AND 11106
        OR `zip code` BETWEEN 11354 AND 11379
        OR `zip code` = 11385
        OR `zip code` BETWEEN 11411 AND 11423
        OR `zip code` BETWEEN 11426 AND 11429
        OR `zip code` BETWEEN 11432 AND 11436
        OR `zip code` = 11691
        OR `zip code` BETWEEN 11692 AND 11697
        AND borough = '';

UPDATE nycaccidents2020 
SET borough = 'BROOKLYN'
WHERE      `zip code` = 11201
        OR `zip code` BETWEEN 11203 AND 11226
        OR `zip code` BETWEEN 11228 AND 11239
        OR `zip code` BETWEEN 11249 AND 11252
        AND borough = '';



-- Adding some columns that will help in further analysis
-- Adding a column that specifies the part of the day
ALTER TABLE nycaccidents2020
ADD  PartOfTheDay varchar(10) AS 
(CASE
		WHEN `CRASH TIME` BETWEEN '05:00:00' AND '11:59:59' THEN 'Morning'
        WHEN `CRASH TIME` BETWEEN '12:00:00' AND '16:59:59' THEN 'Afternoon'
        WHEN `CRASH TIME` BETWEEN '17:00:00' AND '23:59:59' THEN 'Evening'
        WHEN `CRASH TIME` BETWEEN '00:00:00' AND '04:59:59' THEN 'Night'
        END);


-- Adding a column with name of the season
ALTER TABLE nycaccidents2020
ADD Season varchar(10) AS
(CASE 
	WHEN EXTRACT(MONTH FROM `CRASH DATE`) BETWEEN 3 AND 5 THEN 'Spring'
    WHEN EXTRACT(MONTH FROM `CRASH DATE`) BETWEEN 6 AND 8 THEN 'Summer'
    WHEN EXTRACT(MONTH FROM `CRASH DATE`) BETWEEN 9 AND 11 THEN 'Autumn'
    WHEN EXTRACT(MONTH FROM `CRASH DATE`) =12 OR EXTRACT(MONTH FROM `CRASH DATE`) BETWEEN 1 AND 2 THEN 'Winter'
    END);
    
ALTER TABLE nycaccidents2020
ADD DayOfTheWeek varchar(10) AS (DAYNAME(`CRASH DATE`))



    
