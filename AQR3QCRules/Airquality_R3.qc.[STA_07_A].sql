USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qc].[STA_07_A] AS

-- Creation date: 02 September 2025
-- QC rule code: STA_07_A
-- QC rule name: STA_07_A Format - [AirQualityStationEoICode]

WITH CTE_station AS ( 
  SELECT 
    /*record_id,*/
    NULLIF(airqualitystationeoicode, '') AS airqualitystationeoicode
  FROM reporting.station
  WHERE airqualitystationeoicode IS NOT NULL 
),
StationCodeCheck AS (
    SELECT 
       /* record_id,*/
        airqualitystationeoicode,
        CASE
             WHEN airqualitystationeoicode LIKE '[A-Z][A-Z][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9]' 
         AND LEN(airqualitystationeoicode) = 7
                 THEN 'Valid'
            ELSE 'Invalid'
        END AS CodeStatus
    FROM CTE_station
)
SELECT *
FROM StationCodeCheck
WHERE CodeStatus <> 'Valid'

