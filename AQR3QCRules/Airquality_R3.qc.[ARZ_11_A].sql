USE [Airquality_R3]
GO

/****** Object:  View [qctesting].[ARZ_11_A]    Script Date: 01/09/2026 07:54:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER VIEW [qc].[ARZ_11_A] AS

-- Creation date: 31/08/2026
-- QC rule code: ARZ_11_A
-- QC rule name: ARZ_ 11_A

WITH CTE_assesmentRegineZone AS
(
    SELECT
        [CountryCode],
        [ObjectiveType] AS [ObjectiveTypeRaw],
        [AssessmentRegimeId],
        NULLIF(LTRIM(RTRIM([ObjectiveType])), '') AS [ObjectiveType]
    FROM [reporting].[AssessmentRegimeZone]
),
CTE_valid_AssessmentZones_types AS
(
    SELECT DISTINCT
        LOWER(LTRIM(RTRIM([Notation]))) COLLATE Latin1_General_CI_AS
            AS [ObjectiveTypeConcept]
    FROM [qctesting].[Vocabulary]
    WHERE [vocabulary] = 'objectivetype'
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
            AS [ObjectiveTypeConcept]
    FROM [qctesting].[Vocabulary]
    WHERE [vocabulary] = 'objectivetype'
      AND [Status] = 'Valid'
      AND [URI] IS NOT NULL
      AND CHARINDEX('/', [URI]) > 0
)
SELECT DISTINCT
    d.[CountryCode],
    d.[ObjectiveTypeRaw] AS [ObjectiveType],
    d.[AssessmentRegimeId],
    CASE
        WHEN d.[ObjectiveType] IS NULL
            THEN 'MISSING_OR_EMPTY_OBJECTIVETYPE'
        WHEN v.[ObjectiveTypeConcept] IS NULL
            THEN 'INVALID_OBJECTIVETYPE_VOCABULARY'
        ELSE 'UNKNOWN'
    END AS [QC_FailureReason]
FROM CTE_assesmentRegineZone AS d
LEFT JOIN CTE_valid_AssessmentZones_types AS v
    ON LOWER(d.[ObjectiveType]) COLLATE Latin1_General_CI_AS
     = v.[ObjectiveTypeConcept]
WHERE
    d.[ObjectiveType] IS NULL
    OR v.[ObjectiveTypeConcept] IS NULL;
GO