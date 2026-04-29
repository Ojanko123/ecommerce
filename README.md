

## Overview

End-to-end exploratory analysis of a large-scale retail transaction dataset using PostgreSQL. The project covers data cleaning, revenue analysis, customer behavior, and product performance , answering real business questions using SQL.

---

## Dataset

- **Source:** https://www.kaggle.com/datasets/mashlyn/online-retail-ii-uci
- **Size:** 1,067,371 transactions
- **Period:** December 2009 – December 2011
- **Columns:** Invoice, StockCode, Description, Quantity, InvoiceDate, Price, CustomerID, Country

---

## Tools Used

- **PostgreSQL 18** - database and all analysis
- **pgAdmin 4** - query editor and data import
- **SQL** - aggregations, subqueries, CTEs, window functions, views

---

## Data Cleaning

Before analysis, the following data quality issues were identified and handled:

| Issue | Rows Affected | Action |
|---|---|---|
| Missing Customer ID | 243,007 (23%) | Excluded from customer-level analysis only |
| Cancelled orders (negative quantity) | ~22,950 | Excluded from all analysis |
| Zero or invalid prices | Small number | Excluded from all analysis |

A reusable `retail_clean` VIEW was created to apply these filters automatically:

**Clean dataset: 1,041,671 rows**

---

## Key Findings

Total revenue across the dataset was £20.97M, with a clear seasonal peak in November 2010 (£1.47M). The average order value of £479.95 suggests a predominantly wholesale customer base. Sweden ranked 8th internationally with £91,903 from 19 customers.

- **Strong Q4 seasonality** - revenue nearly triples in October–November vs. low months, driven by Christmas gift purchasing
- **High average order value (£479.95)** suggests a predominantly B2B/wholesale customer base rather than individual consumers
- **Top international markets** (excl. UK): Ireland, Netherlands, Germany, France — with Ireland generating £664k from just 5 customers, indicating large wholesale accounts
- **A small number of products drive most revenue** - top 10 products account for a disproportionate share of total sales

---

---

## How to Run

1. Download the [UCI Online Retail II dataset](https://www.kaggle.com/datasets/mashlyn/online-retail-ii-uci) from Kaggle
2. Unzip the csv file
3. Create a PostgreSQL database and run the table creation script in `queries.sql`
4. Import the CSV using pgAdmin's Import/Export tool
5. Run the analysis queries in order

---


**Oresti Janko**
Statistics graduate with focus on data analysis, SQL, and business intelligence.

