USE [Airquality_R3]
GO

/****** Object:  View [qc].[STA_PK]    Script Date: 11/06/2026 13:42:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [qc].[STA_PK] AS

-- QC rule code: STA.PK
-- QC rule name: STA.PK Constraint - [CountryCode,AirQualityStationEoICode]

WITH CTE_station AS (
  SELECT 
    
    NULLIF(StationEoICode, '') AS StationEoICode,
    NULLIF("CountryCode", '') AS CountryCode
   
  FROM reporting.MeasurementStation
),
duplicate_sta_records AS (
  SELECT 
    StationEoICode,
    CountryCode
  FROM CTE_station 
  GROUP BY StationEoICode, CountryCode
  HAVING COUNT(*) > 1
)
SELECT 
  /*a.record_id,*/a.StationEoICode,a.CountryCode
FROM CTE_station a
LEFT JOIN duplicate_sta_records d
  ON a.StationEoICode = d.StationEoICode
 AND a.CountryCode = d.CountryCode
 
WHERE d.StationEoICode IS NOT NULL  -- duplicity
   OR a.StationEoICode IS NULL 
   OR a.CountryCode IS NULL
   


GO


