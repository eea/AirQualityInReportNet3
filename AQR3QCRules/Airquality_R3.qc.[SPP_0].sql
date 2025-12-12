USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPP_0]    Script Date: 12/12/2025 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [qc].[SPP_0] AS

-- Creation date: 12 December 2025
-- QC rule code: SPP_0
-- QC rule name: SPP_0 Status - [PK]
-- Modification date: 

WITH cte_submitted AS (
  SELECT
    --record_id,
    NULLIF("CountryCode", '') AS CountryCode,
    NULLIF("AssessmentMethodId", '') AS AssessmentMethodId,
    "AirPollutantCode",
    NULLIF("ProcessId", '') AS ProcessId,
    NULLIF("ProcessActivityBegin", '') AS ProcessActivityBegin,
    NULLIF("ProcessActivityEnd", '') AS ProcessActivityEnd,
    NULLIF("MeasurementType", '') AS MeasurementType,
    NULLIF("MeasurementMethod", '') AS MeasurementMethod,
    NULLIF("MeasurementEquipment", '') AS MeasurementEquipment,   
    NULLIF("SamplingMethod", '') AS SamplingMethod,
    NULLIF("SamplingEquipment", '') AS SamplingEquipment,
    NULLIF("AnalyticalTechnique", '') AS AnalyticalTechnique,
    NULLIF("EquivalenceDemonstrated", '') AS EquivalenceDemonstrated,
    NULLIF("DataQualityReportId", '') AS DataQualityReportId,
    NULLIF("EquivalenceDemonstrationReportId", '') AS EquivalenceDemonstrationReportId,
    NULLIF("ProcessDocumentationId", '') AS ProcessDocumentationId
  FROM reporting.SamplingProcess
),


cte_reference AS (
  SELECT DISTINCT
    --record_id,
    NULLIF("CountryCode", '') AS CountryCode,
    NULLIF("AssessmentMethodId", '') AS AssessmentMethodId,
    "AirPollutantCode",
    NULLIF("ProcessId", '') AS ProcessId,
    NULLIF("ProcessActivityBegin", '') AS ProcessActivityBegin,
    NULLIF("ProcessActivityEnd", '') AS ProcessActivityEnd,
    NULLIF("MeasurementType", '') AS MeasurementType,
    NULLIF("MeasurementMethod", '') AS MeasurementMethod,
    NULLIF("MeasurementEquipment", '') AS MeasurementEquipment,   
    NULLIF("SamplingMethod", '') AS SamplingMethod,
    NULLIF("SamplingEquipment", '') AS SamplingEquipment,
    NULLIF("AnalyticalTechnique", '') AS AnalyticalTechnique,
    NULLIF("EquivalenceDemonstrated", '') AS EquivalenceDemonstrated
    /*NULLIF("DataQualityReportId", '') AS DataQualityReportId,
    NULLIF("EquivalenceDemonstrationReportId", '') AS EquivalenceDemonstrationReportId,
    NULLIF("ProcessDocumentationId" '') AS ProcessDocumentationId*/
    
  FROM reference.SamplingProcess
)


SELECT
  --s.record_id,
  s."CountryCode",
  s."ProcessId",
  s."AssessmentMethodId",
  s."ProcessActivityBegin",
  CASE
    WHEN r."CountryCode" IS NULL OR r."ProcessId" IS NULL OR r."AssessmentMethodId" IS NULL OR r."ProcessActivityBegin" IS NULL 
    THEN 'Addition of new record'

    WHEN COALESCE(s."CountryCode", '') = COALESCE(r."CountryCode", '')
     AND COALESCE(s."AssessmentMethodId", '') = COALESCE(r."AssessmentMethodId", '')
     AND COALESCE(s."ProcessId", '') = COALESCE(r."ProcessId", '')
     AND COALESCE(s."ProcessActivityBegin", '') = COALESCE(r."ProcessActivityBegin", '')
     AND COALESCE(s."AirPollutantCode", '') = COALESCE(r."AirPollutantCode", '')
     AND COALESCE(s."ProcessActivityEnd", '') = COALESCE(r."ProcessActivityEnd", '')
     AND COALESCE(s."MeasurementType", '') = COALESCE(r."MeasurementType", '')
     AND COALESCE(s."MeasurementMethod", '') = COALESCE(r."MeasurementMethod", '')
     AND COALESCE(s."MeasurementEquipment", '') = COALESCE(r."MeasurementEquipment", '')
     AND COALESCE(s."SamplingMethod", '') = COALESCE(r."SamplingMethod", '') 
     AND COALESCE(s."SamplingEquipment", '') = COALESCE(r."SamplingEquipment", '')  
     AND COALESCE(s."AnalyticalTechnique", '') = COALESCE(r."AnalyticalTechnique", '')  
     AND COALESCE(s."EquivalenceDemonstrated", '') = COALESCE(r."EquivalenceDemonstrated", '')    
    THEN 'No modification'
    
    ELSE 'Modification of existing record'
  END AS record_status

FROM cte_submitted s
LEFT JOIN cte_reference r
  ON s."CountryCode" = r."CountryCode"
 AND s."ProcessId" = r."ProcessId"
 AND s."AssessmentMethodId" = r."AssessmentMethodId"
 AND s."ProcessActivityBegin" = r."ProcessActivityBegin"
 
GO


