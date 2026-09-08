USE [Airquality_R3]
GO

/****** Object:  View [qctesting].[ARZ_12_A]    Script Date: 01/09/2026 07:54:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[ARZ_12_A] AS

-- Creation date: 31/08/2026
-- QC rule code: ARZ_12_A
-- QC rule name: ARZ_ 12_A

WITH CTE_assesmentRegineZone AS
(
    SELECT
        [CountryCode],
        [ReportingMetric] AS [ReportingMetricRaw],
        [AssessmentRegimeId],
        NULLIF(LTRIM(RTRIM([ReportingMetric])), '') AS [ReportingMetric]
    FROM [reporting].[AssessmentRegimeZone]
),
CTE_valid_AssessmentZones_types AS
(
    SELECT DISTINCT
        LOWER(LTRIM(RTRIM([Notation]))) COLLATE Latin1_General_CI_AS
            AS [ReportingMetricConcept]
    FROM [qctesting].[Vocabulary]
    WHERE [vocabulary] = 'reportingmetric'
      AND [Status] = 'Valid'
      AND NULLIF(LTRIM(RTRIM([Notation])), '') IS NOT NULL

    UNION

    SELECT DISTINCT
        LOWER(
            RIGHT(
                [URI],
                CHARINDEX('/', REVERSE([URI])) - 1
            )
        ) COLLATE Latin1_General_CI_AS
            AS [ReportingMetricConcept]
    FROM [qctesting].[Vocabulary]
    WHERE [vocabulary] = 'reportingmetric'
      AND [Status] = 'Valid'
      AND [URI] IS NOT NULL
      AND CHARINDEX('/', [URI]) > 0
)
SELECT DISTINCT
    d.[CountryCode],
    d.[ReportingMetricRaw] AS [ReportingMetric],
    d.[AssessmentRegimeId],
    CASE
        WHEN d.[ReportingMetric] IS NULL
            THEN 'MISSING_OR_EMPTY_REPORTINGMETRIC'
        WHEN v.[ReportingMetricConcept] IS NULL
            THEN 'INVALID_REPORTINGMETRIC_VOCABULARY'
        ELSE 'UNKNOWN'
    END AS [QC_FailureReason]
FROM CTE_assesmentRegineZone AS d
LEFT JOIN CTE_valid_AssessmentZones_types AS v
    ON LOWER(d.[ReportingMetric]) COLLATE Latin1_General_CI_AS
     = v.[ReportingMetricConcept]
WHERE
    d.[ReportingMetric] IS NULL
    OR v.[ReportingMetricConcept] IS NULL;
GO