USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[ARZ_15_A] AS

-- Creation date: 1/09/2026
-- QC rule code: ARZ_15_A
-- QC rule name: ARZ_15_A

WITH CTE_assessmentRegimeZone AS (
    SELECT
        [CountryCode],
        [AssessmentRegimeId],
        [FixedMeasurementReduction]
    FROM [reporting].[AssessmentRegimeZone]
)

SELECT
    [CountryCode],
    [AssessmentRegimeId],
    [FixedMeasurementReduction]

FROM CTE_assessmentRegimeZone

WHERE [FixedMeasurementReduction] IS NULL
   OR UPPER(LTRIM(RTRIM([FixedMeasurementReduction]))) NOT IN ('YES', 'NO')

GO