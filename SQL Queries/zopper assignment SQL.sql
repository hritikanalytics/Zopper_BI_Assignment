CREATE DATABASE zopper_assignment;
USE zopper_assignment;

-- Q.1) Calculate the total premium collected during the year 2024.

SELECT SUM(Premium) AS Total_Premium
FROM policy_sales;

-- Q.2) Calculate the total claim cost for each year (2025 and 2026) with a monthly breakdown.

SELECT 
YEAR(Claim_Date) AS Year,
MONTH(Claim_Date) AS Month,
SUM(Claim_Amount) AS Total_Claims
FROM claims_data
GROUP BY Year, Month
ORDER BY Year, Month;

-- Q.3) Calculate the claim cost to premium ratio for each policy tenure (1, 2, 3, and 4 years).

SELECT 
p.Policy_Tenure,
SUM(c.Claim_Amount) AS Total_Claims,
SUM(p.Premium) AS Total_Premium,
ROUND(SUM(c.Claim_Amount) / SUM(p.Premium),2) AS Claim_Premium_Ratio
FROM policy_sales p
LEFT JOIN claims_data c
ON p.Vehicle_ID = c.Vehicle_ID
GROUP BY p.Policy_Tenure
ORDER BY p.Policy_Tenure;

-- Q.4) Calculate the claim cost to premium ratio by the month in which the policy was sold (January–December 2024).

SELECT 
MONTH(p.Policy_Purchase_Date) AS Sale_Month,
SUM(c.Claim_Amount) AS Claims,
SUM(p.Premium) AS Premium,
ROUND(SUM(c.Claim_Amount) / SUM(p.Premium),2) AS Loss_Ratio
FROM policy_sales p
LEFT JOIN claims_data c
ON p.Vehicle_ID = c.Vehicle_ID
GROUP BY Sale_Month
ORDER BY Sale_Month;

-- Q.5)  If every vehicle that has not yet made a claim eventually files exactly one claim during the 
-- remaining policy tenure, estimate the total potential claim liability. 

SELECT 
(
    COUNT(DISTINCT p.Vehicle_ID) - COUNT(DISTINCT c.Vehicle_ID)
) * 10000 AS Potential_Claim_Liability
FROM policy_sales p
LEFT JOIN claims_data c
ON p.Vehicle_ID = c.Vehicle_ID;

-- Q.6
--  Calculate the premium already earned by the company up to February 28, 2026.

SELECT 
SUM(
(Premium / (Policy_Tenure * 365)) *
LEAST(
GREATEST(DATEDIFF('2026-02-28', Policy_Start_Date),0),
Policy_Tenure * 365
)
) AS Earned_Premium_Upto_Feb_2026
FROM policy_sales;


--  Estimate the premium expected to be earned monthly for the remaining policy period (assume 46 months remaining). 

SELECT 
(SUM(Premium) -SUM((Premium / (Policy_Tenure * 365)) *LEAST(GREATEST(DATEDIFF('2026-02-28', Policy_Start_Date),0),
Policy_Tenure * 365))) / 46 AS Expected_Monthly_Premium
FROM policy_sales;


-- BONUS QUESTIONS

--  Identify which policy tenure appears most profitable

SELECT 
p.Policy_Tenure,
SUM(IFNULL(c.Claim_Amount,0)) AS Total_Claims,
SUM(p.Premium) AS Total_Premium,
SUM(IFNULL(c.Claim_Amount,0)) / SUM(p.Premium) AS Loss_Ratio
FROM policy_sales p
LEFT JOIN claims_data c
ON p.Vehicle_ID = c.Vehicle_ID
GROUP BY p.Policy_Tenure
ORDER BY Loss_Ratio;

--  Estimate the loss ratio (Claims ÷ Premium) for the portfolio.

SELECT 
SUM(IFNULL(c.Claim_Amount,0)) AS Total_Claims,
SUM(p.Premium) AS Total_Premium,
SUM(IFNULL(c.Claim_Amount,0)) / SUM(p.Premium) AS Portfolio_Loss_Ratio
FROM policy_sales p
LEFT JOIN claims_data c
ON p.Vehicle_ID = c.Vehicle_ID;

-- If claim frequency increases by 5% annually, estimate the impact on future profitability.

SELECT 
SUM(IFNULL(c.Claim_Amount,0)) AS Current_Total_Claims,
SUM(IFNULL(c.Claim_Amount,0)) * 1.05 AS Future_Total_Claims,
SUM(p.Premium) AS Total_Premium,
(SUM(IFNULL(c.Claim_Amount,0)) * 1.05) / SUM(p.Premium) AS Future_Loss_Ratio
FROM policy_sales p
LEFT JOIN claims_data c
ON p.Vehicle_ID = c.Vehicle_ID;



