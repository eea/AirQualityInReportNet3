USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPP_14_A]    Script Date: 27/10/2026 08:15:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- Creation date: August 2025
-- QC rule code: SPP_14_A
-- QC rule name: SPP_14_A Cross-check - [ProcessDocumentId]
-- QC rule description: The ProcessDocumentId must exist as a DocumentId in the Documentation table, either within the current R3 submission or in the reference dataset.

CREATE   VIEW [qc].[SPP_14_A]
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
            LTRIM(RTRIM(CONVERT(nvarchar(200), [ProcessDocumentId]))),
            ''
        ) COLLATE Latin1_General_CI_AS AS [ProcessDocumentId]
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
    s.[ProcessDocumentId]
FROM sp AS s
WHERE
    s.[ProcessDocumentId] IS NULL
    OR
    (
        NOT EXISTS
        (
            SELECT 1
            FROM doc_r AS r
            WHERE r.[CountryCode] = s.[CountryCode]
              AND r.[DocumentId] = s.[ProcessDocumentId]
        )
        AND NOT EXISTS
        (
            SELECT 1
            FROM doc_ref AS f
            WHERE f.[CountryCode] = s.[CountryCode]
              AND f.[DocumentId] = s.[ProcessDocumentId]
        )
    );
GO


