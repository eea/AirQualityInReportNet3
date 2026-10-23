USE [Airquality_R3]
GO

/****** Object:  View [qc].[AUT_01_A]    Script Date: 20/10/2026 16:19:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER   VIEW [qc].[AUT_01_A]
AS

-- Creation date: 20 October 2026
-- QC rule code: AUT_01_A
-- QC rule name: AUT_01_A Content check - [CountryCode]
-- QC rule description: CountryCode must be reported as a valid ISO2 country code corresponding to the reporting country.

WITH valid_iso2_codes AS
(
    -- Valid ISO2 country codes maintained in reference.Vocabulary.
    SELECT DISTINCT
        UPPER(LTRIM(RTRIM([Notation]))) AS CountryCode
    FROM [reference].[Vocabulary]
    WHERE [Vocabulary] = 'countries'
      AND NULLIF(LTRIM(RTRIM([Notation])), '') IS NOT NULL
),
authority_data AS
(
    SELECT
        [CountryCode] AS ReportedCountryCode,
        NULLIF(LTRIM(RTRIM([CountryCode])), '') AS NormalisedCountryCode
    FROM [reporting].[Authority]
)
SELECT
    a.ReportedCountryCode AS CountryCode,
    CASE
        WHEN a.NormalisedCountryCode IS NULL
            THEN 'CountryCode must be reported and cannot be null or empty.'
        WHEN iso.CountryCode IS NULL
            THEN 'CountryCode must be a valid ISO2 country code.'
        WHEN UPPER(a.NormalisedCountryCode) <> UPPER('{%R3_COUNTRY_CODE%}')
            THEN 'CountryCode must correspond to the reporting country ({%R3_COUNTRY_CODE%}).'
    END AS ValidationError
FROM authority_data AS a
LEFT JOIN valid_iso2_codes AS iso
    ON UPPER(a.NormalisedCountryCode) = iso.CountryCode
WHERE a.NormalisedCountryCode IS NULL
   OR iso.CountryCode IS NULL
  -- OR UPPER(a.NormalisedCountryCode) <> UPPER('{%R3_COUNTRY_CODE%}')
  ;
GO


