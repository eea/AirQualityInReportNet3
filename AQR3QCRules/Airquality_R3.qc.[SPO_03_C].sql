USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[SPO_03_C]
AS

-- QC rule code: SPO_03_C
-- QC rule name: SPO_03_C Cross-check - [SamplingPointReferenceId,AssessmentMethodId]
-- QC rule description: Each SamplingPointReferenceId shall be consistently associated with the same AssessmentMethodId within the submitted data and the same reported CountryCode.

WITH src AS
(
    SELECT
        NULLIF(LTRIM(RTRIM([CountryCode])), '') AS CountryCode,
        NULLIF(LTRIM(RTRIM([SamplingPointReferenceId])), '') AS SamplingPointReferenceId,
        NULLIF(LTRIM(RTRIM([AssessmentMethodId])), '') AS AssessmentMethodId
    FROM [reporting].[SamplingPoint]
),
inconsistent_submitted_data AS
(
    SELECT
        CountryCode,
        SamplingPointReferenceId
    FROM src
    WHERE SamplingPointReferenceId IS NOT NULL
    GROUP BY
        CountryCode,
        SamplingPointReferenceId
    HAVING COUNT(DISTINCT AssessmentMethodId) > 1
)
SELECT
    s.CountryCode,
    s.SamplingPointReferenceId,
    s.AssessmentMethodId
FROM src AS s
WHERE EXISTS
(
    SELECT 1
    FROM inconsistent_submitted_data AS d
    WHERE s.CountryCode COLLATE DATABASE_DEFAULT =
          d.CountryCode COLLATE DATABASE_DEFAULT
      AND s.SamplingPointReferenceId COLLATE DATABASE_DEFAULT =
          d.SamplingPointReferenceId COLLATE DATABASE_DEFAULT
)
GO