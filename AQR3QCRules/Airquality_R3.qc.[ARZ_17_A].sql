USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[ARZ_17_A] AS

-- Creation date: 31/08/2026
-- QC rule code: ARZ_17_A
-- QC rule name: ARZ_17_A

WITH CTE_assesmentRegineZone AS (
  SELECT 
    /*record_id,*/ 
    [CountryCode],
    [AssessmentRegimeId],
    [ZoneResidentPopulation]

  FROM [reporting].[AssessmentRegimeZone]

)

SELECT 
	/*record_id,*/ 
    [CountryCode],
    [AssessmentRegimeId],
    [ZoneResidentPopulation]

FROM CTE_assesmentRegineZone

WHERE ISNUMERIC(ZoneResidentPopulation) = 1
	AND [ZoneResidentPopulation] > 0 

GO