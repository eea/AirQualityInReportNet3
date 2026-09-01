USE [Airquality_R3]
GO

/****** Object:  View [qc].[DOC_PK]    Script Date: 01/09/2026 12:27:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   VIEW [qc].[DOC_PK]
AS
-- QC rule code: DOC_PK
-- QC rule name: Primary key validation - [CountryCode, DataTable, DocumentType, DocumentId]
--
-- Returns records where at least one primary key attribute is NULL,
-- or where the same complete primary key combination is reused.

WITH CTE_source AS
(
    SELECT
        [CountryCode],
        [DataTable],
        [DocumentType],
        [DocumentId]
    FROM [reporting].[Documentation]
),
CTE_duplicate_keys AS
(
    SELECT
        [CountryCode],
        [DataTable],
        [DocumentType],
        [DocumentId],
        COUNT(*) AS [DuplicateCount]
    FROM CTE_source
    WHERE [CountryCode] IS NOT NULL
      AND [DataTable] IS NOT NULL
      AND [DocumentType] IS NOT NULL
      AND [DocumentId] IS NOT NULL
    GROUP BY
        [CountryCode],
        [DataTable],
        [DocumentType],
        [DocumentId]
    HAVING COUNT(*) > 1
)
SELECT
    s.[CountryCode],
    s.[DataTable],
    s.[DocumentType],
    s.[DocumentId],
    d.[DuplicateCount],
    CASE
        WHEN s.[CountryCode] IS NULL
         AND s.[DataTable] IS NULL
         AND s.[DocumentType] IS NULL
         AND s.[DocumentId] IS NULL
            THEN 'ALL_PRIMARY_KEY_ATTRIBUTES_NULL'

        WHEN s.[CountryCode] IS NULL
            THEN 'COUNTRYCODE_NULL'

        WHEN s.[DataTable] IS NULL
            THEN 'DATATABLE_NULL'

        WHEN s.[DocumentType] IS NULL
            THEN 'DOCUMENTTYPE_NULL'

        WHEN s.[DocumentId] IS NULL
            THEN 'DOCUMENTID_NULL'

        WHEN d.[DuplicateCount] IS NOT NULL
            THEN 'DUPLICATE_PRIMARY_KEY'

        ELSE 'UNKNOWN'
    END AS [QC_FailureReason]
FROM CTE_source AS s
LEFT JOIN CTE_duplicate_keys AS d
    ON d.[CountryCode] = s.[CountryCode]
   AND d.[DataTable] = s.[DataTable]
   AND d.[DocumentType] = s.[DocumentType]
   AND d.[DocumentId] = s.[DocumentId]
WHERE
    s.[CountryCode] IS NULL
    OR s.[DataTable] IS NULL
    OR s.[DocumentType] IS NULL
    OR s.[DocumentId] IS NULL
    OR d.[DuplicateCount] IS NOT NULL;
GO


