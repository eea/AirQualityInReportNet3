USE [Airquality_R3]
GO

/****** Object:  View [qc].[ARZ_01_A]    Script Date: 07/09/2026 13:37:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [qc].[ARZ_01_A]
AS
-- QC rule code: ARZ_01_A
-- QC rule name: Vocabulary validation - [CountryCode]
--
-- Returns AssessmentRegimeZone records where CountryCode is missing,
-- empty, or does not correspond to a valid ISO2 country code.
--
-- Valid country codes are obtained from reference.Vocabulary, using:
--   - vocabulary = 'countries'
--   - Status = 'Valid'
--   - Notation as the ISO2 country code
--
-- The comparison is case-insensitive and ignores leading/trailing spaces.
--
-- Delivery-country validation:
-- CountryCode must also match the country for which the R3 delivery
-- is being reported. This validation is currently commented out and
-- will be compared against the following deployment variable:
-- {%R3_COUNTRY_CODE%}

WITH CTE_assessment_regime_zone AS
(
    SELECT
        [CountryCode] AS [CountryCodeRaw],
        NULLIF(LTRIM(RTRIM([CountryCode])), '') AS [CountryCode]
    FROM [reporting].[AssessmentRegimeZone]
),
CTE_valid_iso2_country_codes AS
(
    SELECT DISTINCT
        LTRIM(RTRIM([Notation])) COLLATE Latin1_General_CI_AS
            AS [CountryCodeConcept]
    FROM [reference].[Vocabulary]
    WHERE [vocabulary] = 'countries'
      AND [Status] = 'Valid'
      AND NULLIF(LTRIM(RTRIM([Notation])), '') IS NOT NULL
)
SELECT
    arz.[CountryCodeRaw] AS [CountryCode],
    CASE
        -- CountryCode is mandatory.
        WHEN arz.[CountryCode] IS NULL
            THEN 'MISSING_OR_EMPTY_COUNTRYCODE'

        -- CountryCode must exist as a valid ISO2 code in the reference vocabulary.
        WHEN v.[CountryCodeConcept] IS NULL
            THEN 'INVALID_COUNTRYCODE_ISO2'

        -- Delivery-country validation. Enable when the R3 country code
        -- deployment variable is available in the execution context.
        -- WHEN arz.[CountryCode] COLLATE Latin1_General_CI_AS
        --      <> '{%R3_COUNTRY_CODE%}' COLLATE Latin1_General_CI_AS
        --     THEN 'COUNTRYCODE_DOES_NOT_MATCH_R3_DELIVERY'

        ELSE 'UNKNOWN'
    END AS [QC_FailureReason]
FROM CTE_assessment_regime_zone AS arz
LEFT JOIN CTE_valid_iso2_country_codes AS v
    ON arz.[CountryCode] COLLATE Latin1_General_CI_AS
       = v.[CountryCodeConcept]
WHERE
    arz.[CountryCode] IS NULL
    OR v.[CountryCodeConcept] IS NULL

    -- Delivery-country validation. Enable together with the CASE condition above.
    -- OR arz.[CountryCode] COLLATE Latin1_General_CI_AS
    --    <> '{%R3_COUNTRY_CODE%}' COLLATE Latin1_General_CI_AS
;
GO


