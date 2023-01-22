--SELECT * FROM public.green_taxi_trips LIMIT 10;

-------------------------------------------------------------
-- Question 3. Count records
-- How many taxi trips were totally made on January 15?

--Tip: started and finished on 2019-01-15.

--Answer: 20530
--------------------------------------------------------------

SELECT COUNT(1)--lpep_pickup_datetime, lpep_dropoff_datetime
	FROM public.green_taxi_trips
	WHERE lpep_pickup_datetime::DATE = '2019-01-15' AND
		lpep_dropoff_datetime::DATE = '2019-01-15';

-------------------------------------------------------------
-- Question 4. Largest trip for each day
-- Which was the day with the largest trip distance?
-- Use the pick up time for your calculations.

--Answer: 2019-01-15
--------------------------------------------------------------
SELECT MAX(trip_distance), lpep_pickup_datetime::DATE AS pickup_date
	FROM public.green_taxi_trips
	GROUP BY lpep_pickup_datetime::DATE
	ORDER BY 1 DESC LIMIT 1;
	
-------------------------------------------------------------
-- Question 5. The number of passengers
-- In 2019-01-01 how many trips had 2 and 3 passengers?

--Answer: 2:1282; 3:254
--------------------------------------------------------------	
SELECT 
	SUM(CASE WHEN passenger_count=2 THEN 1 ELSE 0 END) AS count_2,
	SUM(CASE WHEN passenger_count=3 THEN 1 ELSE 0 END) AS count_3
	FROM public.green_taxi_trips
	WHERE lpep_pickup_datetime::DATE = '2019-01-01' OR
		lpep_dropoff_datetime::DATE = '2019-01-01';
		
--SELECT lpep_pickup_datetime::DATE, lpep_dropoff_datetime::DATE, passenger_count
--	FROM public.green_taxi_trips
--	WHERE (lpep_pickup_datetime::DATE='2019-01-01' OR
--		lpep_dropoff_datetime::DATE='2019-01-01') AND (passenger_count=2 OR passenger_count=3);


--SELECT * FROM public.zones_data LIMIT 10;


-------------------------------------------------------------
-- Question 6. Largest tip
-- For the passengers picked up in the Astoria Zone which was the drop off zone that had the largest tip?
-- We want the name of the zone, not the id.

-- Answer: Long Island City/Queens Plaza
--------------------------------------------------------------
WITH cte AS (
	SELECT gt."DOLocationID" AS location, MAX(gt."tip_amount")
		FROM public.zones_data zd
			INNER JOIN
			public.green_taxi_trips gt
				ON zd."LocationID"=gt."PULocationID"
		WHERE zd."Zone"='Astoria'
		GROUP BY gt."DOLocationID"
		ORDER BY 2 DESC LIMIT 1)	
SELECT z."Zone" 
	FROM public.zones_data z
	INNER JOIN cte
	ON cte.location=z."LocationID";