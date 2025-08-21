USE [Airquality_R3]
GO

/****** Object:  View [qc].[STA.03.A]    Script Date: 21/08/2025 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [qc].[STA.03.A] AS

-- Creation date: 21 August 2025
-- QC rule code: STA.03.A
-- QC rule name: STA.03.A Constraint - [AirQualityNetwork] STA.01 STA.07


WITH CTE_station AS (
  SELECT 
    --record_id,
    CASE WHEN "airqualitynetwork" = '' THEN NULL ELSE "airqualitynetwork" END AS "airqualitynetwork",
    CASE WHEN "countrycode" = '' THEN NULL ELSE "countrycode" END AS "countrycode",
    CASE WHEN "AirQualityStationEoICode" = '' THEN NULL ELSE "AirQualityStationEoICode" END AS "AirQualityStationEoICode"
  FROM reporting.Station
  WHERE "airqualitynetwork" IS NOT NULL AND "countrycode" IS NOT NULL AND "AirQualityStationEoICode" IS NOT NULL
),

duplicate_station_pairs AS (
  SELECT 
    airqualitynetwork,
    countrycode,
	AirQualityStationEoICode
  FROM CTE_station
  GROUP BY airqualitynetwork, countrycode,AirQualityStationEoICode
  HAVING COUNT(*) > 1
)

SELECT 
  /*s.record_id,*/s.airqualitynetwork,s.countrycode,s.AirQualityStationEoICode
FROM CTE_station s
INNER JOIN duplicate_station_pairs d
  ON s.airqualitynetwork = d.airqualitynetwork
 AND s.countrycode = d.countrycode
 AND s.AirQualityStationEoICode = d.AirQualityStationEoICode


GO


