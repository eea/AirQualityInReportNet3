USE [Airquality_R3]
GO

/****** Object:  View [qctesting].[ARZ_10_A]    Script Date: 01/09/2026 07:54:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER VIEW [qc].[ARZ_10_A] AS

-- Creation date: 31/08/2026
-- QC rule code: ARZ_10_A
-- QC rule name: ARZ_ 10_A

WITH CTE_assesmentRegineZone AS
(
    SELECT
        [CountryCode],
        [ProtectionTarget] AS [ProtectionTargetRaw],
        [AssessmentRegimeId],
        NULLIF(LTRIM(RTRIM([ProtectionTarget])), '') AS [ProtectionTarget]
    FROM [reporting].[AssessmentRegimeZone]
),
CTE_valid_AssessmentZones_types AS
(
    SELECT DISTINCT
        LOWER(LTRIM(RTRIM([Notation]))) COLLATE Latin1_General_CI_AS
            AS [ProtectionTargetConcept]
    FROM [qctesting].[Vocabulary]
    WHERE [vocabulary] = 'protectiontarget'
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
            AS [ProtectionTargetConcept]
    FROM [qctesting].[Vocabulary]
    WHERE [vocabulary] = 'protectiontarget'
      AND [Status] = 'Valid'
      AND [URI] IS NOT NULL
      AND CHARINDEX('/', [URI]) > 0
)
SELECT DISTINCT
    d.[CountryCode],
    d.[ProtectionTargetRaw] AS [ProtectionTarget],
    d.[AssessmentRegimeId],
    CASE
        WHEN d.[ProtectionTarget] IS NULL
            THEN 'MISSING_OR_EMPTY_PROTECTIONTARGET'
        WHEN v.[ProtectionTargetConcept] IS NULL
            THEN 'INVALID_PROTECTIONTARGET_VOCABULARY'
        ELSE 'UNKNOWN'
    END AS [QC_FailureReason]
FROM CTE_assesmentRegineZone AS d
LEFT JOIN CTE_valid_AssessmentZones_types AS v
    ON LOWER(d.[ProtectionTarget]) COLLATE Latin1_General_CI_AS
     = v.[ProtectionTargetConcept]
WHERE
    d.[ProtectionTarget] IS NULL
    OR v.[ProtectionTargetConcept] IS NULL;
GO