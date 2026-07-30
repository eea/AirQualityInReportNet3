USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qctesting].[SPO_01_A_TEST]
AS

WITH src AS
(
    SELECT
        NULLIF(
            LTRIM(RTRIM([CountryCode])),
            ''
        ) AS CountryCode,

        [AssessmentMethodId]

    FROM reporting.SamplingPoint
),

CTE_countryCode AS
(
    SELECT
        CountryCode
    FROM reference.CountryCode
)

SELECT
    s.CountryCode,
    s.AssessmentMethodId

FROM src s

LEFT JOIN CTE_countryCode c
    ON s.CountryCode = c.CountryCode

WHERE
    s.CountryCode IS NULL
    OR c.CountryCode IS NULL;

GO