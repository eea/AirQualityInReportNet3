USE [Airquality_R3]
GO

/****** Object:  View [qc].[STA.07.A]    Script Date: 25/05/2026 14:00:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [qc].[STA_07_A] AS

-- Creation date: 02 September 2025
-- QC rule code: STA.07.A
-- QC rule name: STA.07.A Format - [AirQualityStationEoICode]

WITH CTE_station AS ( 
  SELECT 
    /*record_id,*/
    NULLIF(StationNationalCode, '') AS StationNationalCode
  FROM reporting.MeasurementStation
  WHERE StationNationalCode IS NOT NULL 
),
StationCodeCheck AS (
    SELECT 
       /* record_id,*/
        StationNationalCode,
        CASE
             WHEN StationNationalCode LIKE '[A-Z][A-Z][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9]' 
         AND LEN(StationNationalCode) = 7
                 THEN 'Valid'
            ELSE 'Invalid'
        END AS CodeStatus
    FROM CTE_station
)
SELECT *
FROM StationCodeCheck
WHERE CodeStatus <> 'Valid'

GO


