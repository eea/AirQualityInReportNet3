USE [Airquality_R3]
GO

/****** Object:  View [qc].[MER.02.A]    Script Date: 07/07/2025 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [qc].[MER.02.A] AS

-- Creation date: June 2025
-- QC rule code: MER.02.A
-- QC rule name: MER.02.A Cross-check - [AssessmentMethodId] SPO.02

WITH 
CTE_measureresults AS (
    SELECT 
           CASE WHEN assessmentmethodid = '' THEN NULL ELSE assessmentmethodid END AS assessmentmethodid
    FROM reporting.MeasurementResult
),

CTE_samplingpoint_check AS (
    SELECT COUNT(*) AS count_samplingpoint
    FROM  reporting.SamplingPoint
),

CTE_samplingpoint_selected AS (
    SELECT assessmentmethodid
    FROM  reporting.SamplingPoint
    WHERE (SELECT count_samplingpoint FROM CTE_samplingpoint_check) > 0

    UNION ALL

    SELECT assessmentmethodid
    FROM reference.SamplingPoint
    WHERE (SELECT count_samplingpoint FROM CTE_samplingpoint_check) = 0
),

CTE_missing_codes AS (
    SELECT mr.assessmentmethodid AS mr_assessmentmethodid,
        s.assessmentmethodid AS s_assessmentmethodid
    FROM CTE_measureresults mr
    LEFT JOIN CTE_samplingpoint_selected s
      ON mr.assessmentmethodid = s.assessmentmethodid
    WHERE s.assessmentmethodid IS NULL
      AND mr.assessmentmethodid IS NOT NULL
)

SELECT distinct *
FROM CTE_missing_codes
GO


