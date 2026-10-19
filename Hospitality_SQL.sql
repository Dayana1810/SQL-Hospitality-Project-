create database hospitality_analytics;
use hospitality_analytics;

DESC dim_rooms;
DESC dim_hotels;
DESC dim_date;-- change text to DATE,TEXT TO VARCHAR
DESC fact_bookings; -- CHANGE  BOOKING_ID VARCHAR, CHECK-IN-DATE DATE,CHECK-OUT-DATE DATE
DESC FACT_AGGREGATED_BOOKINGS;-- CHANGE CHECK-IN-DATE DATE

ALTER TABLE dim_hotels
ADD PRIMARY KEY(property_id);

ALTER TABLE dim_rooms
MODIFY room_id VARCHAR(10);

ALTER TABLE dim_rooms
ADD PRIMARY KEY(room_id);

ALTER TABLE dim_date
ADD COLUMN new_date DATE;

SET SQL_SAFE_UPDATES=0;

UPDATE dim_date
SET new_date = STR_TO_DATE(`date`, '%d-%b-%y');

DESC dim_date;

ALTER TABLE dim_date
DROP COLUMN `date`;

ALTER TABLE dim_date
CHANGE new_date `date` DATE;

ALTER TABLE dim_date
CHANGE `mmm yy` month_year varchar(20);

ALTER TABLE dim_date
ADD PRIMARY KEY(`date`);

ALTER TABLE fact_bookings
MODIFY booking_date DATE;

ALTER TABLE fact_bookings
MODIFY check_in_date DATE,
MODIFY checkout_date DATE;

DESC FACT_BOOKINGS;

ALTER TABLE fact_bookings
RENAME COLUMN booking_id TO Booking_id;

ALTER TABLE fact_bookings
MODIFY booking_id VARCHAR(30);

ALTER TABLE fact_bookings
ADD PRIMARY KEY(Booking_id);

ALTER TABLE fact_bookings
DROP COLUMN check_in_date_new;

ALTER TABLE fact_bookings
MODIFY room_category VARCHAR(10);

ALTER TABLE fact_bookings
ADD CONSTRAINT fkfb_property
FOREIGN KEY (property_id)
REFERENCES dim_hotels(property_id);

SET SESSION wait_timeout = 28800;

SET SESSION interactive_timeout = 28800;

ALTER TABLE fact_bookings
ADD CONSTRAINT fkfb_room
FOREIGN KEY (room_category)
REFERENCES dim_rooms(room_id);

ALTER TABLE fact_bookings
ADD CONSTRAINT fk_date
FOREIGN KEY (check_in_date)
REFERENCES dim_date(`date`);

desc fact_bookings;

SELECT
    CONSTRAINT_NAME,
    TABLE_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = DATABASE()
AND TABLE_NAME = 'fact_bookings'
AND REFERENCED_TABLE_NAME IS NOT NULL;

desc fact_aggregated_bookings;

ALTER TABLE fact_aggregated_bookings
MODIFY room_category VARCHAR(10);

ALTER TABLE fact_aggregated_bookings
ADD COLUMN check_in_date_new DATE;

UPDATE fact_aggregated_bookings
SET check_in_date_new =
STR_TO_DATE(check_in_date,'%d-%b-%Y');

ALTER TABLE fact_aggregated_bookings
DROP COLUMN check_in_date;

ALTER TABLE fact_aggregated_bookings
CHANGE check_in_date_new check_in_date DATE;

ALTER TABLE fact_aggregated_bookings
ADD CONSTRAINT fk_agg_property
FOREIGN KEY (property_id)
REFERENCES dim_hotels(property_id);

ALTER TABLE fact_aggregated_bookings
ADD CONSTRAINT fk_agg_room
FOREIGN KEY (room_category)
REFERENCES dim_rooms(room_id);

ALTER TABLE fact_aggregated_bookings
ADD CONSTRAINT fk_agg_date
FOREIGN KEY (check_in_date)
REFERENCES dim_date(`date`);

SELECT
    CONSTRAINT_NAME,
    TABLE_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = DATABASE()
AND TABLE_NAME = 'fact_aggregated_bookings'
AND REFERENCED_TABLE_NAME IS NOT NULL;
--------------------------------------------------------------------------------
-- DATA VALIDATION

-- 1. Row Count Validation
-- Make sure all records imported correctly.
SELECT COUNT(*) FROM fact_bookings;-- 134590
SELECT COUNT(*) FROM fact_aggregated_bookings; -- 9200
SELECT COUNT(*) FROM dim_hotels; -- 25
SELECT COUNT(*) FROM dim_rooms; -- 4
SELECT COUNT(*) FROM dim_date; -- 92

-- 2. Duplicate Check
-- booking_id should be unique
SELECT booking_id, COUNT(*)
FROM fact_bookings
GROUP BY booking_id
HAVING COUNT(*) > 1;
-- Expected: 0 rows

-- 3. Null Value Check
-- Hotel IDs
SELECT *
FROM fact_bookings
WHERE property_id IS NULL;
-- -- Expected: 0 rows

-- Room Categories
SELECT *
FROM fact_bookings
WHERE room_category IS NULL;
-- Expected: 0 rows

-- Booking IDs
SELECT *
FROM fact_bookings
WHERE booking_id IS NULL;
-- Expected: 0 rows

-- 4. Date Validation
-- Check for impossible stays:
SELECT *
FROM fact_bookings
WHERE checkout_date < check_in_date;
-- Expected: 0 rows

-- 5. Revenue Validation
-- Revenue should not be negative.
SELECT *
FROM fact_bookings
WHERE revenue_realized < 0;
-- Expected: 0 rows

-- 6. Foreign Key Validation
-- Hotels
SELECT DISTINCT property_id
FROM fact_bookings
WHERE property_id NOT IN
(
SELECT property_id
FROM dim_hotels
);
-- Expected: 0 rows

-- Rooms
SELECT DISTINCT room_category
FROM fact_bookings
WHERE room_category NOT IN
(
SELECT room_id
FROM dim_rooms
);
-- Expected:0 rows

-- Dates
SELECT DISTINCT check_in_date
FROM fact_bookings
WHERE check_in_date NOT IN
(
SELECT date
FROM dim_date
);
-- Expected: 0 rows

-- 7. Booking Status Validation
-- Check valid values:
SELECT DISTINCT booking_status
FROM fact_bookings;
/*Expected values:
Cancelled
Checked Out
No Show*/

-- KPI VALIDATION
-- 1. Total Revenue
SELECT SUM(revenue_realized) AS total_revenue
FROM fact_bookings; -- '1708771229'

SELECT
    concat(round(SUM(revenue_realized) / 1000000, 2), 'M') AS total_revenue
FROM fact_bookings;


-- 2. Occupancy Rate
-- Occupancy Rate = Successful Bookings / Capacity × 100
SELECT
ROUND(
    SUM(successful_bookings)*100.0/
    SUM(capacity),2
) AS occupancy_rate
FROM fact_aggregated_bookings; -- 57.87%

-- 3. Cancellation Rate
-- Cancellation Rate = Cancelled Bookings / Total Bookings × 100

SELECT
ROUND(
COUNT(CASE WHEN booking_status='Cancelled' THEN 1 END)
*100.0/
COUNT(*)
,2) AS cancellation_rate
FROM fact_bookings;-- 24.83

-- 4. Booking Trends (Month-wise)
SELECT
d.month_year,
COUNT(f.booking_id) AS total_bookings
FROM fact_bookings f
JOIN dim_date d
ON f.check_in_date = d.date
GROUP BY d.month_year
ORDER BY MIN(d.date);
/*| month_year | total_bookings |
| May 2022   |          45882 |
| Jun 2022   |          43683 |
| Jul 2022   |          45025 |
*/

-- 5. Weekday vs Weekend Revenue
-- Using dim_date.day_type

SELECT
d.day_type,
SUM(f.revenue_realized) AS revenue
FROM fact_bookings f
JOIN dim_date d
ON f.check_in_date=d.date
GROUP BY d.day_type;
/* | Day Type |       Revenue |
| -------- | ------------: |
| Weekday  | 1,069,703,782 |
| Weekend  |   639,067,447 |
*/

-- 6. Revenue by Hotel
SELECT
h.property_name,
SUM(f.revenue_realized) AS revenue
FROM fact_bookings f
JOIN dim_hotels h
ON f.property_id=h.property_id
GROUP BY h.property_name
ORDER BY revenue DESC;
/*
| Property Name  |     Revenue |
| -------------- | ----------: |
| Shodwe Exotica | 320,312,468 |
| Shodwe Palace  | 304,081,863 |
| Shodwe City    | 285,811,939 |
| Shodwe Blu     | 260,855,522 |
| Shodwe Bay     | 260,051,178 |
| Shodwe Grands  | 211,532,764 |
| Shodwe Seasons |  66,125,495 |
*/

-- 7. Room-wise Revenue
SELECT
r.room_class,
SUM(f.revenue_realized) AS revenue
FROM fact_bookings f
JOIN dim_rooms r
ON f.room_category=r.room_id
GROUP BY r.room_class
ORDER BY revenue DESC;
/*
| Room Class   |     Revenue |
| Elite        | 560,271,204 |
| Premium      | 462,166,344 |
| Presidential | 376,752,786 |
| Standard     | 309,580,895 |
*/