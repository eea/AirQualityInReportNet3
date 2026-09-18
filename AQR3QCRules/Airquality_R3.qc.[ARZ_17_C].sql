USE [Airquality_R3]
GO

/****** Object:  View [qc].[ARZ_17_C]    Script Date: 18/09/2026 09:57:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER   VIEW [qc].[ARZ_17_C] AS

-- Creation date: 09/09/2026
-- QC rule code: ARZ_17_C
-- QC rule name: ARZ_17_C ZoneResidentPopulation

WITH CTE_current AS (
    SELECT
        [CountryCode],
        [ZoneId],
        [ZoneResidentPopulationYear],
        [ZoneResidentPopulation]
    FROM [reporting].[AssessmentRegimeZone]
),

CTE_reference AS (
    SELECT
        [CountryCode],
        [ZoneId],
        [ZoneResidentPopulationYear],
        [ZoneResidentPopulation]
    FROM [reference].[AssessmentRegimeZone]
	--FROM [reference].[AssessmentRegimeZone]
)

SELECT
    CUR.[CountryCode],
    CUR.[ZoneId],
    CUR.[ZoneResidentPopulationYear],
    CUR.[ZoneResidentPopulation],
    REF.[ZoneResidentPopulationYear] AS [ReferencePopulationYear],
    REF.[ZoneResidentPopulation] AS [ReferenceZoneResidentPopulation]

FROM CTE_current CUR

LEFT JOIN CTE_reference REF
    ON  CUR.[CountryCode] = REF.[CountryCode]
    AND CUR.[ZoneId] = REF.[ZoneId]

WHERE
    REF.[ZoneId] IS NULL

    OR

    (
        REF.[ZoneResidentPopulation] IS NOT NULL
        AND CUR.[ZoneResidentPopulation] IS NOT NULL
        AND ABS(
            CUR.[ZoneResidentPopulation]
            - REF.[ZoneResidentPopulation]
        ) / NULLIF(REF.[ZoneResidentPopulation], 0) > 0.20
		-- ) / NULLIF(REF.[ZoneResidentPopulation], 0) > 0.XX change XX for %
    )

GO