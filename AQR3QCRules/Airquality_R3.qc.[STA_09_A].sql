USE [Airquality_R3]
GO

/****** Object:  View [qc].[STA_09_A]    Script Date: 20/11/2026 14:09:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   VIEW [qc].[STA_09_A]
AS
-- QC rule code: STA_09_A
-- QC rule name: STA_09_A Cross-check - [NetworkDocumentId]
-- QC rule description:
-- The NetworkDocumentId must exist as a DocumentId in the Documentation table,
-- either within the current R3 submission or in the reference dataset.
-- The cross-check is performed using the same CountryCode.

WITH CTE_measurement_station AS
(
    SELECT
        ms.NetworkDocumentId,
        ms.CountryCode,

        NULLIF(
            LTRIM(RTRIM(ms.NetworkDocumentId)) COLLATE DATABASE_DEFAULT,
            ''
        ) AS NetworkDocumentIdClean,

        NULLIF(
            LTRIM(RTRIM(ms.CountryCode)) COLLATE DATABASE_DEFAULT,
            ''
        ) AS CountryCodeClean
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
            LTRIM(RTRIM(d.CountryCode)) COLLATE DATABASE_DEFAULT,
            ''
        ) AS CountryCodeClean
    FROM [reporting].[Documentation] AS d
),
CTE_reference_documentation AS
(
    SELECT DISTINCT
        NULLIF(
            LTRIM(RTRIM(rd.DocumentId)) COLLATE DATABASE_DEFAULT,
            ''
        ) AS DocumentIdClean,

        NULLIF(
            LTRIM(RTRIM(rd.CountryCode)) COLLATE DATABASE_DEFAULT,
            ''
        ) AS CountryCodeClean
    FROM [reference].[Documentation] AS rd
)
SELECT DISTINCT
    ms.NetworkDocumentId,
    ms.CountryCode
FROM CTE_measurement_station AS ms
WHERE
    /*
       STA_09:
       A value shall be reported for NetworkDocumentId.
       NULL, empty and whitespace-only values are invalid.
    */
    ms.NetworkDocumentIdClean IS NULL

    /*
       STA_09_A:
       NetworkDocumentId must match a DocumentId in the current R3 submission
       or in the reference dataset, using the same CountryCode.
    */
    OR
    (
        NOT EXISTS
        (
            SELECT 1
            FROM CTE_reporting_documentation AS d
            WHERE d.DocumentIdClean = ms.NetworkDocumentIdClean
              AND d.CountryCodeClean = ms.CountryCodeClean
        )
        AND NOT EXISTS
        (
            SELECT 1
            FROM CTE_reference_documentation AS rd
            WHERE rd.DocumentIdClean = ms.NetworkDocumentIdClean
              AND rd.CountryCodeClean = ms.CountryCodeClean
        )
    );
GO


