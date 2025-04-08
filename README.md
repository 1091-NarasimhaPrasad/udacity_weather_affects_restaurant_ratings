# udacity_weather_affects_restaurant_ratings

Welcome to the project "Designing a Data Warehouse for Reporting and OLAP." In this project, I explored the relationship between weather and customer reviews of restaurants using real-world Yelp and climate datasets. The project revolves around architecting and designing a Data Warehouse (DWH) for the purpose of reporting and online analytical processing (OLAP). I utilized Snowflake, a cloud-native data warehouse system, to accomplish this task.

# Instructions:

1.Data Architecture Diagram: Create a diagram illustrating how you will move data into Staging, Operational Data Store (ODS), and Data Warehouse environments. This diagram will help visualize your approach.

2.Staging Environment: Set up a staging environment/schema in Snowflake.

3.Data Upload to Staging: Upload all Yelp and Climate data to the staging environment. Make sure to split large JSON files (< 3 million records per file in Yelp) using tools like PineTools or 7zip to prevent parsing errors.

4.Operational Data Store (ODS): Create an ODS environment/schema in Snowflake. Design an entity-relationship (ER) diagram to illustrate data structure.

5.Migrate to ODS: Move the data from the staging environment to the ODS environment. Document this process using screenshots.

6.Data Warehouse Environment: Design a STAR schema for the Data Warehouse environment.

7.Migrate to Data Warehouse: Transfer data from ODS to the Data Warehouse. Capture this process with screenshots.

8.Query and Analysis: Use SQL queries to analyze the data in the Data Warehouse. Specifically, explore how weather affects Yelp reviews. Provide SQL code and screenshots.
