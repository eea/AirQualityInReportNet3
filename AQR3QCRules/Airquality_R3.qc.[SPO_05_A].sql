USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qc].[SPO_05_A] AS

-- Creation date: 02 September 2025
-- QC rule code: SPO_05_A
-- QC rule name:  SPO_05_A Vocabulary - [AirQualityStationArea]

WITH CTE_sampligPoint AS ( 
SELECT /*record_id ,*/
CASE WHEN "AirQualityStationArea" = '' THEN NULL ELSE "AirQualityStationArea" END as "AirQualityStationArea" 
FROM reporting."SamplingPoint" ) 

,missing_codes AS ( 
SELECT /*s.record_id,*/ s."AirQualityStationArea" 
FROM CTE_sampligPoint s 
LEFT JOIN reference."vocabulary" v 
ON s."AirQualityStationArea" = v."notation" COLLATE Latin1_General_CI_AS AND v."vocabulary" = 'areaclassification'
WHERE v."notation" COLLATE Latin1_General_CI_AS IS NULL 
      AND s.AirQualityStationArea IS NOT NULL
) 

SELECT * FROM missing_codes
