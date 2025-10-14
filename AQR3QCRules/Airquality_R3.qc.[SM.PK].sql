USE [Airquality_R3]
GO

/****** Object:  View [qc].[SM.PK]    Script Date: 22/09/2025 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qc].[SM.PK] AS

-- Creation date: 22 September 2025
-- QC rule code: SM.PK
-- QC rule name: SM.PK Constraint - [CountryCode,ScenarioId,ScenarioCategory,MeasureGroupId]

WITH CTE_SM AS (
  SELECT 
    /*record_id,*/
    NULLIF("ScenarioId", '') AS ScenarioId   ,
    NULLIF("CountryCode", '') AS CountryCode,
	NULLIF("ScenarioCategory", '') AS ScenarioCategory, 
	NULLIF("MeasureGroupId", '') AS MeasureGroupId
	
	
  FROM reporting.ScenarioMeasure
),
duplicate_auth_records AS (
  SELECT 
    ScenarioId ,
    CountryCode,
    ScenarioCategory,
	MeasureGroupId
	
  FROM CTE_SM 
  GROUP BY ScenarioId , CountryCode,ScenarioCategory,MeasureGroupId
	
  HAVING COUNT(*) > 1
)
SELECT 
  /*a.record_id,*/a.ScenarioId ,a.CountryCode,a.ScenarioCategory,a.MeasureGroupId
	
FROM CTE_SM a
LEFT JOIN duplicate_auth_records d
  ON a.ScenarioId  = d.ScenarioId 
 AND a.CountryCode = d.CountryCode
 AND a.ScenarioCategory = d.ScenarioCategory
 AND a.MeasureGroupId=a.MeasureGroupId
 
 
WHERE d.CountryCode  IS NOT NULL  -- duplicity
   OR a.CountryCode  IS NULL 
   OR a.ScenarioId IS NULL
   OR a.ScenarioCategory IS NULL
   OR a.MeasureGroupId IS NULL


GO


