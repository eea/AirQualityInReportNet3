USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qc].[MOD.PK] AS

-- Creation date: 03 September 2025
-- QC rule code: MOD.PK
-- QC rule name: MOD.PK Constraint - [CountryCode,AssessmentMethodId,DataAggregationDataAggregationProcessId]

WITH CTE_model AS (
  SELECT 
    /*record_id,*/
    NULLIF("AssessmentMethodId", '') AS AssessmentMethodId,
    NULLIF("CountryCode", '') AS CountryCode,
    NULLIF("DataAggregationProcessId", '') AS DataAggregationProcessId
    
  FROM reporting."Model"
),
duplicate_auth_records AS (
  SELECT 
    AssessmentMethodId,
    CountryCode,
    DataAggregationProcessId
    
  FROM CTE_model 
  GROUP BY AssessmentMethodId, CountryCode, DataAggregationProcessId
  HAVING COUNT(*) > 1
)
SELECT 
 /* a.record_id,*/a.AssessmentMethodId,a.CountryCode,a.DataAggregationProcessId
FROM CTE_model a
LEFT JOIN duplicate_auth_records d
  ON a.AssessmentMethodId = d.AssessmentMethodId
 AND a.CountryCode = d.CountryCode
 AND a.DataAggregationProcessId = d.DataAggregationProcessId 
 
WHERE d.AssessmentMethodId IS NOT NULL  -- duplicity
   OR a.AssessmentMethodId IS NULL 
   OR a.CountryCode IS NULL
   OR a.DataAggregationProcessId IS NULL