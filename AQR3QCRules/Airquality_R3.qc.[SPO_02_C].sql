USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qctesting].[SPO_02_C_TEST]
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
        ) AS AssessmentMethodId,

        NULLIF(
            LTRIM(RTRIM([SamplingPointRef])),
            ''
        ) AS SamplingPointRef

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
    HAVING COUNT(DISTINCT SamplingPointRef) > 1
),

reference_samplingpoint AS
(
    SELECT
        CountryCode,
        AssessmentMethodId,
        SamplingPointRef
    FROM reference.SamplingPoint
)

SELECT
    s.CountryCode,
    s.AssessmentMethodId,
    s.SamplingPointRef

FROM src s

LEFT JOIN duplicates d
    ON s.CountryCode = d.CountryCode
   AND s.AssessmentMethodId = d.AssessmentMethodId

LEFT JOIN reference_samplingpoint r
    ON s.CountryCode = r.CountryCode
   AND s.AssessmentMethodId = r.AssessmentMethodId

WHERE
    d.CountryCode IS NOT NULL
    OR
    (
        r.AssessmentMethodId IS NOT NULL
        AND ISNULL(s.SamplingPointRef, '') <> ISNULL(r.SamplingPointRef, '')
    );

GO