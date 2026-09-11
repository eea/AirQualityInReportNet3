USE [Airquality_R3]
GO

/****** Object:  View [qc].[ARZ_03_A]    Script Date: 11/09/2026 12:37:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   VIEW [qc].[ARZ_03_A]
AS
-- QC rule code: ARZ_03_A
-- QC rule name: Referential validation - [ZoneId]
--
-- Returns AssessmentRegimeZone records where ZoneId does not identify an
-- existing air quality zone for the same CountryCode.
--
-- Validation logic:
--   1. ZoneId must exist in reporting.ZoneGeometry within the current
--      R3 submission; or
--   2. If it is not present in the current submission, it must exist in
--      reference.ZoneGeometry in the reference dataset.
--
-- The CountryCode + ZoneId combination is used for the cross-check.
--
-- ZoneId missing-value validation is not included in this rule. It should
-- be covered by a separate mandatory-field QC rule.

WITH CTE_assessment_regime_zone AS
(
    SELECT
        CONVERT(NVARCHAR(100), [CountryCode])
            COLLATE Latin1_General_100_CI_AS AS [CountryCodeRaw],

        CONVERT(NVARCHAR(500), [AssessmentRegimeId])
            COLLATE Latin1_General_100_CI_AS AS [AssessmentRegimeId],

        CONVERT(NVARCHAR(500), [ZoneId])
            COLLATE Latin1_General_100_CI_AS AS [ZoneIdRaw],

        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(100), [CountryCode]))),
            N''
        ) COLLATE Latin1_General_100_CI_AS AS [CountryCode],

        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(500), [ZoneId]))),
            N''
        ) COLLATE Latin1_General_100_CI_AS AS [ZoneId]
    FROM [reporting].[AssessmentRegimeZone]
),
CTE_available_zones AS
(
    -- Zones included in the current R3 submission.
    SELECT DISTINCT
        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(100), [CountryCode]))),
            N''
        ) COLLATE Latin1_General_100_CI_AS AS [CountryCode],

        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(500), [ZoneId]))),
            N''
        ) COLLATE Latin1_General_100_CI_AS AS [ZoneId]
    FROM [reporting].[ZoneGeometry]

    UNION

    -- Zones available in the reference dataset.
    SELECT DISTINCT
        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(100), [CountryCode]))),
            N''
        ) COLLATE Latin1_General_100_CI_AS AS [CountryCode],

        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(500), [ZoneId]))),
            N''
        ) COLLATE Latin1_General_100_CI_AS AS [ZoneId]
    FROM [reference].[ZoneGeometry]
)
SELECT
    arz.[CountryCodeRaw] AS [CountryCode],
    arz.[AssessmentRegimeId],
    arz.[ZoneIdRaw] AS [ZoneId],
    'ZONEID_NOT_FOUND_IN_CURRENT_OR_REFERENCE_ZONEGEOMETRY'
        AS [QC_FailureReason]
FROM CTE_assessment_regime_zone AS arz
LEFT JOIN CTE_available_zones AS zog
    ON zog.[CountryCode] COLLATE Latin1_General_100_CI_AS
       = arz.[CountryCode] COLLATE Latin1_General_100_CI_AS
   AND zog.[ZoneId] COLLATE Latin1_General_100_CI_AS
       = arz.[ZoneId] COLLATE Latin1_General_100_CI_AS
WHERE arz.[ZoneId] IS NOT NULL
  AND zog.[ZoneId] IS NULL;
GO


