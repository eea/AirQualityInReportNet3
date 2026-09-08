USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[ARZ_16_A] AS

-- Creation date: 31/08/2026
-- QC rule code: ARZ_16_A
-- QC rule name: ARZ_16_A

WITH CTE_assesmentRegineZone AS (
  SELECT 
    /*record_id,*/ 
    [CountryCode],
    [AssessmentRegimeId],
    [ZoneResidentPopulationYear]

  FROM [reporting].[AssessmentRegimeZone]

)

SELECT 
	/*record_id,*/ 
    [CountryCode],
    [AssessmentRegimeId],
    [ZoneResidentPopulationYear]

FROM CTE_assesmentRegineZone

WHERE ISNUMERIC(ZoneResidentPopulationYear) = 1
	AND LEN(ZoneResidentPopulationYear) = 4 
	AND [ZoneResidentPopulationYear] > YEAR(GETDATE()) - 5

GO