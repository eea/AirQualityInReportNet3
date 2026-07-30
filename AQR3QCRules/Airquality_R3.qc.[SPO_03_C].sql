USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qctesting].[SPO_03_C_TEST]
AS

WITH src AS
(
    SELECT
        NULLIF(
            LTRIM(RTRIM([CountryCode])),
            ''
        ) AS CountryCode,

        NULLIF(
            LTRIM(RTRIM([SamplingPointRef])),
            ''
        ) AS SamplingPointRef,

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
        SamplingPointRef
    FROM src
    GROUP BY
        CountryCode,
        SamplingPointRef
    HAVING COUNT(DISTINCT AssessmentMethodId) > 1
),

reference_samplingpoint AS
(
    SELECT
        CountryCode,
        SamplingPointRef,
        AssessmentMethodId
    FROM reference.SamplingPoint
)

SELECT
    s.CountryCode,
    s.SamplingPointRef,
    s.AssessmentMethodId

FROM src s

LEFT JOIN duplicates d
    ON s.CountryCode = d.CountryCode
   AND s.SamplingPointRef = d.SamplingPointRef

LEFT JOIN reference_samplingpoint r
    ON s.CountryCode = r.CountryCode
   AND s.SamplingPointRef = r.SamplingPointRef

WHERE
    d.CountryCode IS NOT NULL
    OR
    (
        r.SamplingPointRef IS NOT NULL
        AND ISNULL(s.AssessmentMethodId, '') <> ISNULL(r.AssessmentMethodId, '')
    );

GO