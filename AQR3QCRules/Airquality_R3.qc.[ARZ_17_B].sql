USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[ARZ_17_B] AS

-- Creation date: 09/09/2026
-- QC rule code: ARZ_17_B
-- QC rule name: ARZ_17_B Completeness of Zone Resident Population

WITH CTE_assessmentRegimeZone AS (
    SELECT
        [CountryCode],
        [PollutantId],
        [ProtectionTarget],
        [ObjectiveType],
        [ReportingYear],
        SUM([ZoneResidentPopulation]) AS [TotalZoneResidentPopulation]
    FROM [reporting].[AssessmentRegimeZone]
    GROUP BY
        [CountryCode],
        [PollutantId],
        [ProtectionTarget],
        [ObjectiveType],
        [ReportingYear]
),

CTE_countryPopulation AS (
    SELECT
        [CountryCode],
        [Year],
        [Population]
    FROM [reference].[CountryAreaPopulation]
)

SELECT
    ARZ.[CountryCode],
    ARZ.[PollutantId],
    ARZ.[ProtectionTarget],
    ARZ.[ObjectiveType],
    ARZ.[ReportingYear],
    ARZ.[TotalZoneResidentPopulation],
    REF.[Population] AS [ExpectedPopulation]

FROM CTE_assessmentRegimeZone AS ARZ

INNER JOIN CTE_countryPopulation AS REF
    ON ARZ.[CountryCode] = REF.[CountryCode]
    AND ARZ.[ReportingYear] = REF.[Year]

WHERE
    ARZ.[TotalZoneResidentPopulation] < REF.[Population] * 0.95
    OR
    ARZ.[TotalZoneResidentPopulation] > REF.[Population] * 1.05

GO