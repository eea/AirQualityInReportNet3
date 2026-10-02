USE [Airquality_R3]
GO

/****** Object:  View [qc].[DOC_04_A]    Script Date: 02/10/2026 13:10:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   VIEW [qc].[DOC_04_A]
AS
/* ============================================================
   QC rule code: DOC_04_A
   QC rule name: Uniqueness validation - DocumentId

   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ERROR (not a BLOCKER).!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

   Validation rules:
   - DocumentId must be reported.
   - DocumentId must not be NULL, empty or whitespace-only.
   - CountryCode + DocumentId must not be repeated in
     reporting.Documentation within the same submission.

   Note:
   A repeated DocumentId can be technically valid according to
   the data model PK when other fields differ. Nevertheless,
   it is not recommended and is reported as an ERROR.
   ============================================================ */

WITH CTE_source AS
(
    SELECT
        CONVERT(NVARCHAR(100), doc.CountryCode)
            COLLATE Latin1_General_100_CI_AS AS CountryCodeRaw,

        CONVERT(NVARCHAR(500), doc.DocumentId)
            COLLATE Latin1_General_100_CI_AS AS DocumentIdRaw,

        CONVERT(NVARCHAR(500), doc.DataTable)
            COLLATE Latin1_General_100_CI_AS AS DataTable,

        CONVERT(NVARCHAR(500), doc.DocumentType)
            COLLATE Latin1_General_100_CI_AS AS DocumentType,

        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(100), doc.CountryCode))),
            N''
        ) COLLATE Latin1_General_100_CI_AS AS CountryCode,

        NULLIF
        (
            LTRIM(RTRIM(CONVERT(NVARCHAR(500), doc.DocumentId))),
            N''
        ) COLLATE Latin1_General_100_CI_AS AS DocumentId
    FROM [reporting].[Documentation] AS doc
),
CTE_repeated_document_ids AS
(
    SELECT
        CountryCode,
        DocumentId,
        COUNT(*) AS DocumentIdOccurrenceCount
    FROM CTE_source
    WHERE CountryCode IS NOT NULL
      AND DocumentId IS NOT NULL
    GROUP BY
        CountryCode,
        DocumentId
    HAVING COUNT(*) > 1
)
SELECT
    s.CountryCodeRaw AS CountryCode,
    s.DocumentIdRaw AS DocumentId,
    s.DataTable,
    s.DocumentType,
    d.DocumentIdOccurrenceCount,
    CASE
        WHEN s.DocumentId IS NULL
            THEN 'MISSING_OR_EMPTY_DOCUMENTID'

        WHEN d.DocumentId IS NOT NULL
            THEN 'DOCUMENTID_REPEATED_FOR_SAME_COUNTRYCODE'
    END AS QC_FailureReason
FROM CTE_source AS s
LEFT JOIN CTE_repeated_document_ids AS d
    ON  d.CountryCode = s.CountryCode
    AND d.DocumentId = s.DocumentId
WHERE s.DocumentId IS NULL
   OR d.DocumentId IS NOT NULL;
GO


