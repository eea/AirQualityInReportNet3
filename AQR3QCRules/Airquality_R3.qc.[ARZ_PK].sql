USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qc].[ARZ_PK] AS

-- Creation date: 31/08/2026
-- QC rule code: ARZ_PK
-- QC rule name: ARZ_ PK

WITH CTE_assessmentRegimeZone AS (
  SELECT 
    /*record_id,*/
    NULLIF("CountryCode", '') AS CountryCode,
	 NULLIF("AssessmentRegimeId", '') AS AssessmentRegimeId
	
  FROM [reporting].[AssessmentRegimeZone]
),

duplicate_arz_records AS (
  SELECT 
    CountryCode,
	AssessmentRegimeId
  FROM CTE_assessmentRegimeZone 
  GROUP BY CountryCode, AssessmentRegimeId
	
  HAVING COUNT(*) > 1
)

SELECT 
  /*a.record_id,*/
  a.CountryCode,
  a.AssessmentRegimeId
	
	FROM CTE_assessmentRegimeZone a
	LEFT JOIN duplicate_arz_records d
	 ON a.CountryCode = d.CountryCode
	 AND a.AssessmentRegimeId=a.AssessmentRegimeId
 
	WHERE d.CountryCode  IS NOT NULL  -- duplicity
	   OR a.CountryCode  IS NULL 
	   OR a.AssessmentRegimeId IS NULL

GO