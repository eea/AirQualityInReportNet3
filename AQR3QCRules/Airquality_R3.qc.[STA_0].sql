USE [Airquality_R3]
GO

/****** Object:  View [qc].[STA_0_OLD]    Script Date: 25/05/2026 14:10:38 ******/
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
    NULLIF(StationNationalCode, '') AS StationNationalCode,
    NULLIF(NetworkId, '') AS NetworkId,
    NULLIF(NetworkOrganisationalLevel, '') AS NetworkOrganisationalLevel,
    NULLIF(Timezone, '') AS Timezone

  FROM reporting.MeasurementStation
),

cte_reference AS (
  SELECT
    NULLIF(CountryCode, '') AS CountryCode,
    NULLIF(StationNationalCode, '') AS StationNationalCode,
    NULLIF(NetworkOrganisationalLevel, '') AS NetworkOrganisationalLevel,
    Deletion,
    ReportingTime

  FROM reference.MeasurementStation
)

SELECT
  -- s.record_id,
  s.CountryCode,
  s.StationNationalCode,
  CASE
    WHEN r.CountryCode IS NULL THEN 'Addition of new record'
    WHEN COALESCE(s.NetworkOrganisationalLevel, '') = COALESCE(r.NetworkOrganisationalLevel, '')
    THEN 'No modification'
    ELSE 'Modification of existing record'
  END AS record_status
FROM cte_submitted s
LEFT JOIN cte_reference r
  ON s.CountryCode = r.CountryCode
 AND s.StationNationalCode = r.StationNationalCode

GO


