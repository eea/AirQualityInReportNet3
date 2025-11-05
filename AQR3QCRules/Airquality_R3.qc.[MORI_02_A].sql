USE [Airquality_R3]
GO

/****** Object:  View [qc].[MORI_02_A]    Script Date: 26/08/2025 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [qc].[MORI_02_A] AS

-- Creation date: 26 August 2025
-- QC rule code: MORI_02_A
-- QC rule name: MORI_02_A Cross-check - [AssessmentMethodId] MOD_02


WITH 
CTE_ModellingResultsInline AS (
    SELECT /*record_id,*/
           CASE WHEN "assessmentmethodid" = '' THEN NULL ELSE "assessmentmethodid" END AS "assessmentmethodid"
    FROM reporting.ModellingResultInline
),

CTE_codes_from_ModellingResultInlineTable_missing_in_ModelReportingTable AS (
  SELECT /*record_id,*/ MRIreporting."assessmentmethodid"
  FROM CTE_ModellingResultsInline as MRIreporting
  WHERE NOT EXISTS (
    SELECT ModelReporting.assessmentmethodid
	FROM reporting.Model ModelReporting 
	WHERE MRIreporting.assessmentmethodid = ModelReporting.assessmentmethodid
  ) 
),

CTE_codes_missing_from_ModelReportingTable_missing_in_ModelRefTable AS (
  SELECT /*record_id,*/ ModelReporting."assessmentmethodid"
  FROM CTE_codes_from_ModellingResultInlineTable_missing_in_ModelReportingTable AS ModelReporting
  WHERE NOT EXISTS (
    SELECT ModelRef.AssessmentmethodId
	FROM reference.Model ModelRef 
	WHERE ModelReporting.assessmentmethodid = ModelRef.AssessmentmethodId
  ) 
)

SELECT /*record_id*/ *
FROM CTE_codes_missing_from_ModelReportingTable_missing_in_ModelRefTable 


GO


