USE [Airquality_R3]
GO

/****** Object:  View [qc].[MORI.PK]    Script Date: 22/09/2025 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qc].[MORI.PK] AS

-- Creation date: 22 September 2025
-- QC rule code: MORI.PK
-- QC rule name: MORI.PK Constraint - [CountryCode,AssessmentMethodId,Start,DataAggregationProcessId,X,Y]

WITH CTE_modelResInline AS (
  SELECT 
    /*record_id,*/
    NULLIF("AssessmentMethodId", '') AS AssessmentMethodId,
    NULLIF("CountryCode", '') AS CountryCode,
    NULLIF("DataAggregationProcessId", '') AS DataAggregationProcessId,
 NULLIF("Start", '') AS StartDate,
 NULLIF("X", '') AS X,
 NULLIF("Y", '') AS Y
    
	FROM reporting.ModellingResultInline
),
duplicate_auth_records AS (
  SELECT 
    AssessmentMethodId,
    CountryCode,
    DataAggregationProcessId,
 StartDate,
 X,
 Y
    
  FROM CTE_modelResInline 
  GROUP BY AssessmentMethodId, CountryCode, DataAggregationProcessId,StartDate,X,Y
  HAVING COUNT(*) > 1
)
SELECT 
  /*a.record_id,*/a.AssessmentMethodId,a.CountryCode,a.DataAggregationProcessId
FROM CTE_modelResInline a
LEFT JOIN duplicate_auth_records d
  ON a.AssessmentMethodId = d.AssessmentMethodId
 AND a.CountryCode = d.CountryCode
 AND a.DataAggregationProcessId = d.DataAggregationProcessId 
 AND a.StartDate = d.StartDate 
 AND a.X = d.X 
 AND a.Y = d.Y 
 
WHERE d.AssessmentMethodId IS NOT NULL  -- duplicity
   OR a.AssessmentMethodId IS NULL 
   OR a.CountryCode IS NULL
   OR a.DataAggregationProcessId IS NULL
   OR a.StartDate IS NULL
   OR a.X IS NULL
   OR a.Y IS NULL


GO


