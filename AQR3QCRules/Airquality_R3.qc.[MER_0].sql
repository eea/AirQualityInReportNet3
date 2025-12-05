USE [Airquality_R3]
GO

/****** Object:  View [qc].[MER_0]  Script Date: 27/10/2025  ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qc].[MER_0] AS

-- Creation date: 27 November 2025
-- QC rule code: MER_0
-- QC rule name: MER_0 Status - [PK]

WITH cte_submitted AS (
  SELECT
    -- record_id,
    NULLIF(CountryCode, '') AS CountryCode,
    NULLIF(AssessmentMethodId, '') AS AssessmentMethodId,
    NULLIF([Start], '') AS StartDate,
    AirPollutantCode,
    DataCapture,
    [End] AS EndDate,
    ResultTime,
    Validity,
    Value AS ResultValue,
    Verification

  FROM reporting.MeasurementResult
),

cte_reference AS (
  SELECT
    CountryCode,
    AssessmentMethodId,
    [Start] AS StartDate,
    AirPollutantCode,
    DataCapture,
    [End] AS EndDate,
    ResultTime,
    Validity,
    Value AS ResultValue,
    Verification
  FROM reference.MeasurementResult
)

SELECT
  -- s.record_id,
  s.CountryCode,
  s.AssessmentMethodId,
  s.StartDate,
  CASE
    WHEN r.CountryCode IS NULL THEN 'Addition of new record'
    WHEN COALESCE(s.AirPollutantCode, 0) = COALESCE(r.AirPollutantCode, 0)
     AND COALESCE(s.DataCapture, 0) = COALESCE(r.DataCapture, 0)
     AND COALESCE(s.EndDate, '') = COALESCE(r.EndDate, '')
     AND COALESCE(s.ResultTime, '') = COALESCE(r.ResultTime, '')
     AND COALESCE(s.Validity, 0) = COALESCE(r.Validity, 0)
     AND COALESCE(s.ResultValue, 0) = COALESCE(r.ResultValue, 0)
     AND COALESCE(s.Verification, 0) = COALESCE(r.Verification, 0)
    THEN 'No modification'
    ELSE 'Modification of existing record'
  END AS record_status
FROM cte_submitted s
LEFT JOIN cte_reference r
  ON s.CountryCode = r.CountryCode
 AND s.AssessmentMethodId = r.AssessmentMethodId
 AND s.StartDate = r.StartDate

GO
