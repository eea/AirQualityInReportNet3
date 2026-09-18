USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[ARZ_17_A] AS

-- Creation date: 31/08/2026
-- QC rule code: ARZ_17_A
-- QC rule name: ARZ_17_A

WITH CTE_assessmentRegimeZone AS (
    SELECT
        [CountryCode],
        [AssessmentRegimeId],
        [ZoneResidentPopulation]

    FROM [reporting].[AssessmentRegimeZone]
)

SELECT
    [CountryCode],
    [AssessmentRegimeId],
    [ZoneResidentPopulation]

FROM CTE_assessmentRegimeZone

WHERE TRY_CONVERT(decimal(38, 10), [ZoneResidentPopulation]) IS NULL
   OR TRY_CONVERT(decimal(38, 10), [ZoneResidentPopulation]) <= 0

GO