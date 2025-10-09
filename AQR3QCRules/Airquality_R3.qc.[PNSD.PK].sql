USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [qc].[PNSD.PK] AS

-- Creation date: 09 October 2025
-- QC rule code: PNSD.PK
-- QC rule name: PNSD.PK Constraint - [CountryCode,AssessmentMethodId,Start,LowerRange]

WITH CTE_MRPNSD AS (
  SELECT 
    --record_id,
    NULLIF("AssessmentMethodId", '') AS AssessmentMethodId   ,
    NULLIF("CountryCode", '') AS CountryCode,
    NULLIF("Start", '') AS StartDate,
    NULLIF("LowerRange", '') AS LowerRange
  FROM reporting.MeasurementResultPNSD
),

duplicate_auth_records AS (
  SELECT 
    AssessmentMethodId ,
    CountryCode,
    StartDate,
    LowerRange
  FROM CTE_MRPNSD 
  GROUP BY AssessmentMethodId , CountryCode,StartDate,LowerRange
  HAVING COUNT(*) > 1
)

SELECT DISTINCT
  /*a.record_id,*/ a.AssessmentMethodId, a.CountryCode, a.StartDate, a.LowerRange
	
FROM CTE_MRPNSD a
LEFT JOIN duplicate_auth_records d
  ON a.AssessmentMethodId  = d.AssessmentMethodId 
 AND a.CountryCode = d.CountryCode
 AND a.StartDate = d.StartDate
 AND a.LowerRange = d.LowerRange
 
WHERE d.CountryCode  IS NOT NULL  -- duplicity
   OR a.CountryCode  IS NULL 
   OR a.AssessmentMethodId IS NULL
   OR a.StartDate IS NULL
   OR a.LowerRange IS NULL


GO