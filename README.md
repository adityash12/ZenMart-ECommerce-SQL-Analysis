# ZenMart E-Commerce SQL Analysis

## 📌 Project Overview

This project focuses on analysing e-commerce order and customer data using SQL in Google BigQuery.

The objective was to answer key business questions around order growth, customer distribution, sales value, freight costs, delivery performance, and payment behaviour.

The analysis was performed through a set of business-driven SQL case studies using joins, CTEs, window functions, date/time functions, aggregations, and conditional logic.

## 🛠️ Tools & Technologies

- Google BigQuery
- SQL

## 📊 Business Questions & Analysis

### 1. Data & Customer Analysis
- Analysed the data types and schema of the customer table.
- Identified the time period covered by customer orders.
- Calculated the number of unique customer cities and states.
- Analysed customer distribution across Brazilian states.

### 2. Order & Sales Analysis
- Analysed yearly order growth.
- Identified monthly order seasonality.
- Calculated month-on-month order volumes by state.
- Calculated total and average order value for each state.
- Analysed the percentage increase in order value from 2017 to 2018.

### 3. Customer Ordering Behaviour
- Analysed the time of day when customers place orders.
- Categorised orders into Dawn, Morning, Afternoon, and Night.

### 4. Freight & Delivery Analysis
- Calculated total and average freight value by state.
- Identified states with the highest and lowest average freight values.
- Calculated delivery time for individual orders.
- Compared actual delivery dates against estimated delivery dates.
- Identified states with the fastest and slowest average delivery performance.

### 5. Payment Analysis
- Analysed monthly order volume across different payment types.
- Analysed order distribution based on payment installments.


## 🧠 SQL Concepts Demonstrated

- SELECT, WHERE, GROUP BY, ORDER BY
- INNER JOIN
- Common Table Expressions (CTEs)
- Subqueries
- UNION ALL
- CASE statements
- Aggregate Functions
- DISTINCT
- EXTRACT
- TIMESTAMP_DIFF
- Window Functions
- LEAD
- ROUND
- LIMIT

## 💡 Key Business Insights

The analysis helps answer questions such as:

- Is the business experiencing growth in order volume over time?
- Which states have the highest customer concentration?
- When are customers most likely to place orders?
- Which states generate higher order values?
- Which states have higher freight costs?
- Which states experience faster or slower deliveries?
- How does actual delivery performance compare with estimated delivery dates?
- Which payment methods and installment patterns are most commonly used?

These insights can support business decisions related to **customer demand, regional performance, logistics efficiency, delivery operations, and payment behaviour.**


