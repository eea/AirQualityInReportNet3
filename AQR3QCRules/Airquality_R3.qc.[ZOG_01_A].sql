USE [Airquality_R3]
GO

/****** Object:  View [qc].[ZOG_01_A] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qctesting].[ZOG_01_A_TEST]
AS

-- Creation date: July 2026

WITH CTE_countryCode AS (
    SELECT
        NULLIF(LTRIM(RTRIM(CountryCode)), '') AS CountryCode
    FROM reporting.ZoneGeometry
),

missing_codes AS (
    SELECT
        cc.CountryCode
    FROM CTE_countryCode cc
    LEFT JOIN reference.Vocabulary v
        ON cc.CountryCode = v.Notation COLLATE Latin1_General_CI_AS
       AND v.Vocabulary = 'countries'
    WHERE
        v.Notation IS NULL
        AND cc.CountryCode IS NOT NULL
)

SELECT DISTINCT *
FROM missing_codes;

GO