USE [Airquality_R3]
GO

/****** Object:  View [qc].[STA_0]    Script Date: 11/06/2026 13:09:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



alter VIEW [qc].[STA_0] AS

-- QC rule code: STA_0
-- QC rule name: STA_0 Status - [PK]


WITH cte_submitted AS (
  SELECT
    -- record_id,
    NULLIF(CountryCode, '') AS CountryCode,
    NULLIF(StationEoICode, '') AS StationEoICode,
    NULLIF(NetworkId, '') AS NetworkId,
    NULLIF(NetworkOrganisationalLevel, '') AS NetworkOrganisationalLevel,
    NULLIF(Timezone, '') AS Timezone

  FROM reporting.MeasurementStation
),

cte_reference AS (
  SELECT
    NULLIF(CountryCode, '') AS CountryCode,
    NULLIF(StationEoICode, '') AS StationEoICode,
    NULLIF(NetworkOrganisationalLevel, '') AS NetworkOrganisationalLevel,
    Deletion,
    ReportingTime

  FROM reference.MeasurementStation
)

SELECT
  -- s.record_id,
  s.CountryCode,
  s.StationEoICode,
  CASE
    WHEN r.CountryCode IS NULL THEN 'Addition of new record'
    WHEN COALESCE(s.NetworkOrganisationalLevel, '') = COALESCE(r.NetworkOrganisationalLevel, '')
    THEN 'No modification'
    ELSE 'Modification of existing record'
  END AS record_status
FROM cte_submitted s
LEFT JOIN cte_reference r
  ON s.CountryCode = r.CountryCode
 AND s.StationEoICode = r.StationEoICode

GO


