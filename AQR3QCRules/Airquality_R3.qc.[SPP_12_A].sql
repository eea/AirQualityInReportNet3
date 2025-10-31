USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPP_12_A]    Script Date: 30/10/2025 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [qc].[SPP_12_A] AS

-- Creation date: 30 October 2025
-- QC rule code: SPP_12_A
-- QC rule name: SPP_12_A Vocabulary - [AnalyticalTechnique]


WITH CTE_samplingprocess AS ( 
SELECT /*record_id,*/
CASE WHEN "countrycode" = '' THEN NULL ELSE "countrycode" END as "countrycode",
CASE WHEN "assessmentmethodid" = '' THEN NULL ELSE "assessmentmethodid" END as "assessmentmethodid",
CASE WHEN "measurementtype" = '' THEN NULL ELSE "measurementtype" END as "measurementtype",
CASE WHEN "analyticaltechnique" = '' THEN NULL ELSE "analyticaltechnique" END as "analyticaltechnique" 
FROM reporting."samplingprocess" ) 

, missing_codes AS ( 
SELECT /*sp.record_id,*/ sp."countrycode", sp."assessmentmethodid", sp."measurementtype", sp."analyticaltechnique" 
FROM CTE_samplingprocess sp 
LEFT JOIN reference."vocabulary" v 
ON sp."analyticaltechnique" = v."notation" COLLATE Latin1_General_CI_AS AND v."vocabulary" = 'analyticaltechnique'
WHERE 
  (v."notation" IS NULL AND sp."analyticaltechnique" IS NOT NULL) 
  OR
  (v."notation" IS NULL AND sp."measurementtype" IN ('active', 'passive'))
  OR
  (v."notation" IS NOT NULL AND sp."measurementtype" IN ('automatic', 'remote'))
)

SELECT DISTINCT * FROM missing_codes


GO

