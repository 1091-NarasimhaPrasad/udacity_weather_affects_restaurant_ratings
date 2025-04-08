USE DATABASE RESTAURANT_WEATHER;

-- Create DWH schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS DWH;
USE SCHEMA DWH;

/**********************
* DIMENSION TABLES    *
**********************/

-- DIM_TEMPERATURE
CREATE OR REPLACE TABLE DIM_TEMPERATURE (
    date DATE PRIMARY KEY,
    min_value FLOAT,
    max_value FLOAT,
    normal_min FLOAT,
    normal_max FLOAT
);

INSERT INTO DIM_TEMPERATURE
SELECT 
    TO_DATE(date, 'YYYYMMDD') AS date,
    min_value::FLOAT,
    max_value::FLOAT,
    normal_min::FLOAT,
    normal_max::FLOAT
FROM ODS.TEMPERATURE;

-- DIM_PRECIPITATION
CREATE OR REPLACE TABLE DIM_PRECIPITATION (
    date DATE PRIMARY KEY,
    precipitation FLOAT,
    precipitation_normal FLOAT
);

INSERT INTO DIM_PRECIPITATION
SELECT 
    TO_DATE(date, 'YYYYMMDD') AS date,
    precipitation::FLOAT,
    precipitation_normal::FLOAT
FROM ODS.PRECIPITATION;

-- DIM_USERS
CREATE OR REPLACE TABLE DIM_USERS (
    user_id STRING PRIMARY KEY,
    average_stars FLOAT,
    compliment_cool INTEGER,
    compliment_cute INTEGER,
    compliment_funny INTEGER,
    compliment_hot INTEGER,
    compliment_list INTEGER,
    compliment_more INTEGER,
    compliment_note INTEGER,
    compliment_photos INTEGER,
    compliment_plain INTEGER,
    compliment_profile INTEGER,
    compliment_writer INTEGER,
    cool INTEGER,
    elite STRING,
    fans INTEGER,
    review_count INTEGER,
    useful INTEGER,
    yelping_since TIMESTAMP
);

INSERT INTO DIM_USERS
SELECT 
    user_id,
    average_stars,
    compliment_cool,
    compliment_cute,
    compliment_funny,
    compliment_hot,
    compliment_list,
    compliment_more,
    compliment_note,
    compliment_photos,
    compliment_plain,
    compliment_profile,
    compliment_writer,
    cool,
    elite,
    fans,
    review_count,
    useful,
    yelping_since
FROM ODS.YELP_USERS;

-- DIM_REVIEWS
CREATE OR REPLACE TABLE DIM_REVIEWS (
    review_id STRING PRIMARY KEY,
    business_id STRING,
    user_id STRING,
    cool INTEGER,
    date DATE,
    funny INTEGER,
    stars INTEGER,
    text STRING,
    useful INTEGER,
    FOREIGN KEY (business_id) REFERENCES DIM_BUSINESSES(business_id),
    FOREIGN KEY (user_id) REFERENCES DIM_USERS(user_id)
);

INSERT INTO DIM_REVIEWS
SELECT 
    review_id,
    business_id,
    user_id,
    cool,
    TO_DATE(date, 'YYYY-MM-DD') AS date,
    funny,
    stars,
    text,
    useful
FROM ODS.YELP_REVIEWS;

-- DIM_BUSINESSES
CREATE OR REPLACE TABLE DIM_BUSINESSES (
    business_id STRING PRIMARY KEY,
    address STRING,
    attributes STRING,
    city STRING,
    hours STRING,
    is_open BOOLEAN,
    latitude FLOAT,
    longitude FLOAT,
    name STRING,
    postal_code STRING,
    review_count INTEGER,
    stars FLOAT,
    state STRING
);

INSERT INTO DIM_BUSINESSES
SELECT 
    business_id,
    address,
    attributes,
    city,
    hours,
    is_open,
    latitude,
    longitude,
    name,
    postal_code,
    review_count,
    stars,
    state
FROM ODS.YELP_BUSINESSES;

/**********************
* FACT TABLE          *
**********************/

-- FACT_CLIMATE_REVIEW
CREATE OR REPLACE TABLE FACT_CLIMATE_REVIEW (
    date DATE,
    review_id STRING,
    business_id STRING,
    user_id STRING,
    min_temperature FLOAT,
    max_temperature FLOAT,
    precipitation FLOAT,
    stars FLOAT,
    PRIMARY KEY (date, review_id, business_id),
    FOREIGN KEY (review_id) REFERENCES DIM_REVIEWS(review_id),
    FOREIGN KEY (business_id) REFERENCES DIM_BUSINESSES(business_id),
    FOREIGN KEY (user_id) REFERENCES DIM_USERS(user_id)
);

INSERT INTO FACT_CLIMATE_REVIEW
SELECT 
    r.date,
    r.review_id,
    r.business_id,
    r.user_id,
    t.min_value AS min_temperature,
    t.max_value AS max_temperature,
    p.precipitation,
    r.stars
FROM DIM_REVIEWS r
JOIN DIM_TEMPERATURE t ON r.date = t.date
JOIN DIM_PRECIPITATION p ON r.date = p.date
WHERE p.precipitation != 999; -- Filter out invalid precipitation values

/**********************
* VERIFICATION QUERIES *
**********************/

-- Check dimension tables
SELECT * FROM DIM_TEMPERATURE LIMIT 10;
SELECT * FROM DIM_PRECIPITATION LIMIT 10;
SELECT * FROM DIM_USERS LIMIT 10;
SELECT * FROM DIM_REVIEWS LIMIT 10;
SELECT * FROM DIM_BUSINESSES LIMIT 10;

-- Check fact table
SELECT * FROM FACT_CLIMATE_REVIEW LIMIT 10;
