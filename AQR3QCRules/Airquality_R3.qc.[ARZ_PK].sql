USE [Airquality_R3]
GO

/****** Object:  View [qc].[ARZ_PK]    Script Date: 22/09/2025 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qc].ARZ AS

-- Creation date: 22 September 2025
-- QC rule code: ARZ_PK
-- QC rule name: ��ARZ_PK Constraint - [CountryCode,AssessmentRegimeId,DataAggregationProcessId]

WITH CTE_ARZ AS (
  SELECT 
    /*record_id,*/
    NULLIF("AssessmentRegimeId", '') AS AssessmentRegimeId ,
    NULLIF("CountryCode", '') AS CountryCode,
	NULLIF("DataAggregationProcessId", '') AS DataAggregationProcessId 
    
  FROM reporting.AssessmentRegimeZone
),
duplicate_auth_records AS (
  SELECT 
    AssessmentRegimeId,
    CountryCode,
	DataAggregationProcessId
    
  FROM CTE_ARZ 
  GROUP BY AssessmentRegimeId, CountryCode, DataAggregationProcessId
  HAVING COUNT(*) > 1
)
SELECT 
  /*a.record_id,*/a.AssessmentRegimeId,a.CountryCode,a.DataAggregationProcessId
FROM CTE_ARZ a
LEFT JOIN duplicate_auth_records d
  ON a.AssessmentRegimeId = d.AssessmentRegimeId
 AND a.CountryCode = d.CountryCode
 AND a.DataAggregationProcessId = d.DataAggregationProcessId
 
 
WHERE d.AssessmentRegimeId IS NOT NULL  -- duplicity
   OR a.AssessmentRegimeId IS NULL 
   OR a.CountryCode IS NULL
   OR a.DataAggregationProcessId IS NULL


GO


