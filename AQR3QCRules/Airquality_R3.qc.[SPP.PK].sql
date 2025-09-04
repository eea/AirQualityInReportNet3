USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qc].[SPP.PK] AS

-- Creation date: 03 September 2025
-- QC rule code: SPP.PK
-- QC rule name: SPP.PK Constraint - [CountryCode,ProcessId,AssessmentMethodId,ProcessActivityBegin]

WITH CTE_SP AS (
  SELECT 
    /*record_id,*/
    NULLIF("AssessmentMethodId", '') AS AssessmentMethodId,
    NULLIF("CountryCode", '') AS CountryCode,
    NULLIF("ProcessId", '') AS ProcessId,
    NULLIF("ProcessActivityBegin", '') AS ProcessActivityBegin
  FROM reporting."SamplingProcess"
),
duplicate_sp_records AS (
  SELECT 
    AssessmentMethodId,
    CountryCode,
    ProcessId,
    ProcessActivityBegin
  FROM CTE_SP 
  GROUP BY AssessmentMethodId, CountryCode, ProcessId, ProcessActivityBegin
  HAVING COUNT(*) > 1
)
SELECT 
 /* a.record_id,*/a.AssessmentMethodId,a.CountryCode,a.ProcessId,a.ProcessActivityBegin
FROM CTE_SP a
LEFT JOIN duplicate_sp_records d
  ON a.AssessmentMethodId = d.AssessmentMethodId
 AND a.CountryCode = d.CountryCode
 AND a.ProcessId = d.ProcessId 
 AND a.ProcessActivityBegin = d.ProcessActivityBegin
WHERE d.AssessmentMethodId IS NOT NULL  -- duplicity
   OR a.AssessmentMethodId IS NULL 
   OR a.CountryCode IS NULL
   OR a.ProcessId IS NULL
   OR a.ProcessActivityBegin IS NULL 