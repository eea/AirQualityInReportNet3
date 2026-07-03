USE [Airquality_R3]
GO

/****** Object:  View [qc].[STA_07_A]    Script Date: 02/07/2026 14:31:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





create or alter VIEW [qc].[STA_07_A] AS


-- QC rule code: STA.07.A
-- QC rule name: STA.07.A Format - [AirQualityStationNationalCode]

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

