USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qc].[SPO.PK] AS

-- Creation date: 02 September 2025
-- QC rule code: SPO.PK
-- QC rule name:  SPO.PK Constraint - [CountryCode,AssessmentMethodId]

WITH CTE_SPO AS (
  SELECT 
    /*record_id,*/
    NULLIF("AssessmentMethodId", '') AS AssessmentMethodId,
    NULLIF("CountryCode", '') AS CountryCode
  FROM reporting."samplingpoint"
),
duplicate_auth_records AS (
  SELECT 
    AssessmentMethodId,
    CountryCode
  FROM CTE_SPO 
  GROUP BY AssessmentMethodId, CountryCode
  HAVING COUNT(*) > 1
)
SELECT 
 /* a.record_id,*/a.AssessmentMethodId,a.CountryCode
FROM CTE_SPO a
LEFT JOIN duplicate_auth_records d
  ON a.AssessmentMethodId = d.AssessmentMethodId
 AND a.CountryCode = d.CountryCode
 
WHERE d.AssessmentMethodId IS NOT NULL  -- duplicity
   OR a.AssessmentMethodId IS NULL 
   OR a.CountryCode IS NULL