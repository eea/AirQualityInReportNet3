USE [Airquality_R3]
GO

/****** Object:  View [qc].[ADJ.PK]    Script Date: 22/09/2025 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qc].ADJ AS

-- Creation date: 22 September 2025
-- QC rule code: ADJ.PK
-- QC rule name: ADJ.PK Constraint - [CountryCode,AttainmentId,Adj_AssessmentMethodId]


WITH CTE_SRAE AS (
  SELECT 
    /*record_id,*/
    NULLIF("AttainmentId", '') AS AttainmentId  ,
    NULLIF("CountryCode", '') AS CountryCode,
	NULLIF("Adj_AssessmentMethodId", '') AS Adj_AssessmentMethodId 
	
		
  FROM reporting.Adjustment
),

duplicate_auth_records AS (
  SELECT 
    AttainmentId,
    CountryCode,
    Adj_AssessmentMethodId
  FROM CTE_SRAE 
  GROUP BY AttainmentId, CountryCode,Adj_AssessmentMethodId
  HAVING COUNT(*) > 1
)
SELECT 
  /*a.record_id,*/a.AttainmentId,a.CountryCode,a.Adj_AssessmentMethodId
FROM CTE_SRAE a
LEFT JOIN duplicate_auth_records d
  ON a.AttainmentId = d.AttainmentId
 AND a.CountryCode = d.CountryCode
 AND a.Adj_AssessmentMethodId = d.Adj_AssessmentMethodId
 
 
WHERE d.AttainmentId IS NOT NULL  -- duplicity
   OR a.AttainmentId IS NULL 
   OR a.CountryCode IS NULL
   OR a.Adj_AssessmentMethodId IS NULL


GO


