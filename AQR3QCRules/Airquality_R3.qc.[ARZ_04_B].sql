USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[ARZ_04_B] AS

-- Creation date: 18/09/2026
-- QC rule code: ARZ_04_B
-- QC rule name: ARZ_04_B

WITH CTE_reporting AS (
    SELECT
        [CountryCode],
        [AssessmentRegimeId],
        [ZoneId],
        [ZoneNationalCode]
    FROM [reporting].[AssessmentRegimeZone]
),

CTE_inconsistent_reporting AS (
    SELECT
        [CountryCode],
        [ZoneId]
    FROM CTE_reporting
    GROUP BY
        [CountryCode],
        [ZoneId]
    HAVING COUNT(DISTINCT
        NULLIF(LTRIM(RTRIM([ZoneNationalCode])), '')
    ) > 1
),

CTE_reference AS (
    SELECT
        [CountryCode],
        [ZoneId],
        [ZoneNationalCode]
    FROM [reference].[AssessmentRegimeZone]
)

SELECT DISTINCT
    r.[CountryCode],
    r.[AssessmentRegimeId],
    r.[ZoneId],
    r.[ZoneNationalCode]

FROM CTE_reporting r

LEFT JOIN CTE_inconsistent_reporting i
    ON r.[CountryCode] = i.[CountryCode]
    AND r.[ZoneId] = i.[ZoneId]

LEFT JOIN CTE_reference ref
    ON r.[CountryCode] = ref.[CountryCode]
    AND r.[ZoneId] = ref.[ZoneId]

WHERE
    -- Inconsistency within the current delivery
    i.[ZoneId] IS NOT NULL

    OR

    -- Inconsistency against the reference dataset
    (
        ref.[ZoneId] IS NOT NULL
        AND ISNULL(
                NULLIF(LTRIM(RTRIM(r.[ZoneNationalCode])), ''),
                ''
            )
            <>
            ISNULL(
                NULLIF(LTRIM(RTRIM(ref.[ZoneNationalCode])), ''),
                ''
            )
    )

GO