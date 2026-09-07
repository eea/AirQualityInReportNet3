USE [Airquality_R3]
GO

/****** Object:  View [qc].[ARZ_02_B]    Script Date: 07/09/2026 13:37:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   VIEW [qc].[ARZ_02_B]
AS
-- QC rule code: ARZ_02_B
-- QC rule name: Naming convention validation - [AssessmentRegimeId]
--
-- Returns AssessmentRegimeZone records where AssessmentRegimeId does not
-- follow the recommended assessment regime identifier convention:
--
--   ARE_{ZoneId}_{PollutantId}_{ObjectiveType}_{ProtectionTarget}_
--   {ReportingMetric}_{ClassificationYear}[_{Index}]
--
-- Assumptions:
--   - Components are separated by underscore characters.
--   - PollutantId is represented using exactly four digits.
--   - ClassificationYear is represented using exactly four digits (YYYY).
--   - Index is optional. When reported, it is separated by an underscore
--     and has a maximum length of one character.
--
-- ZoneId may contain underscore characters. Therefore, ZoneId is not parsed
-- from AssessmentRegimeId. The expected identifier is instead built from
-- the attribute values reported in the same record.
--
-- Related attribute mappings:
--   ARZ_03 = ZoneId
--   ARZ_09 = PollutantId
--   ARZ_10 = ProtectionTarget
--   ARZ_11 = ObjectiveType
--   ARZ_12 = ReportingMetric
--   ARZ_18 = ClassificationYear
--
-- Mandatory-value validation for AssessmentRegimeId is also covered by
-- QC rule ARZ_02_A.

WITH CTE_source AS
(
    SELECT
        [CountryCode] COLLATE Latin1_General_CI_AS AS [CountryCode],

        [AssessmentRegimeId] COLLATE Latin1_General_CI_AS
            AS [AssessmentRegimeIdRaw],

        [ZoneId] COLLATE Latin1_General_CI_AS
            AS [ZoneId],

        [PollutantId] AS [PollutantId],

        CONVERT(NVARCHAR(100), [ObjectiveType])
            COLLATE Latin1_General_CI_AS AS [ObjectiveType],

        CONVERT(NVARCHAR(100), [ProtectionTarget])
            COLLATE Latin1_General_CI_AS AS [ProtectionTarget],

        CONVERT(NVARCHAR(100), [ReportingMetric])
            COLLATE Latin1_General_CI_AS AS [ReportingMetric],

        [ClassificationYear] AS [ClassificationYear],

        NULLIF
        (
            LTRIM(RTRIM([AssessmentRegimeId])) COLLATE Latin1_General_CI_AS,
            N''
        ) COLLATE Latin1_General_CI_AS AS [AssessmentRegimeId],

        NULLIF
        (
            LTRIM(RTRIM([ZoneId])) COLLATE Latin1_General_CI_AS,
            N''
        ) COLLATE Latin1_General_CI_AS AS [ZoneIdNormalized],

        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(100), [ObjectiveType])))
                COLLATE Latin1_General_CI_AS,
            N''
        ) COLLATE Latin1_General_CI_AS AS [ObjectiveTypeNormalized],

        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(100), [ProtectionTarget])))
                COLLATE Latin1_General_CI_AS,
            N''
        ) COLLATE Latin1_General_CI_AS AS [ProtectionTargetNormalized],

        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(100), [ReportingMetric])))
                COLLATE Latin1_General_CI_AS,
            N''
        ) COLLATE Latin1_General_CI_AS AS [ReportingMetricNormalized],

        TRY_CONVERT(INT, [PollutantId]) AS [PollutantIdNumeric],

        TRY_CONVERT(INT, [ClassificationYear]) AS [ClassificationYearNumeric]
    FROM [reporting].[AssessmentRegimeZone]
),
CTE_expected_identifier AS
(
    SELECT
        s.*,
        CASE
            WHEN s.[ZoneIdNormalized] IS NOT NULL
             AND s.[PollutantIdNumeric] BETWEEN 0 AND 9999
             AND s.[ObjectiveTypeNormalized] IS NOT NULL
             AND s.[ProtectionTargetNormalized] IS NOT NULL
             AND s.[ReportingMetricNormalized] IS NOT NULL
             AND s.[ClassificationYearNumeric] BETWEEN 1000 AND 9999
            THEN
                CONCAT
                (
                    N'ARE_' COLLATE Latin1_General_CI_AS,
                    s.[ZoneIdNormalized] COLLATE Latin1_General_CI_AS,
                    N'_' COLLATE Latin1_General_CI_AS,
                    RIGHT
                    (
                        N'0000' + CONVERT(NVARCHAR(4), s.[PollutantIdNumeric]),
                        4
                    ) COLLATE Latin1_General_CI_AS,
                    N'_' COLLATE Latin1_General_CI_AS,
                    s.[ObjectiveTypeNormalized] COLLATE Latin1_General_CI_AS,
                    N'_' COLLATE Latin1_General_CI_AS,
                    s.[ProtectionTargetNormalized] COLLATE Latin1_General_CI_AS,
                    N'_' COLLATE Latin1_General_CI_AS,
                    s.[ReportingMetricNormalized] COLLATE Latin1_General_CI_AS,
                    N'_' COLLATE Latin1_General_CI_AS,
                    CONVERT(NVARCHAR(4), s.[ClassificationYearNumeric])
                        COLLATE Latin1_General_CI_AS
                ) COLLATE Latin1_General_CI_AS
            ELSE NULL
        END AS [ExpectedAssessmentRegimeId]
    FROM CTE_source AS s
),
CTE_validation AS
(
    SELECT
        e.*,
        CASE
            -- The identifier exactly matches the recommended base structure.
            WHEN e.[AssessmentRegimeId] COLLATE Latin1_General_CI_AS
                 = e.[ExpectedAssessmentRegimeId] COLLATE Latin1_General_CI_AS
                THEN 1

            -- The identifier matches the base structure followed by:
            --   _{Index}
            -- where Index contains exactly one character.
            WHEN LEN(e.[AssessmentRegimeId] COLLATE Latin1_General_CI_AS)
                 = LEN(e.[ExpectedAssessmentRegimeId] COLLATE Latin1_General_CI_AS) + 2
             AND LEFT
                 (
                     e.[AssessmentRegimeId] COLLATE Latin1_General_CI_AS,
                     LEN(e.[ExpectedAssessmentRegimeId] COLLATE Latin1_General_CI_AS)
                 ) COLLATE Latin1_General_CI_AS
                 = e.[ExpectedAssessmentRegimeId] COLLATE Latin1_General_CI_AS
             AND SUBSTRING
                 (
                     e.[AssessmentRegimeId] COLLATE Latin1_General_CI_AS,
                     LEN(e.[ExpectedAssessmentRegimeId] COLLATE Latin1_General_CI_AS) + 1,
                     1
                 ) COLLATE Latin1_General_CI_AS
                 = N'_' COLLATE Latin1_General_CI_AS
                THEN 1

            ELSE 0
        END AS [IsValidAssessmentRegimeId]
    FROM CTE_expected_identifier AS e
)
SELECT
    [CountryCode],
    [AssessmentRegimeIdRaw] AS [AssessmentRegimeId],
    [ZoneId],
    [PollutantId],
    [ObjectiveType],
    [ProtectionTarget],
    [ReportingMetric],
    [ClassificationYear],
    [ExpectedAssessmentRegimeId],
    CASE
        WHEN [AssessmentRegimeId] IS NULL
            THEN 'MISSING_OR_EMPTY_ASSESSMENTREGIMEID'

        WHEN [ExpectedAssessmentRegimeId] IS NULL
            THEN 'MISSING_OR_INVALID_IDENTIFIER_COMPONENT'

        WHEN [IsValidAssessmentRegimeId] = 0
            THEN 'INVALID_ASSESSMENTREGIMEID_NAMING_CONVENTION'

        ELSE 'UNKNOWN'
    END AS [QC_FailureReason]
FROM CTE_validation
WHERE
    [AssessmentRegimeId] IS NULL
    OR [ExpectedAssessmentRegimeId] IS NULL
    OR [IsValidAssessmentRegimeId] = 0;
GO


