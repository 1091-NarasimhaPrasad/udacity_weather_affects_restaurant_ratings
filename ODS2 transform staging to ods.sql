-- Switch to the target database and schema
USE DATABASE RESTAURANT_WEATHER;
USE SCHEMA ODS;

---------------------------------------------------------------------
-- 1. TRANSFORM PRECIPITATION DATA
---------------------------------------------------------------------
-- Create the ODS table for precipitation observations
CREATE OR REPLACE TABLE ods_precipitation (
  obs_date DATE,
  precipitation FLOAT,
  precipitation_normal FLOAT
);

-- Insert transformed data from staging:
-- Convert the date string and convert 'T' (trace) into a NULL value,
-- otherwise try to convert the value to a number.
INSERT INTO ods_precipitation (obs_date, precipitation, precipitation_normal)
SELECT 
  TO_DATE($1, 'YYYYMMDD') AS obs_date,
  CASE 
    WHEN $2 = 'T' THEN NULL 
    ELSE TRY_TO_NUMBER($2) 
  END AS precipitation,
  TRY_TO_NUMBER($3) AS precipitation_normal
FROM RESTAURANT_WEATHER.STAGING.NYC_PRECIPITATION;

-- Verify the loaded data:
SELECT * FROM ods_precipitation LIMIT 1000;


---------------------------------------------------------------------
-- 2. TRANSFORM TEMPERATURE DATA
---------------------------------------------------------------------
-- Create the ODS table for temperature observations
CREATE OR REPLACE TABLE ods_temperature (
  obs_date DATE,
  min_temperature FLOAT,
  max_temperature FLOAT,
  normal_min FLOAT,
  normal_max FLOAT
);

-- Insert transformed temperature data from staging:
INSERT INTO ods_temperature (obs_date, min_temperature, max_temperature, normal_min, normal_max)
SELECT 
  TO_DATE($1, 'YYYYMMDD') AS obs_date,
  TRY_TO_NUMBER($2) AS min_temperature,
  TRY_TO_NUMBER($3) AS max_temperature,
  TRY_TO_NUMBER($4) AS normal_min,
  TRY_TO_NUMBER($5) AS normal_max
FROM RESTAURANT_WEATHER.STAGING.NYC_TEMPERATURE;

-- Verify the loaded data:
SELECT * FROM ods_temperature LIMIT 1000;


---------------------------------------------------------------------
-- 3. TRANSFORM YELP BUSINESSES
---------------------------------------------------------------------
-- Create the ODS table for Yelp Businesses
CREATE OR REPLACE TABLE ods_yelp_businesses (
  business_id STRING,
  name STRING,
  address STRING,
  city STRING,
  state STRING,
  postal_code STRING,
  latitude FLOAT,
  longitude FLOAT,
  stars FLOAT,
  review_count NUMBER,
  is_open BOOLEAN,
  attributes VARIANT,
  categories STRING,
  hours VARIANT
);

-- Insert transformed Yelp Business data.
-- We use TRY_TO_* casts and assume the raw JSON is in the column "raw_data".
INSERT INTO ods_yelp_businesses
SELECT 
  TRY_TO_VARCHAR(PARSE_JSON(raw_data):business_id),
  TRY_TO_VARCHAR(PARSE_JSON(raw_data):name),
  TRY_TO_VARCHAR(PARSE_JSON(raw_data):address),
  TRY_TO_VARCHAR(PARSE_JSON(raw_data):city),
  TRY_TO_VARCHAR(PARSE_JSON(raw_data):state),
  TRY_TO_VARCHAR(PARSE_JSON(raw_data):postal_code),
  TRY_TO_NUMBER(PARSE_JSON(raw_data):latitude),
  TRY_TO_NUMBER(PARSE_JSON(raw_data):longitude),
  TRY_TO_NUMBER(PARSE_JSON(raw_data):stars),
  TRY_TO_NUMBER(PARSE_JSON(raw_data):review_count),
  TRY_TO_BOOLEAN(PARSE_JSON(raw_data):is_open),
  PARSE_JSON(raw_data):attributes,
  TRY_TO_VARCHAR(PARSE_JSON(raw_data):categories),
  PARSE_JSON(raw_data):hours
FROM RESTAURANT_WEATHER.STAGING.YELP_BUSINESSES;

-- Check the transformation:
SELECT * FROM ods_yelp_businesses LIMIT 1000;


---------------------------------------------------------------------
-- 4. TRANSFORM YELP CHECKINS
---------------------------------------------------------------------
-- Create the ODS table for Yelp Checkins
CREATE OR REPLACE TABLE ods_yelp_checkins (
  business_id STRING,
  checkin_datetime TIMESTAMP_NTZ
);

-- Insert transformed data from the staging checkins table.
-- If the checkin date is a comma-separated list, you might need to split and flatten it.
INSERT INTO ods_yelp_checkins
SELECT 
  TRY_TO_VARCHAR(PARSE_JSON(raw_data):business_id),
  TRY_TO_TIMESTAMP(PARSE_JSON(raw_data):date)
FROM RESTAURANT_WEATHER.STAGING.YELP_CHECKINS;

-- Verify:
SELECT * FROM ods_yelp_checkins LIMIT 1000;


---------------------------------------------------------------------
-- 5. TRANSFORM YELP USERS
---------------------------------------------------------------------
-- Create the ODS table for Yelp Users
CREATE OR REPLACE TABLE ods_yelp_users (
  user_id STRING,
  name STRING,
  review_count NUMBER,
  yelping_since TIMESTAMP_NTZ,
  useful NUMBER,
  funny NUMBER,
  cool NUMBER,
  elite STRING,
  friends VARIANT,
  fans NUMBER,
  average_stars FLOAT,
  compliment_hot NUMBER,
  compliment_more NUMBER,
  compliment_profile NUMBER,
  compliment_cute NUMBER,
  compliment_list NUMBER,
  compliment_note NUMBER,
  compliment_plain NUMBER,
  compliment_cool NUMBER,
  compliment_funny NUMBER,
  compliment_writer NUMBER,
  compliment_photos NUMBER
);

INSERT INTO ods_yelp_users
SELECT 
  TRY_TO_VARCHAR(PARSE_JSON(raw_data):user_id),
  TRY_TO_VARCHAR(PARSE_JSON(raw_data):name),
  TRY_TO_NUMBER(PARSE_JSON(raw_data):review_count),
  TRY_TO_TIMESTAMP(PARSE_JSON(raw_data):yelping_since),
  TRY_TO_NUMBER(PARSE_JSON(raw_data):useful),
  TRY_TO_NUMBER(PARSE_JSON(raw_data):funny),
  TRY_TO_NUMBER(PARSE_JSON(raw_data):cool),
  TRY_TO_VARCHAR(PARSE_JSON(raw_data):elite),
  PARSE_JSON(raw_data):friends,
  TRY_TO_NUMBER(PARSE_JSON(raw_data):fans),
  TRY_TO_NUMBER(PARSE_JSON(raw_data):average_stars),
  TRY_TO_NUMBER(PARSE_JSON(raw_data):compliment_hot),
  TRY_TO_NUMBER(PARSE_JSON(raw_data):compliment_more),
  TRY_TO_NUMBER(PARSE_JSON(raw_data):compliment_profile),
  TRY_TO_NUMBER(PARSE_JSON(raw_data):compliment_cute),
  TRY_TO_NUMBER(PARSE_JSON(raw_data):compliment_list),
  TRY_TO_NUMBER(PARSE_JSON(raw_data):compliment_note),
  TRY_TO_NUMBER(PARSE_JSON(raw_data):compliment_plain),
  TRY_TO_NUMBER(PARSE_JSON(raw_data):compliment_cool),
  TRY_TO_NUMBER(PARSE_JSON(raw_data):compliment_funny),
  TRY_TO_NUMBER(PARSE_JSON(raw_data):compliment_writer),
  TRY_TO_NUMBER(PARSE_JSON(raw_data):compliment_photos)
FROM RESTAURANT_WEATHER.STAGING.YELP_USERS;

-- Check the transformation:
SELECT * FROM ods_yelp_users LIMIT 100;


---------------------------------------------------------------------
-- 6. TRANSFORM YELP REVIEWS
---------------------------------------------------------------------
-- Create the ODS table for Yelp Reviews
CREATE OR REPLACE TABLE ods_yelp_reviews (
  review_id STRING,
  user_id STRING,
  business_id STRING,
  stars FLOAT,
  useful NUMBER,
  funny NUMBER,
  cool NUMBER,
  review_text STRING,
  review_date TIMESTAMP_NTZ
);

INSERT INTO ods_yelp_reviews
SELECT 
  TRY_TO_VARCHAR(PARSE_JSON(raw_data):review_id),
  TRY_TO_VARCHAR(PARSE_JSON(raw_data):user_id),
  TRY_TO_VARCHAR(PARSE_JSON(raw_data):business_id),
  TRY_TO_NUMBER(PARSE_JSON(raw_data):stars),
  TRY_TO_NUMBER(PARSE_JSON(raw_data):useful),
  TRY_TO_NUMBER(PARSE_JSON(raw_data):funny),
  TRY_TO_NUMBER(PARSE_JSON(raw_data):cool),
  TRY_TO_VARCHAR(PARSE_JSON(raw_data):text),
  TRY_TO_TIMESTAMP(PARSE_JSON(raw_data):date)
FROM RESTAURANT_WEATHER.STAGING.YELP_REVIEWS;

-- Validate:
SELECT * FROM ods_yelp_reviews LIMIT 1000;


---------------------------------------------------------------------
-- 7. TRANSFORM YELP TIPS
---------------------------------------------------------------------
-- Create the ODS table for Yelp Tips
CREATE OR REPLACE TABLE ods_yelp_tips (
  user_id STRING,
  business_id STRING,
  tip_text STRING,
  tip_date TIMESTAMP_NTZ,
  compliment_count NUMBER
);

INSERT INTO ods_yelp_tips
SELECT 
  TRY_TO_VARCHAR(PARSE_JSON(raw_data):user_id),
  TRY_TO_VARCHAR(PARSE_JSON(raw_data):business_id),
  TRY_TO_VARCHAR(PARSE_JSON(raw_data):text),
  TRY_TO_TIMESTAMP(PARSE_JSON(raw_data):date),
  TRY_TO_NUMBER(PARSE_JSON(raw_data):compliment_count)
FROM RESTAURANT_WEATHER.STAGING.YELP_TIPS;

-- Verify:
SELECT * FROM ods_yelp_tips LIMIT 100;


---------------------------------------------------------------------
-- 8. TRANSFORM YELP COVID DATA
---------------------------------------------------------------------
-- Create the ODS table for Yelp COVID data
CREATE OR REPLACE TABLE ods_yelp_covid (
  business_id STRING,
  highlights STRING,
  delivery_or_takeout STRING,
  grubhub_enabled BOOLEAN,
  call_to_action_enabled BOOLEAN,
  request_a_quote_enabled BOOLEAN,
  covid_banner STRING,
  temporary_closed_until DATE,
  virtual_services_offered STRING
);

INSERT INTO ods_yelp_covid
SELECT 
  TRY_TO_VARCHAR(PARSE_JSON(raw_data):business_id),
  TRY_TO_VARCHAR(PARSE_JSON(raw_data):highlights),
  TRY_TO_VARCHAR(PARSE_JSON(raw_data):"delivery or takeout"),
  TRY_TO_BOOLEAN(PARSE_JSON(raw_data):"Grubhub enabled"),
  TRY_TO_BOOLEAN(PARSE_JSON(raw_data):"Call To Action enabled"),
  TRY_TO_BOOLEAN(PARSE_JSON(raw_data):"Request a Quote Enabled"),
  TRY_TO_VARCHAR(PARSE_JSON(raw_data):"Covid Banner"),
  NULLIF(TRY_TO_VARCHAR(PARSE_JSON(raw_data):"Temporary Closed Until"), 'FALSE')::DATE,
  TRY_TO_VARCHAR(PARSE_JSON(raw_data):"Virtual Services Offered")
FROM RESTAURANT_WEATHER.STAGING.YELP_COVID;

-- Validate:
SELECT * FROM ods_yelp_covid LIMIT 100;
