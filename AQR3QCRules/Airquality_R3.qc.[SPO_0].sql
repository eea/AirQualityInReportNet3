USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPO_0]  Script Date: 27/10/2025  ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qc].[SPO_0] AS

-- Creation date: 27 November 2025
-- QC rule code: SPO_0
-- QC rule name: SPO_0 Status - [PK]


WITH cte_submitted AS (
  SELECT
    -- record_id,
    NULLIF(CountryCode, '') AS CountryCode,
    NULLIF(AssessmentMethodId, '') AS AssessmentMethodId,
    AirPollutantCode,
    [Altitude(masl)] AS Altitude_masl,
    [BuildingDistance(m)] AS BuildingDistance_m,
    [InletHeight(m)] AS InletHeight_m,
    [KerbDistance(m)] AS KerbDistance_m,
    Latitude,
    Longitude,
    SuperSite

  FROM reporting.SamplingPoint
),

cte_reference AS (
  SELECT
    NULLIF(CountryCode, '') AS CountryCode,
    NULLIF(AssessmentMethodId, '') AS AssessmentMethodId,
    AirPollutantCode,
    [Altitude(masl)] AS Altitude_masl,
    [BuildingDistance(m)] AS BuildingDistance_m,
    [InletHeight(m)] AS InletHeight_m,
    [KerbDistance(m)] AS KerbDistance_m,
    Latitude,
    Longitude,
    SuperSite
  FROM reference.SamplingPoint
)

SELECT
  -- s.record_id,
  s.CountryCode,
  s.AssessmentMethodId,
  CASE
    WHEN r.CountryCode IS NULL THEN 'Addition of new record'
    WHEN COALESCE(s.AirPollutantCode, -1) = COALESCE(r.AirPollutantCode, -1)
     AND COALESCE(s.Altitude_masl, -9999) = COALESCE(r.Altitude_masl, -9999)
     AND COALESCE(s.BuildingDistance_m, -9999) = COALESCE(r.BuildingDistance_m, -9999)
     AND COALESCE(s.InletHeight_m, -9999) = COALESCE(r.InletHeight_m, -9999)
     AND COALESCE(s.KerbDistance_m, -9999) = COALESCE(r.KerbDistance_m, -9999)
     AND COALESCE(s.Latitude, -9999) = COALESCE(r.Latitude, -9999)
     AND COALESCE(s.Longitude, -9999) = COALESCE(r.Longitude, -9999)
     AND COALESCE(s.SuperSite, 0) = COALESCE(r.SuperSite, 0)
    THEN 'No modification'
    ELSE 'Modification of existing record'
  END AS record_status
FROM cte_submitted s
LEFT JOIN cte_reference r
  ON s.CountryCode = r.CountryCode
 AND s.AssessmentMethodId = r.AssessmentMethodId

GO


