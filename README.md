# udacity_weather_affects_restaurant_ratings

Welcome to the project "Designing a Data Warehouse for Reporting and OLAP." In this project, I explored the relationship between weather and customer reviews of restaurants using real-world Yelp and climate datasets. The project revolves around architecting and designing a Data Warehouse (DWH) for the purpose of reporting and online analytical processing (OLAP). I utilized Snowflake, a cloud-native data warehouse system, to accomplish this task.
Getting Set Up
Downloading the Data
To begin, you need to download the necessary datasets for your analysis. Follow these steps:

Visit the Yelp Dataset page and enter your details to access the data. YELP dataset page
Download the "Download JSON" and "COVID-19 Data" files.
If the COVID-19 Data is not available on Yelp, you can get it from the provided Kaggle page. Kaggle Page to download COVID-19 data
Save the downloaded files using single-word filenames for ease of loading into the database later.
You'll also need climate data:

Download the precipitation and temperature data CSV files using links below.
Temperature csv
Precipitation csv
Snowflake Account Setup
If you already have a Snowflake account, you can skip this step. Otherwise, follow these instructions:

Create a Snowflake account at Snowflake: Your Cloud Data Platform.
Choose the "Start for free" option and provide your details.
Select an Enterprise plan and a cloud provider.
Activate your account using the link sent to your email.
Install the SnowSQL client:

Install the SnowSQL client from the Snowflake Repository.
For Mac OS users, troubleshoot using the provided link if needed.
Explore the Data
Take some time to familiarize yourself with the data you've uploaded into Snowflake.

Instructions
Data Architecture Diagram: Create a diagram illustrating how you will move data into Staging, Operational Data Store (ODS), and Data Warehouse environments. This diagram will help visualize your approach.

Staging Environment: Set up a staging environment/schema in Snowflake.

Data Upload to Staging: Upload all Yelp and Climate data to the staging environment. Make sure to split large JSON files (< 3 million records per file in Yelp) using tools like PineTools or 7zip to prevent parsing errors.

Operational Data Store (ODS): Create an ODS environment/schema in Snowflake. Design an entity-relationship (ER) diagram to illustrate data structure.

Migrate to ODS: Move the data from the staging environment to the ODS environment. Document this process using screenshots.

Data Warehouse Environment: Design a STAR schema for the Data Warehouse environment.

Migrate to Data Warehouse: Transfer data from ODS to the Data Warehouse. Capture this process with screenshots.

Query and Analysis: Use SQL queries to analyze the data in the Data Warehouse. Specifically, explore how weather affects Yelp reviews. Provide SQL code and screenshots.
