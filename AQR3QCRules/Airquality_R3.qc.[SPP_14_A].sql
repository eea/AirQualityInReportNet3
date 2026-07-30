USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qctesting].[SPP_14_A_TEST]
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

reporting_documentation AS
(
    SELECT DISTINCT
        CountryCode,
        DocumentId
    FROM reporting.Documentation
),

reference_documentation AS
(
    SELECT DISTINCT
        CountryCode,
        DocumentId
    FROM reference.Documentation
)

SELECT
    s.CountryCode,
    s.ProcessDocumentationId

FROM src s

LEFT JOIN reporting_documentation pd
    ON s.CountryCode = pd.CountryCode
   AND s.ProcessDocumentationId = pd.DocumentId

LEFT JOIN reference_documentation rd
    ON s.CountryCode = rd.CountryCode
   AND s.ProcessDocumentationId = rd.DocumentId

WHERE
    s.ProcessDocumentationId IS NULL
    OR
    (
        pd.DocumentId IS NULL
        AND rd.DocumentId IS NULL
    );

GO