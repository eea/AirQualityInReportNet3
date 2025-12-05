USE [Airquality_R3]
GO

/****** Object:  View [qc].[SRI_0]  Script Date: 27/10/2025  ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qc].[SRI_0] AS

-- Creation date: 27 November 2025
-- QC rule code: SRI_0
-- QC rule name: SRI_0 Status - [PK]


WITH cte_submitted AS (
  SELECT
    -- record_id,
    NULLIF(CountryCode, '') AS CountryCode,
    NULLIF(SR_ApplicationId, '') AS SR_ApplicationId,
    NULLIF(X, '') AS X,
    NULLIF(Y, '') AS Y,
    SpatialResolution

  FROM reporting.SRArea_Inline
),

cte_reference AS (
  SELECT
    CountryCode,
    SR_ApplicationId,
    X,
    Y,
    SpatialResolution

  FROM reference.SRArea
)

SELECT
  -- s.record_id,
  s.CountryCode,
  s.SR_ApplicationId,
  s.X,
  s.Y,
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
 AND s.X = r.X
 AND s.Y = r.Y

GO
