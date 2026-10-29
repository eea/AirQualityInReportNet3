USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[SPO_03_A]
AS

-- Creation date: June 2026
-- QC rule code: SPO_03_A
-- QC rule name: SPO_03_A Constraint - [SamplingPointReferenceId]
-- QC rule description: SamplingPointReferenceId shall uniquely identify a sampling point reference within each reported CountryCode.

WITH sampling_points AS
(
    SELECT
        NULLIF(LTRIM(RTRIM([CountryCode])), '') AS CountryCode,
        NULLIF(LTRIM(RTRIM([AssessmentMethodId])), '') AS AssessmentMethodId,
        NULLIF(LTRIM(RTRIM([SamplingPointReferenceId])), '') AS SamplingPointReferenceId
    FROM [reporting].[SamplingPoint]
),
duplicate_references AS
(
    SELECT
        CountryCode,
        SamplingPointReferenceId
    FROM sampling_points
    WHERE SamplingPointReferenceId IS NOT NULL
    GROUP BY
        CountryCode,
        SamplingPointReferenceId
    HAVING COUNT(*) > 1
),
reference_sampling_points AS
(
    SELECT
        NULLIF(LTRIM(RTRIM([CountryCode])), '') AS CountryCode,
        NULLIF(LTRIM(RTRIM([SamplingPointReferenceId])), '') AS SamplingPointReferenceId,
        COUNT(*) AS ReferenceCount
    FROM [reference].[SamplingPoint]
    WHERE NULLIF(LTRIM(RTRIM([SamplingPointReferenceId])), '') IS NOT NULL
    GROUP BY
        NULLIF(LTRIM(RTRIM([CountryCode])), ''),
        NULLIF(LTRIM(RTRIM([SamplingPointReferenceId])), '')
)
SELECT
    sp.CountryCode,
    sp.AssessmentMethodId,
    sp.SamplingPointReferenceId
FROM sampling_points AS sp
LEFT JOIN duplicate_references AS d
    ON sp.CountryCode COLLATE DATABASE_DEFAULT =
       d.CountryCode COLLATE DATABASE_DEFAULT
   AND sp.SamplingPointReferenceId COLLATE DATABASE_DEFAULT =
       d.SamplingPointReferenceId COLLATE DATABASE_DEFAULT
LEFT JOIN reference_sampling_points AS r
    ON sp.CountryCode COLLATE DATABASE_DEFAULT =
       r.CountryCode COLLATE DATABASE_DEFAULT
   AND sp.SamplingPointReferenceId COLLATE DATABASE_DEFAULT =
       r.SamplingPointReferenceId COLLATE DATABASE_DEFAULT
WHERE sp.SamplingPointReferenceId IS NULL
   OR d.SamplingPointReferenceId IS NOT NULL
   OR r.ReferenceCount IS NULL
   OR r.ReferenceCount <> 1
GO