USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [qc].[MER.PK] AS

-- Creation date: 07 October 2025
-- QC rule code: MER.PK
-- QC rule name: MER.PK Constraint - [CountryCode,AssessmentMethodId,Start]

WITH CTE_Doc AS (
  SELECT 
    /*record_id,*/
    NULLIF("AssessmentMethodId", '') AS AssessmentMethodId,
    NULLIF("CountryCode", '') AS CountryCode,
	NULLIF("Start", '') AS StartDate

  FROM reporting.MeasurementResult
),

duplicate_auth_records AS (
  SELECT 
    AssessmentMethodId,
    CountryCode,
    StartDate
  FROM CTE_Doc 
  GROUP BY AssessmentMethodId , CountryCode,StartDate
	
  HAVING COUNT(*) > 1
)

SELECT DISTINCT
  /*a.record_id,*/a.AssessmentMethodId, a.CountryCode, a.StartDate
	
	FROM CTE_Doc a
	LEFT JOIN duplicate_auth_records d
	  ON a.AssessmentMethodId  = d.AssessmentMethodId 
	 AND a.CountryCode = d.CountryCode
	 AND a.StartDate = d.StartDate

	WHERE d.CountryCode IS NOT NULL  -- duplicity
	   OR a.CountryCode IS NULL 
	   OR a.AssessmentMethodId IS NULL
	   OR a.StartDate IS NULL


GO


