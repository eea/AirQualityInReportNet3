USE [Airquality_R3];
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER VIEW [qc].[STA_08_B]
AS
-- QC rule code: STA_08_B
-- QC rule name: STA_08_B Content check - [StationName]
-- QC rule description:
-- StationName must have a length greater than 0 and less than 51 characters.

SELECT
    ms.[StationEoICode],
    ms.[CountryCode],
    ms.[StationName]
FROM [reporting].[MeasurementStation] AS ms
WHERE
    ms.[StationName] IS NULL
    OR LEN(LTRIM(RTRIM(ms.[StationName]))) NOT BETWEEN 1 AND 50;
GO