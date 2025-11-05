USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPO_04_A]    Script Date: 16/07/2025 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [qc].[SPO_04_A] AS

-- Creation date: July 2025
-- QC rule code: SPO_04_A
-- QC rule name: SPO_04_A Cross-check - [AirQualityStationEoICode] STA_02

WITH CTE_samplingpoint AS (
  SELECT --record_id,
         CASE WHEN "airqualitystationeoicode" = '' THEN NULL 
              ELSE "airqualitystationeoicode" 
         END AS "airqualitystationeoicode"
  FROM reporting."samplingpoint"
),

CTE_codes_from_SPOreportingTable_missing_in_StationReportingTable AS (
  SELECT /*record_id,*/ SPOreporting."airqualitystationeoicode"
  FROM CTE_samplingpoint as SPOreporting
  WHERE NOT EXISTS (
    SELECT StationReporting.AirQualityStationEoICode
	FROM reporting.Station StationReporting 
	WHERE SPOreporting.airqualitystationeoicode = StationReporting .AirQualityStationEoICode
  ) 
),

CTE_codes_missing_from_StationReportingTable_missing_in_StationRefTable AS (
  SELECT /*record_id,*/ StationReporting."airqualitystationeoicode"
  FROM CTE_codes_from_SPOreportingTable_missing_in_StationReportingTable as StationReporting
  WHERE NOT EXISTS (
    SELECT StationRef.AirQualityStationEoICode
	FROM reference.Station StationRef 
	WHERE StationReporting.airqualitystationeoicode = StationRef.AirQualityStationEoICode
  ) 
)

SELECT DISTINCT * --record_id,
FROM CTE_codes_missing_from_StationReportingTable_missing_in_StationRefTable

GO


