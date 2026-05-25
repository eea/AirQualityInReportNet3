USE [Airquality_R3]
GO

/****** Object:  View [qc].[STA.03.A]    Script Date: 25/05/2026 13:41:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [qc].[STA_03_A] AS

-- Creation date: 21 August 2025
-- QC rule code: STA.03.A
-- QC rule name: STA.03.A Constraint - [AirQualityNetwork] STA.01 STA.07


WITH CTE_station AS (
  SELECT 
    --record_id,
    CASE WHEN "networkid" = '' THEN NULL ELSE "networkid" END AS "network",
    CASE WHEN "countrycode" = '' THEN NULL ELSE "countrycode" END AS "countrycode",
    CASE WHEN "StationNationalCode" = '' THEN NULL ELSE "StationNationalCode" END AS "StationNationalCode"
  FROM reporting.MeasurementStation
  WHERE "networkid" IS NOT NULL AND "countrycode" IS NOT NULL AND "StationNationalCode" IS NOT NULL
),

duplicate_station_pairs AS (
  SELECT 
    network,
    countrycode,
	"StationNationalCode"
  FROM CTE_station
  GROUP BY network, countrycode,"StationNationalCode"
  HAVING COUNT(*) > 1
)

SELECT 
  /*s.record_id,*/s.network,s.countrycode,s."StationNationalCode"
FROM CTE_station s
INNER JOIN duplicate_station_pairs d
  ON s.network = d.network
 AND s.countrycode = d.countrycode
 AND s."StationNationalCode" = d."StationNationalCode"


GO


