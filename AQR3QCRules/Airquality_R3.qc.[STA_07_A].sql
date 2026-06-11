USE [Airquality_R3]
GO

/****** Object:  View [qc].[STA_07_A]    Script Date: 11/06/2026 13:01:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [qc].[STA_07_A] AS


-- QC rule code: STA.07.A
-- QC rule name: STA.07.A Format - [AirQualityStationEoICode]

WITH CTE_station AS ( 
  SELECT 
    /*record_id,*/
    NULLIF(StationEoICode, '') AS StationEoICode
  FROM reporting.MeasurementStation
  WHERE StationEoICode IS NOT NULL 
),
StationCodeCheck AS (
    SELECT 
       /* record_id,*/
        StationEoICode,
        CASE
             WHEN StationEoICode LIKE '[A-Z][A-Z][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9]' 
         AND LEN(StationEoICode) = 7
                 THEN 'Valid'
            ELSE 'Invalid'
        END AS CodeStatus
    FROM CTE_station
)
SELECT *
FROM StationCodeCheck
WHERE CodeStatus <> 'Valid'

GO


