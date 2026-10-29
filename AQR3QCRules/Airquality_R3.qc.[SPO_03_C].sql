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
-- QC rule description: Each SamplingPointReferenceId shall remain consistently associated with the same AssessmentMethodId within each reported CountryCode, both in the submitted data and against the reference data.

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
),
reference_sampling_points AS
(
    SELECT
        NULLIF(LTRIM(RTRIM([CountryCode])), '') AS CountryCode,
        NULLIF(LTRIM(RTRIM([SamplingPointReferenceId])), '') AS SamplingPointReferenceId,
        NULLIF(LTRIM(RTRIM([AssessmentMethodId])), '') AS AssessmentMethodId
    FROM [reference].[SamplingPoint]
)
SELECT
    s.CountryCode,
    s.SamplingPointReferenceId,
    s.AssessmentMethodId
FROM src AS s
WHERE
    EXISTS
    (
        SELECT 1
        FROM inconsistent_submitted_data AS d
        WHERE s.CountryCode COLLATE DATABASE_DEFAULT =
              d.CountryCode COLLATE DATABASE_DEFAULT
          AND s.SamplingPointReferenceId COLLATE DATABASE_DEFAULT =
              d.SamplingPointReferenceId COLLATE DATABASE_DEFAULT
    )
    OR EXISTS
    (
        SELECT 1
        FROM reference_sampling_points AS r
        WHERE s.CountryCode COLLATE DATABASE_DEFAULT =
              r.CountryCode COLLATE DATABASE_DEFAULT
          AND s.SamplingPointReferenceId COLLATE DATABASE_DEFAULT =
              r.SamplingPointReferenceId COLLATE DATABASE_DEFAULT
          AND ISNULL(s.AssessmentMethodId, '') COLLATE DATABASE_DEFAULT <>
              ISNULL(r.AssessmentMethodId, '') COLLATE DATABASE_DEFAULT
    )
GO