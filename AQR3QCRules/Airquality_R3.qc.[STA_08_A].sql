USE [Airquality_R3];
GO

CREATE OR ALTER VIEW [qc].[STA_08_A]
AS
-- QC rule code: STA_08_A
-- QC rule name: STA_08_A Cross-check - [StationEoICode], [StationName]

WITH submitted AS
(
    SELECT
        ms.CountryCode,
        ms.StationEoICode,
        ms.StationName,
        NULLIF(LTRIM(RTRIM(ms.CountryCode)), '') AS CountryCodeClean,
        NULLIF(LTRIM(RTRIM(ms.StationEoICode)), '') AS StationEoICodeClean,
        NULLIF(LTRIM(RTRIM(ms.StationName)), '') AS StationNameClean
    FROM [reporting].[MeasurementStation] AS ms
),
inconsistent_submitted_values AS
(
    SELECT
        CountryCodeClean,
        StationEoICodeClean
    FROM submitted
    WHERE StationNameClean IS NOT NULL
    GROUP BY
        CountryCodeClean,
        StationEoICodeClean
    HAVING COUNT(DISTINCT StationNameClean) > 1
)
SELECT DISTINCT
    s.CountryCode,
    s.StationEoICode,
    s.StationName,
    CASE
        WHEN s.StationNameClean IS NULL THEN
            'StationName is mandatory and cannot be null, empty or whitespace-only.'

        WHEN EXISTS
        (
            SELECT 1
            FROM inconsistent_submitted_values AS i
            WHERE i.CountryCodeClean = s.CountryCodeClean
              AND i.StationEoICodeClean = s.StationEoICodeClean
        ) THEN
            'StationName is not consistently associated with the reported StationEoICode within the reported CountryCode.'

        WHEN EXISTS
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
              AND NULLIF(LTRIM(RTRIM(r.StationName)), '') = s.StationNameClean
        ) THEN
            'StationName does not match the reference value associated with the reported CountryCode and StationEoICode.'
    END AS ErrorMessage
FROM submitted AS s
WHERE
    s.StationNameClean IS NULL

    OR EXISTS
    (
        SELECT 1
        FROM inconsistent_submitted_values AS i
        WHERE i.CountryCodeClean = s.CountryCodeClean
          AND i.StationEoICodeClean = s.StationEoICodeClean
    )

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
              AND NULLIF(LTRIM(RTRIM(r.StationName)), '') = s.StationNameClean
        )
    );
GO