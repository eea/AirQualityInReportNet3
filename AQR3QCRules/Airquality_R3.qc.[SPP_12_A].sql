USE [Airquality_R3];
GO

/****** Object:  View [qc].[SPP_12_A2] ******/
SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

-- Creation date: July 2026
--QC code: SPP_12_A2
--QC name: SPP_12_A2 Cross-check - [DataQualityDocumentId]
--QC rule description: The DataQualityDocumentId must exist as a DocumentId in the Documentation table, either within the current R3 submission or in the reference dataset.

CREATE OR ALTER VIEW [qc].[SPP_12_A2]
AS
WITH sp AS
(
    SELECT
        NULLIF(
            LTRIM(RTRIM(CONVERT(nvarchar(100), [CountryCode]))),
            ''
        ) COLLATE Latin1_General_CI_AS AS [CountryCode],
        [AssessmentMethodId],
        NULLIF(
            LTRIM(RTRIM(CONVERT(nvarchar(200), [DataQualityDocumentId]))),
            ''
        ) COLLATE Latin1_General_CI_AS AS [DataQualityDocumentId]
    FROM [reporting].[SamplingProcess]
),
doc_r AS
(
    SELECT DISTINCT
        NULLIF(
            LTRIM(RTRIM(CONVERT(nvarchar(100), [CountryCode]))),
            ''
        ) COLLATE Latin1_General_CI_AS AS [CountryCode],
        NULLIF(
            LTRIM(RTRIM(CONVERT(nvarchar(200), [DocumentId]))),
            ''
        ) COLLATE Latin1_General_CI_AS AS [DocumentId]
    FROM [reporting].[Documentation]
),
doc_ref AS
(
    SELECT DISTINCT
        NULLIF(
            LTRIM(RTRIM(CONVERT(nvarchar(100), [CountryCode]))),
            ''
        ) COLLATE Latin1_General_CI_AS AS [CountryCode],
        NULLIF(
            LTRIM(RTRIM(CONVERT(nvarchar(200), [DocumentId]))),
            ''
        ) COLLATE Latin1_General_CI_AS AS [DocumentId]
    FROM [reference].[Documentation]
)
SELECT
    s.[CountryCode],
    s.[AssessmentMethodId],
    s.[DataQualityDocumentId]
FROM sp AS s
WHERE
    s.[DataQualityDocumentId] IS NULL
    OR
    (
        NOT EXISTS
        (
            SELECT 1
            FROM doc_r AS r
            WHERE r.[CountryCode] = s.[CountryCode]
              AND r.[DocumentId] = s.[DataQualityDocumentId]
        )
        AND NOT EXISTS
        (
            SELECT 1
            FROM doc_ref AS f
            WHERE f.[CountryCode] = s.[CountryCode]
              AND f.[DocumentId] = s.[DataQualityDocumentId]
        )
    );
GO