USE [Airquality_R3]
GO

/****** Object:  View [qc].[ARZ_02_D]    Script Date: 07/09/2026 13:37:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   VIEW [qc].[ARZ_02_D]
AS
-- QC rule code: ARZ_02_D
-- QC rule name: Reference consistency validation - [AssessmentRegimeId]
--
-- Returns reference AssessmentRegimeZone records where the same
-- AssessmentRegimeId is associated with more than one environmental
-- objective combination across reporting cycles.
--
-- The environmental objective is defined by the following attributes:
--   - PollutantId
--   - ObjectiveType
--   - ProtectionTarget
--   - ReportingMetric
--
-- The check is performed against the reference dataset:
--   reference.AssessmentRegimeZone
--
-- AssessmentRegimeId missing-value validation is covered separately
-- by QC rule ARZ_02_A.
--
-- Leading and trailing spaces are ignored. Text comparisons are
-- case-insensitive.

WITH CTE_source AS
(
    SELECT
        [CountryCode] COLLATE Latin1_General_100_CI_AS
            AS [CountryCode],

        [ReportingYear] AS [ReportingYear],

        [AssessmentRegimeId] COLLATE Latin1_General_100_CI_AS
            AS [AssessmentRegimeIdRaw],

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
    FROM [reference].[AssessmentRegimeZone]
),
CTE_distinct_environmental_objectives AS
(
    -- One row per different environmental objective associated with
    -- each AssessmentRegimeId.
    SELECT DISTINCT
        [AssessmentRegimeId],
        [PollutantId],
        [ObjectiveType],
        [ProtectionTarget],
        [ReportingMetric]
    FROM CTE_source
    WHERE [AssessmentRegimeId] IS NOT NULL
),
CTE_inconsistent_assessment_regime_ids AS
(
    SELECT
        [AssessmentRegimeId],
        COUNT(*) AS [DifferentEnvironmentalObjectiveCount]
    FROM CTE_distinct_environmental_objectives
    GROUP BY [AssessmentRegimeId]
    HAVING COUNT(*) > 1
)
SELECT
    s.[CountryCode],
    s.[ReportingYear],
    s.[AssessmentRegimeIdRaw] AS [AssessmentRegimeId],
    s.[PollutantIdRaw] AS [PollutantId],
    s.[ObjectiveTypeRaw] AS [ObjectiveType],
    s.[ProtectionTargetRaw] AS [ProtectionTarget],
    s.[ReportingMetricRaw] AS [ReportingMetric],
    i.[DifferentEnvironmentalObjectiveCount],
    'ASSESSMENTREGIMEID_ASSOCIATED_WITH_MULTIPLE_ENVIRONMENTAL_OBJECTIVES'
        AS [QC_FailureReason]
FROM CTE_source AS s
INNER JOIN CTE_inconsistent_assessment_regime_ids AS i
    ON i.[AssessmentRegimeId] = s.[AssessmentRegimeId];
GO


