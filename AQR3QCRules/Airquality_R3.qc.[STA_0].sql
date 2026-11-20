USE [Airquality_R3];
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER VIEW [qc].[STA_0]
AS
-- QC rule code: STA_0
-- QC rule name: STA_0 Information - [MeasurementStation]
-- QC rule description:
-- Identify whether each submitted record represents a new measurement station
-- or an update to an existing one in the reference dataset.

WITH submitted AS
(
    SELECT
        ms.CountryCode,
        ms.StationNationalCode,

        NULLIF(
            LTRIM(RTRIM(ms.CountryCode)) COLLATE DATABASE_DEFAULT,
            ''
        ) AS CountryCodeClean,

        NULLIF(
            LTRIM(RTRIM(ms.StationNationalCode)) COLLATE DATABASE_DEFAULT,
            ''
        ) AS StationNationalCodeClean
    FROM [reporting].[MeasurementStation] AS ms
),
reference_data AS
(
    SELECT DISTINCT
        NULLIF(
            LTRIM(RTRIM(r.CountryCode)) COLLATE DATABASE_DEFAULT,
            ''
        ) AS CountryCodeClean,

        NULLIF(
            LTRIM(RTRIM(r.StationNationalCode)) COLLATE DATABASE_DEFAULT,
            ''
        ) AS StationNationalCodeClean
    FROM [reference].[MeasurementStation] AS r
)
SELECT
    s.CountryCode,
    s.StationNationalCode,
    CASE
        WHEN EXISTS
        (
            SELECT 1
            FROM reference_data AS r
            WHERE r.CountryCodeClean = s.CountryCodeClean
              AND r.StationNationalCodeClean = s.StationNationalCodeClean
        ) THEN
            'Modification of existing record'

        ELSE
            'Addition of new record'
    END AS record_status
FROM submitted AS s;
GO