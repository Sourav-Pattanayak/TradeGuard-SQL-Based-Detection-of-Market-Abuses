# TradeGuard: SQL-Based Detection of Market Abuses 🚨📊

Welcome to **TradeGuard**, an SQL-based project aimed at detecting various types of market abuses such as insider trading, wash trading, spoofing, and more. This project mimics real-world scenarios and provides insights into how data analytics can help maintain market integrity and prevent fraudulent activities.

## 📘 Project Overview

Financial markets are susceptible to various forms of manipulation and fraud, which can have devastating effects on market stability and investor trust. As a Data Analyst at EquiAnalytics Inc., you have been tasked by the Risk Management team to investigate unusual trading patterns and identify any signs of market abuse. This project uses SQL to analyze three datasets—**Surveillance Optimization**, **Regulatory Enquiries**, and **Market Manipulation Data**—to detect anomalies and uncover hidden patterns indicative of market abuse.

## 🚀 Features

- **Comprehensive Data Analysis**: Analyzes transactional data to detect various types of market manipulation, such as **insider trading**, **spoofing**, **pump and dump**, and **wash trading**.
- **Real-World Scenarios**: Mimics real-world trading environments to provide practical insights into market behaviors.
- **SQL-Based Analysis**: Utilizes SQL queries ranging from basic to advanced complexity to identify suspicious trading patterns and potential market abuses.
- **Actionable Insights**: Provides recommendations based on detected anomalies to improve monitoring and regulatory compliance.

## 📂 Datasets

You can access all datasets used in this project via the following Google Drive link:

👉 [**Click here to access the datasets**](https://drive.google.com/drive/folders/1-b4OphZ4VcJNujAx-NFF_Rujhx0sZYan?usp=sharing)

## 📊 SQL Queries and Analysis

### Easy Complexity
1. **Find the Total Transaction Value for Each Stock**: Identify the total transaction value to understand the most traded stocks.
2. **Identify the Top Three Manipulated Stocks with the Highest Average Order Price**: Detect stocks that are being manipulated through inflated prices.
3. **Find the Top Five Enquiry Types and the Users Who Requested Them**: Analyze user behavior and the nature of their enquiries.
4. **Find Users Who Made More Than One Regulatory Enquiry in a Single Month**: Identify potentially suspicious users based on enquiry frequency.
5. **Retrieve Users Who Conducted a Transaction and Made a Corresponding Enquiry with Regulatory Volume Greater Than 9000**: Cross-check transactions and regulatory enquiries for consistency.
6. **Find the Total Volume of Orders for Each Stock with a Corresponding Regulatory Enquiry**: Link stock orders to regulatory activity to detect anomalies.

### Intermediate Complexity
1. **Identify the Top 5 Stocks with the Highest Positive Price Difference in Average Transaction Prices Between Two Consecutive Months**: Track price changes over time to detect manipulation.
2. **Give a Count of Different Price Ranges for Each Stock**: Categorize stocks based on price ranges to detect unusual patterns.
3. **Detect Users Who Experienced More Than Three Significant Fluctuations in Enquiry Prices**: Monitor significant price changes in user enquiries to detect suspicious activity.
4. **Find the Top 5 Entities with the Highest Average Order Volume Excluding Any Extreme Values**: Analyze order volumes while removing outliers to detect normal trading behavior.
5. **Identify the Stock with the Maximum Percentage Increase in Price Over a Year**: Highlight stocks with unusual price growth.
6. **Find Stocks with a Price Drop of More Than 90% Compared to the Previous Transaction**: Detect drastic price changes that could indicate manipulation.
7. **Retrieve Orders with Manipulated Prices Higher Than the Average Manipulated Price for Each Stock**: Identify orders that exceed typical manipulation levels.
8. **Find the Stocks with the Top 5 Highest Percentages of Total Transactions and Their Corresponding Percentages**: Determine which stocks dominate trading volume.
9. **Determine the Top 3 Most Common Market Manipulation Types and Their Average Price for Each Stock**: Analyze manipulation techniques and their impact on stock prices.

### Advanced Complexity
1. **Calculate the Yearly Original Price Increase and Identify Stocks with Over 500% Growth**: Track significant growth trends that could indicate market abuse.
2. **Identify Users with Significant Price Fluctuations in Both Transaction and Enquiry Prices**: Monitor users with unstable trading behaviors.
3. **Find the Average Manipulated Prices for the Top 3 Stocks with the Highest Total Manipulated Volumes Due to Insider Trading**: Focus on insider trading activities and their impact.
4. **Identify the Top 10 Cross-Market Manipulation Patterns and Calculate Potential Gains**: Detect patterns of abuse across different markets and estimate potential financial gains.
5. **Find Stocks with High Volatility Using Manipulation and Enquiry Tables**: Correlate stock volatility with manipulation tactics.
6. **Calculate the Monthly Average Price and Volume for Each Stock and Compare with Global Averages**: Benchmark stock performance against global data to detect anomalies.
7. **Determine the Impact on Stock Prices Where the Average Post-Manipulation Price is at Least Twice the Average Pre-Manipulation Price**: Analyze how manipulation affects stock prices over time.

## 🧰 Tools and Technologies

- **SQL**: Core tool used for data manipulation and analysis.
- **Google Drive**: Used for dataset storage and sharing.
- **Excel/Google Sheets**: For initial data cleaning and visualization (optional).

## 📝 How to Use

1. **Download the Datasets**: Access the datasets via the link provided above.
2. **Set Up Your Environment**: Ensure you have SQL Server or any SQL-compatible database management system installed.
3. **Run the Queries**: Use the SQL scripts provided in this repository to run your analysis on the datasets.
4. **Analyze the Results**: Review the output of each query to identify patterns indicative of market manipulation.

## 🎯 Key Takeaways

- **Market surveillance** is crucial for detecting and preventing fraud.
- **SQL** is a powerful tool for analyzing large datasets and uncovering hidden patterns.
- **Data-driven insights** can help regulatory bodies and financial institutions strengthen their monitoring processes.

## 📢 Contributions

Feel free to contribute to this project by opening issues or pull requests. Suggestions and improvements are always welcome!

## 📧 Contact

For any questions or collaboration opportunities, please reach out to me at **sourav.pattanayak368@gmail.com**.

---

**Happy Analyzing!** 🌟
