USE [Airquality_R3]
GO

/****** Object:  View [qc].[STA_PK]    Script Date: 25/05/2026 14:12:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [qc].[STA_PK] AS

-- Creation date: 02 September 2025
-- QC rule code: STA.PK
-- QC rule name: STA.PK Constraint - [CountryCode,AirQualityStationEoICode]

WITH CTE_station AS (
  SELECT 
    
    NULLIF(StationNationalCode, '') AS StationNationalCode,
    NULLIF("CountryCode", '') AS CountryCode
   
  FROM reporting.MeasurementStation
),
duplicate_sta_records AS (
  SELECT 
    StationNationalCode,
    CountryCode
  FROM CTE_station 
  GROUP BY StationNationalCode, CountryCode
  HAVING COUNT(*) > 1
)
SELECT 
  /*a.record_id,*/a.StationNationalCode,a.CountryCode
FROM CTE_station a
LEFT JOIN duplicate_sta_records d
  ON a.StationNationalCode = d.StationNationalCode
 AND a.CountryCode = d.CountryCode
 
WHERE d.StationNationalCode IS NOT NULL  -- duplicity
   OR a.StationNationalCode IS NULL 
   OR a.CountryCode IS NULL
   


GO


