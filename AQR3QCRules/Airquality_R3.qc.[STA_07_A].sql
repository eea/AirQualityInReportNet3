USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[STA_07_A]
AS
-- QC rule code: STA_07_A
-- QC rule name: STA_07_A Cross-check - [StationEoICode], [StationNationalCode]
-- QC rule description: StationNationalCode shall be consistently associated with the corresponding StationEoICode within each reported CountryCode.
WITH submitted AS
(
    SELECT
        ms.CountryCode,
        ms.StationEoICode,
        ms.StationNationalCode,
        NULLIF(LTRIM(RTRIM(ms.CountryCode)), '') AS CountryCodeClean,
        NULLIF(LTRIM(RTRIM(ms.StationEoICode)), '') AS StationEoICodeClean,
        NULLIF(LTRIM(RTRIM(ms.StationNationalCode)), '') AS StationNationalCodeClean
    FROM [reporting].[MeasurementStation] AS ms
),
inconsistent_submitted_values AS
(
    SELECT
        CountryCodeClean,
        StationEoICodeClean
    FROM submitted
    WHERE StationNationalCodeClean IS NOT NULL
    GROUP BY
        CountryCodeClean,
        StationEoICodeClean
    HAVING COUNT(DISTINCT StationNationalCodeClean) > 1
)
SELECT DISTINCT
    s.CountryCode,
    s.StationEoICode,
    s.StationNationalCode
FROM submitted AS s
WHERE
    -- StationNationalCode is missing, NULL, empty, or whitespace-only
    s.StationNationalCodeClean IS NULL

    -- The same StationEoICode has different StationNationalCode values
    -- within the same reported CountryCode
    OR EXISTS
    (
        SELECT 1
        FROM inconsistent_submitted_values AS i
        WHERE i.CountryCodeClean = s.CountryCodeClean
          AND i.StationEoICodeClean = s.StationEoICodeClean
    )

    -- A reference record exists for the CountryCode + StationEoICode pair,
    -- but the reported StationNationalCode does not match it
    OR
    (
        EXISTS
        (
            SELECT 1
            FROM [reference].[MeasurementStation] AS r
            WHERE NULLIF(LTRIM(RTRIM(r.CountryCode)), '') = s.CountryCodeClean
              AND NULLIF(LTRIM(RTRIM(r.StationEoICode)), '') = s.StationEoICodeClean
        )
        AND NOT EXISTS
        (
            SELECT 1
            FROM [reference].[MeasurementStation] AS r
            WHERE NULLIF(LTRIM(RTRIM(r.CountryCode)), '') = s.CountryCodeClean
              AND NULLIF(LTRIM(RTRIM(r.StationEoICode)), '') = s.StationEoICodeClean
              AND NULLIF(LTRIM(RTRIM(r.StationNationalCode)), '') = s.StationNationalCodeClean
        )
    )
GO