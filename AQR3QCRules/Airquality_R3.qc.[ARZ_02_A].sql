USE [Airquality_R3]
GO

/****** Object:  View [qc].[ARZ_02_A]    Script Date: 07/09/2026 13:37:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   VIEW [qc].[ARZ_02_A]
AS
-- QC rule code: ARZ_02_A
-- QC rule name: Uniqueness validation - [AssessmentRegimeId]
--
-- Returns AssessmentRegimeZone records where AssessmentRegimeId is
-- missing, empty, or reused within the same CountryCode in the current
-- delivery.
--
-- The uniqueness check is performed using the following combination:
--   CountryCode + AssessmentRegimeId
--
-- CountryCode is normalized by trimming leading/trailing spaces.
-- AssessmentRegimeId is normalized by trimming leading/trailing spaces.
--
-- CountryCode validity is checked separately by QC rule ARZ_01_A.

WITH CTE_source AS
(
    SELECT
        [CountryCode] AS [CountryCodeRaw],
        [AssessmentRegimeId] AS [AssessmentRegimeIdRaw],
        NULLIF(LTRIM(RTRIM([CountryCode])), '') AS [CountryCode],
        NULLIF(LTRIM(RTRIM([AssessmentRegimeId])), '') AS [AssessmentRegimeId]
    FROM [reporting].[AssessmentRegimeZone]
),
CTE_duplicate_assessment_regime_ids AS
(
    SELECT
        [CountryCode],
        [AssessmentRegimeId],
        COUNT(*) AS [DuplicateCount]
    FROM CTE_source
    WHERE [CountryCode] IS NOT NULL
      AND [AssessmentRegimeId] IS NOT NULL
    GROUP BY
        [CountryCode],
        [AssessmentRegimeId]
    HAVING COUNT(*) > 1
)
SELECT
    s.[CountryCodeRaw] AS [CountryCode],
    s.[AssessmentRegimeIdRaw] AS [AssessmentRegimeId],
    d.[DuplicateCount],
    CASE
        -- AssessmentRegimeId is mandatory.
        WHEN s.[AssessmentRegimeId] IS NULL
            THEN 'MISSING_OR_EMPTY_ASSESSMENTREGIMEID'

        -- The same AssessmentRegimeId must not be reused for the same
        -- CountryCode within the current delivery.
        WHEN d.[AssessmentRegimeId] IS NOT NULL
            THEN 'DUPLICATE_ASSESSMENTREGIMEID_WITHIN_COUNTRYCODE'

        ELSE 'UNKNOWN'
    END AS [QC_FailureReason]
FROM CTE_source AS s
LEFT JOIN CTE_duplicate_assessment_regime_ids AS d
    ON d.[CountryCode] = s.[CountryCode]
   AND d.[AssessmentRegimeId] = s.[AssessmentRegimeId]
WHERE
    s.[AssessmentRegimeId] IS NULL
    OR d.[AssessmentRegimeId] IS NOT NULL;
GO


