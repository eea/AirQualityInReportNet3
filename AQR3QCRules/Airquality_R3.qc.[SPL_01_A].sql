USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[SPL_01_A] AS

-- Creation date: 02/08/2026
-- QC rule code: SPL_01_A
-- QC rule name: SPL_01_A CountryCode

WITH CTE_countryCode AS (
    SELECT
        [CountryCode] AS [CountryCodeRaw],
        NULLIF(LTRIM(RTRIM([CountryCode])), '') AS [CountryCode]
    FROM [reporting].[SamplingPointLocation]
),

CTE_validCountryCodes AS (
    SELECT DISTINCT
        LTRIM(RTRIM(v.[notation])) COLLATE Latin1_General_CI_AS
            AS [CountryCode]
    FROM [reference].[Vocabulary] AS v
    WHERE v.[vocabulary] = 'countries'
      AND NULLIF(LTRIM(RTRIM(v.[notation])), '') IS NOT NULL
)

SELECT DISTINCT
    cc.[CountryCodeRaw] AS [CountryCode]
FROM CTE_countryCode AS cc
LEFT JOIN CTE_validCountryCodes AS v
    ON cc.[CountryCode] COLLATE Latin1_General_CI_AS = v.[CountryCode]
WHERE
    cc.[CountryCode] IS NULL
    OR v.[CountryCode] IS NULL

GO