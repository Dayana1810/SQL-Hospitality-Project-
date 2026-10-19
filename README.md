# SQL Hospitality Project
## Hospitality Analyst Project – SQL Queries Explanation

Since you have already written SQL queries for your **Hospitality Analyst Project**, you can explain the topics, their purpose, and how they help analyze hotel business performance during your project presentation or interview.

## CSV File Import into MySQL – Hospitality Analyst Project

In my Hospitality Analyst project, I imported CSV files into the MySQL database using MySQL Workbench. First, I created a database and table structure, then imported the CSV data into the tables. After importing, I checked the data and used SQL queries to analyze hotel bookings, revenue, cancellations, and customer trends.

Steps followed:

- Created a database in MySQL.
- Created tables with appropriate column names and data types.
- Imported CSV files into MySQL tables.
- Verified the imported data using SELECT queries.
- Analyzed the data using SQL queries.
- Used the insights for dashboard development in Excel, Power BI, and Tableau.
- 
### 1. Introduction to SQL in Hospitality Analytics

SQL (Structured Query Language) is used to retrieve, organize, filter, and analyze data stored in databases.

In my Hospitality Analyst project, I used **MySQL** to analyze hotel bookings, revenue, occupancy, cancellations, customer behavior, and booking trends. SQL helped me extract meaningful insights from the data and support business decision-making.

### 2. Important SQL Topics and Their Explanations

### 1. SELECT Statement

**Purpose:** Retrieves specific columns from a database table.

**Hospitality example:** Retrieve hotel names, booking dates, and revenue.

```sql
SELECT hotel, arrival_date, adr
FROM hotel_bookings;
```

**Explanation:** This query retrieves the hotel name, arrival date, and average daily rate from the hotel bookings table.

### 2. WHERE Clause

**Purpose:** Filters records based on specific conditions.

```sql
SELECT *
FROM hotel_bookings
WHERE is_canceled = 1;
```

**Explanation:** This query identifies canceled hotel bookings and helps analyze cancellation patterns.

### 3. GROUP BY

**Purpose:** Groups records with the same values to calculate summary statistics.

```sql
SELECT hotel, COUNT(*) AS total_bookings
FROM hotel_bookings
GROUP BY hotel;
```

**Explanation:** This query calculates the total number of bookings for each hotel type, helping compare booking performance.

### 4. Aggregate Functions

**Purpose:** Calculate summary values using functions such as `COUNT()`, `SUM()`, `AVG()`, `MIN()`, and `MAX()`.

```sql
SELECT AVG(adr) AS average_daily_rate
FROM hotel_bookings;
```

**Explanation:** This query calculates the average daily rate (ADR), which helps understand the average room price per day.

### 5. ORDER BY

**Purpose:** Sorts query results in ascending or descending order.

```sql
SELECT hotel, SUM(adr) AS total_adr
FROM hotel_bookings
GROUP BY hotel
ORDER BY total_adr DESC;
```

**Explanation:** This query sorts hotel types by the sum of their ADR values, from highest to lowest. Note that summing ADR does not calculate actual revenue; actual revenue analysis requires appropriate revenue data.

### 6. JOIN

**Purpose:** Combines information from two or more related tables.

```sql
SELECT b.booking_id, c.customer_name
FROM bookings b
JOIN customers c
ON b.customer_id = c.customer_id;
```

**Explanation:** This query combines booking information with customer details using their common customer ID.

### 7. CASE Statement

**Purpose:** Categorizes data based on specified conditions.

```sql
SELECT
    hotel,
    CASE
        WHEN adr >= 150 THEN 'High Rate'
        WHEN adr >= 80 THEN 'Medium Rate'
        ELSE 'Low Rate'
    END AS rate_category
FROM hotel_bookings;
```

**Explanation:** This query categorizes daily room rates into high, medium, and low groups, making pricing patterns easier to analyze.

### 8. Date Functions

**Purpose:** Analyze booking trends over time.

```sql
SELECT
    MONTH(arrival_date) AS booking_month,
    COUNT(*) AS total_bookings
FROM hotel_bookings
GROUP BY MONTH(arrival_date)
ORDER BY booking_month;
```

**Explanation:** This query counts bookings by arrival month and helps identify seasonal patterns. It assumes `arrival_date` is stored as a proper date column.

### 9. Subqueries

**Purpose:** Use the result of one query inside another query.

```sql
SELECT *
FROM hotel_bookings
WHERE adr > (
    SELECT AVG(adr)
    FROM hotel_bookings
);
```

**Explanation:** This query identifies bookings with an ADR higher than the overall average ADR.

### 10. Window Functions

**Purpose:** Calculate rankings and comparisons without combining rows into a single summary.

```sql
SELECT
    hotel,
    adr,
    RANK() OVER (ORDER BY adr DESC) AS rate_rank
FROM hotel_bookings;
```

**Explanation:** This query ranks records based on ADR, with the highest rate receiving rank 1.

---

## 3. Key Hospitality Business Questions Answered Using SQL

Your SQL analysis can help answer these important questions:

1. What is the total number of hotel bookings?
2. Which hotel type receives the most bookings?
3. What percentage of bookings are canceled?
4. What is the average daily room rate (ADR)?
5. Which months have the highest booking demand?
6. What is the average length of stay?
7. Which customer segments generate the most bookings?
8. Which distribution channels contribute the most bookings?
9. How many guests are repeated customers?
10. What factors are associated with booking cancellations?

**Important:** The correct query depends on your dataset's column names and structure.

## 4. How to Explain Your SQL Work in an Interview

You can use this short explanation:

"In my Hospitality Analyst project, I used MySQL to extract and analyze hotel booking data. I applied SQL concepts such as SELECT, WHERE, GROUP BY, aggregate functions, JOINs, subqueries, and date functions to analyze booking trends, cancellations, room rates, customer segments, and hotel performance. These queries helped me identify meaningful business insights and prepare data for visualization in Excel, Power BI, and Tableau."

## 5. Final Conclusion

SQL played an important role in my Hospitality Analyst project by helping me organize and analyze hotel booking data. Through SQL queries, I explored booking trends, cancellation rates, pricing patterns, and customer behavior. The insights supported better understanding of hotel performance and helped prepare the data for dashboard development.

**My suggestion:** For your presentation, explain each SQL query using three points: **the SQL concept, the business question, and the insight obtained.** This will help you demonstrate not only your SQL knowledge but also your understanding of hospitality analytics.
