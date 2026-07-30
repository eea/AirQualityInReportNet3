USE [Airquality_R3]
GO

/****** Object:  View [qc].[ZOG_02_A] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qctesting].[ZOG_02_A_TEST]
AS

-- Creation date: July 2026

WITH CTE_zoneId AS (
SELECT
    NULLIF(LTRIM(RTRIM(CountryCode)), '') AS CountryCode,
    NULLIF(LTRIM(RTRIM(ZoneId)), '') AS ZoneId
FROM reporting.ZoneGeometry
),

duplicate_ids AS (
SELECT
    CountryCode,
    ZoneId
FROM CTE_zoneId
WHERE ZoneId IS NOT NULL
GROUP BY CountryCode, ZoneId
HAVING COUNT(*) > 1
),

invalid_zoneIds AS (
SELECT
    z.CountryCode,
    z.ZoneId
FROM CTE_zoneId z
LEFT JOIN duplicate_ids d
    ON z.CountryCode = d.CountryCode
   AND z.ZoneId = d.ZoneId
WHERE
      z.ZoneId IS NULL
   OR d.ZoneId IS NOT NULL
)

SELECT DISTINCT *
FROM invalid_zoneIds

GO