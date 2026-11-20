USE [Airquality_R3];
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER VIEW [qc].[STA_09_B]
AS
-- QC rule code: STA_09_B
-- QC rule name: STA_09_B Cross-check - [NetworkDocumentId]
-- QC rule description:
-- The NetworkDocumentId must refer to a document classified as MeasurementStation
-- in DOC_02 and as NetworkDocumentId in DOC_03.

WITH CTE_measurement_station AS
(
    SELECT
        ms.NetworkDocumentId,
        NULLIF(
            LTRIM(RTRIM(ms.NetworkDocumentId)) COLLATE DATABASE_DEFAULT,
            ''
        ) AS NetworkDocumentIdClean
    FROM [reporting].[MeasurementStation] AS ms
),
CTE_reporting_documentation AS
(
    SELECT DISTINCT
        NULLIF(
            LTRIM(RTRIM(d.DocumentId)) COLLATE DATABASE_DEFAULT,
            ''
        ) AS DocumentIdClean,

        NULLIF(
            LTRIM(RTRIM(d.DataTable)) COLLATE DATABASE_DEFAULT,
            ''
        ) AS DataTableClean,

        NULLIF(
            LTRIM(RTRIM(d.DocumentType)) COLLATE DATABASE_DEFAULT,
            ''
        ) AS DocumentTypeClean
    FROM [reporting].[Documentation] AS d
)
SELECT DISTINCT
    ms.NetworkDocumentId
FROM CTE_measurement_station AS ms
WHERE
    /*
       STA_09_B:
       The matching DocumentId in Documentation must be classified as:
       - DataTable    = aq/datatable/MeasurementStation
       - DocumentType = aq/documenttype/NetworkDocumentId

       The rule is evaluated only where a matching DocumentId exists in
       Documentation. The existence of the DocumentId itself is checked by
       STA_09_A.
    */
    ms.NetworkDocumentIdClean IS NOT NULL
    AND EXISTS
    (
        SELECT 1
        FROM CTE_reporting_documentation AS d
        WHERE d.DocumentIdClean = ms.NetworkDocumentIdClean
    )
    AND NOT EXISTS
    (
        SELECT 1
        FROM CTE_reporting_documentation AS d
        WHERE d.DocumentIdClean = ms.NetworkDocumentIdClean
          AND d.DataTableClean = 'aq/datatable/MeasurementStation'
          AND d.DocumentTypeClean = 'aq/documenttype/NetworkDocumentId'
    );
GO