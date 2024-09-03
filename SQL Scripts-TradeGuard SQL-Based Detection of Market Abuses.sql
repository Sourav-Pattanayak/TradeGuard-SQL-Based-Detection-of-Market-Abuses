-- Change the column in market_manipulation table
ALTER TABLE market_manipulation
MODIFY COLUMN Date_of_Manipulation DATE;

-- Change the column in regulatory_enquiries table
ALTER TABLE regulatory_enquiries
MODIFY COLUMN Enquiry_Date DATE;

-- Change the column in surveillance_optimization table
ALTER TABLE surveillance_optimization
MODIFY COLUMN Transaction_Date DATE;

/* AN END TO END CASE STUDY ON MARKET ABUSE & FINANCIAL CRIME*/

/*1.Find the Total Transaction Value for Each Stock in the surveillance_optimization*/

SELECT Stock_ID, ROUND(SUM(Transaction_Price * Volume), 2) AS Total_Transaction_Value
FROM surveillance_optimization
GROUP BY Stock_ID;


/*2 Identify the top three manipulated Stocks with the Highest Average Order Price */

SELECT Stock_Name, ROUND(AVG(Order_Price), 2) AS Avg_Order_Price
FROM market_manipulation
GROUP BY Stock_Name
ORDER BY Avg_Order_Price DESC
LIMIT 3;


/*3. Find the Top five Enquiry_Type and the users who requested it */

WITH UserEnquiries AS (
SELECT User_ID, Enquiry_Type, COUNT(*) AS Enquiry_Count
FROM regulatory_enquiries
GROUP BY User_ID, Enquiry_Type)
SELECT User_ID, Enquiry_Type, Enquiry_Count
FROM UserEnquiries
ORDER BY Enquiry_Count DESC
LIMIT 5;


/*4.Find Users Who Made More Than one Regulatory Enquiries in a single month*/

SELECT User_ID, YEAR(Enquiry_Date) AS Year,
MONTHNAME(Enquiry_Date) AS Month, COUNT(*) AS Enquiry_Count
FROM regulatory_enquiries
GROUP BY User_ID, YEAR(Enquiry_Date), MONTHNAME(Enquiry_Date)
HAVING COUNT(*) > 1;


/*5.Write a SQL query to retrieve a list of users who have both conducted a transaction and made
 a corresponding enquiry having regulatory volume greater than 9000.
 The query should identify users that appear in both datasets.*/
 
SELECT DISTINCT so.User_ID
FROM surveillance_optimization AS so
INNER JOIN regulatory_enquiries AS re ON so.User_ID = re.User_ID
WHERE so.Volume >= 9000;


/*6.Find the total volume of orders for each stock with a corresponding regulatory enquiry*/

SELECT mm.Stock_Name, SUM(mm.Order_Volume) AS Total_Order_Volume
FROM market_manipulation AS mm
INNER JOIN regulatory_enquiries AS re ON mm.Stock_ID = re.Stock_ID
GROUP BY mm.Stock_Name
ORDER BY SUM(mm.Order_Volume) DESC ;

/*7.Which are the top 5 stocks with the highest positive price difference in average transaction prices 
between two consecutive months? Provide the stock names, the two consecutive months,
 and the corresponding price difference.*/

WITH MonthlyAvg AS (SELECT Stock_Name, DATE_FORMAT(Transaction_Date, '%Y-%m') AS Month,
AVG(Transaction_Price) AS Avg_Price FROM surveillance_optimization
GROUP BY Stock_Name, DATE_FORMAT(Transaction_Date, '%Y-%m')), 

PriceDiff AS (SELECT Stock_Name, Month, Avg_Price, 
LAG(Month) OVER (PARTITION BY Stock_Name ORDER BY Month) AS Prev_Month, 
Avg_Price - LAG(Avg_Price) OVER (PARTITION BY Stock_Name ORDER BY Month) AS Price_Difference 
FROM MonthlyAvg),

RankedStocks AS (SELECT Stock_Name, Month, Prev_Month, Price_Difference,
ROW_NUMBER() OVER (ORDER BY Price_Difference DESC) AS Price_Rank FROM PriceDiff
WHERE Price_Difference > 0)

SELECT Stock_Name, Prev_Month AS Previous_Month,
Month AS Current_Month, Price_Difference FROM RankedStocks WHERE Price_Rank <= 5;


/*8.Give a count of the different Price Ranges for Each Stock*/

SELECT Stock_Name, 
CASE WHEN Order_Price < 50 THEN '0-50'
WHEN Order_Price BETWEEN 50 AND 100 THEN '50-100' ELSE '100+' END AS Price_Range, 
COUNT(*) AS Range_Count
FROM market_manipulation
GROUP BY Stock_Name, Price_Range
ORDER BY Stock_Name, Range_Count DESC;

/*9.Detect users who have experienced more than three significant fluctuations in enquiry prices.
 A significant fluctuation is defined as a change in price that exceeds 10 units 
 compared to the previous enquiry price.*/

SELECT User_ID, COUNT(*) AS Fluctuation_Count
FROM (SELECT User_ID, Enquiry_Price, 
LAG(Enquiry_Price) OVER (PARTITION BY User_ID ORDER BY Enquiry_Date) AS Prev_Enquiry_Price
FROM regulatory_enquiries
) AS PriceDiffs
WHERE ABS(Enquiry_Price - Prev_Enquiry_Price) > 10
GROUP BY User_ID
HAVING COUNT(*) > 3;

/*10.Write a query to find the top 5 entities with the highest average order volume,
 excluding any extreme values. Calculate the average order volume for each entity,
 rounding the result to two decimal places. */

WITH Stats AS (SELECT Stock_Name, 
AVG(Order_Volume) AS Avg_Volume, 
STDDEV(Order_Volume) AS StdDev_Volume
FROM market_manipulation
GROUP BY Stock_Name)
 
SELECT mm.Stock_Name, ROUND(AVG(mm.Order_Volume),2) AS Avg_Order_Volume_Excluding_Outliers
FROM market_manipulation AS mm
JOIN Stats AS s ON mm.Stock_Name = s.Stock_Name
WHERE mm.Order_Volume BETWEEN s.Avg_Volume - 2 * s.StdDev_Volume 
AND s.Avg_Volume + 2 * s.StdDev_Volume
GROUP BY mm.Stock_Name
ORDER BY Avg_Order_Volume_Excluding_Outliers DESC
LIMIT 5;


/*11.Identify the Stock with the Maximum Percentage Increase in Price Over a Year*/

WITH YearlyPrices AS (SELECT Stock_Name, 
YEAR(Transaction_Date) AS Year, 
FIRST_VALUE(Transaction_Price) OVER (PARTITION BY Stock_Name, YEAR(Transaction_Date) ORDER BY Transaction_Date) AS Start_Price,
LAST_VALUE(Transaction_Price) OVER (PARTITION BY Stock_Name, YEAR(Transaction_Date) ORDER BY Transaction_Date RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS End_Price
FROM surveillance_optimization)

SELECT Stock_Name, Year, 
ROUND((End_Price - Start_Price) / Start_Price * 100, 2) AS Percentage_Increase
FROM YearlyPrices
ORDER BY Percentage_Increase DESC
LIMIT 1;

/*12.Find Stocks with a Price Drop of More Than 90% Compared to the Previous Transaction*/

SELECT Transaction_ID, Stock_Name, Transaction_Price, Prev_Price
FROM (SELECT Transaction_ID, Stock_Name, Transaction_Price,
LAG(Transaction_Price) OVER (PARTITION BY Stock_Name ORDER BY Transaction_Date) AS Prev_Price
FROM surveillance_optimization) AS Subquery

WHERE Prev_Price IS NOT NULL 
AND (Transaction_Price / Prev_Price) < 0.1;

/*13.Retrieve Orders with Prices Higher Than the Average manipulated Price for Each Stock*/

SELECT Stock_Name, Order_Price
FROM market_manipulation AS mm
WHERE Order_Price >
(SELECT AVG(Order_Price)FROM market_manipulation WHERE Stock_Name = mm.Stock_Name);

/*14.Find the stocks with the top 5 highest percentages of total transactions
 and their corresponding percentages.*/

SELECT Stock_Name, 
ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM surveillance_optimization),2) AS Percentage_Of_Total_Transactions
FROM surveillance_optimization
GROUP BY Stock_Name
ORDER BY ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM surveillance_optimization),2) DESC
LIMIT 5 ;

/*15.Determine the top 3 Most Common market manipulation Type and Its Average Price for Each Stock*/

WITH CommonOrderType AS (SELECT Order_Price,Stock_Name, Manipulation_Type, COUNT(*) AS manipulation_Type_Count,
ROW_NUMBER() OVER (PARTITION BY Stock_Name ORDER BY COUNT(*) DESC) AS RowNum
FROM market_manipulation
GROUP BY Stock_Name, Manipulation_Type,Order_Price)

SELECT Manipulation_Type, ROUND(AVG(Order_Price),2)AS Avg_Price
FROM CommonOrderType
WHERE RowNum = 1
GROUP BY Manipulation_Type
ORDER BY Avg_Price DESC
LIMIT 3;

/*ADVANCED QUERIES*/

/*16.Calculate the Yearly Price Increase and Identify Stocks with Over 500% Growth*/

WITH YearlyPrices AS (SELECT Stock_Name, 
YEAR(Transaction_Date) AS Year, 
FIRST_VALUE(Transaction_Price) OVER (PARTITION BY Stock_Name, YEAR(Transaction_Date) ORDER BY Transaction_Date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Start_Price,
LAST_VALUE(Transaction_Price) OVER (PARTITION BY Stock_Name, YEAR(Transaction_Date) ORDER BY Transaction_Date ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS End_Price
FROM surveillance_optimization
GROUP BY Stock_Name, YEAR(Transaction_Date), Transaction_Date, Transaction_Price),

PriceGrowth AS (SELECT Stock_Name, Year, 
ROUND((End_Price - Start_Price) / Start_Price * 100,2) AS Percentage_Growth
FROM YearlyPrices
GROUP BY Stock_Name, Year, Start_Price, End_Price)

SELECT Stock_Name, year, Percentage_Growth
FROM PriceGrowth
WHERE Percentage_Growth > 500
ORDER BY Percentage_Growth DESC;

/*17.Identify Users with Significant Price Fluctuations in Both Transaction and Enquiry Prices*/

WITH TransactionFluctuations AS (SELECT User_ID, 
Transaction_ID, 
LAG(Transaction_Price) OVER (PARTITION BY User_ID ORDER BY Transaction_Date)
AS Previous_Transaction_Price,
Transaction_Price,
ABS(Transaction_Price - LAG(Transaction_Price) OVER (PARTITION BY User_ID ORDER BY Transaction_Date)) / LAG(Transaction_Price) OVER (PARTITION BY User_ID ORDER BY Transaction_Date) * 100 AS Price_Change_Percentage
FROM surveillance_optimization),

EnquiryFluctuations AS (
SELECT User_ID, 
LAG(Enquiry_Price) OVER (PARTITION BY User_ID ORDER BY Enquiry_Date) AS Previous_Enquiry_Price,
Enquiry_Price,
ABS(Enquiry_Price - LAG(Enquiry_Price) OVER (PARTITION BY User_ID ORDER BY Enquiry_Date)) / LAG(Enquiry_Price) OVER (PARTITION BY User_ID ORDER BY Enquiry_Date) * 100 AS Enquiry_Change_Percentage
FROM regulatory_enquiries)

SELECT DISTINCT t.User_ID
FROM TransactionFluctuations AS t
JOIN EnquiryFluctuations AS e ON t.User_ID = e.User_ID
WHERE t.Price_Change_Percentage > 90 
AND e.Enquiry_Change_Percentage > 90
AND t.Previous_Transaction_Price IS NOT NULL
AND e.Previous_Enquiry_Price IS NOT NULL;

/*18.Find the average manipulated prices for the top 3 stocks with the highest total manipulated volumes
 due to insider trading.*/
 
WITH ManipulatedVolumes AS (SELECT Stock_Name, SUM(Order_Volume) AS Total_Manipulated_Volume
FROM market_manipulation
WHERE Manipulation_Type = 'Insider Trading'
GROUP BY Stock_Name),
 
TopStocks AS (
SELECT Stock_Name
FROM ManipulatedVolumes
ORDER BY Total_Manipulated_Volume DESC
LIMIT 3)

SELECT mm.Stock_Name, AVG(mm.Order_Price) AS Avg_Manipulated_Price
FROM market_manipulation AS mm
JOIN TopStocks AS ts ON mm.Stock_Name = ts.Stock_Name
WHERE mm.Manipulation_Type = 'Insider Trading'
GROUP BY mm.Stock_Name;

/*19.Identify Cross-Market Manipulation Patterns and Calculate Potential Gains */

WITH CrossMarketManipulations AS (SELECT so.User_ID, so.Stock_Name AS Stock_Name, 
so.Transaction_Price AS Surveillance_Price, 
mm.Order_Price AS Manipulation_Price, 
mm.Order_Volume,
ROW_NUMBER() OVER (PARTITION BY so.User_ID, so.Stock_Name 
ORDER BY so.Transaction_Date DESC, mm.Date_of_Manipulation DESC) AS Row_Num
FROM surveillance_optimization AS so
INNER JOIN market_manipulation AS mm 
ON so.User_ID = mm.User_ID AND so.Stock_Name = mm.Stock_Name
WHERE so.Transaction_Date < mm.Date_of_Manipulation),

PotentialGains AS (SELECT User_ID, Stock_Name AS Stock_Name,
ROUND(SUM((Manipulation_Price - Surveillance_Price) * Order_Volume),2) AS Total_Potential_Gain
FROM CrossMarketManipulations
WHERE Row_Num = 1
GROUP BY User_ID, Stock_Name)

SELECT User_ID, Stock_Name, Total_Potential_Gain
FROM PotentialGains
ORDER BY Total_Potential_Gain DESC
LIMIT 10;

#SIGNIFICANCE:

/*A.Potential Gain Analysis: The results show which users and stocks have the highest potential gains 
from market manipulation activities. This can help in identifying the most significant instances of manipulation and their impact.

B.Risk Assessment: By focusing on the top 10 potential gains, the query highlights the most critical
cases that may warrant further investigation or regulatory action.

C.Strategic Insights: The results can be used to develop strategies to mitigate risks associated with
 market manipulation, such as improving surveillance systems or strengthening regulations.*/

/*20.Find Stocks with High Volatility using  Manipulation and Enquiry Tables */

WITH CombinedData AS (SELECT mm.Stock_Name AS Stock_Name, 
mm.Order_Price AS Price,  mm.Date_of_Manipulation AS Date
FROM market_manipulation AS mm
UNION ALL
SELECT re.Stock_Name AS Stock_Name, 
re.Enquiry_Price AS Price, 
re.Enquiry_Date AS Date
FROM regulatory_enquiries AS re),

StockVolatility AS (
SELECT Stock_Name, 
ROUND(STDDEV(Price),2) AS Price_StdDev
FROM CombinedData
GROUP BY Stock_Name)

SELECT Stock_Name, Price_StdDev
FROM StockVolatility
WHERE Price_StdDev > (SELECT AVG(Price_StdDev) FROM StockVolatility)
ORDER BY Price_StdDev DESC;

#SIGNIFICANCE:
/*A.Volatility Analysis: The query helps identify stocks with high price volatility by
calculating and comparing the standard deviation of prices.
High volatility can indicate potential risks or opportunities.

B.Comparative Insight: By comparing each stock's volatility against the average,
the query highlights stocks with significantly higher fluctuations. This can be useful for investors, 
analysts, or regulators to focus on stocks that may need further investigation or attention.

C.Data Integration: Combining data from different sources 
(market manipulation and regulatory enquiries) provides a more comprehensive view of stock behavior, 
which can lead to better-informed decisions and analyses. */

/*21.Calculate the Monthly Average Price and Volume for Each Stock and Compare with Global Averages */

WITH MonthlyAverages AS (
SELECT Stock_Name, 
DATE_FORMAT(Transaction_Date, '%Y-%m') AS Month, 
ROUND(AVG(Transaction_Price), 2) AS Avg_Price, 
ROUND(AVG(Volume), 2) AS Avg_Volume
FROM surveillance_optimization
GROUP BY Stock_Name, DATE_FORMAT(Transaction_Date, '%Y-%m')),

GlobalAverages AS (
SELECT ROUND(AVG(Transaction_Price), 2) AS Global_Avg_Price, 
ROUND(AVG(Volume), 2) AS Global_Avg_Volume
FROM surveillance_optimization)

SELECT ma.Stock_Name, ma.Month, ma.Avg_Price, ma.Avg_Volume,
ga.Global_Avg_Price, ga.Global_Avg_Volume,
ROUND(ma.Avg_Price - ga.Global_Avg_Price, 2) AS Price_Difference,
ROUND(ma.Avg_Volume - ga.Global_Avg_Volume, 2) AS Volume_Difference
FROM MonthlyAverages AS ma
INNER JOIN GlobalAverages AS ga;

#SIGNIFICANCE:
/*This query helps detect potential market abuse by comparing individual stock price and volume
 trends against global averages. Significant deviations might indicate manipulative trading activities 
 or abnormal market behavior */
 
/*22.Determine the impact on stock prices where the average post-manipulation price is at least 
twice the average pre-manipulation price. */

WITH PreManipulationPrices AS (
SELECT mm.Stock_Name, mm.Date_of_Manipulation, 
ROUND(AVG(so.Transaction_Price),2)AS Avg_Pre_Manipulation_Price
FROM market_manipulation AS mm
JOIN surveillance_optimization AS so ON mm.Stock_Name = so.Stock_Name
WHERE so.Transaction_Date < mm.Date_of_Manipulation
GROUP BY mm.Stock_Name, mm.Date_of_Manipulation),

PostManipulationPrices AS (
SELECT mm.Stock_Name, mm.Date_of_Manipulation, 
ROUND(AVG(so.Transaction_Price),2) AS Avg_Post_Manipulation_Price
FROM market_manipulation AS mm
JOIN surveillance_optimization AS so ON mm.Stock_Name = so.Stock_Name
WHERE so.Transaction_Date > mm.Date_of_Manipulation
GROUP BY mm.Stock_Name, mm.Date_of_Manipulation)

SELECT pre.Stock_Name, pre.Date_of_Manipulation, 
pre.Avg_Pre_Manipulation_Price, post.Avg_Post_Manipulation_Price,
ROUND(post.Avg_Post_Manipulation_Price - pre.Avg_Pre_Manipulation_Price, 2) AS Price_Impact
FROM PreManipulationPrices AS pre
JOIN PostManipulationPrices AS post ON pre.Stock_Name = post.Stock_Name 
AND pre.Date_of_Manipulation = post.Date_of_Manipulation
WHERE post.Avg_Post_Manipulation_Price >= 2 * pre.Avg_Pre_Manipulation_Price;

#SIGNIFICANCE:
/*This query helps identify significant market abuse by detecting instances where the manipulation 
causes a dramatic increase in stock prices, specifically 
where the post-manipulation price is at least double the pre-manipulation price. 
This can indicate potential market manipulation or fraudulent activities impacting stock valuations.*/