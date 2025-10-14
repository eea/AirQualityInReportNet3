USE [Airquality_R3]
GO

/****** Object:  View [qc].[CPL.PK]    Script Date: 22/09/2025 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qc].CPL AS

-- Creation date: 22 September 2025
-- QC rule code: CPL.PK
-- QC rule name: CPL.PK Constraint - [CountryCode,AttainmentId,PlanId,SourceAppId,ScenarioId]

WITH CTE_SR AS (
  SELECT 
    /*record_id,*/
    NULLIF("AttainmentId", '') AS AttainmentId  ,
    NULLIF("CountryCode", '') AS CountryCode,
	NULLIF("PlanId", '') AS PlanId, 
	NULLIF("SourceAppId", '') AS SourceAppId,
	NULLIF("ScenarioId", '') AS ScenarioId
	
	
  FROM reporting.CompliancePlanLink

),
duplicate_auth_records AS (
  SELECT 
    AttainmentId,
    CountryCode,
    PlanId,
	SourceAppId,
	ScenarioId
  FROM CTE_SR 
  GROUP BY AttainmentId, CountryCode,PlanId,SourceAppId,
	ScenarioId
  HAVING COUNT(*) > 1
)
SELECT 
  /*a.record_id,*/a.AttainmentId,a.CountryCode,a.PlanId,a.SourceAppId,
	a.ScenarioId

	FROM CTE_SR a
	LEFT JOIN duplicate_auth_records d
	  ON a.AttainmentId = d.AttainmentId
	 AND a.CountryCode = d.CountryCode
	 AND a.PlanId = d.PlanId
	 AND a.SourceAppId = d.SourceAppId
	 AND a.ScenarioId = d.ScenarioId
 
	WHERE d.AttainmentId IS NOT NULL  -- duplicity
	   OR a.AttainmentId IS NULL 
	   OR a.CountryCode IS NULL
	   OR a.PlanId IS NULL
	   OR a.SourceAppId IS NULL
	   OR a.ScenarioId IS NULL


GO


