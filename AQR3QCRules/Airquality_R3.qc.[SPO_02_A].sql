USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[SPO_02_A]
AS

-- QC rule code: SPO_02_A
-- QC rule name: SPO_02_A Cross-check - [AssessmentMethodId]
-- QC rule description: AssessmentMethodId reported in the SamplingPoint table shall exist in the SamplingProcess table.

WITH sampling_points AS
(
    SELECT
        NULLIF(LTRIM(RTRIM([CountryCode])), '') AS CountryCode,
        NULLIF(LTRIM(RTRIM([AssessmentMethodId])), '') AS AssessmentMethodId
    FROM [reporting].[SamplingPoint]
),
sampling_processes AS
(
    SELECT DISTINCT
        NULLIF(LTRIM(RTRIM([CountryCode])), '') AS CountryCode,
        NULLIF(LTRIM(RTRIM([AssessmentMethodId])), '') AS AssessmentMethodId
    FROM [reporting].[SamplingProcess]
)
SELECT
    sp.CountryCode,
    sp.AssessmentMethodId
FROM sampling_points AS sp
LEFT JOIN sampling_processes AS spp
    ON sp.CountryCode COLLATE DATABASE_DEFAULT =
       spp.CountryCode COLLATE DATABASE_DEFAULT
   AND sp.AssessmentMethodId COLLATE DATABASE_DEFAULT =
       spp.AssessmentMethodId COLLATE DATABASE_DEFAULT
WHERE spp.AssessmentMethodId IS NULL
GO