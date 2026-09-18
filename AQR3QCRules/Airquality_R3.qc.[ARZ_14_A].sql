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

WITH CTE_assessmentRegimeZone AS (
    SELECT
        [CountryCode],
        [AssessmentRegimeId],
        [PostponementYear]
    FROM [reporting].[AssessmentRegimeZone]
)

SELECT
    [CountryCode],
    [AssessmentRegimeId],
    [PostponementYear]

FROM CTE_assessmentRegimeZone

WHERE [PostponementYear] IS NOT NULL
  AND (
        [PostponementYear] NOT LIKE '[0-9][0-9][0-9][0-9]'
        OR TRY_CONVERT(int, [PostponementYear]) < 2026
      )

GO