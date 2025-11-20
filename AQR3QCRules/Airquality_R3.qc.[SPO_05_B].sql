USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPO_05_B]    Script Date: 20/11/2025 16:57:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [qc].[SPO_05_B] AS

-- Creation date: 02 September 2025
-- QC rule code: SPO_05_B
-- QC rule name:  SPO_05_B Constraint - [AirQualityStationArea] SPO_02
-- Modification date: 20 November 2025

WITH 
CTE_samplingPoint AS (
  SELECT 
    --record_id
    CASE WHEN "AirQualityStationArea" = '' THEN NULL 
      ELSE "AirQualityStationArea" END as "AirQualityStationArea"
    ,CASE WHEN "AssessmentMethodId" = '' THEN NULL 
      ELSE "AssessmentMethodId" END AS "AssessmentMethodId"
    FROM reporting."samplingpoint"
)

, several_AirQualityStationArea AS ( 
  SELECT DISTINCT 
         sp."AssessmentMethodId",
         --COUNT(DISTINCT(sp."AirQualityStationArea")) -- Reportnet 3
         COUNT(DISTINCT(sp."AirQualityStationArea")) AS CountingAirQualityStationArea -- SQL Server view
  FROM CTE_samplingPoint sp 
  GROUP BY sp."AssessmentMethodId"
  HAVING COUNT(DISTINCT(sp."AirQualityStationArea")) > 1
) 

SELECT --record_id -- Reportnet 3
       DISTINCT sp."AssessmentMethodId" -- SQL Server view
FROM CTE_samplingPoint sp 
INNER JOIN several_AirQualityStationArea saqsa
ON sp."AssessmentMethodId" = saqsa."AssessmentMethodId"


GO


