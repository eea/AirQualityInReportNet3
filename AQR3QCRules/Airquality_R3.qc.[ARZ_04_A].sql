USE [Airquality_R3]
GO

/****** Object:  View [qctesting].[ARZ_04_A]    Script Date: 31/08/2026 11:05:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[ARZ_04_A] AS

-- Creation date: 31/08/2026
-- QC rule code: ARZ_04_A
-- QC rule name: ARZ_04_A ZoneNationalCode

WITH CTE_assessmentRegimeZone AS (
  SELECT 
    /*record_id,*/
	  [ZoneId],
	  [AssessmentRegimeId],
    [ZoneNationalCode]

  FROM [reporting].[AssessmentRegimeZone]
    
)

SELECT
	  [ZoneId],
	  [AssessmentRegimeId],
    [ZoneNationalCode]

FROM CTE_assessmentRegimeZone

WHERE
    [ZoneNationalCode] IS NULL OR LEN([ZoneNationalCode]) = 0

GO