USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[SPO_04_B]
AS

-- QC rule code: SPO_04_B
-- QC rule name: SPO_04_B Constraint - [AssessmentMethodId,PollutantId]
-- QC rule description: Each AssessmentMethodId shall be associated with one single PollutantId within each reported CountryCode.

WITH src AS
(
    SELECT
        NULLIF(LTRIM(RTRIM([CountryCode])), '') AS CountryCode,
        NULLIF(LTRIM(RTRIM([AssessmentMethodId])), '') AS AssessmentMethodId,
        [PollutantId]
    FROM [reporting].[SamplingPoint]
),
inconsistent_submitted_data AS
(
    SELECT
        CountryCode,
        AssessmentMethodId
    FROM src
    WHERE AssessmentMethodId IS NOT NULL
    GROUP BY
        CountryCode,
        AssessmentMethodId
    HAVING COUNT(DISTINCT PollutantId) > 1
),
reference_sampling_points AS
(
    SELECT
        NULLIF(LTRIM(RTRIM([CountryCode])), '') AS CountryCode,
        NULLIF(LTRIM(RTRIM([AssessmentMethodId])), '') AS AssessmentMethodId,
        [PollutantId]
    FROM [reference].[SamplingPoint]
)
SELECT
    s.CountryCode,
    s.AssessmentMethodId,
    s.PollutantId
FROM src AS s
WHERE
    EXISTS
    (
        SELECT 1
        FROM inconsistent_submitted_data AS d
        WHERE s.CountryCode COLLATE DATABASE_DEFAULT =
              d.CountryCode COLLATE DATABASE_DEFAULT
          AND s.AssessmentMethodId COLLATE DATABASE_DEFAULT =
              d.AssessmentMethodId COLLATE DATABASE_DEFAULT
    )
    OR EXISTS
    (
        SELECT 1
        FROM reference_sampling_points AS r
        WHERE s.CountryCode COLLATE DATABASE_DEFAULT =
              r.CountryCode COLLATE DATABASE_DEFAULT
          AND s.AssessmentMethodId COLLATE DATABASE_DEFAULT =
              r.AssessmentMethodId COLLATE DATABASE_DEFAULT
          AND
          (
              s.PollutantId <> r.PollutantId
              OR (s.PollutantId IS NULL AND r.PollutantId IS NOT NULL)
              OR (s.PollutantId IS NOT NULL AND r.PollutantId IS NULL)
          )
    )
GO