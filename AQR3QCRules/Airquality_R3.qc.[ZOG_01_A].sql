USE [Airquality_R3]
GO

/****** Object:  View [qc].[ZOG_01_A]    Script Date: 25/08/2026 14:28:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [qc].[ZOG_01_A]
AS
-- QC rule code: ZOG_01_A
-- QC rule name: CountryCode mandatory and ISO2 vocabulary validation

WITH CTE_zone_geometry AS
(
    SELECT
        [countryCode] AS original_countryCode,
        NULLIF(LTRIM(RTRIM([countryCode])), '') AS countryCode
    FROM [reporting].[ZoneGeometry]
),
CTE_invalid_country_codes AS
(
    SELECT
        zg.original_countryCode,
        zg.countryCode
    FROM CTE_zone_geometry AS zg
    LEFT JOIN [reference].[Vocabulary] AS v
        ON zg.countryCode COLLATE Latin1_General_CI_AS
         = v.[notation] COLLATE Latin1_General_CI_AS
       AND v.[vocabulary] = 'countries'
    WHERE
        -- CountryCode is mandatory: NULL, empty, or whitespace-only values are invalid.
        zg.countryCode IS NULL

        -- CountryCode must exist in the ISO2 country-code vocabulary.
        OR v.[notation] IS NULL
)
SELECT DISTINCT
    original_countryCode AS countryCode
FROM CTE_invalid_country_codes;
GO


