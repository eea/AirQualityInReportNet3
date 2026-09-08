USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[ARZ_18_A] AS

-- Creation date: 31/08/2026
-- QC rule code: ARZ_18_A
-- QC rule name: ARZ_18_A

WITH CTE_assesmentRegineZone AS (
  SELECT 
    /*record_id,*/ 
    [CountryCode],
    [AssessmentRegimeId],
    [ClassificationYear]

  FROM [reporting].[AssessmentRegimeZone]

)

SELECT 
	/*record_id,*/ 
    [CountryCode],
    [AssessmentRegimeId],
    [ClassificationYear]

FROM CTE_assesmentRegineZone

WHERE ISNUMERIC(ClassificationYear) = 1
	AND LEN(ClassificationYear) = 4 
	AND [ClassificationYear] > YEAR(GETDATE()) - 5

GO