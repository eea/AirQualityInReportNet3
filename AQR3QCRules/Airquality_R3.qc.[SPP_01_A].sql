USE [Airquality_R3];
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

ALTER VIEW [qc].[SPP_01_A]
AS

-- Creation date: October 2026
-- QC rule code: SPP_01_A
-- QC rule name: SPP.01_A Content check - [CountryCode]
-- QC rule description: CountryCode must be reported as a valid ISO2 country code corresponding to the reporting country.

WITH CTE_countryCode AS
(
    SELECT
        spp.CountryCode AS CountryCodeRaw,
        spp.ProcessId,
        spp.AssessmentMethodId,
        spp.ProcessActivityBegin,
        spp.ProcessActivityEnd,
        spp.PollutantId,

        NULLIF
        (
            LTRIM(RTRIM(spp.CountryCode)),
            ''
        ) COLLATE Latin1_General_CI_AS AS CountryCode
    FROM [reporting].[SamplingProcess] AS spp
),
missing_codes AS
(
    SELECT
        cc.CountryCodeRaw,
        cc.ProcessId,
        cc.AssessmentMethodId,
        cc.ProcessActivityBegin,
        cc.ProcessActivityEnd,
        cc.PollutantId,
        cc.CountryCode,
        CASE
            WHEN cc.CountryCode IS NULL
                THEN 'MISSING_OR_EMPTY_COUNTRYCODE'

            WHEN v.Notation IS NULL
                THEN 'COUNTRYCODE_NOT_IN_COUNTRIES_VOCABULARY'

            /*
            WHEN cc.CountryCode <> '{%R3_COUNTRY_CODE%}'
                THEN 'COUNTRYCODE_DOES_NOT_MATCH_REPORTING_COUNTRY'
            */
        END AS QC_FailureReason
    FROM CTE_countryCode AS cc
    LEFT JOIN [reference].[Vocabulary] AS v
        ON  cc.CountryCode = v.Notation COLLATE Latin1_General_CI_AS
        AND v.Vocabulary = 'countries'
    WHERE
        cc.CountryCode IS NULL
        OR v.Notation IS NULL

        /*
        OR cc.CountryCode <> '{%R3_COUNTRY_CODE%}'
        */
)
SELECT
    CountryCodeRaw AS CountryCode,
    ProcessId,
    AssessmentMethodId,
    ProcessActivityBegin,
    ProcessActivityEnd,
    PollutantId,
    QC_FailureReason
FROM missing_codes;
GO