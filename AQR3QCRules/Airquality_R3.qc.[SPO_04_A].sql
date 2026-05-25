USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPO.04.A]    Script Date: 25/05/2026 14:38:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [qc].[SPO_04_A] AS

-- Creation date: July 2025
-- QC rule code: SPO.04.A
-- QC rule name: SPO.04.A Cross-check - [AirQualityStationEoICode] STA.02

WITH CTE_samplingpoint AS (
  SELECT --record_id,
         CASE WHEN "StationEoICode" = '' THEN NULL 
              ELSE "StationEoICode" 
         END AS "StationEoICode"
  FROM reporting."samplingpoint"
),

CTE_codes_from_SPOreportingTable_missing_in_StationReportingTable AS (
  SELECT /*record_id,*/ SPOreporting."StationEoICode"
  FROM CTE_samplingpoint as SPOreporting
  WHERE NOT EXISTS (
    SELECT StationReporting."StationEoICode"
	FROM reporting.MeasurementStation StationReporting 
	WHERE SPOreporting."StationEoICode" = StationReporting ."StationEoICode"
  ) 
),

CTE_codes_missing_from_StationReportingTable_missing_in_StationRefTable AS (
  SELECT /*record_id,*/ StationReporting."StationEoICode"
  FROM CTE_codes_from_SPOreportingTable_missing_in_StationReportingTable as StationReporting
  WHERE NOT EXISTS (
    SELECT StationRef."StationEoICode"
	FROM reference.MeasurementStation StationRef 
	WHERE StationReporting."StationEoICode" = StationRef."StationEoICode"
  ) 
)

SELECT DISTINCT * --record_id,
FROM CTE_codes_missing_from_StationReportingTable_missing_in_StationRefTable

GO


