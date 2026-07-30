USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qctesting].[SPO_02_A_TEST]
AS

WITH src AS
(
    SELECT
        NULLIF(
            LTRIM(RTRIM([CountryCode])),
            ''
        ) AS CountryCode,

        NULLIF(
            LTRIM(RTRIM([AssessmentMethodId])),
            ''
        ) AS AssessmentMethodId

    FROM reporting.SamplingPoint
),

duplicates AS
(
    SELECT
        CountryCode,
        AssessmentMethodId
    FROM src
    GROUP BY
        CountryCode,
        AssessmentMethodId
    HAVING COUNT(*) > 1
),

reference_samplingpoint AS
(
    SELECT
        CountryCode,
        AssessmentMethodId,
        COUNT(*) AS RefCount
    FROM reference.SamplingPoint
    GROUP BY
        CountryCode,
        AssessmentMethodId
)

SELECT
    s.CountryCode,
    s.AssessmentMethodId

FROM src s

LEFT JOIN duplicates d
    ON s.CountryCode = d.CountryCode
   AND s.AssessmentMethodId = d.AssessmentMethodId

LEFT JOIN reference_samplingpoint r
    ON s.CountryCode = r.CountryCode
   AND s.AssessmentMethodId = r.AssessmentMethodId

WHERE
    s.AssessmentMethodId IS NULL
    OR d.CountryCode IS NOT NULL
    OR r.RefCount IS NULL
    OR r.RefCount <> 1;

GO