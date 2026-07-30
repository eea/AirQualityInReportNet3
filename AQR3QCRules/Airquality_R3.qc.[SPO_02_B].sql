USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qctesting].[SPO_02_B_TEST]
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

sampling_process AS
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

    FROM reporting.SamplingProcess
)

SELECT
    s.CountryCode,
    s.AssessmentMethodId

FROM src s

LEFT JOIN sampling_process sp
    ON s.CountryCode = sp.CountryCode
   AND s.AssessmentMethodId = sp.AssessmentMethodId

WHERE
    s.AssessmentMethodId IS NOT NULL
    AND sp.AssessmentMethodId IS NULL;

GO