USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPP.09.A]    Script Date: 23/10/2025 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [qc].[SPP.09.A] AS

-- Creation date: 23 October 2025
-- QC rule code: SPP.09.A
-- QC rule name: SPP.09.A Vocabulary - [MeasurementEquipment]


WITH CTE_samplingprocess AS ( 
SELECT /*record_id ,*/
  CASE WHEN "measurementtype" = '' THEN NULL ELSE "measurementtype" END as "measurementtype",
  CASE WHEN "measurementequipment" = '' THEN NULL ELSE "measurementequipment" END as "measurementequipment" 
FROM reporting."samplingprocess" ) 

, missing_codes AS ( 
SELECT /*sp.record_id,*/ sp."measurementtype", sp."measurementequipment" 
FROM CTE_samplingprocess sp 
LEFT JOIN reference."vocabulary" v 
ON sp."measurementequipment" = v."notation" COLLATE Latin1_General_CI_AS AND v."vocabulary" = 'measurementequipment'
WHERE 
  (v."notation" IS NULL AND sp."measurementequipment" IS NOT NULL) 
  OR
  (v."notation" IS NULL AND sp."measurementtype" IN ('automatic', 'remote'))
  OR
  (v."notation" IS NOT NULL AND sp."measurementtype" IN ('active', 'passive'))
) 

SELECT DISTINCT * FROM missing_codes


GO

