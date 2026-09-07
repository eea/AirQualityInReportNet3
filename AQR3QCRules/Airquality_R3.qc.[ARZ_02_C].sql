USE [Airquality_R3]
GO

/****** Object:  View [qc].[ARZ_02_C]    Script Date: 07/09/2026 13:37:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   VIEW [qc].[ARZ_02_C]
AS
-- QC rule code: ARZ_02_C
-- QC rule name: Environmental objective validation
--
-- Returns AssessmentRegimeZone records where the combination of:
--   - PollutantId
--   - ObjectiveType
--   - ProtectionTarget
--   - ReportingMetric
--
-- does not correspond to a valid environmental objective defined in
-- reference.Vocabulary.
--
-- Valid environmental objectives are obtained from reference.Vocabulary,
-- using:
--   - vocabulary = 'environmentalobjective'
--   - Status = 'Valid'
--   - Label containing the environmental objective components
--
-- Expected Label format:
--   Pollutant {PollutantId}, Objective type {ObjectiveType},
--   Metric {ReportingMetric}, Target {ProtectionTarget}
--
-- Notation is the internal identifier of the environmental objective and
-- is returned for traceability after a valid combination is found.

WITH CTE_source AS
(
    SELECT
        CONVERT(NVARCHAR(100), [CountryCode])
            COLLATE Latin1_General_100_CI_AS AS [CountryCode],

        CONVERT(NVARCHAR(100), [AssessmentRegimeId])
            COLLATE Latin1_General_100_CI_AS AS [AssessmentRegimeId],

        [PollutantId] AS [PollutantIdRaw],

        CONVERT(NVARCHAR(100), [ObjectiveType])
            COLLATE Latin1_General_100_CI_AS AS [ObjectiveTypeRaw],

        CONVERT(NVARCHAR(100), [ProtectionTarget])
            COLLATE Latin1_General_100_CI_AS AS [ProtectionTargetRaw],

        CONVERT(NVARCHAR(100), [ReportingMetric])
            COLLATE Latin1_General_100_CI_AS AS [ReportingMetricRaw],

        TRY_CONVERT(INT, [PollutantId]) AS [PollutantId],

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
CTE_environmental_objective_labels AS
(
    SELECT
        CONVERT(NVARCHAR(100), [Notation])
            COLLATE Latin1_General_100_CI_AS AS [EnvironmentalObjectiveNotation],

        CONVERT(NVARCHAR(MAX), [Label])
            COLLATE Latin1_General_100_CI_AS AS [EnvironmentalObjectiveLabel]
    FROM [reference].[Vocabulary]
    WHERE [vocabulary] = 'environmentalobjective'
      AND [Status] = 'Valid'
      AND NULLIF(LTRIM(RTRIM(CONVERT(NVARCHAR(MAX), [Label]))), N'') IS NOT NULL
),
CTE_valid_environmental_objectives AS
(
    SELECT DISTINCT
        e.[EnvironmentalObjectiveNotation],

        TRY_CONVERT
        (
            INT,
            SUBSTRING
            (
                e.[EnvironmentalObjectiveLabel],
                LEN(N'Pollutant ') + 1,
                p.[ObjectiveTypeStart] - (LEN(N'Pollutant ') + 1)
            )
        ) AS [PollutantId],

        LTRIM(RTRIM(SUBSTRING
        (
            e.[EnvironmentalObjectiveLabel],
            p.[ObjectiveTypeStart] + LEN(N', Objective type '),
            p.[MetricStart] -
                (p.[ObjectiveTypeStart] + LEN(N', Objective type '))
        ))) COLLATE Latin1_General_100_CI_AS AS [ObjectiveType],

        LTRIM(RTRIM(SUBSTRING
        (
            e.[EnvironmentalObjectiveLabel],
            p.[MetricStart] + LEN(N', Metric '),
            p.[TargetStart] -
                (p.[MetricStart] + LEN(N', Metric '))
        ))) COLLATE Latin1_General_100_CI_AS AS [ReportingMetric],

        LTRIM(RTRIM(SUBSTRING
        (
            e.[EnvironmentalObjectiveLabel],
            p.[TargetStart] + LEN(N', Target '),
            LEN(e.[EnvironmentalObjectiveLabel])
        ))) COLLATE Latin1_General_100_CI_AS AS [ProtectionTarget]
    FROM CTE_environmental_objective_labels AS e
    CROSS APPLY
    (
        SELECT
            CHARINDEX
            (
                N', Objective type ',
                e.[EnvironmentalObjectiveLabel]
                    COLLATE Latin1_General_100_CI_AS
            ) AS [ObjectiveTypeStart],

            CHARINDEX
            (
                N', Metric ',
                e.[EnvironmentalObjectiveLabel]
                    COLLATE Latin1_General_100_CI_AS
            ) AS [MetricStart],

            CHARINDEX
            (
                N', Target ',
                e.[EnvironmentalObjectiveLabel]
                    COLLATE Latin1_General_100_CI_AS
            ) AS [TargetStart]
    ) AS p
    WHERE e.[EnvironmentalObjectiveLabel]
              COLLATE Latin1_General_100_CI_AS LIKE N'Pollutant %'
      AND p.[ObjectiveTypeStart] > LEN(N'Pollutant ')
      AND p.[MetricStart] > p.[ObjectiveTypeStart]
      AND p.[TargetStart] > p.[MetricStart]
),
CTE_validation AS
(
    SELECT
        s.*,
        v.[EnvironmentalObjectiveNotation]
    FROM CTE_source AS s
    LEFT JOIN CTE_valid_environmental_objectives AS v
        ON v.[PollutantId] = s.[PollutantId]
       AND v.[ObjectiveType] COLLATE Latin1_General_100_CI_AS
           = s.[ObjectiveType] COLLATE Latin1_General_100_CI_AS
       AND v.[ProtectionTarget] COLLATE Latin1_General_100_CI_AS
           = s.[ProtectionTarget] COLLATE Latin1_General_100_CI_AS
       AND v.[ReportingMetric] COLLATE Latin1_General_100_CI_AS
           = s.[ReportingMetric] COLLATE Latin1_General_100_CI_AS
)
SELECT
    [CountryCode],
    [AssessmentRegimeId],
    [PollutantIdRaw] AS [PollutantId],
    [ObjectiveTypeRaw] AS [ObjectiveType],
    [ProtectionTargetRaw] AS [ProtectionTarget],
    [ReportingMetricRaw] AS [ReportingMetric],
    [EnvironmentalObjectiveNotation],
    CASE
        -- All components are required to validate the environmental objective.
        WHEN [PollutantId] IS NULL
          OR [ObjectiveType] IS NULL
          OR [ProtectionTarget] IS NULL
          OR [ReportingMetric] IS NULL
            THEN 'MISSING_OR_INVALID_ENVIRONMENTAL_OBJECTIVE_COMPONENT'

        -- The reported component combination does not exist in the
        -- environmental objective reference vocabulary.
        WHEN [EnvironmentalObjectiveNotation] IS NULL
            THEN 'INVALID_ENVIRONMENTAL_OBJECTIVE_COMBINATION'

        ELSE 'UNKNOWN'
    END AS [QC_FailureReason]
FROM CTE_validation
WHERE
    [PollutantId] IS NULL
    OR [ObjectiveType] IS NULL
    OR [ProtectionTarget] IS NULL
    OR [ReportingMetric] IS NULL
    OR [EnvironmentalObjectiveNotation] IS NULL;
GO


