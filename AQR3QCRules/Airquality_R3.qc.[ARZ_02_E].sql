USE [Airquality_R3]
GO

/****** Object:  View [qc].[ARZ_02_E]    Script Date: 07/09/2026 13:38:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   VIEW [qc].[ARZ_02_E]
AS
-- QC rule code: ARZ_02_E
-- QC rule name: AssessmentRegimeId consistency validation within submission
--
-- Returns AssessmentRegimeZone records where the same AssessmentRegimeId
-- is associated with different ZoneId values and/or different environmental
-- objective combinations within the current R3 submission.
--
-- The environmental objective is defined by:
--   - PollutantId
--   - ObjectiveType
--   - ProtectionTarget
--   - ReportingMetric
--
-- The validation is performed against:
--   reporting.AssessmentRegimeZone
--
-- AssessmentRegimeId mandatory-value validation is covered separately by
-- QC rule ARZ_02_A.
--
-- Leading and trailing spaces are ignored.
-- Text comparisons are case-insensitive.

WITH CTE_source AS
(
    SELECT
        CONVERT(NVARCHAR(100), [CountryCode])
            COLLATE Latin1_General_100_CI_AS AS [CountryCode],

        CONVERT(NVARCHAR(500), [AssessmentRegimeId])
            COLLATE Latin1_General_100_CI_AS AS [AssessmentRegimeIdRaw],

        CONVERT(NVARCHAR(500), [ZoneId])
            COLLATE Latin1_General_100_CI_AS AS [ZoneIdRaw],

        [PollutantId] AS [PollutantIdRaw],

        CONVERT(NVARCHAR(100), [ObjectiveType])
            COLLATE Latin1_General_100_CI_AS AS [ObjectiveTypeRaw],

        CONVERT(NVARCHAR(100), [ProtectionTarget])
            COLLATE Latin1_General_100_CI_AS AS [ProtectionTargetRaw],

        CONVERT(NVARCHAR(100), [ReportingMetric])
            COLLATE Latin1_General_100_CI_AS AS [ReportingMetricRaw],

        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(500), [AssessmentRegimeId]))),
            N''
        ) COLLATE Latin1_General_100_CI_AS AS [AssessmentRegimeId],

        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(500), [ZoneId]))),
            N''
        ) COLLATE Latin1_General_100_CI_AS AS [ZoneId],

        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(100), [PollutantId]))),
            N''
        ) COLLATE Latin1_General_100_CI_AS AS [PollutantId],

        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(100), [ObjectiveType]))),
            N''
        ) COLLATE Latin1_General_100_CI_AS AS [ObjectiveType],

        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(100), [ProtectionTarget]))),
            N''
        ) COLLATE Latin1_General_100_CI_AS AS [ProtectionTarget],

        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(100), [ReportingMetric]))),
            N''
        ) COLLATE Latin1_General_100_CI_AS AS [ReportingMetric]
    FROM [reporting].[AssessmentRegimeZone]
),
CTE_distinct_assessment_regime_definitions AS
(
    -- One row per different ZoneId and environmental objective combination
    -- associated with each AssessmentRegimeId.
    SELECT DISTINCT
        [AssessmentRegimeId],
        COALESCE([ZoneId], N'<NULL>') COLLATE Latin1_General_100_CI_AS
            AS [ZoneId],
        COALESCE([PollutantId], N'<NULL>') COLLATE Latin1_General_100_CI_AS
            AS [PollutantId],
        COALESCE([ObjectiveType], N'<NULL>') COLLATE Latin1_General_100_CI_AS
            AS [ObjectiveType],
        COALESCE([ProtectionTarget], N'<NULL>') COLLATE Latin1_General_100_CI_AS
            AS [ProtectionTarget],
        COALESCE([ReportingMetric], N'<NULL>') COLLATE Latin1_General_100_CI_AS
            AS [ReportingMetric]
    FROM CTE_source
    WHERE [AssessmentRegimeId] IS NOT NULL
),
CTE_assessment_regime_counts AS
(
    SELECT
        [AssessmentRegimeId],
        COUNT(DISTINCT [ZoneId]) AS [DifferentZoneCount],
        COUNT(*) AS [DifferentAssessmentRegimeDefinitionCount]
    FROM CTE_distinct_assessment_regime_definitions
    GROUP BY [AssessmentRegimeId]
),
CTE_inconsistent_assessment_regime_ids AS
(
    SELECT
        [AssessmentRegimeId],
        [DifferentZoneCount],
        [DifferentAssessmentRegimeDefinitionCount]
    FROM CTE_assessment_regime_counts
    WHERE [DifferentZoneCount] > 1
       OR [DifferentAssessmentRegimeDefinitionCount] > 1
)
SELECT
    s.[CountryCode],
    s.[AssessmentRegimeIdRaw] AS [AssessmentRegimeId],
    s.[ZoneIdRaw] AS [ZoneId],
    s.[PollutantIdRaw] AS [PollutantId],
    s.[ObjectiveTypeRaw] AS [ObjectiveType],
    s.[ProtectionTargetRaw] AS [ProtectionTarget],
    s.[ReportingMetricRaw] AS [ReportingMetric],
    i.[DifferentZoneCount],
    i.[DifferentAssessmentRegimeDefinitionCount],
    CASE
        -- The identifier is associated with more than one ZoneId.
        WHEN i.[DifferentZoneCount] > 1
         AND i.[DifferentAssessmentRegimeDefinitionCount] > 1
            THEN 'ASSESSMENTREGIMEID_REUSED_FOR_DIFFERENT_ZONE_AND_ENVIRONMENTAL_OBJECTIVE'

        -- The identifier is associated with one ZoneId but different
        -- environmental objective combinations.
        WHEN i.[DifferentZoneCount] = 1
         AND i.[DifferentAssessmentRegimeDefinitionCount] > 1
            THEN 'ASSESSMENTREGIMEID_REUSED_FOR_DIFFERENT_ENVIRONMENTAL_OBJECTIVE'

        -- This condition is kept for completeness. In practice, changing
        -- ZoneId also changes the complete assessment regime definition.
        WHEN i.[DifferentZoneCount] > 1
            THEN 'ASSESSMENTREGIMEID_REUSED_FOR_DIFFERENT_ZONE'

        ELSE 'UNKNOWN'
    END AS [QC_FailureReason]
FROM CTE_source AS s
INNER JOIN CTE_inconsistent_assessment_regime_ids AS i
    ON i.[AssessmentRegimeId] = s.[AssessmentRegimeId];
GO


