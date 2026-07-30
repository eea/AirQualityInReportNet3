USE [Airquality_R3]
GO

/****** Object:  View [qc].[ZOG_02_B] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qctesting].[ZOG_02_B_TEST]
AS

-- Creation date: July 2026

WITH CTE_zoneId AS (
SELECT
    NULLIF(LTRIM(RTRIM(CountryCode)), '') AS CountryCode,
    NULLIF(LTRIM(RTRIM(ZoneId)), '') AS ZoneId
FROM reporting.ZoneGeometry
),

invalid_format AS (
SELECT
    CountryCode,
    ZoneId
FROM CTE_zoneId
WHERE
    ZoneId IS NOT NULL
    AND ZoneId NOT IN (
        CONCAT('ZON.', CountryCode),
        CONCAT('ZON_', CountryCode),
        CONCAT('ZON-', CountryCode)
    )
)

SELECT DISTINCT *
FROM invalid_format

GO