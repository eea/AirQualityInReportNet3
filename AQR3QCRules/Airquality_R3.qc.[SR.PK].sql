USE [Airquality_R3]
GO

/****** Object:  View [qc].[SR.PK]    Script Date: 22/09/2025 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qc].SR AS

-- Creation date: 22 September 2025
-- QC rule code: SR.PK
-- QC rule name: SR.PK Constraint - [CountryCode,SR_Id,SR_ApplicationId]


WITH CTE_SpaRep AS (
  SELECT 
    /*record_id,*/
    NULLIF("SR_Id", '') AS SR_Id  ,
    NULLIF("CountryCode", '') AS CountryCode,
	NULLIF("SR_ApplicationId", '') AS SR_ApplicationId
	
	
	FROM reporting.SpatialRepresentativeness
),
duplicate_auth_records AS (
  SELECT 
    SR_Id,
    CountryCode,
	SR_ApplicationId
    
  FROM CTE_SpaRep 
  GROUP BY SR_Id, CountryCode, SR_ApplicationId
  HAVING COUNT(*) > 1
)
SELECT 
  /*a.record_id,a.SR_Id,*/a.CountryCode,a.SR_ApplicationId
FROM CTE_SpaRep a
LEFT JOIN duplicate_auth_records d
  ON a.SR_Id = d.SR_Id
 AND a.CountryCode = d.CountryCode
 AND a.SR_ApplicationId = d.SR_ApplicationId
 
 
WHERE d.SR_Id IS NOT NULL  -- duplicity
   OR a.SR_Id IS NULL 
   OR a.CountryCode IS NULL
   OR a.SR_ApplicationId IS NULL
   


GO


