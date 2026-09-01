USE [Airquality_R3]
GO

/****** Object:  View [qc].[DOC_04_A]    Script Date: 01/09/2026 12:27:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [qc].[DOC_04_A]
AS
-- QC rule code: DOC_04_A
-- QC rule name: Uniqueness validation - [DocumentId]
--
-- Returns records where DocumentId is missing or where the same
-- CountryCode + DocumentId combination identifies different documents.

WITH CTE_source AS
(
    SELECT
        [CountryCode] AS [CountryCodeRaw],
        [DocumentId] AS [DocumentIdRaw],
        NULLIF(LTRIM(RTRIM([CountryCode])), '') AS [CountryCode],
        NULLIF(LTRIM(RTRIM([DocumentId])), '') AS [DocumentId],

        -- Document signature used to identify whether records with the
        -- same CountryCode and DocumentId represent different documents.
        CONCAT
        (
            N'DataTable=',
            COALESCE(LTRIM(RTRIM([DataTable])), N'<NULL>'),
            N'|DocumentType=',
            COALESCE(LTRIM(RTRIM([DocumentType])), N'<NULL>'),
            N'|DocumentAttachment=',
            COALESCE(LTRIM(RTRIM([DocumentAttachment])), N'<NULL>'),
            N'|DocumentOriginalURL=',
            COALESCE(LTRIM(RTRIM([DocumentOriginalURL])), N'<NULL>')
        ) AS [DocumentSignature]
    FROM [reporting].[Documentation]
),
CTE_reused_document_ids AS
(
    SELECT
        [CountryCode],
        [DocumentId],
        COUNT(DISTINCT [DocumentSignature]) AS [DifferentDocumentCount]
    FROM CTE_source
    WHERE [CountryCode] IS NOT NULL
      AND [DocumentId] IS NOT NULL
    GROUP BY
        [CountryCode],
        [DocumentId]
    HAVING COUNT(DISTINCT [DocumentSignature]) > 1
)
SELECT
    s.[CountryCodeRaw] AS [CountryCode],
    s.[DocumentIdRaw] AS [DocumentId],
    s.[DocumentSignature],
    d.[DifferentDocumentCount],
    CASE
        WHEN s.[DocumentId] IS NULL
            THEN 'MISSING_OR_EMPTY_DOCUMENTID'
        WHEN d.[DocumentId] IS NOT NULL
            THEN 'DOCUMENTID_REUSED_FOR_DIFFERENT_DOCUMENTS'
        ELSE 'UNKNOWN'
    END AS [QC_FailureReason]
FROM CTE_source AS s
LEFT JOIN CTE_reused_document_ids AS d
    ON d.[CountryCode] = s.[CountryCode]
   AND d.[DocumentId] = s.[DocumentId]
WHERE
    s.[DocumentId] IS NULL
    OR d.[DocumentId] IS NOT NULL;
GO


