USE [Airquality_R3]
GO

/****** Object:  View [qc].[STA_06_A]    Script Date: 24/06/2026 11:43:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [qc].[STA_06_A] AS

-- Creation date: June 2026
-- QC rule code: STA_03_A2
-- QC rule name: STA_03_A2 Vocabulary - [TimeZone]

WITH CTE_stationTimeZone AS ( 
SELECT --record_id ,
NULLIF(LTRIM(RTRIM(TimeZone)), '') AS TimeZone
FROM reporting.MeasurementStation ) ,

missing_codes AS ( 
SELECT /*sp.record_id,*/ tz.TimeZone 
FROM CTE_stationTimeZone tz 
LEFT JOIN reference."vocabulary" v 
ON tz.TimeZone = v."notation" COLLATE Latin1_General_CI_AS AND v."vocabulary" = 'timezone'
WHERE 
  (v."notation" IS NULL AND tz.TimeZone IS NOT NULL) 
  
)

SELECT DISTINCT * FROM missing_codes





GO


