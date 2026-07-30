USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qctesting].[SPO_PK_TEST]
AS

WITH src AS
(
    SELECT
        [CountryCode],
        [AssessmentMethodId]
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
)

SELECT
    s.CountryCode,
    s.AssessmentMethodId

FROM src s

LEFT JOIN duplicates d
    ON s.CountryCode = d.CountryCode
   AND s.AssessmentMethodId = d.AssessmentMethodId

WHERE
    s.CountryCode IS NULL
    OR s.AssessmentMethodId IS NULL
    OR d.CountryCode IS NOT NULL;

GO