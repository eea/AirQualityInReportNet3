USE [Airquality_R3]
GO

/****** Object:  View [qc].[SRI_PK]    Script Date: 22/09/2025 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qc].[SRI_PK] AS

-- Creation date: 22 September 2025
-- QC rule code: SRI_PK
-- QC rule name: SRI_PK Constraint - [CountryCode,SR_ApplicationId,X,Y]

WITH CTE_SRAI AS (
  SELECT 
    /*record_id,*/
    NULLIF("SR_ApplicationId", '') AS SR_ApplicationId  ,
    NULLIF("CountryCode", '') AS CountryCode,
	NULLIF("X", '') AS X,
	NULLIF("Y", '') AS Y
	
	
  FROM reporting.SRArea_Inline
),
duplicate_auth_records AS (
  SELECT 
    SR_ApplicationId,
    CountryCode,
	X,
	Y
    
  FROM CTE_SRAI 
  GROUP BY SR_ApplicationId, CountryCode, X,Y
  HAVING COUNT(*) > 1
)
SELECT 
  /*a.record_id,*/a.SR_ApplicationId,a.CountryCode,a.X,a.Y
FROM CTE_SRAI a
LEFT JOIN duplicate_auth_records d
  ON a.SR_ApplicationId = d.SR_ApplicationId
 AND a.CountryCode = d.CountryCode
 AND a.X = d.X
 AND a.Y = d.Y
 
 
WHERE d.SR_ApplicationId IS NOT NULL  -- duplicity
   OR a.SR_ApplicationId IS NULL 
   OR a.CountryCode IS NULL
   OR a.X IS NULL
   OR a.Y IS NULL
   
  

GO


