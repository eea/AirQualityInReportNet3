USE [Airquality_R3]
GO

/****** Object:  View [qc].[ZOG_PK]    Script Date: 22/09/2025 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qc].ZOG AS

-- Creation date: 22 September 2025
-- QC rule code: ZOG_PK
-- QC rule name: �ZOG_PK Constraint - [CountryCode,ZoneId]

WITH CTE_zone AS (
  SELECT 
    /*record_id,*/
    NULLIF("ZoneId", '') AS ZoneId,
    NULLIF("CountryCode", '') AS CountryCode
    
  FROM reporting.ZoneGeometry
),
duplicate_auth_records AS (
  SELECT 
    ZoneId,
    CountryCode
    
  FROM CTE_zone 
  GROUP BY ZoneId, CountryCode
  HAVING COUNT(*) > 1
)
SELECT 
  /*a.record_id,*/a.ZoneId,a.CountryCode
FROM CTE_zone a
LEFT JOIN duplicate_auth_records d
  ON a.ZoneId = d.ZoneId
 AND a.CountryCode = d.CountryCode
 
 
WHERE d.ZoneId IS NOT NULL  -- duplicity
   OR a.ZoneId IS NULL 
   OR a.CountryCode IS NULL


GO


