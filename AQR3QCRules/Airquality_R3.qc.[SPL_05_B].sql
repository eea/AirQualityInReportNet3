USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPL_05_B]    Script Date: 15/06/2026 14:10:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [qc].[SPL_05_B] AS


-- QC rule code: [SPL_05_B]
-- QC rule name:  [SPL_05_B] Constraint - [StationArea] SPO_02

WITH 
CTE_samplingPoint AS (
  SELECT 
    --record_id
    CASE WHEN "StationArea" = '' THEN NULL 
      ELSE "StationArea" END as "StationArea"
    ,CASE WHEN "AssessmentMethodId" = '' THEN NULL 
	  ELSE "AssessmentMethodId" END AS "AssessmentMethodId"
    FROM reporting."samplingpointlocation"
)

, several_StationArea AS ( 
  SELECT DISTINCT 
         sp."AssessmentMethodId",
         --COUNT(DISTINCT(sp."StationArea")) -- Reportnet 3
		 COUNT(DISTINCT(sp."StationArea")) AS CountingStationArea -- SQL Server view
  FROM CTE_samplingPoint sp 
  GROUP BY sp."AssessmentMethodId"
  HAVING COUNT(DISTINCT(sp."StationArea")) > 1
) 

SELECT --record_id -- Reportnet 3
       DISTINCT sp."AssessmentMethodId" -- SQL Server view
FROM CTE_samplingPoint sp 
INNER JOIN several_StationArea saqsa
ON sp."AssessmentMethodId" = saqsa."AssessmentMethodId"


GO


