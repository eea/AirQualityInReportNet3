USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[ARZ_14_A] AS

-- Creation date: 31/08/2026
-- QC rule code: ARZ_14_A
-- QC rule name: ARZ_14_A

WITH CTE_assesmentRegineZone AS (
  SELECT 
    /*record_id,*/ 
    [CountryCode],
    [AssessmentRegimeId],
    [PostponementYear]

  FROM [reporting].[AssessmentRegimeZone]

)

SELECT 
	/*record_id,*/ 
    [CountryCode],
    [AssessmentRegimeId],
    [PostponementYear]

FROM CTE_assesmentRegineZone

WHERE ISNUMERIC(PostponementYear) = 1
	AND LEN(PostponementYear) = 4 
	AND [PostponementYear] >= 2026

GO