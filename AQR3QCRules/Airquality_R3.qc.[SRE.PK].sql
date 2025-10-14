USE [Airquality_R3]
GO

/****** Object:  View [qc].[SRE.PK]    Script Date: 22/09/2025 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qc].[SRE.PK] AS

-- Creation date: 22 September 2025
-- QC rule code: SRE.PK
-- QC rule name: SRE.PK Constraint - [CountryCode,SR_ApplicationId]

WITH CTE_SRAE AS (
  SELECT 
    /*record_id,*/
    NULLIF("SR_ApplicationId", '') AS SR_ApplicationId  ,
    NULLIF("CountryCode", '') AS CountryCode
	
	
	
  FROM reporting.SRArea_External
),
duplicate_auth_records AS (
  SELECT 
    SR_ApplicationId,
    CountryCode
    
  FROM CTE_SRAE 
  GROUP BY SR_ApplicationId, CountryCode
  HAVING COUNT(*) > 1
)
SELECT 
  /*a.record_id,*/a.SR_ApplicationId,a.CountryCode
FROM CTE_SRAE a
LEFT JOIN duplicate_auth_records d
  ON a.SR_ApplicationId = d.SR_ApplicationId
 AND a.CountryCode = d.CountryCode
 
 
 
WHERE d.SR_ApplicationId IS NOT NULL  -- duplicity
   OR a.SR_ApplicationId IS NULL 
   OR a.CountryCode IS NULL


GO


