USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qc].[STA_PK] AS

-- Creation date: 02 September 2025
-- QC rule code: STA_PK
-- QC rule name: STA_PK Constraint - [CountryCode,AirQualityStationEoICode]

WITH CTE_station AS (
  SELECT 
    
    NULLIF("airqualitystationeoicode", '') AS airqualitystationeoicode,
    NULLIF("CountryCode", '') AS CountryCode
   
  FROM reporting."station"
),
duplicate_sta_records AS (
  SELECT 
    airqualitystationeoicode,
    CountryCode
  FROM CTE_station 
  GROUP BY airqualitystationeoicode, CountryCode
  HAVING COUNT(*) > 1
)
SELECT 
  /*a.record_id,*/a.airqualitystationeoicode,a.CountryCode
FROM CTE_station a
LEFT JOIN duplicate_sta_records d
  ON a.airqualitystationeoicode = d.airqualitystationeoicode
 AND a.CountryCode = d.CountryCode
 
WHERE d.airqualitystationeoicode IS NOT NULL  -- duplicity
   OR a.airqualitystationeoicode IS NULL 
   OR a.CountryCode IS NULL
   


