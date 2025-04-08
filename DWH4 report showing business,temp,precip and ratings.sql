USE DATABASE RESTAURANT_WEATHER;
USE SCHEMA DWH;

-- Generate report with business name, temperature, precipitation, and ratings
SELECT 
    bus.name AS business_name,
    fact.min_temperature,
    fact.max_temperature,
    fact.precipitation,
    fact.stars 
FROM 
    FACT_CLIMATE_REVIEW fact
JOIN 
    DIM_BUSINESSES bus 
    ON fact.business_id = bus.business_id
ORDER BY 
    business_name, 
    fact.date;
