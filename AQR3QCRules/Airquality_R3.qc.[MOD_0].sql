USE [Airquality_R3]
GO

/****** Object:  View [qc].[MOD_0]  Script Date: 27/10/2025  ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qc].[MOD_0] AS

-- Creation date: 27 November 2025
-- QC rule code: MOD_0
-- QC rule name: MOD_0 Status - [PK]


WITH cte_submitted AS (
  SELECT
    -- record_id,
    NULLIF(CountryCode, '') AS CountryCode,
    NULLIF(AssessmentMethodId, '') AS AssessmentMethodId,
    NULLIF(DataAggregationProcessId, '') AS DataAggregationProcessId,
    AirPollutantCode,
    AssessmentType,
    MQI

  FROM reporting.Model
),

cte_reference AS (
  SELECT
    CountryCode,
    AssessmentMethodId,
    DataAggregationProcessId,
    AirPollutantCode,
    DataQualityReportURL,
    Deletion,
    ModelReportURL,
    MQI

  FROM reference.Model
)

SELECT
  -- s.record_id,
  s.CountryCode,
  s.AssessmentMethodId,
  s.DataAggregationProcessId,
  CASE
    WHEN r.CountryCode IS NULL THEN 'Addition of new record'
    WHEN COALESCE(s.AirPollutantCode, '') = COALESCE(r.AirPollutantCode, '')
     AND COALESCE(s.MQI, '') = COALESCE(r.MQI, '')
      THEN 'No modification'
    ELSE 'Modification of existing record'
  END AS record_status

FROM cte_submitted s
LEFT JOIN cte_reference r
  ON s.CountryCode = r.CountryCode
 AND s.AssessmentMethodId = r.AssessmentMethodId
 AND s.DataAggregationProcessId = r.DataAggregationProcessId

GO
