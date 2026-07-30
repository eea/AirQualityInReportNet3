USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qctesting].[SPP_12_A_TEST]
AS

WITH src AS
(
    SELECT
        NULLIF(
            LTRIM(RTRIM([CountryCode])),
            ''
        ) AS CountryCode,

        NULLIF(
            LTRIM(RTRIM([DataQualityReportId])),
            ''
        ) AS DataQualityReportId

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
    s.DataQualityReportId

FROM src s

LEFT JOIN reporting_documentation pd
    ON s.CountryCode = pd.CountryCode
   AND s.DataQualityReportId = pd.DocumentId

LEFT JOIN reference_documentation rd
    ON s.CountryCode = rd.CountryCode
   AND s.DataQualityReportId = rd.DocumentId

WHERE
    s.DataQualityReportId IS NULL
    OR
    (
        pd.DocumentId IS NULL
        AND rd.DocumentId IS NULL
    );

GO