USE [Airquality_R3]
GO

/****** Object:  View [qc].[MOD_05_A]    Script Date: 07/07/2025 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [qc].[MOD_05_A] AS

-- Creation date: June 2025
-- QC rule code: MOD_05_A
-- QC rule name: MOD_05_A Vocabulary - [AssessmentType]
-- Update date: 16 December 2025

WITH 

CTE_model AS ( 
  SELECT 
    CASE WHEN assessmenttype = '' THEN NULL ELSE assessmenttype END as assessmenttype,
    CASE WHEN assessmentmethodid = '' THEN NULL ELSE assessmentmethodid END as assessmentmethodid
  FROM reporting.Model 
),

missing_codes AS ( 
  SELECT /*m.record_id,*/ m.assessmentmethodid, m.assessmenttype
  FROM CTE_model m 
  LEFT JOIN reference.Vocabulary v 
    ON m.assessmenttype = v.Notation COLLATE Latin1_General_CI_AS AND v.vocabulary = 'assessmenttype'
  WHERE v.Notation IS NULL
) 

SELECT * FROM missing_codes
GO


