USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[SPL_02_B]
AS

-- Creation date: 02/08/2026
-- QC rule code: SPL_02_B
-- QC rule name: SPL_02_B AssessmentMethodId

WITH CTE_samplingPointLocation AS (
    SELECT
        [CountryCode],
        [AssessmentMethodId] AS [AssessmentMethodIdRaw],
        NULLIF(LTRIM(RTRIM([AssessmentMethodId])), '') AS [AssessmentMethodId]
    FROM [reporting].[SamplingPointLocation]
),

CTE_samplingPoint AS (
    SELECT DISTINCT
        [CountryCode],
        NULLIF(LTRIM(RTRIM([AssessmentMethodId])), '') AS [AssessmentMethodId]
    FROM [reporting].[SamplingPoint]
)

SELECT DISTINCT
    SPL.[CountryCode],
    SPL.[AssessmentMethodIdRaw] AS [AssessmentMethodId]
FROM CTE_samplingPointLocation AS SPL

LEFT JOIN CTE_samplingPoint AS SPO
    ON SPL.[CountryCode] = SPO.[CountryCode]
    AND SPL.[AssessmentMethodId] = SPO.[AssessmentMethodId]

WHERE
    SPL.[AssessmentMethodId] IS NULL
    OR SPO.[AssessmentMethodId] IS NULL

GO