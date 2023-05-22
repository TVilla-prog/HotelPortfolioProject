
--After importing Dataset checking to make sure each year is complete.  Looks like 2020 only has data until August.

SELECT *
--From[HotelPorfolioProject].[dbo].['2018$']
--From[HotelPorfolioProject].[dbo].['2019$']
FROM [HotelPorfolioProject].[dbo].['2020$']
ORDER BY
    CASE arrival_date_month
        WHEN 'January' THEN 1
        WHEN 'February' THEN 2
        WHEN 'March' THEN 3
        WHEN 'April' THEN 4
        WHEN 'May' THEN 5
        WHEN 'June' THEN 6
        WHEN 'July' THEN 7
        WHEN 'August' THEN 8
        WHEN 'September' THEN 9
        WHEN 'October' THEN 10
        WHEN 'November' THEN 11
        WHEN 'December' THEN 12
    END;
--Looking at Total Revenue
with hotels as(
select *
from[HotelPorfolioProject].[dbo].['2018$']
union
select *
from[HotelPorfolioProject].[dbo].['2019$']
union
select *
from[HotelPorfolioProject].[dbo].['2020$'])
select 
arrival_date_year, 
hotel,
round(sum((stays_in_week_nights+stays_in_weekend_nights)*adr),2) as revenue 
from hotels
group by arrival_date_year,hotel

--Looking at market_segment and hotel meal discounts compared to total revenue
with hotels as(
select *
from[HotelPorfolioProject].[dbo].['2018$']
union
select *
from[HotelPorfolioProject].[dbo].['2019$']
union
select *
from[HotelPorfolioProject].[dbo].['2020$'])

select* from hotels
left join [HotelPorfolioProject].[dbo].[market_segment$]
on hotels.market_segment = market_segment$.market_segment
left join [HotelPorfolioProject].[dbo].[meal_cost$]
on meal_cost$.meal = hotels.meal

  -- Combine years into new table
  SELECT *
INTO NewTable
FROM
(
    SELECT *
    FROM [HotelPorfolioProject].[dbo].['2018$']
    UNION ALL
    SELECT *
    FROM [HotelPorfolioProject].[dbo].['2019$']
    UNION ALL
    SELECT *
    FROM [HotelPorfolioProject].[dbo].['2020$']
) AS CombinedData;

select *
from NewTable

-- ALL years combined with Discount and Cost of meals 
SELECT NewTable.*,
       market_segment$.Discount,
       meal_cost$.Cost
INTO NewJoinedTable
FROM NewTable
LEFT JOIN [HotelPorfolioProject].[dbo].[market_segment$]
    ON NewTable.market_segment = market_segment$.market_segment
LEFT JOIN [HotelPorfolioProject].[dbo].[meal_cost$]
    ON meal_cost$.meal = NewTable.meal;

 select *
 From NewJoinedTable

 --Analysis will be done with NewJoinedTable
 --Revenue without any discounts
 select
 arrival_date_year,
round(sum((stays_in_week_nights+stays_in_weekend_nights)*adr),2) as revenue 
 From NewJoinedTable
 group by arrival_date_year,hotel

 --Revenue queries with Discounts/Cost of meals

 --Total Revenue--
	SELECT
    ROUND(SUM(((stays_in_week_nights + stays_in_weekend_nights) * adr) - (Discount * 100) - Cost), 2) AS revenueByYear
FROM
    NewJoinedTable

    
--Revenue by year, hotel type, total--Visuals for trend line dashboard 

SELECT
    arrival_date_year,
    hotel,
    ROUND(SUM(((stays_in_week_nights + stays_in_weekend_nights) * adr) - (Discount * 100) - Cost), 2) AS revenue
FROM
    NewJoinedTable
GROUP BY
    arrival_date_year,
    hotel

UNION ALL

SELECT
    arrival_date_year,
    'Total' AS hotel,
    ROUND(SUM(((stays_in_week_nights + stays_in_weekend_nights) * adr) - (Discount * 100) - Cost), 2) AS revenue
FROM
    NewJoinedTable
GROUP BY
    arrival_date_year
ORDER BY
    arrival_date_year, hotel;



--Average ADR-Visual 
 select 
 arrival_date_year,
    'Total' as hotel,
	ROUND(AVG(adr),2) as AvgAmountPaid
 From NewJoinedTable
 GROUP BY
    arrival_date_year, hotel
	Union all
	 select 
 arrival_date_year,
    hotel,
	ROUND(AVG(adr),2) as AvgAmountPaid
 From NewJoinedTable
 GROUP BY
    arrival_date_year, hotel


--Total nights,weeknights,weekend,adults verses children City/Resort hotel stays organized by month and country visual

	SELECT
    arrival_date_year,
    hotel,
    arrival_date_month,
    country,
    SUM(stays_in_week_nights + stays_in_weekend_nights) as TotalNights,
    SUM(stays_in_weekend_nights) as Weekend,
    SUM(stays_in_week_nights) as Week_nights,
    SUM(CASE WHEN stays_in_weekend_nights > 0 AND adults > 0 AND children = 0 THEN 1 ELSE 0 END) AS WeekendStaysWithAdults,
    SUM(CASE WHEN stays_in_week_nights > 0 AND adults > 0 AND children = 0 THEN 1 ELSE 0 END) AS WeeknightStaysWithAdults,
    SUM(CASE WHEN stays_in_weekend_nights > 0 AND children > 0 THEN 1 ELSE 0 END) AS WeekendStaysWithChildren,
    SUM(CASE WHEN stays_in_week_nights > 0 AND children > 0 THEN 1 ELSE 0 END) AS WeeknightStaysWithChildren
FROM NewJoinedTable
GROUP BY
    arrival_date_year, hotel, arrival_date_month, country;

	--Average Discount visual
	 select 
	arrival_date_year,
    hotel,
	AVG(Discount)*100 as AverageDiscount
 From NewJoinedTable
 GROUP BY
    arrival_date_year, hotel;

	--Total and hotel type Required Parking with Percentage Visual

	select 
	arrival_date_year,
    'Total' as hotel,
	SUM(required_car_parking_spaces)as TotalRequiredParking,
	SUM(required_car_parking_spaces)/
	SUM(stays_in_weekend_nights + stays_in_week_nights)*100 as ParkingPercentage
from NewTable
GROUP BY
    arrival_date_year, hotel
	Union all
	select 
	arrival_date_year,
    hotel,
	SUM(required_car_parking_spaces)as RequiredParking,
	SUM(required_car_parking_spaces)/
	SUM(stays_in_weekend_nights + stays_in_week_nights)*100 as ParkingPercentage
from NewTable
GROUP BY
    arrival_date_year, hotel
	
	

--

