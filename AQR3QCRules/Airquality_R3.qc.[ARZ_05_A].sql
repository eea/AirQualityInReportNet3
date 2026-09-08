USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qc].[ARZ_05_A] AS

-- Creation date: 31/08/2026
-- QC rule code: ARZ_05_A
-- QC rule name: ARZ_05_A 

WITH CTE_assesmentRegineZone AS (
  SELECT 
    /*record_id,*/ 
    [CountryCode],
    [AssessmentRegimeId],
    [ZoneId],
    [ZoneArea]

  FROM [reporting].[AssessmentRegimeZone]

  WHERE [ZoneArea] IS NOT NULL 
    AND ISNUMERIC[ZoneArea] and [ZoneArea] > 0
 )

 
SELECT
	  [CountryCode],
    [AssessmentRegimeId],
    [ZoneId],
    [ZoneArea]

FROM CTE_assessmentRegimeZone

WHERE
    [ZoneArea] IS NULL 
    OR  [ZoneArea] <= 0

GO
