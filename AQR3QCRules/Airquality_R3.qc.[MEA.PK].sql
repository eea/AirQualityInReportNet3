USE [Airquality_R3]
GO

/****** Object:  View [qc].[MEA.PK]    Script Date: 22/09/2025 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qc].[MEA.PK] AS

-- Creation date: 22 September 2025
-- QC rule code: MEA.PK
-- QC rule name: MEA.PK Constraint - [CountryCode,MeasureGroupId,MeasureId]

WITH CTE_Measure AS (
  SELECT 
    /*record_id,*/
    NULLIF("MeasureGroupId", '') AS MeasureGroupId   ,
    NULLIF("CountryCode", '') AS CountryCode,
	NULLIF("MeasureId", '') AS MeasureId 
	
  FROM reporting.Measure
),

duplicate_auth_records AS (
  SELECT 
    MeasureGroupId ,
    CountryCode,
    MeasureId
	
  FROM CTE_Measure 
  GROUP BY MeasureGroupId , CountryCode,MeasureId
	
  HAVING COUNT(*) > 1
)

SELECT 
  /*a.record_id,*/a.MeasureGroupId ,a.CountryCode,a.MeasureId
	
FROM CTE_Measure a
	LEFT JOIN duplicate_auth_records d
	  ON a.MeasureGroupId  = d.MeasureGroupId 
	 AND a.CountryCode = d.CountryCode
	 AND a.MeasureId = d.MeasureId

 
 
	WHERE d.CountryCode  IS NOT NULL  -- duplicity
	   OR a.CountryCode  IS NULL 
	   OR a.MeasureGroupId IS NULL
	   OR a.MeasureId IS NULL


GO


