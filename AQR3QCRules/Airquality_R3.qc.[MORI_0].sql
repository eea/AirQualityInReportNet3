USE [Airquality_R3]
GO

/****** Object:  View [qc].[MORI_0]  Script Date: 27/10/2025  ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qc].[MORI_0] AS

-- Creation date: 27 November 2025
-- QC rule code: MORI_0
-- QC rule name: MORI_0 Status - [PK]

WITH cte_submitted AS (
  SELECT
    -- record_id,
    NULLIF(CountryCode, '') AS CountryCode,
    NULLIF(AssessmentMethodId, '') AS AssessmentMethodId,
    NULLIF(DataAggregationProcessId, '') AS DataAggregationProcessId,
    NULLIF([Start], '') AS StartDate,
    AirPollutantCode,
    [End] AS EndDate,
    ResultTime,
    SpatialResolution,
    Validity,
    Value,
    X,
    Y

  FROM reporting.ModellingResultInline
),

cte_reference AS (
  SELECT
    CountryCode,
    AssessmentMethodId,
    DataAggregationProcessId,
    [Start] AS StartDate,
    AirPollutantCode,
    [End] AS EndDate,
    ResultTime,
    SpatialResolution,
    Validity,
    Value,
    X,
    Y

  FROM reference.ModellingResult
)

SELECT
  -- s.record_id,
  s.CountryCode,
  s.AssessmentMethodId,
  s.DataAggregationProcessId,
  s.StartDate,
  s.X,
  s.Y,
  CASE
    WHEN r.CountryCode IS NULL THEN 'Addition of new record'
    WHEN COALESCE(s.AirPollutantCode, '') = COALESCE(r.AirPollutantCode, '')
     AND COALESCE(s.EndDate, '') = COALESCE(r.EndDate, '')
     AND COALESCE(s.ResultTime, '') = COALESCE(r.ResultTime, '')
     AND COALESCE(s.SpatialResolution, '') = COALESCE(r.SpatialResolution, '')
     AND COALESCE(s.Validity, '') = COALESCE(r.Validity, '')
     AND COALESCE(s.Value, '') = COALESCE(r.Value, '')
      THEN 'No modification'
    ELSE 'Modification of existing record'
  END AS record_status

FROM cte_submitted s
LEFT JOIN cte_reference r
  ON s.CountryCode = r.CountryCode
 AND s.AssessmentMethodId = r.AssessmentMethodId
 AND s.DataAggregationProcessId = r.DataAggregationProcessId
 AND s.StartDate = r.StartDate
 AND s.X = r.X
 AND s.Y = r.Y

GO
