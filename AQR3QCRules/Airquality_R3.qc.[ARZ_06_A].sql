USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qc].[ARZ_06_A] AS

-- Creation date: 31/08/2026
-- QC rule code: ARZ_06_A
-- QC rule name: ARZ_ 06_A

WITH CTE_assesmentRegineZone AS
(
    SELECT
        [CountryCode],
        [ZoneCategory] AS [ZoneCategoryRaw],
        [AssessmentRegimeId],
        NULLIF(LTRIM(RTRIM([ZoneCategory])), '') AS [ZoneCategory]
    FROM [reporting].[AssessmentRegimeZone]
),
CTE_valid_AssessmentZones_types AS
(
    SELECT DISTINCT
        LOWER(LTRIM(RTRIM([Notation]))) COLLATE Latin1_General_CI_AS
            AS [ZoneTypeConcept]
    FROM [qctesting].[Vocabulary]
    WHERE [vocabulary] = 'zonecategory'
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
            AS [ZoneTypeConcept]
    FROM [qctesting].[Vocabulary]
    WHERE [vocabulary] = 'zonecategory'
      AND [Status] = 'Valid'
      AND [URI] IS NOT NULL
      AND CHARINDEX('/', [URI]) > 0
)
SELECT DISTINCT
    d.[CountryCode],
    d.[ZoneCategoryRaw] AS [ZoneCategory],
    d.[AssessmentRegimeId],
    CASE
        WHEN d.[ZoneCategory] IS NULL
            THEN 'MISSING_OR_EMPTY_DOCUMENTTYPE'
        WHEN v.[ZoneTypeConcept] IS NULL
            THEN 'INVALID_DOCUMENTTYPE_VOCABULARY'
        ELSE 'UNKNOWN'
    END AS [QC_FailureReason]
FROM CTE_assesmentRegineZone AS d
LEFT JOIN CTE_valid_AssessmentZones_types AS v
    ON LOWER(d.[ZoneCategory]) COLLATE Latin1_General_CI_AS
     = v.[ZoneTypeConcept]
WHERE
    d.[ZoneCategory] IS NULL
    OR v.[ZoneTypeConcept] IS NULL;
GO