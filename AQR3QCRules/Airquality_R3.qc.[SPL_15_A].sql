USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[SPL_15_A]
AS

-- Creation date: 02/08/2026
-- QC rule code: SPL_15_A
-- QC rule name: EmissionSourceDistance

WITH CTE_samplingPointLocation AS
(
    SELECT
        [CountryCode],
        [AssessmentMethodId],
        [SamplingPointCategory],
        [EmissionSourceDistance],

        NULLIF(
            LTRIM(RTRIM(CONVERT(nvarchar(50), [EmissionSourceDistance]))),
            ''
        ) AS [EmissionSourceDistance_str],

        TRY_CONVERT(
            decimal(18, 6),
            NULLIF(
                LTRIM(RTRIM(CONVERT(nvarchar(50), [EmissionSourceDistance]))),
                ''
            )
        ) AS [EmissionSourceDistance_num]

    FROM [reporting].[SamplingPointLocation]
)

SELECT
    [CountryCode],
    [AssessmentMethodId],
    [SamplingPointCategory],
    [EmissionSourceDistance]

FROM CTE_samplingPointLocation

WHERE
       [EmissionSourceDistance_str] IS NOT NULL
   AND (
          [EmissionSourceDistance_num] IS NULL
       OR [EmissionSourceDistance_num] < 0
   );

GO