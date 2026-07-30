USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qctesting].[SPP_14_B_TEST]
AS

WITH src AS
(
    SELECT
        NULLIF(
            LTRIM(RTRIM([CountryCode])),
            ''
        ) AS CountryCode,

        NULLIF(
            LTRIM(RTRIM([ProcessDocumentationId])),
            ''
        ) AS ProcessDocumentationId

    FROM reporting.SamplingProcess
),

documentation AS
(
    SELECT
        CountryCode,
        DocumentId,
        DataTable,
        DocumentObject
    FROM reporting.Documentation

    UNION ALL

    SELECT
        CountryCode,
        DocumentId,
        DataTable,
        DocumentObject
    FROM reference.Documentation
)

SELECT
    s.CountryCode,
    s.ProcessDocumentationId

FROM src s

LEFT JOIN documentation d
    ON s.CountryCode = d.CountryCode
   AND s.ProcessDocumentationId = d.DocumentId

WHERE
    s.ProcessDocumentationId IS NOT NULL
    AND
    (
        d.DocumentId IS NULL
        OR d.DataTable <> 'aq/datatable/SamplingProcess'
        OR d.DocumentObject <> 'aq/documenttype/ProcessDocumentId'
    );

GO