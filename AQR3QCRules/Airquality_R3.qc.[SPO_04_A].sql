USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qctesting].[SPO_04_A_TEST]
AS

WITH src AS
(
    SELECT
        [CountryCode],
        [AssessmentMethodId],

        [PollutantID]

    FROM reporting.SamplingPoint
),

CTE_pollutant AS
(
    SELECT
        PollutantID
    FROM reference.SamplingPoint
)

SELECT
    s.CountryCode,
    s.AssessmentMethodId,
    s.PollutantID

FROM src s

LEFT JOIN CTE_pollutant p
    ON s.PollutantID = p.PollutantID

WHERE
    s.PollutantID IS NULL
    OR p.PollutantID IS NULL;

GO