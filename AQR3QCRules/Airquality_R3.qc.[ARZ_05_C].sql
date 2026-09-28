USE [Airquality_R3]
GO

/****** Object:  View [qc].[ARZ_05_C]    Script Date: 23/09/2026 07:48:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   VIEW [qc].[ARZ_05_C]
AS
/* ============================================================
   QC rule code: ARZ_05_C
   QC rule name: National territory coverage - ZoneArea

   Returns Health protection target groups for which the sum of
   reported ZoneArea values does not cover the national territory
   within the permitted tolerance.

   Grouping dimensions:
   - CountryCode
   - PollutantId
   - ProtectionTarget
   - ObjectiveType
   - ReportingMetric

   The official country area is obtained from the latest available
   Year in reference.CountryAreaPopulation for each CountryCode.

   Accepted range:
       OfficialAreaKM2 * 0.995 <= TotalZoneAreaKM2
       TotalZoneAreaKM2 <= OfficialAreaKM2 * 1.005
   ============================================================ */
WITH CTE_latest_country_area AS
(
    SELECT
        cap.CountryCode,
        cap.[Year] AS ReferenceYear,
        cap.AreaKM2 AS OfficialAreaKM2,
        ROW_NUMBER() OVER
        (
            PARTITION BY cap.CountryCode
            ORDER BY
                CASE WHEN cap.[Year] IS NULL THEN 1 ELSE 0 END,
                cap.[Year] DESC
        ) AS RowNumber
    FROM [reference].[CountryAreaPopulation] AS cap
),
CTE_health_groups AS
(
    SELECT
        arz.CountryCode,
        arz.PollutantId,
        LTRIM(RTRIM(arz.ProtectionTarget)) AS ProtectionTarget,
        LTRIM(RTRIM(arz.ObjectiveType)) AS ObjectiveType,
        LTRIM(RTRIM(arz.ReportingMetric)) AS ReportingMetric,

        /* A NULL ZoneArea contributes zero to the reported total. */
        COALESCE
        (
            SUM(CAST(arz.ZoneArea AS DECIMAL(38, 2))),
            CAST(0.00 AS DECIMAL(38, 2))
        ) AS TotalZoneAreaKM2,

        COUNT(*) AS ZoneRecordCount
    FROM [reporting].[AssessmentRegimeZone] AS arz
    WHERE UPPER(LTRIM(RTRIM(arz.ProtectionTarget))) = 'HEALTH'
    GROUP BY
        arz.CountryCode,
        arz.PollutantId,
        LTRIM(RTRIM(arz.ProtectionTarget)),
        LTRIM(RTRIM(arz.ObjectiveType)),
        LTRIM(RTRIM(arz.ReportingMetric))
)
SELECT
    g.CountryCode,
    g.PollutantId,
    g.ProtectionTarget,
    g.ObjectiveType,
    g.ReportingMetric,
    g.ZoneRecordCount,
    g.TotalZoneAreaKM2,
    ca.ReferenceYear,
    ca.OfficialAreaKM2,
    CAST(ca.OfficialAreaKM2 * 0.995 AS DECIMAL(38, 2))
        AS LowerToleranceLimitKM2,
    CAST(ca.OfficialAreaKM2 * 1.005 AS DECIMAL(38, 2))
        AS UpperToleranceLimitKM2,
    CASE
        WHEN ca.CountryCode IS NULL
          OR ca.OfficialAreaKM2 IS NULL
            THEN 'MISSING_OFFICIAL_COUNTRY_AREA'

        WHEN g.TotalZoneAreaKM2 < ca.OfficialAreaKM2 * 0.995
            THEN 'ZONE_AREA_BELOW_NATIONAL_COVERAGE_TOLERANCE'

        WHEN g.TotalZoneAreaKM2 > ca.OfficialAreaKM2 * 1.005
            THEN 'ZONE_AREA_ABOVE_NATIONAL_COVERAGE_TOLERANCE'

        ELSE 'UNKNOWN'
    END AS QC_FailureReason
FROM CTE_health_groups AS g
LEFT JOIN CTE_latest_country_area AS ca
    ON ca.CountryCode = g.CountryCode
   AND ca.RowNumber = 1
WHERE
    ca.CountryCode IS NULL
    OR ca.OfficialAreaKM2 IS NULL
    OR g.TotalZoneAreaKM2 < ca.OfficialAreaKM2 * 0.995
    OR g.TotalZoneAreaKM2 > ca.OfficialAreaKM2 * 1.005;
GO


