USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPP_0]    Script Date: 22/05/2026 13:47:25 ******/
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
    NULLIF(CountryCode, '') AS CountryCode,
    NULLIF(AssessmentMethodId, '') AS AssessmentMethodId,
    PollutantID,
    NULLIF(ProcessId, '') AS ProcessId,
    NULLIF(ProcessActivityBegin, '') AS ProcessActivityBegin,
    NULLIF(ProcessActivityEnd, '') AS ProcessActivityEnd,
    NULLIF(MeasurementType, '') AS MeasurementType,
    NULLIF(Method, '') AS Method,
    NULLIF(Equipment, '') AS Equipment,   
    
    
    NULLIF(AnalyticalTechnique, '') AS AnalyticalTechnique,
    NULLIF(EquivalenceDemonstrated, '') AS EquivalenceDemonstrated,
    NULLIF(DataQualityDocumentId, '') AS DataQualityDocumentId,
    NULLIF(EquivalenceDemonstrationDocumentId, '') AS EquivalenceDemonstrationDocumentId
   
  FROM reporting.SamplingProcess
),


cte_reference AS (
  SELECT DISTINCT
    --record_id,
    NULLIF(CountryCode, '') AS CountryCode,
    NULLIF(AssessmentMethodId, '') AS AssessmentMethodId,
    PollutantID,
    NULLIF(ProcessId, '') AS ProcessId,
    NULLIF(ProcessActivityBegin, '') AS ProcessActivityBegin,
    NULLIF(ProcessActivityEnd, '') AS ProcessActivityEnd,
    NULLIF(MeasurementType, '') AS MeasurementType,
    NULLIF(Method, '') AS Method,
    NULLIF(Equipment, '') AS Equipment,   
    
    
    NULLIF(AnalyticalTechnique, '') AS AnalyticalTechnique,
    NULLIF(EquivalenceDemonstrated, '') AS EquivalenceDemonstrated
    /*NULLIF(DataQualityDocumentId, '') AS DataQualityDocumentId,
    NULLIF(EquivalenceDemonstrationDocumentId, '') AS EquivalenceDemonstrationDocumentId,
    NULLIF(ProcessDocumentationId, '') AS ProcessDocumentationId*/
    
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
     AND COALESCE(s."PollutantID", '') = COALESCE(r."PollutantID", '')
     AND COALESCE(s."ProcessActivityEnd", '') = COALESCE(r."ProcessActivityEnd", '')
     AND COALESCE(s."MeasurementType", '') = COALESCE(r."MeasurementType", '')
     AND COALESCE(s."Method", '') = COALESCE(r."Method", '')
     AND COALESCE(s."Equipment", '') = COALESCE(r."Equipment", '')
     
     
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


