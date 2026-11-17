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
-- QC rule name: SPO_03_A Content - [SamplingPointReferenceId]
-- QC rule description: SamplingPointReferenceId must be provided and must not be null or empty.

WITH sampling_points AS
(
    SELECT
        NULLIF(LTRIM(RTRIM([CountryCode])), '') AS CountryCode,
        NULLIF(LTRIM(RTRIM([AssessmentMethodId])), '') AS AssessmentMethodId,
        NULLIF
        (
            LTRIM(RTRIM([SamplingPointReferenceId])),
            ''
        ) AS SamplingPointReferenceId
    FROM [reporting].[SamplingPoint]
)
SELECT
    CountryCode,
    AssessmentMethodId,
    SamplingPointReferenceId
FROM sampling_points
WHERE SamplingPointReferenceId IS NULL
GO