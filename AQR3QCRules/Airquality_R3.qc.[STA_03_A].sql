USE [Airquality_R3]
GO

/****** Object:  View [qc].[STA_03_A_TEST]    Script Date: 11/06/2026 10:30:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






create or alter VIEW [qc].[STA_03_A] AS


-- QC rule code: STA.03.A
-- QC rule name: STA.03.A Constraint - [AirQualityNetwork] STA.01 STA.07


WITH CTE_station AS (
  SELECT 
    --record_id,
    CASE WHEN "networkid" = '' THEN NULL ELSE "networkid" END AS "network",
    CASE WHEN "countrycode" = '' THEN NULL ELSE "countrycode" END AS "countrycode",
    CASE WHEN "StationEoICode" = '' THEN NULL ELSE "StationEoICode" END AS "StationEoICode"
  FROM reporting.MeasurementStation
  WHERE "networkid" IS NOT NULL AND "countrycode" IS NOT NULL AND "StationEoICode" IS NOT NULL
),

duplicate_station_pairs AS (
  SELECT 
    network,
    countrycode,
	"StationEoICode"
  FROM CTE_station
  GROUP BY network, countrycode,"StationEoICode"
  HAVING COUNT(*) > 1
)--,

--bad_format AS (
	--SELECT [network], [countrycode], [StationEoICode]
	--FROM CTE_station
	--WHERE LEN([network]) < 3
		--OR [network] COLLATE Latin1_General_BIN2 LIKE '%0-9A-Za-z%' -- no alphanumeric character
		--OR NOT ( -- only num or string (add this condition if network should be strict alphanumeric)
		--[network] COLLATE Latin1_General_BIN2 LIKE '%[A-Za-z]%'
		--AND [network] COLLATE Latin1_General_BIN2 LIKE '%[0-9]%'
		--)
--)
SELECT 
  /*s.record_id,*/s.network,s.countrycode,s."StationEoICode"
FROM CTE_station s
INNER JOIN duplicate_station_pairs d
  ON s.network = d.network
 AND s.countrycode = d.countrycode
 AND s."StationEoICode" = d."StationEoICode"

--UNION ALL
--SELECT [network], [countrycode], [StationEoICode]--, 'Invalid network format' AS violation
--FROM bad_format;

GO


