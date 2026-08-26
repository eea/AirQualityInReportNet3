USE [Airquality_R3]
GO

/****** Object:  View [qc].[DOC_03_A]    Script Date: 26/08/2026 14:34:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [qc].[DOC_03_A]
AS
-- QC rule code: DOC_03_A
-- QC rule name: Vocabulary validation - [DocumentType]
--
-- Returns records where DocumentType is missing or does not exist
-- as a valid concept in the 'documenttype' reference vocabulary.

WITH CTE_documentation AS
(
    SELECT
        [CountryCode],
        [DataTable],
        [DocumentType] AS [DocumentTypeRaw],
        [DocumentId],
        NULLIF(LTRIM(RTRIM([DocumentType])), '') AS [DocumentType]
    FROM [reporting].[Documentation]
),
CTE_valid_document_types AS
(
    SELECT DISTINCT
        LOWER(LTRIM(RTRIM([Notation]))) COLLATE Latin1_General_CI_AS
            AS [DocumentTypeConcept]
    FROM [reference].[Vocabulary]
    WHERE [vocabulary] = 'documenttype'
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
            AS [DocumentTypeConcept]
    FROM [reference].[Vocabulary]
    WHERE [vocabulary] = 'documenttype'
      AND [Status] = 'Valid'
      AND [URI] IS NOT NULL
      AND CHARINDEX('/', [URI]) > 0
)
SELECT DISTINCT
    d.[CountryCode],
    d.[DataTable],
    d.[DocumentTypeRaw] AS [DocumentType],
    d.[DocumentId],
    CASE
        WHEN d.[DocumentType] IS NULL
            THEN 'MISSING_OR_EMPTY_DOCUMENTTYPE'
        WHEN v.[DocumentTypeConcept] IS NULL
            THEN 'INVALID_DOCUMENTTYPE_VOCABULARY'
        ELSE 'UNKNOWN'
    END AS [QC_FailureReason]
FROM CTE_documentation AS d
LEFT JOIN CTE_valid_document_types AS v
    ON LOWER(d.[DocumentType]) COLLATE Latin1_General_CI_AS
     = v.[DocumentTypeConcept]
WHERE
    d.[DocumentType] IS NULL
    OR v.[DocumentTypeConcept] IS NULL;
GO


