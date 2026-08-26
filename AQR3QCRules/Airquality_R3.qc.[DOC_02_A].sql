USE [Airquality_R3]
GO

/****** Object:  View [qc].[DOC_02_A]    Script Date: 26/08/2026 14:13:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [qc].[DOC_02_A]
AS
-- QC rule code: DOC_02_A
-- QC rule name: Vocabulary validation - [DataTable]
--
-- Returns Documentation records where DataTable is missing or does not
-- correspond to a valid concept in the 'datatable' reference vocabulary.

WITH CTE_documentation AS
(
    SELECT
        [CountryCode],
        [DataTable] AS [DataTableRaw],
        NULLIF(LTRIM(RTRIM([DataTable])), '') AS [DataTable]
    FROM [reporting].[Documentation]
),
CTE_valid_datatables AS
(
    SELECT DISTINCT
        LOWER(
            RIGHT(
                [URI],
                CHARINDEX('/', REVERSE([URI])) - 1
            )
        ) COLLATE Latin1_General_CI_AS AS [DataTableConcept]
    FROM [reference].[Vocabulary]
    WHERE [vocabulary] = 'datatable'
      AND [Status] = 'Valid'
      AND [URI] IS NOT NULL
      AND CHARINDEX('/', [URI]) > 0
)
SELECT DISTINCT
    d.[CountryCode],
    d.[DataTableRaw] AS [DataTable],
    CASE
        WHEN d.[DataTable] IS NULL
            THEN 'MISSING_OR_EMPTY_DATATABLE'
        WHEN v.[DataTableConcept] IS NULL
            THEN 'INVALID_DATATABLE_VOCABULARY'
        ELSE 'UNKNOWN'
    END AS [QC_FailureReason]
FROM CTE_documentation AS d
LEFT JOIN CTE_valid_datatables AS v
    ON LOWER(d.[DataTable]) COLLATE Latin1_General_CI_AS
     = v.[DataTableConcept]
WHERE
    d.[DataTable] IS NULL
    OR v.[DataTableConcept] IS NULL;
GO


