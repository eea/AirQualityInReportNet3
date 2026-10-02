USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[SPL_02_A]
AS

-- Creation date: 02/08/2026
-- QC rule code: SPL_02_A
-- QC rule name: SPL_02_A AssessmentMethodId length

WITH CTE_samplingPointLocation AS
(
    SELECT
        [CountryCode],
        [AssessmentMethodId]
    FROM [reporting].[SamplingPointLocation]
)

SELECT
    [CountryCode],
    [AssessmentMethodId]
FROM CTE_samplingPointLocation

WHERE
    [AssessmentMethodId] IS NULL
    OR LEN(LTRIM(RTRIM([AssessmentMethodId]))) = 0
    OR LEN(LTRIM(RTRIM([AssessmentMethodId]))) > 50

GO