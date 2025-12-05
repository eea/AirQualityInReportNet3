USE [Airquality_R3]
GO

/****** Object:  View [qc].[ZOG_0]  Script Date: 27/10/2025  ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qc].[ZOG_0] AS

-- Creation date: 27 November 2025
-- QC rule code: ZOG_0
-- QC rule name: ZOG_0 Status - [PK]


WITH cte_submitted AS (
  SELECT
    -- record_id,
    NULLIF(CountryCode, '') AS CountryCode,
    NULLIF(ZoneId, '') AS ZoneId

  FROM reporting.ZoneGeometry
),

cte_reference AS (
  SELECT
    CountryCode,
    ZoneId,
    Deletion

  FROM reference.ZoneGeometry
)

SELECT
  -- s.record_id,
  s.CountryCode,
  s.ZoneId,
  CASE
    WHEN r.CountryCode IS NULL THEN 'Addition of new record'
    WHEN COALESCE(r.Deletion, '') <> '' THEN 'Modification of existing record'
    ELSE 'No modification'
  END AS record_status

FROM cte_submitted s
LEFT JOIN cte_reference r
  ON s.CountryCode = r.CountryCode
 AND s.ZoneId = r.ZoneId

GO
