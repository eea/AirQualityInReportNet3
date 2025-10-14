USE [Airquality_R3]
GO

/****** Object:  View [qc].[MORE.PK]    Script Date: 22/09/2025 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qc].[MORE.PK] AS

-- Creation date: 22 September 2025
-- QC rule code: MORE.PK
-- QC rule name: MORE.PK Constraint - [CountryCode,AssessmentMethodId,Start,DataAggregationProcessId]

WITH CTE_modelResExt AS (
  SELECT 
    /*record_id,*/
    NULLIF("AssessmentMethodId", '') AS AssessmentMethodId,
    NULLIF("CountryCode", '') AS CountryCode,
    NULLIF("DataAggregationProcessId", '') AS DataAggregationProcessId,
	NULLIF("Start", '') AS StartDate
    
  FROM reporting.ModellingResultInline
),
duplicate_auth_records AS (
  SELECT 
    AssessmentMethodId,
    CountryCode,
    DataAggregationProcessId,
	StartDate
    
  FROM CTE_modelResExt 
  GROUP BY AssessmentMethodId, CountryCode, DataAggregationProcessId,StartDate
  HAVING COUNT(*) > 1
)
SELECT 
  /*a.record_id,*/a.AssessmentMethodId,a.CountryCode,a.DataAggregationProcessId
FROM CTE_modelResExt a
LEFT JOIN duplicate_auth_records d
  ON a.AssessmentMethodId = d.AssessmentMethodId
 AND a.CountryCode = d.CountryCode
 AND a.DataAggregationProcessId = d.DataAggregationProcessId 
 AND a.StartDate = d.StartDate 
 
WHERE d.AssessmentMethodId IS NOT NULL  -- duplicity
   OR a.AssessmentMethodId IS NULL 
   OR a.CountryCode IS NULL
   OR a.DataAggregationProcessId IS NULL
   OR a.StartDate IS NULL
   


GO


