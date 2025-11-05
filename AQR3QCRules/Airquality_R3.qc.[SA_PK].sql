USE [Airquality_R3]
GO

/****** Object:  View [qc].[SA_PK]    Script Date: 22/09/2025 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qc].[SA_PK] AS

-- Creation date: 22 September 2025
-- QC rule code: SA_PK
-- QC rule name: SA_PK Constraint - [CountryCode,SourceAppId]

WITH CTE_PS AS (
  SELECT 
    /*record_id,*/
    NULLIF("CountryCode", '') AS CountryCode,	
	NULLIF("SourceAppId", '') AS SourceAppId 	
	
  FROM reporting.SourceApportionment
),
duplicate_auth_records AS (
  SELECT 
    CountryCode,   
	SourceAppId	
  FROM CTE_PS 
  GROUP BY CountryCode,SourceAppId
	
  HAVING COUNT(*) > 1
)
SELECT 
  /*a.record_id,*/a.CountryCode,a.SourceAppId
	
	FROM CTE_PS a
	LEFT JOIN duplicate_auth_records d
	  ON a.CountryCode = d.CountryCode 
	 AND a.SourceAppId=a.SourceAppId
 
	WHERE d.CountryCode  IS NOT NULL  -- duplicity
	   OR a.CountryCode  IS NULL   
	   OR a.SourceAppId IS NULL


GO


