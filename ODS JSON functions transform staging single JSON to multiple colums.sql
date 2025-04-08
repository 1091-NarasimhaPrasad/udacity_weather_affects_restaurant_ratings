--
-- JSON to Relational Transformation for ODS
--
USE DATABASE RESTAURANT_WEATHER;
USE SCHEMA ODS;

-- 1. Transform Business Data
-- 
CREATE OR REPLACE TABLE businesses (
    business_id STRING PRIMARY KEY,
    name STRING,
    address STRING,
    city STRING,
    state STRING,
    postal_code STRING,
    latitude FLOAT,
    longitude FLOAT,
    stars FLOAT,
    review_count INT,
    is_open BOOLEAN,
    attributes VARIANT,
    categories ARRAY,
    hours VARIANT
);

INSERT INTO businesses
SELECT
    TRY_TO_VARCHAR(PARSE_JSON(raw_json):business_id),
    TRY_TO_VARCHAR(PARSE_JSON(raw_json):name),
    TRY_TO_VARCHAR(PARSE_JSON(raw_json):address),
    TRY_TO_VARCHAR(PARSE_JSON(raw_json):city),
    TRY_TO_VARCHAR(PARSE_JSON(raw_json):state),
    TRY_TO_VARCHAR(PARSE_JSON(raw_json):postal_code),
    TRY_TO_DOUBLE(PARSE_JSON(raw_json):latitude),
    TRY_TO_DOUBLE(PARSE_JSON(raw_json):longitude),
    TRY_TO_DOUBLE(PARSE_JSON(raw_json):stars),
    TRY_TO_NUMBER(PARSE_JSON(raw_json):review_count),
    TRY_TO_BOOLEAN(PARSE_JSON(raw_json):is_open),
    PARSE_JSON(raw_json):attributes,
    SPLIT(PARSE_JSON(raw_json):categories, ', ')::ARRAY,
    PARSE_JSON(raw_json):hours
FROM STAGING.business_json;

-- 2. Transform Checkins with Array Handling
-- 
CREATE OR REPLACE TABLE business_checkins (
    business_id STRING REFERENCES businesses(business_id),
    checkin_time TIMESTAMP,
    checkin_id INT AUTOINCREMENT PRIMARY KEY
);

INSERT INTO business_checkins (business_id, checkin_time)
SELECT
    TRY_TO_VARCHAR(PARSE_JSON(raw_json):business_id),
    TRY_TO_TIMESTAMP(c.value)
FROM STAGING.checkin_json,
LATERAL FLATTEN(INPUT => SPLIT(PARSE_JSON(raw_json):date, ', ')) c;

-- 3. Transform Reviews
-- 
CREATE OR REPLACE TABLE customer_reviews (
    review_id STRING PRIMARY KEY,
    business_id STRING REFERENCES businesses(business_id),
    user_id STRING,
    stars FLOAT CHECK (stars BETWEEN 1 AND 5),
    useful_count INT,
    funny_count INT,
    cool_count INT,
    review_text STRING,
    review_date DATE
);

INSERT INTO customer_reviews
SELECT
    TRY_TO_VARCHAR(PARSE_JSON(raw_json):review_id),
    TRY_TO_VARCHAR(PARSE_JSON(raw_json):business_id),
    TRY_TO_VARCHAR(PARSE_JSON(raw_json):user_id),
    TRY_TO_DOUBLE(PARSE_JSON(raw_json):stars),
    TRY_TO_NUMBER(PARSE_JSON(raw_json):useful),
    TRY_TO_NUMBER(PARSE_JSON(raw_json):funny),
    TRY_TO_NUMBER(PARSE_JSON(raw_json):cool),
    TRY_TO_VARCHAR(PARSE_JSON(raw_json):text),
    TRY_TO_DATE(PARSE_JSON(raw_json):date)
FROM STAGING.review_json;

-- 4. Transform COVID Features
-- 
CREATE OR REPLACE TABLE covid_features (
    business_id STRING REFERENCES businesses(business_id),
    temporary_closed_until DATE,
    delivery_available BOOLEAN,
    virtual_services STRING,
    health_safety_features ARRAY
);

INSERT INTO covid_features
SELECT
    TRY_TO_VARCHAR(PARSE_JSON(raw_json):business_id),
    NULLIF(TRY_TO_DATE(PARSE_JSON(raw_json):"Temporary Closed Until"), '1970-01-01'),
    TRY_TO_BOOLEAN(PARSE_JSON(raw_json):"delivery or takeout"),
    TRY_TO_VARCHAR(PARSE_JSON(raw_json):"Virtual Services Offered"),
    SPLIT(PARSE_JSON(raw_json):highlights, ', ')::ARRAY
FROM STAGING.covid_json;

-- 5. Validation Queries
-- 
SELECT 'Businesses' AS table_name, COUNT(*) FROM businesses
UNION ALL
SELECT 'Checkins', COUNT(*) FROM business_checkins
UNION ALL
SELECT 'Reviews', COUNT(*) FROM customer_reviews
UNION ALL
SELECT 'COVID Features', COUNT(*) FROM covid_features;
