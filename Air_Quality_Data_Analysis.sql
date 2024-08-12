create database if not exists Air_Quality ;
use Air_Quality;
select * from air_quality;
ALTER TABLE global_air_quality_data_10000
RENAME TO Air_Quality_data;
select * from air_quality_data;

## Basic 
1); select * from air_quality_data where city="New York";

2); select * from air_quality_data where city="Los Angeles" and date= '2023-08-01';

3); SELECT City, COUNT(*) AS EntryCount
	FROM Air_Quality_data
	GROUP BY City;
    
4); SELECT City, MAX(`PM2.5`) AS `Max_PM2.5`
FROM Air_Quality_data
GROUP BY City;

5); SELECT *
FROM Air_Quality_data
WHERE PM10 IS NULL;

##Intermediate
1); SELECT 
    city,
    ROUND(AVG(`PM2.5`), 2) AS `avg_pm2.5`,
    ROUND(AVG(PM10), 2) AS avg_pm10,
    ROUND(AVG(NO2), 2) AS avg_no2,
    ROUND(AVG(SO2), 2) AS avg_so2
FROM
    air_quality_data
GROUP BY city;

2); SELECT 
    date
FROM
    air_quality_data
WHERE
    city = 'Mumbai' AND `PM2.5` > 100;
    
3); SELECT 
    city, 
    round(AVG(`PM2.5`),2) as `avg_pm2.5`,
    round(AVG(pm10),2) as avg_pm10
FROM
    air_quality_data
group by city 
order by `avg_pm2.5`desc,avg_pm10 desc;

4); SELECT City,
    round((SUM(Temperature * `PM2.5`) - SUM(Temperature) * SUM(`PM2.5`) / COUNT(*)) / 
       (SQRT((SUM(Temperature * Temperature) - SUM(Temperature) * SUM(Temperature) / COUNT(*)) *
              (SUM(`PM2.5` * `PM2.5`) - SUM(`PM2.5`) * SUM(`PM2.5`) / COUNT(*)))),2) AS Temperature_PM25_Correlation
FROM Air_Quality_data
GROUP BY City;

5); select city,
	round(avg(NO2),2) as `avg_no2`
    from air_quality_data where month(date)=7 and year(date)=2023
    group by city
    order by `avg_no2` desc
    limit 1;
    
#Hard
1); SELECT 
    DATE_FORMAT(Date, '%Y-%m') AS Month,
    ROUND(AVG(`PM2.5`), 2) AS `Avg_PM2.5`
FROM air_quality_data
WHERE City = 'Beijing'
GROUP BY Month
ORDER BY Month ASC;

 SELECT 
    DATE_FORMAT(Date, '%Y-%m') AS Month,
    ROUND(AVG(`PM2.5`), 2) AS `Avg_PM2.5`
FROM air_quality_data
WHERE City = 'Beijing' 
  AND Date >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
GROUP BY Month
ORDER BY Month ASC;

2); SELECT 
    City,
    ROUND(AVG(`PM2.5`), 2) AS Avg_PM25
FROM air_quality_data
WHERE Date BETWEEN '2023-07-01' AND '2023-12-31'
GROUP BY City
ORDER BY Avg_PM25 DESC
LIMIT 5;

3); SELECT 
    City,
    CASE
        WHEN `Wind Speed` < 5 THEN '< 5 m/s'
        WHEN `Wind Speed` BETWEEN 5 AND 10 THEN '5-10 m/s'
        WHEN `Wind Speed` BETWEEN 10 AND 15 THEN '10-15 m/s'
        WHEN `Wind Speed` BETWEEN 15 AND 20 THEN '15-20 m/s'
    END AS WindSpeedRange,
    ROUND(AVG(PM10), 2) AS Avg_PM10
FROM air_quality_data
GROUP BY City, WindSpeedRange
ORDER BY City, WindSpeedRange;

SELECT 
    City,
    CASE
        WHEN `Wind Speed` >= 15 THEN 'Above 15 km/h'
        ELSE 'Below 15 km/h'
    END AS WindSpeedCategory,
    ROUND(AVG(PM10), 2) AS Avg_PM10
FROM air_quality_data
GROUP BY City, WindSpeedCategory
ORDER BY City, WindSpeedCategory;

4); WITH PreviousDayData AS (
    SELECT 
        City,
        Date,
        `PM2.5`,
        PM10,
        LAG(`PM2.5`) OVER (PARTITION BY City ORDER BY Date) AS `Prev_PM2.5`,
        LAG(PM10) OVER (PARTITION BY City ORDER BY Date) AS Prev_PM10
    FROM air_quality_data
    WHERE City = 'Dubai'
)

SELECT 
    Date,
    `PM2.5`,
    PM10,
    `Prev_PM2.5`,
    Prev_PM10,
    ROUND((`PM2.5` - `Prev_PM2.5`) / `Prev_PM2.5` * 100, 2) AS `PM2.5_Spike_Percentage`,
    ROUND((PM10 - Prev_PM10) / Prev_PM10 * 100, 2) AS PM10_Spike_Percentage
FROM PreviousDayData
WHERE 
    ((`PM2.5` - `Prev_PM2.5`) / `Prev_PM2.5` * 100 > 50 
     OR (PM10 - Prev_PM10) / Prev_PM10 * 100 > 50)
    AND `Prev_PM2.5` IS NOT NULL 
    AND Prev_PM10 IS NOT NULL;
