USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPP_10_A]    Script Date: 25/05/2026 09:45:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [qc].[SPP_10_A] AS

-- Creation date: 29 October 2025
-- QC rule code: SPP_10_A
-- QC rule name: SPP_10_A Vocabulary - [method]


WITH CTE_samplingprocess AS ( 
SELECT /*record_id ,*/
CASE WHEN "countrycode" = '' THEN NULL ELSE "countrycode" END as "countrycode",
CASE WHEN "assessmentmethodid" = '' THEN NULL ELSE "assessmentmethodid" END as "assessmentmethodid",
CASE WHEN "measurementtype" = '' THEN NULL ELSE "measurementtype" END as "measurementtype",
CASE WHEN "method" = '' THEN NULL ELSE "method" END as "method" 
FROM reporting."samplingprocess" ) 

, missing_codes AS ( 
SELECT /*sp.record_id,*/ sp.countrycode, sp.assessmentmethodid, sp."measurementtype", sp."method" 
FROM CTE_samplingprocess sp 
LEFT JOIN reference."vocabulary" v 
ON sp."method" = v."notation" COLLATE Latin1_General_CI_AS AND v."vocabulary" = 'samplingmethod'
WHERE 
  (v."notation" IS NULL AND sp."method" IS NOT NULL) 
  OR
  (v."notation" IS NULL AND sp."measurementtype" IN ('active', 'passive'))
  OR
  (v."notation" IS NOT NULL AND sp."measurementtype" IN ('automatic', 'remote'))
)

SELECT DISTINCT * FROM missing_codes


GO


