USE [Airquality_R3]
GO

/****** Object:  View [qc].[SRE_0]  Script Date: 27/10/2025  ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qc].[SRE_0] AS

-- Creation date: 27 November 2025
-- QC rule code: SRE_0
-- QC rule name: SRE_0 Status - [PK]


WITH cte_submitted AS (
  SELECT
    -- record_id,
    NULLIF(CountryCode, '') AS CountryCode,
    NULLIF(SR_ApplicationId, '') AS SR_ApplicationId,
    SpatialResolution,
    GeoTiffAttachment

  FROM reporting.SRArea_External
),

cte_reference AS (
  SELECT
    CountryCode,
    SR_ApplicationId,
    SpatialResolution,
    X,
    Y,
    Deletion

  FROM reference.SRArea
)

SELECT
  -- s.record_id,
  s.CountryCode,
  s.SR_ApplicationId,
  CASE
    WHEN r.CountryCode IS NULL THEN 'Addition of new record'
    WHEN COALESCE(s.SpatialResolution, '') = COALESCE(r.SpatialResolution, '')
    THEN 'No modification'
    ELSE 'Modification of existing record'
  END AS record_status

FROM cte_submitted s
LEFT JOIN cte_reference r
  ON s.CountryCode = r.CountryCode
 AND s.SR_ApplicationId = r.SR_ApplicationId

GO
