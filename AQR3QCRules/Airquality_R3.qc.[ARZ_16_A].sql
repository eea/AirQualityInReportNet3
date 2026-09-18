USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[ARZ_16_A] AS

-- Creation date: 31/08/2026
-- QC rule code: ARZ_16_A
-- QC rule name: ARZ_16_A

WITH CTE_assessmentRegimeZone AS (
    SELECT
        [CountryCode],
        [AssessmentRegimeId],
        [ZoneResidentPopulationYear],
        [ReportingYear]
    FROM [reporting].[AssessmentRegimeZone]
)

SELECT
    [CountryCode],
    [AssessmentRegimeId],
    [ZoneResidentPopulationYear]

FROM CTE_assessmentRegimeZone

WHERE [ZoneResidentPopulationYear] IS NULL
   OR [ZoneResidentPopulationYear] NOT LIKE '[0-9][0-9][0-9][0-9]'
   OR TRY_CONVERT(int, [ZoneResidentPopulationYear]) < TRY_CONVERT(int, [ReportingYear]) - 5

GO