USE [Airquality_R3]
GO

/****** Object:  View [qc].[STA_02_A]    Script Date: 12/11/2026 12:10:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


alter   VIEW [qc].[STA_02_A] AS

-- QC rule code: STA_02_A
-- QC rule name: STA_02_A Constraint - [StationEoICode]
-- QC rule description: StationEoICode is the official Exchange of Information (EoI) identifier for the air quality measurement station and must be unique within each reported CountryCode.

WITH s AS (
    SELECT
        NULLIF(LTRIM(RTRIM([StationEoICode])),'') AS [StationEoICode],
        NULLIF(LTRIM(RTRIM([CountryCode])),'')    AS [CountryCode]
    FROM [reporting].[MeasurementStation]
),
reported AS (
    SELECT
        [CountryCode],
        [StationEoICode],
        COUNT(*) AS [Occurrences]
    FROM s
    GROUP BY [CountryCode], [StationEoICode]
),
reference_stations AS (
    SELECT
        NULLIF(LTRIM(RTRIM([StationEoICode])),'') AS [StationEoICode],
        COUNT(*) AS [ReferenceStations]
    FROM [reference].[MeasurementStation]
    GROUP BY NULLIF(LTRIM(RTRIM([StationEoICode])),'')
)
SELECT
    r.[CountryCode],
    r.[StationEoICode]
FROM reported r
LEFT JOIN reference_stations rs
    ON r.[StationEoICode] = rs.[StationEoICode]
WHERE r.[StationEoICode] IS NULL        -- points 1-3: not reported / null / empty
   OR r.[Occurrences] > 1               -- point 4: same StationEoICode repeated within the same CountryCode
   
   --OR rs.[ReferenceStations] > 1;       -- point 5: code corresponds to more than one reference station
GO


