USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPL_05_A]    Script Date: 15/06/2026 14:10:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [qc].[SPL_05_A] AS


-- QC rule code: [SPL_05_A]
-- QC rule name:  [SPL_05_A] Vocabulary - [AirQualityStationArea]

WITH CTE_sampligPoint AS ( 
SELECT /*record_id ,*/
CASE WHEN "StationArea" = '' THEN NULL ELSE "StationArea" END as "StationArea" 
FROM reporting."SamplingPointLocation" ) 

,missing_codes AS ( 
SELECT /*s.record_id,*/ s."StationArea" 
FROM CTE_sampligPoint s 
LEFT JOIN reference."vocabulary" v 
ON s."StationArea" = v."notation" COLLATE Latin1_General_CI_AS AND v."vocabulary" = 'areaclassification'
WHERE v."notation" COLLATE Latin1_General_CI_AS IS NULL 
      AND s.StationArea IS NOT NULL
) 

SELECT * FROM missing_codes
GO


