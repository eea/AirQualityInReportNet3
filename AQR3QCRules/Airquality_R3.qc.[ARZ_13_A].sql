USE [Airquality_R3]
GO

/****** Object:  View [qctesting].[ARZ_13_A]    Script Date: 01/09/2026 07:54:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[ARZ_13_A] AS

-- Creation date: 31/08/2026
-- QC rule code: ARZ_13_A
-- QC rule name: ARZ_ 13_A

WITH CTE_assesmentRegineZone AS
(
    SELECT
        [CountryCode],
        [AssessmentThresholdExceedance] AS [AssessmentThresholdExceedanceRaw],
        [AssessmentRegimeId],
        NULLIF(LTRIM(RTRIM([AssessmentThresholdExceedance])), '') AS [AssessmentThresholdExceedance]
    FROM [reporting].[AssessmentRegimeZone]
),
CTE_valid_AssessmentZones_types AS
(
    SELECT DISTINCT
        LOWER(LTRIM(RTRIM([Notation]))) COLLATE Latin1_General_CI_AS
            AS [AssessmentThresholdExceedanceConcept]
    FROM [qctesting].[Vocabulary]
    WHERE [vocabulary] = 'assessmentthresholdexceedance'
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
            AS [AssessmentThresholdExceedanceConcept]
    FROM [qctesting].[Vocabulary]
    WHERE [vocabulary] = 'assessmentthresholdexceedance'
      AND [Status] = 'Valid'
      AND [URI] IS NOT NULL
      AND CHARINDEX('/', [URI]) > 0
)
SELECT DISTINCT
    d.[CountryCode],
    d.[AssessmentThresholdExceedanceRaw] AS [AssessmentThresholdExceedance],
    d.[AssessmentRegimeId],
    CASE
        WHEN d.[AssessmentThresholdExceedance] IS NULL
            THEN 'MISSING_OR_EMPTY_ASSESSMENTTHRESHOLDEXCEEDANCE'
        WHEN v.[AssessmentThresholdExceedanceConcept] IS NULL
            THEN 'INVALID_ASSESSMENTTHRESHOLDEXCEEDANCE_VOCABULARY'
        ELSE 'UNKNOWN'
    END AS [QC_FailureReason]
FROM CTE_assesmentRegineZone AS d
LEFT JOIN CTE_valid_AssessmentZones_types AS v
    ON LOWER(d.[AssessmentThresholdExceedance]) COLLATE Latin1_General_CI_AS
     = v.[AssessmentThresholdExceedanceConcept]
WHERE
    d.[AssessmentThresholdExceedance] IS NULL
    OR v.[AssessmentThresholdExceedanceConcept] IS NULL;
GO