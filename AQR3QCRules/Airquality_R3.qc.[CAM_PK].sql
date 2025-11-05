USE [Airquality_R3]
GO

/****** Object:  View [qc].[CAM_PK]    Script Date: 22/09/2025 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qc].CAM AS

-- Creation date: 22 September 2025
-- QC rule code: CAM_PK
-- QC rule name: CAM_PK Constraint - [CountryCode,AssessmentRegimeId,DataAggregationProcessId,AssessmentMethodId,AttainmentId]

WITH CTE_CAM AS (
  SELECT 
    /*record_id,*/
    NULLIF("AssessmentRegimeId", '') AS AssessmentRegimeId ,
    NULLIF("CountryCode", '') AS CountryCode,
	NULLIF("DataAggregationProcessId", '') AS DataAggregationProcessId,
	NULLIF("AssessmentMethodId", '') AS AssessmentMethodId,
	NULLIF("AttainmentId", '') AS AttainmentId
	
	
  FROM reporting.ComplianceAssessmentMethod
),
duplicate_auth_records AS (
  SELECT 
    AssessmentRegimeId,
    CountryCode,
	DataAggregationProcessId,
	AssessmentMethodId,
	AttainmentId 
    
  FROM CTE_CAM 
  GROUP BY AssessmentRegimeId, CountryCode, DataAggregationProcessId,AssessmentMethodId,
	AttainmentId 
  HAVING COUNT(*) > 1
)
SELECT 
  /*a.record_id,*/a.AssessmentRegimeId,a.CountryCode,a.DataAggregationProcessId,a.AssessmentMethodId,
	a.AttainmentId 
FROM CTE_CAM a
LEFT JOIN duplicate_auth_records d
  ON a.AssessmentRegimeId = d.AssessmentRegimeId
 AND a.CountryCode = d.CountryCode
 AND a.DataAggregationProcessId = d.DataAggregationProcessId
 AND a.AssessmentMethodId = d.AssessmentMethodId
 AND a.AttainmentId = d.AttainmentId
 
 
WHERE d.AssessmentRegimeId IS NOT NULL  -- duplicity
   OR a.AssessmentRegimeId IS NULL 
   OR a.CountryCode IS NULL
   OR a.DataAggregationProcessId IS NULL
   OR a.AssessmentMethodId IS NULL
   OR a.AttainmentId IS NULL
  


GO


