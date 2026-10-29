USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[SPO_01_A]
AS

-- QC rule code: SPO_01_A
-- QC rule name: SPO_01_A Content check - [CountryCode]
-- QC rule description: CountryCode must be reported as a valid ISO2 country code corresponding to the reporting country.

WITH src AS
(
    SELECT
        NULLIF(LTRIM(RTRIM([CountryCode])), '') AS CountryCode,
        [AssessmentMethodId]
    FROM [reporting].[SamplingPoint]
),
country_vocabulary AS
(
    SELECT
        NULLIF(LTRIM(RTRIM([Notation])), '') AS CountryCode
    FROM [reference].[Vocabulary]
    WHERE [vocabulary] COLLATE DATABASE_DEFAULT = 'countries' COLLATE DATABASE_DEFAULT
)
SELECT
    s.CountryCode,
    s.AssessmentMethodId
FROM src AS s
LEFT JOIN country_vocabulary AS c
    ON s.CountryCode COLLATE DATABASE_DEFAULT =
       c.CountryCode COLLATE DATABASE_DEFAULT
WHERE
    s.CountryCode IS NULL
    OR c.CountryCode IS NULL
    -- OR s.CountryCode <> '{%R3_COUNTRY_CODE%}'
GO