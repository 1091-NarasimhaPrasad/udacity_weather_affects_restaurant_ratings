USE DATABASE RESTAURANT_WEATHER;

-- Create a view to integrate climate and Yelp data
CREATE OR REPLACE VIEW integrated_climate_yelp AS
SELECT
    yr.review_date AS review_date,
    yr.business_id,
    yb.business_name,
    ((t.min_temp + t.max_temp) / 2) AS avg_temperature_fahrenheit,
    p.precipitation_inches,
    yr.avg_review_stars,
    yr.total_reviews,
    c.temporary_closure_date
FROM (
    SELECT
        CAST(DATE_TRUNC('DAY', review_date) AS DATE) AS review_date,
        business_id,
        AVG(review_stars) AS avg_review_stars,
        COUNT(*) AS total_reviews
    FROM RESTAURANT_WEATHER.ODS.YELP_REVIEWS
    GROUP BY review_date, business_id
) AS yr
LEFT JOIN RESTAURANT_WEATHER.ODS.TEMPERATURES t
    ON yr.review_date = t.recorded_date
LEFT JOIN RESTAURANT_WEATHER.ODS.PRECIPITATION p
    ON yr.review_date = p.recorded_date
LEFT JOIN RESTAURANT_WEATHER.ODS.YELP_BUSINESSES yb
    ON yr.business_id = yb.business_id
LEFT JOIN RESTAURANT_WEATHER.ODS.COVID_CLOSURES c
    ON yr.business_id = c.business_id
WHERE p.precipitation_inches != 999 -- Exclude invalid precipitation values
ORDER BY yr.review_date, yr.business_id;
