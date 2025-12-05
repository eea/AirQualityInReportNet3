USE [Airquality_R3]
GO

/****** Object:  View [qc].[ARZ_0]  Script Date: 27/10/2025  ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qc].[ARZ_0] AS

-- Creation date: 27 November 2025
-- QC rule code: ARZ_0
-- QC rule name: ARZ_0 Status - [PK]


WITH cte_submitted AS (
  SELECT
    -- record_id,
    NULLIF(CountryCode, '') AS CountryCode,
    NULLIF(AssessmentRegimeId, '') AS AssessmentRegimeId,
    NULLIF(DataAggregationProcessId, '') AS DataAggregationProcessId,
    AirPollutantCode,
    ClassificationYear,
    FixedSPOReduction,
    PostponementYear,
    ZoneArea,
    ZoneResidentPopulation,
    ZoneResidentPopulationYear

  FROM reporting.AssessmentRegimeZone
),

cte_reference AS (
  SELECT
    CountryCode,
    AssessmentRegimeId,
    DataAggregationProcessId,
    AirPollutantCode,
    ClassificationYear,
    FixedSPOReduction,
    PostponementYear,
    ZoneArea,
    ZoneResidentPopulation,
    ZoneResidentPopulationYear

  FROM reference.AssessmentRegimeZone
)

SELECT
  -- s.record_id,
  s.CountryCode,
  s.AssessmentRegimeId,
  s.DataAggregationProcessId,
  CASE
    WHEN r.CountryCode IS NULL THEN 'Addition of new record'
    WHEN COALESCE(s.AirPollutantCode, '') = COALESCE(r.AirPollutantCode, '')
     AND COALESCE(s.ClassificationYear, '') = COALESCE(r.ClassificationYear, '')
     AND COALESCE(s.FixedSPOReduction, '') = COALESCE(r.FixedSPOReduction, '')
     AND COALESCE(s.PostponementYear, '') = COALESCE(r.PostponementYear, '')
     AND COALESCE(s.ZoneArea, '') = COALESCE(r.ZoneArea, '')
     AND COALESCE(s.ZoneResidentPopulation, '') = COALESCE(r.ZoneResidentPopulation, '')
     AND COALESCE(s.ZoneResidentPopulationYear, '') = COALESCE(r.ZoneResidentPopulationYear, '')
      THEN 'No modification'
    ELSE 'Modification of existing record'
  END AS record_status

FROM cte_submitted s
LEFT JOIN cte_reference r
  ON s.CountryCode = r.CountryCode
 AND s.AssessmentRegimeId = r.AssessmentRegimeId
 AND s.DataAggregationProcessId = r.DataAggregationProcessId

GO
