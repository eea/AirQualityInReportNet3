USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[ARZ_18_A] AS

-- Creation date: 31/08/2026
-- QC rule code: ARZ_18_A
-- QC rule name: ARZ_18_A

WITH CTE_assessmentRegimeZone AS (
    SELECT
        [CountryCode],
        [AssessmentRegimeId],
        [ClassificationYear],
        [ReportingYear]

    FROM [reporting].[AssessmentRegimeZone]
)

SELECT
    [CountryCode],
    [AssessmentRegimeId],
    [ClassificationYear]

FROM CTE_assessmentRegimeZone

WHERE [ClassificationYear] IS NULL
   OR [ClassificationYear] NOT LIKE '[0-9][0-9][0-9][0-9]'
   OR TRY_CONVERT(int, [ClassificationYear]) < TRY_CONVERT(int, [ReportingYear]) - 5

GO