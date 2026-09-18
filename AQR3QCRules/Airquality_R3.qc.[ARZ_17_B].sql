USE [Airquality_R3]
GO

/****** Object:  View [qc].[ARZ_17_B]    Script Date: 18/09/2026 09:56:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER   VIEW [qc].[ARZ_17_B] AS

-- Creation date: 09/09/2026
-- QC rule code: ARZ_17_B
-- QC rule name: ARZ_17_B Completeness of Zone Resident Population

WITH CTE_assessmentRegimeZone AS (
    SELECT
        [CountryCode],
        [PollutantId],
        [ProtectionTarget],
        SUM([ZoneResidentPopulation]) AS [TotalZoneResidentPopulation]
    FROM [reporting].[AssessmentRegimeZone]
    GROUP BY
        [CountryCode],
        [PollutantId],
        [ProtectionTarget]
),

CTE_expected_combinations AS (
    SELECT
        [CountryCode],
        [PollutantId],
        [ProtectionTarget],
        [ZoneResidentPopulation]
    FROM [reference].[AssessmentRegimeZone]
    -- FROM [reference].[AssessmentRegimeZone]
)

SELECT
    ARZ.[CountryCode],
    ARZ.[PollutantId],
    ARZ.[ProtectionTarget],
    ARZ.[TotalZoneResidentPopulation],
    EXP.[ZoneResidentPopulation]

FROM CTE_assessmentRegimeZone ARZ

INNER JOIN CTE_expected_combinations EXP
    ON  ARZ.[CountryCode] = EXP.[CountryCode]
    AND ARZ.[PollutantId] = EXP.[PollutantId]
    AND ARZ.[ProtectionTarget] = EXP.[ProtectionTarget]

WHERE
    ARZ.[TotalZoneResidentPopulation] < EXP.[ZoneResidentPopulation] * 0.95
    OR
    ARZ.[TotalZoneResidentPopulation] > EXP.[ZoneResidentPopulation] * 1.05

GO