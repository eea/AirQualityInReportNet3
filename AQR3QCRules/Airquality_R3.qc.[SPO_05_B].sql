USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qc].[SPO_05_B] AS

-- Creation date: 02 September 2025
-- QC rule code: SPO_05_B
-- QC rule name:  SPO_05_B Constraint - [AirQualityStationArea] SPO_02

WITH CTE_samplingpoint AS (
  SELECT    
    CASE WHEN "AirQualityStationArea" = '' THEN NULL ELSE "AirQualityStationArea" END AS "AirQualityStationArea",
    CASE WHEN "AssessmentMethodId" = '' THEN NULL ELSE "AssessmentMethodId" END AS "AssessmentMethodId"
  FROM reporting."samplingpoint"
  WHERE "AirQualityStationArea" IS NOT NULL AND "AssessmentMethodId" IS NOT NULL
),

duplicate_spo_pairs AS (
  SELECT 
   AirQualityStationArea,
    AssessmentMethodId
  FROM CTE_samplingpoint s
  GROUP BY AirQualityStationArea, AssessmentMethodId
  HAVING COUNT(*) > 1
)

SELECT 
s.*
FROM CTE_samplingpoint s
INNER JOIN duplicate_spo_pairs d
  ON s.AirQualityStationArea = d.AirQualityStationArea
 AND s.AssessmentMethodId = d.AssessmentMethodId