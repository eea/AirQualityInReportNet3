USE [Airquality_R3]
GO

/****** Object:  View [qc].[MORE.02.A]    Script Date: 26/08/2025 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [qc].[MORE.02.A] AS

-- Creation date: 26 August 2025
-- QC rule code: MORE.02.A
-- QC rule name: MORE.02.A Cross-check - [AssessmentMethodId] MOD.02


WITH 
CTE_ModellingResultsExternal AS (
    SELECT /*record_id,*/
           CASE WHEN "assessmentmethodid" = '' THEN NULL ELSE "assessmentmethodid" END AS "assessmentmethodid"
    FROM reporting.ModellingResultExternal
),

CTE_codes_from_ModellingResultExternalTable_missing_in_ModelReportingTable AS (
  SELECT /*record_id,*/ MREreporting."assessmentmethodid"
  FROM CTE_ModellingResultsExternal as MREreporting
  WHERE NOT EXISTS (
    SELECT ModelReporting.assessmentmethodid
	FROM reporting.Model ModelReporting 
	WHERE MREreporting.assessmentmethodid = ModelReporting.assessmentmethodid
  ) 
),

CTE_codes_missing_from_ModelReportingTable_missing_in_ModelRefTable AS (
  SELECT /*record_id,*/ ModelReporting."assessmentmethodid"
  FROM CTE_codes_from_ModellingResultExternalTable_missing_in_ModelReportingTable AS ModelReporting
  WHERE NOT EXISTS (
    SELECT ModelRef.AssessmentmethodId
	FROM reference.Model ModelRef 
	WHERE ModelReporting.assessmentmethodid = ModelRef.AssessmentmethodId
  ) 
)

SELECT /*record_id*/ *
FROM CTE_codes_missing_from_ModelReportingTable_missing_in_ModelRefTable


GO


