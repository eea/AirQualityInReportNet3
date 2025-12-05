USE [Airquality_R3]
GO

/****** Object:  View [qc].[CAM_0]  Script Date: 27/10/2025  ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qc].[CAM_0] AS

-- Creation date: 27 November 2025
-- QC rule code: CAM_0
-- QC rule name: CAM_0 Status - [PK]


WITH cte_submitted AS (
  SELECT
    -- record_id,
    NULLIF(CountryCode, '') AS CountryCode,
    NULLIF(AssessmentRegimeId, '') AS AssessmentRegimeId,
    NULLIF(DataAggregationProcessId, '') AS DataAggregationProcessId,
    NULLIF(AssessmentMethodId, '') AS AssessmentMethodId,
    NULLIF(ReportingYear, '') AS ReportingYear,
    AbsoluteUncertaintyLimit,
    AirPollutantCode,
    AirPollutionLevel,
    AirPollutionLevelAdjusted,
    CorrectionFactor,
    Deletion,
    HotSpot,
    MaxRatioUncertainty,
    RelativeUncertaintyLimit,
    AttainmentId

  FROM reporting.ComplianceAssessmentMethod
),

cte_reference AS (
  SELECT
    CountryCode,
    AssessmentRegimeId,
    DataAggregationProcessId,
    AssessmentMethodId,
    ReportingYear,
    AbsoluteUncertaintyLimit,
    AirPollutantCode,
    AirPollutionLevel,
    AirPollutionLevelAdjusted,
    CorrectionFactor,
    Deletion,
    HotSpot,
    MaxRatioUncertainty,
    RelativeUncertaintyLimit,
    AttainmentId

  FROM reference.ComplianceAssessmentMethod
)

SELECT
  -- s.record_id,
  s.CountryCode,
  s.AssessmentRegimeId,
  s.DataAggregationProcessId,
  s.AssessmentMethodId,
  s.ReportingYear,
  CASE
    WHEN r.CountryCode IS NULL THEN 'Addition of new record'
    WHEN COALESCE(s.AbsoluteUncertaintyLimit, '') = COALESCE(r.AbsoluteUncertaintyLimit, '')
     AND COALESCE(s.AirPollutantCode, '') = COALESCE(r.AirPollutantCode, '')
     AND COALESCE(s.AirPollutionLevel, '') = COALESCE(r.AirPollutionLevel, '')
     AND COALESCE(s.AirPollutionLevelAdjusted, '') = COALESCE(r.AirPollutionLevelAdjusted, '')
     AND COALESCE(s.CorrectionFactor, '') = COALESCE(r.CorrectionFactor, '')
     AND COALESCE(s.Deletion, '') = COALESCE(r.Deletion, '')
     AND COALESCE(s.HotSpot, '') = COALESCE(r.HotSpot, '')
     AND COALESCE(s.MaxRatioUncertainty, '') = COALESCE(r.MaxRatioUncertainty, '')
     AND COALESCE(s.RelativeUncertaintyLimit, '') = COALESCE(r.RelativeUncertaintyLimit, '')
     AND COALESCE(s.AttainmentId, '') = COALESCE(r.AttainmentId, '')
    THEN 'No modification'
    ELSE 'Modification of existing record'
  END AS record_status

FROM cte_submitted s
LEFT JOIN cte_reference r
  ON s.CountryCode = r.CountryCode
 AND s.AssessmentRegimeId = r.AssessmentRegimeId
 AND s.DataAggregationProcessId = r.DataAggregationProcessId
 AND s.AssessmentMethodId = r.AssessmentMethodId
 AND s.ReportingYear = r.ReportingYear

GO
