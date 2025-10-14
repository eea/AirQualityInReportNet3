USE [Airquality_R3]
GO

/****** Object:  View [qc].[PS.PK]    Script Date: 22/09/2025 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qc].[PS.PK] AS

-- Creation date: 22 September 2025
-- QC rule code: PS.PK
-- QC rule name: PS.PK Constraint - [CountryCode,PlanId,ScenarioId,ScenarioCategory]

WITH CTE_PS AS (
  SELECT 
    /*record_id,*/
    NULLIF("ScenarioCategory", '') AS ScenarioCategory   ,
    NULLIF("CountryCode", '') AS CountryCode,
	NULLIF("PlanId", '') AS PlanId, 	
	NULLIF("ScenarioId", '') AS ScenarioId	
	
	
  FROM reporting.PlanScenario
),
duplicate_auth_records AS (
  SELECT 
    ScenarioCategory ,
    CountryCode,
    PlanId,	
	ScenarioId
  FROM CTE_PS 
  GROUP BY ScenarioCategory , CountryCode,PlanId,
	ScenarioId
  HAVING COUNT(*) > 1
)
SELECT 
  /*a.record_id,*/a.ScenarioCategory ,a.CountryCode,a.PlanId,
	a.ScenarioId
	FROM CTE_PS a
	LEFT JOIN duplicate_auth_records d
	  ON a.ScenarioCategory  = d.ScenarioCategory 
	 AND a.CountryCode = d.CountryCode
	 AND a.PlanId = d.PlanId
 
	 AND a.ScenarioId = d.ScenarioId
 
	WHERE d.CountryCode  IS NOT NULL  -- duplicity
	   OR a.CountryCode  IS NULL 
	   OR a.ScenarioCategory IS NULL
	   OR a.PlanId IS NULL  
	   OR a.ScenarioId IS NULL


GO


