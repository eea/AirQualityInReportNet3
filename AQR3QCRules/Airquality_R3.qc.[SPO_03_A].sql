USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qctesting].[SPO_03_A_TEST]
AS

WITH src AS
(
    SELECT
        NULLIF(
            LTRIM(RTRIM([CountryCode])),
            ''
        ) AS CountryCode,

        NULLIF(
            LTRIM(RTRIM([SamplingPointReferenceId])),
            ''
        ) AS SamplingPointReferenceId

    FROM reporting.SamplingPoint
),

duplicates AS
(
    SELECT
        CountryCode,
        SamplingPointReferenceId
    FROM src
    GROUP BY
        CountryCode,
        SamplingPointReferenceId
    HAVING COUNT(*) > 1
),

reference_samplingpoint AS
(
    SELECT
        CountryCode,
        SamplingPointReferenceId,
        COUNT(*) AS RefCount
    FROM reference.SamplingPoint
    GROUP BY
        CountryCode,
        SamplingPointReferenceId
)

SELECT
    s.CountryCode,
    s.SamplingPointReferenceId

FROM src s

LEFT JOIN duplicates d
    ON s.CountryCode = d.CountryCode
   AND s.SamplingPointReferenceId = d.SamplingPointReferenceId

LEFT JOIN reference_samplingpoint r
    ON s.CountryCode = r.CountryCode
   AND s.SamplingPointReferenceId = r.SamplingPointReferenceId

WHERE
    s.SamplingPointReferenceId IS NULL
    OR d.CountryCode IS NOT NULL
    OR r.RefCount IS NULL
    OR r.RefCount <> 1;

GO