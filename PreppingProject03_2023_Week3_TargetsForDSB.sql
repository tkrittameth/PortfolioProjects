/*This is from preppingdata.com 2023 week3 https://preppindata.blogspot.com/2023/01/2023-week-3-targets-for-dsb.html */
SELECT *
FROM PreppingData.dbo.week3_2023

--Firstly, we will be filtering out for only DSB in Transaction_Code
--And renaming the values in the Online or In-person field, Online of the 1 values and In-Person for the 2 values
SELECT *,
CASE
	WHEN Online_or_In_Person = 1 THEN 'Online'
	WHEN Online_or_In_Person = 2 THEN 'In-Person'
	END AS Type_of_Transaction
FROM PreppingData.dbo.week3_2023
WHERE Transaction_Code LIKE 'DSB%'

--Next, I will change the date to the quarter
SELECT *,
CASE
	WHEN Online_or_In_Person = 1 THEN 'Online'
	WHEN Online_or_In_Person = 2 THEN 'In-Person'
	END AS Type_of_Transaction,
	DATEPART(QUARTER, Transaction_Date) AS Quarter
FROM PreppingData.dbo.week3_2023
WHERE Transaction_Code LIKE 'DSB%'

--Now, we will do the sum the transaction values for each quarter and for each type of transaction
WITH CTE
AS (
SELECT Transaction_Code,
CASE
	WHEN Online_or_In_Person = 1 THEN 'Online'
	WHEN Online_or_In_Person = 2 THEN 'In-Person'
	END AS Type_of_Transaction,
	DATEPART(QUARTER, Transaction_Date) AS Quarter,
	Value
FROM PreppingData.dbo.week3_2023
WHERE Transaction_Code LIKE 'DSB%'
)
SELECT Type_of_Transaction, Quarter, SUM(Value) AS Sum_Value
FROM CTE
GROUP BY Type_of_Transaction, Quarter

/*For the week3 target table I will pivot the quarterly targets so we have a row for each Type of Transaction and each Quarter*/
SELECT
    Online_or_In_Person,
    '1' AS Quarter,
    Q1 AS Target
FROM PreppingData.dbo.week3_2023_target
UNION ALL
SELECT
    Online_or_In_Person,
    '2' AS Quarter,
    Q2 AS Target
FROM PreppingData.dbo.week3_2023_target 
UNION ALL
SELECT
    Online_or_In_Person,
    '3' AS Quarter,
    Q3 AS Target
FROM PreppingData.dbo.week3_2023_target 
UNION ALL
SELECT
    Online_or_In_Person,
    '4' AS Quarter,
    Q4 AS Target
FROM PreppingData.dbo.week3_2023_target 


-- We will create a temporary table for the result of our target table above
CREATE TABLE #TempQuarterlyTargets (
    Online_or_In_Person VARCHAR(50),
    Quarter VARCHAR(1),
    Target INT
)

INSERT INTO #TempQuarterlyTargets
SELECT
    Online_or_In_Person,
    '1' AS Quarter,
    Q1 AS Target
FROM PreppingData.dbo.week3_2023_target
UNION ALL
SELECT
    Online_or_In_Person,
    '2' AS Quarter,
    Q2 AS Target
FROM PreppingData.dbo.week3_2023_target 
UNION ALL
SELECT
    Online_or_In_Person,
    '3' AS Quarter,
    Q3 AS Target
FROM PreppingData.dbo.week3_2023_target 
UNION ALL
SELECT
    Online_or_In_Person,
    '4' AS Quarter,
    Q4 AS Target
FROM PreppingData.dbo.week3_2023_target;

--See the temporary table
SELECT * FROM #TempQuarterlyTargets


--We will join the two table together
WITH CTE 
AS (
SELECT 
Transaction_Code,
CASE
	WHEN Online_or_In_Person = 1 THEN 'Online'
	WHEN Online_or_In_Person = 2 THEN 'In-Person'
	END AS Type_of_Transaction,
	DATEPART(QUARTER, Transaction_Date) AS Quarter,
	Value
FROM PreppingData.dbo.week3_2023
WHERE Transaction_Code LIKE 'DSB%'
)

SELECT 
    Type_of_Transaction,
    CTE.Quarter,
    SUM(Value) AS Sum_Value,
    #TempQuarterlyTargets.Target
FROM CTE
INNER JOIN #TempQuarterlyTargets ON CTE.Quarter = #TempQuarterlyTargets.Quarter 
    AND CTE.Type_of_Transaction = #TempQuarterlyTargets.Online_or_In_Person
GROUP BY 
    Type_of_Transaction,
    CTE.Quarter,
    #TempQuarterlyTargets.Target

--Now, we will find the variance to target for each row 
WITH CTE 
AS (
SELECT 
Transaction_Code,
CASE
	WHEN Online_or_In_Person = 1 THEN 'Online'
	WHEN Online_or_In_Person = 2 THEN 'In-Person'
	END AS Type_of_Transaction,
	DATEPART(QUARTER, Transaction_Date) AS Quarter,
	Value
FROM PreppingData.dbo.week3_2023
WHERE Transaction_Code LIKE 'DSB%'
)

SELECT 
    Type_of_Transaction,
    CTE.Quarter,
    SUM(Value) AS Sum_Value,
    #TempQuarterlyTargets.Target,
	SUM(Value) - #TempQuarterlyTargets.Target AS Variance_to_Target
FROM CTE
INNER JOIN #TempQuarterlyTargets ON CTE.Quarter = #TempQuarterlyTargets.Quarter 
    AND CTE.Type_of_Transaction = #TempQuarterlyTargets.Online_or_In_Person
GROUP BY 
    Type_of_Transaction,
    CTE.Quarter,
    #TempQuarterlyTargets.Target
ORDER BY CTE.Quarter





