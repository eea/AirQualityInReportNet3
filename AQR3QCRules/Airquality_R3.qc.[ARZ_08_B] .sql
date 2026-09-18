USE [Airquality_R3]
GO

/****** Object:  View [qc].[ARZ_08_B]    Script Date: 18/09/2026 10:58:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER   VIEW [qc].[ARZ_08_B] AS

-- Creation date: 09/09/2026
-- QC rule code: ARZ_08_B
-- QC rule name: ARZ_08_B ZoneName

WITH CTE_assessmentRegimeZone AS (
    SELECT
        [CountryCode],
        [ZoneId],
        [ZoneName]
    FROM [reporting].[AssessmentRegimeZone]
),

CTE_current_inconsistent AS (
    SELECT
        [CountryCode],
        [ZoneId]
    FROM CTE_assessmentRegimeZone
    GROUP BY
        [CountryCode],
        [ZoneId]
    HAVING COUNT(DISTINCT [ZoneName]) > 1
),

CTE_reference AS (
    SELECT
        [CountryCode],
        [ZoneId],
        [ZoneName]
    FROM [reference].[AssessmentRegimeZone]
)

SELECT DISTINCT
    ARZ.[CountryCode],
    ARZ.[ZoneId],
    ARZ.[ZoneName]
FROM CTE_assessmentRegimeZone ARZ

LEFT JOIN CTE_reference REF
    ON  ARZ.[CountryCode] = REF.[CountryCode]
    AND ARZ.[ZoneId] = REF.[ZoneId]

LEFT JOIN CTE_current_inconsistent INC
    ON  ARZ.[CountryCode] = INC.[CountryCode]
    AND ARZ.[ZoneId] = INC.[ZoneId]

WHERE
    INC.[ZoneId] IS NOT NULL

    OR

    (
        REF.[ZoneId] IS NOT NULL
        AND ISNULL(ARZ.[ZoneName], '') <> ISNULL(REF.[ZoneName], '')
    )

GO