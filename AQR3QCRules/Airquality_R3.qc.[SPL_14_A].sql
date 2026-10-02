USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[SPL_14_A]
AS

-- Creation date: 02/08/2026
-- QC rule code: SPL_14_A
-- QC rule name: KerbDistance

WITH CTE_samplingPointLocation AS
(
    SELECT
        [CountryCode],
        [AssessmentMethodId],
        [SamplingPointCategory],
        [KerbDistance],

        NULLIF(
            LTRIM(RTRIM(CONVERT(nvarchar(50), [KerbDistance]))),
            ''
        ) AS [KerbDistance_str],

        TRY_CONVERT(
            decimal(18, 6),
            NULLIF(
                LTRIM(RTRIM(CONVERT(nvarchar(50), [KerbDistance]))),
                ''
            )
        ) AS [KerbDistance_num]

    FROM [reporting].[SamplingPointLocation]
)

SELECT
    [CountryCode],
    [AssessmentMethodId],
    [SamplingPointCategory],
    [KerbDistance]

FROM CTE_samplingPointLocation

WHERE
       (
           LOWER(LTRIM(RTRIM([SamplingPointCategory]))) = 'traffic'
           AND [KerbDistance_str] IS NULL
       )

    OR (
           [KerbDistance_str] IS NOT NULL
           AND (
                  [KerbDistance_num] IS NULL
               OR [KerbDistance_num] < 0
           )
       );

GO