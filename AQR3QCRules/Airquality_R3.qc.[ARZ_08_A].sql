USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qc].[ARZ_08_A] AS

-- Creation date: 31/08/2026
-- QC rule code: ARZ__08_A
-- QC rule name: ARZ_ _08_A


WITH CTE_assessmentRegimeZone AS (
  SELECT 
    /*record_id,*/
	  [ZoneId],
	  [AssessmentRegimeId],
    [ZoneName]

  FROM [reporting].[AssessmentRegimeZone]
    
)

SELECT
	  [ZoneId],
	  [AssessmentRegimeId],
    [ZoneName]

FROM CTE_assessmentRegimeZone

WHERE
    [ZoneName] IS NULL OR LEN([ZoneName]) = 0

GO
