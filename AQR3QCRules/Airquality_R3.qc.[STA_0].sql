USE [Airquality_R3]
GO

/****** Object:  View [qc].[STA_0]  Script Date: 27/10/2025  ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qc].[STA_0] AS

-- Creation date: 27 November 2025
-- QC rule code: STA_0
-- QC rule name: STA_0 Status - [PK]


WITH cte_submitted AS (
  SELECT
    -- record_id,
    NULLIF(CountryCode, '') AS CountryCode,
    NULLIF(AirQualityStationEoICode, '') AS AirQualityStationEoICode,
    NULLIF(AirQualityNetwork, '') AS AirQualityNetwork,
    NULLIF(AirQualityNetworkOrganisationalLevel, '') AS AirQualityNetworkOrganisationalLevel,
    NULLIF(Timezone, '') AS Timezone

  FROM reporting.Station
),

cte_reference AS (
  SELECT
    NULLIF(CountryCode, '') AS CountryCode,
    NULLIF(AirQualityStationEoICode, '') AS AirQualityStationEoICode,
    NULLIF(AirQualityNetworkOrganisationalLevel, '') AS AirQualityNetworkOrganisationalLevel,
    Deletion,
    ReportingTime

  FROM reference.Station
)

SELECT
  -- s.record_id,
  s.CountryCode,
  s.AirQualityStationEoICode,
  CASE
    WHEN r.CountryCode IS NULL THEN 'Addition of new record'
    WHEN COALESCE(s.AirQualityNetworkOrganisationalLevel, '') = COALESCE(r.AirQualityNetworkOrganisationalLevel, '')
    THEN 'No modification'
    ELSE 'Modification of existing record'
  END AS record_status
FROM cte_submitted s
LEFT JOIN cte_reference r
  ON s.CountryCode = r.CountryCode
 AND s.AirQualityStationEoICode = r.AirQualityStationEoICode

GO
