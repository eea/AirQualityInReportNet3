USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPL_01_A] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qctesting].SPL_01_A_TEST
 AS

-- Creation date: June 2026


WITH CTE_countryCode AS ( 
SELECT --record_id ,
NULLIF(LTRIM(RTRIM(countryCode)), '') AS countryCode
FROM reporting.SamplingPointLocation ) ,

missing_codes AS ( 
SELECT /*sp.record_id,*/ cc.countryCode 
FROM CTE_countryCode cc 
LEFT JOIN reference."vocabulary" v 
ON cc.countryCode = v."notation" COLLATE Latin1_General_CI_AS 
AND v."vocabulary" = 'countries'
WHERE 
  (v."notation" IS NULL AND cc.countryCode IS NOT NULL) 
  
)

SELECT DISTINCT * FROM missing_codes

GO