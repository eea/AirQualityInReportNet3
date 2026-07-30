USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qctesting].[SPO_02_D_TEST]
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

sampling_point_location AS
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

    FROM reporting.SamplingPointLocation
)

SELECT
    s.CountryCode,
    s.AssessmentMethodId

FROM src s

LEFT JOIN sampling_point_location spl
    ON s.CountryCode = spl.CountryCode
   AND s.AssessmentMethodId = spl.AssessmentMethodId

WHERE
    s.AssessmentMethodId IS NOT NULL
    AND spl.AssessmentMethodId IS NULL;

GO