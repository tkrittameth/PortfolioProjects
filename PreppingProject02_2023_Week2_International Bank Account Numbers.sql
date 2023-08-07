/*This is a data preparation from prepping.coom 2023 week2*/
/* https://preppindata.blogspot.com/2023/01/2023-week-2-international-bank-account.html */
SELECT *
FROM PreppingData.dbo.week2_2023

--First step I will be making a new column and adding the UK country code to the table
ALTER TABLE PreppingData.dbo.week2_2023
ADD Country_Code VARCHAR(3)

UPDATE PreppingData.dbo.week2_2023
SET Country_Code = 'GB'

--Next, we will get rid of dashes in the Sort_Code field
UPDATE PreppingData.dbo.week2_2023
SET Sort_Code = REPLACE(Sort_Code,'-','')
WHERE Sort_Code LIKE '%-%'

--Next, I will add SWIFT bank code and check digits for each bank
--Plus, we will arrange them in the IBAN order
SELECT Transaction_ID,Country_Code,
CASE
	WHEN Bank = 'Lloyds Bank' THEN 'C1'
	WHEN Bank = 'Barclays Bank' THEN '22'
	WHEN Bank = 'Halifax' THEN '22'
	WHEN Bank = 'HSBC' THEN '4B'
	WHEN Bank = 'Natwest' THEN '2L'
	WHEN Bank = 'Santander' THEN '3E'
	WHEN Bank = 'Data Source Bank' THEN '12'
	END AS Check_Digits,
CASE 
	WHEN Bank = 'Lloyds Bank' THEN 'LOYD'
	WHEN Bank = 'Barclays Bank' THEN 'BARC'
	WHEN Bank = 'Halifax' THEN 'HLFX'
	WHEN Bank = 'HSBC' THEN 'HBUK'
	WHEN Bank = 'Natwest' THEN 'NWBK'
	WHEN Bank = 'Santander' THEN 'ABBY'
	WHEN Bank = 'Data Source Bank' THEN 'DSBX'
	END AS SWIFT_Code,
Sort_Code, Account_Number
FROM PreppingData.dbo.week2_2023

--Now, we will make the IBAN
WITH CTE
AS(
SELECT Transaction_ID,Country_Code,
CASE
	WHEN Bank = 'Lloyds Bank' THEN 'C1'
	WHEN Bank = 'Barclays Bank' THEN '22'
	WHEN Bank = 'Halifax' THEN '22'
	WHEN Bank = 'HSBC' THEN '4B'
	WHEN Bank = 'Natwest' THEN '2L'
	WHEN Bank = 'Santander' THEN '3E'
	WHEN Bank = 'Data Source Bank' THEN '12'
	END AS Check_Digits,
CASE 
	WHEN Bank = 'Lloyds Bank' THEN 'LOYD'
	WHEN Bank = 'Barclays Bank' THEN 'BARC'
	WHEN Bank = 'Halifax' THEN 'HLFX'
	WHEN Bank = 'HSBC' THEN 'HBUK'
	WHEN Bank = 'Natwest' THEN 'NWBK'
	WHEN Bank = 'Santander' THEN 'ABBY'
	WHEN Bank = 'Data Source Bank' THEN 'DSBX'
	END AS SWIFT_Code,
Sort_Code, Account_Number
FROM PreppingData.dbo.week2_2023
)

SELECT Transaction_ID, CONCAT(Country_Code,Check_Digits,SWIFT_Code,Sort_Code,Account_Number) AS IBAN
FROM CTE



