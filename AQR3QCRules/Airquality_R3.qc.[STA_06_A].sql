USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[STA_06_A] AS
-- Creation date: June 2026
-- QC rule code: STA_06_A
-- QC rule name: STA_06_A Vocabulary - [TimeZone]
-- QC rule description: TimeZone shall be reported using a valid value from the timezone vocabulary.
WITH CTE_stationTimeZone AS (
    SELECT
        NULLIF(LTRIM(RTRIM(TimeZone)), '') AS TimeZone
    FROM reporting.MeasurementStation
),
invalid_codes AS (
    SELECT
        tz.TimeZone
    FROM CTE_stationTimeZone AS tz
    LEFT JOIN reference.vocabulary AS v
        ON tz.TimeZone = v.notation COLLATE Latin1_General_CI_AS
        AND v.vocabulary = 'timezone'
    WHERE tz.TimeZone IS NULL
       OR v.notation IS NULL
)
SELECT DISTINCT
    TimeZone
FROM invalid_codes
GO