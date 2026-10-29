USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[SPO_02_C]
AS

-- QC rule code: SPO_02_C
-- QC rule name: SPO_02_C Cross-check - [AssessmentMethodId]
-- QC rule description: AssessmentMethodId reported in the SamplingPoint table shall have at least one corresponding record in the SamplingPointLocation table.

WITH sampling_points AS
(
    SELECT
        NULLIF(LTRIM(RTRIM([CountryCode])), '') AS CountryCode,
        NULLIF(LTRIM(RTRIM([AssessmentMethodId])), '') AS AssessmentMethodId
    FROM [reporting].[SamplingPoint]
),
sampling_point_locations AS
(
    SELECT DISTINCT
        NULLIF(LTRIM(RTRIM([CountryCode])), '') AS CountryCode,
        NULLIF(LTRIM(RTRIM([AssessmentMethodId])), '') AS AssessmentMethodId
    FROM [reporting].[SamplingPointLocation]
)
SELECT
    sp.CountryCode,
    sp.AssessmentMethodId
FROM sampling_points AS sp
WHERE sp.AssessmentMethodId IS NULL
   OR NOT EXISTS
   (
       SELECT 1
       FROM sampling_point_locations AS spl
       WHERE sp.CountryCode COLLATE DATABASE_DEFAULT =
             spl.CountryCode COLLATE DATABASE_DEFAULT
         AND sp.AssessmentMethodId COLLATE DATABASE_DEFAULT =
             spl.AssessmentMethodId COLLATE DATABASE_DEFAULT
   )
GO