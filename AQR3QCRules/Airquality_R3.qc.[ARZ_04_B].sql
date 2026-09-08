USE [Airquality_R3]
GO

/****** Object:  View [qctesting].[ARZ_04_B]    Script Date: 31/08/2026 12:06:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER VIEW [qc].[ARZ_04_B] AS

-- Creation date: 31/08/2026
-- QC rule code: ARZ_04_B
-- QC rule name: ARZ_04_B

WITH CTE_assessmentRegimeZone AS (
  SELECT 
    /*record_id,*/ 
    [CountryCode],	
    [AssessmentRegimeId],	
    [ZoneId],
    [ZoneNationalCode]

  FROM [reporting].[AssessmentRegimeZone]

  WHERE [ZoneId] IS NULL 
        OR [ZoneId] NOT LIKE [ZoneNationalCode]
),

CTE_reference AS (
  SELECT 
    [AssessmentRegimeId],	
    [ZoneId]
  FROM [reference].[AssessmentRegimeZone]
)

SELECT
	s.CountryCode,
	s.AssessmentRegimeId,
	s.ZoneId,
	s.ZoneNationalCode
FROM CTE_assessmentRegimeZone s
LEFT JOIN CTE_reference r
  ON s.ZoneId = r.ZoneId
  AND s.AssessmentRegimeId = r.AssessmentRegimeId

GO