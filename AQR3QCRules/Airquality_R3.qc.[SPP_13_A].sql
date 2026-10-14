USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPP_13_A]    Script Date: 13/10/2026 11:03:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   VIEW [qc].[SPP_13_A]
-- Creation date: August 2025
-- QC rule code: SPP_13_A
-- QC rule name: SPP_13_A Cross-check - [EquivalenceDemonstrationDocumentId]
-- QC rule description: The EquivalenceDemonstrationDocumentId must exist as a DocumentId in the Documentation table, either within the current R3 submission or in the reference dataset.
AS
WITH sp AS
(
    SELECT
        [CountryCode],
        [AssessmentMethodId],
        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(100), [CountryCode]))),
            N''
        ) COLLATE Latin1_General_CI_AS AS [CountryCode_norm],
        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(200), [EquivalenceDemonstrationDocumentId]))),
            N''
        ) COLLATE Latin1_General_CI_AS AS [EquivalenceDemonstrationDocumentId]
    FROM [reporting].[SamplingProcess]
),
doc_r AS
(
    SELECT DISTINCT
        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(100), [CountryCode]))),
            N''
        ) COLLATE Latin1_General_CI_AS AS [CountryCode],
        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(200), [DocumentId]))),
            N''
        ) COLLATE Latin1_General_CI_AS AS [DocumentId]
    FROM [reporting].[Documentation]
),
doc_ref AS
(
    SELECT DISTINCT
        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(100), [CountryCode]))),
            N''
        ) COLLATE Latin1_General_CI_AS AS [CountryCode],
        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(200), [DocumentId]))),
            N''
        ) COLLATE Latin1_General_CI_AS AS [DocumentId]
    FROM [reference].[Documentation]
)
SELECT
    s.[CountryCode],
    s.[AssessmentMethodId],
    s.[EquivalenceDemonstrationDocumentId]
FROM sp AS s
WHERE s.[EquivalenceDemonstrationDocumentId] IS NULL
   OR
   (
       NOT EXISTS
       (
           SELECT 1
           FROM doc_r AS r
           WHERE r.[CountryCode] = s.[CountryCode_norm]
             AND r.[DocumentId] = s.[EquivalenceDemonstrationDocumentId]
       )
       AND NOT EXISTS
       (
           SELECT 1
           FROM doc_ref AS f
           WHERE f.[CountryCode] = s.[CountryCode_norm]
             AND f.[DocumentId] = s.[EquivalenceDemonstrationDocumentId]
       )
   );
GO


