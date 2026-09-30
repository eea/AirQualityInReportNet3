USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[ARZ_17_C] AS

-- Creation date: 09/09/2026
-- QC rule code: ARZ_17_C
-- QC rule name: ARZ_17_C ZoneResidentPopulation

WITH CTE_current AS (
    SELECT
        [CountryCode],
        [ZoneId],
        [PollutantId],
        [ProtectionTarget],
        [ObjectiveType],
        [ZoneResidentPopulationYear],
        [ZoneResidentPopulation]
    FROM [reporting].[AssessmentRegimeZone]
)

SELECT
    CUR.[CountryCode],
    CUR.[ZoneId],
    CUR.[PollutantId],
    CUR.[ProtectionTarget],
    CUR.[ObjectiveType],
    CUR.[ZoneResidentPopulationYear],
    CUR.[ZoneResidentPopulation],
    REF.[ZoneResidentPopulationYear] AS [ReferencePopulationYear],
    REF.[ZoneResidentPopulation] AS [ReferenceZoneResidentPopulation]

FROM CTE_current AS CUR

OUTER APPLY (
    SELECT TOP 1
        R.[ZoneResidentPopulationYear],
        R.[ZoneResidentPopulation]
    FROM [reference].[AssessmentRegimeZone] AS R
    WHERE
        R.[CountryCode] = CUR.[CountryCode]
        AND R.[ZoneId] = CUR.[ZoneId]
        AND R.[PollutantId] = CUR.[PollutantId]
        AND R.[ProtectionTarget] = CUR.[ProtectionTarget]
        AND R.[ObjectiveType] = CUR.[ObjectiveType]
        AND TRY_CONVERT(int, R.[ZoneResidentPopulationYear])
            < TRY_CONVERT(int, CUR.[ZoneResidentPopulationYear])
    ORDER BY
        TRY_CONVERT(int, R.[ZoneResidentPopulationYear]) DESC
) AS REF

WHERE
    REF.[ZoneResidentPopulationYear] IS NULL

    OR

    (
        CUR.[ZoneResidentPopulation] IS NOT NULL
        AND REF.[ZoneResidentPopulation] IS NOT NULL
        AND ABS(
            TRY_CONVERT(bigint, CUR.[ZoneResidentPopulation])
            - TRY_CONVERT(bigint, REF.[ZoneResidentPopulation])
        ) / NULLIF(
            TRY_CONVERT(decimal(38, 10), REF.[ZoneResidentPopulation]),
            0
        ) > 0.20
    )

GO