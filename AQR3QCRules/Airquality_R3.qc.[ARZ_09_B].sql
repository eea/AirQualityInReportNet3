USE [Airquality_R3]
GO

/****** Object:  View [qctesting].[ARZ_09_B]    Script Date: 30/09/2026 10:43:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER   VIEW [qc].[ARZ_09_B] AS

-- Creation date: 09/09/2026
-- QC rule code: ARZ_09_B
-- QC rule name: ARZ_09_B Applicable Pollutants for Assessment Regime Reporting

WITH CTE_assessmentRegimeZone AS (
    SELECT
        [CountryCode],
        [AssessmentRegimeId],
        [ZoneId],
        [PollutantId]
    FROM [reporting].[AssessmentRegimeZone]
)

SELECT
    [CountryCode],
    [AssessmentRegimeId],
    [ZoneId],
    [PollutantId]

FROM CTE_assessmentRegimeZone

WHERE
    [PollutantId] IS NULL
    OR [PollutantId] NOT IN (
        1,
        5,
        7,
        8,
        9,
        10,
        20,
        6001,
        5012,
        5014,
        5015,
        5018,
        5029
    )

GO


