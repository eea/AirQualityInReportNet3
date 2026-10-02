USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[SPL_13_A]
AS

-- Creation date: 02/08/2026
-- QC rule code: SPL_13_A
-- QC rule name: BuildingDistance

WITH CTE_samplingPointLocation AS
(
    SELECT
        [CountryCode],
        [AssessmentMethodId],
        [BuildingDistance],

        NULLIF(
            LTRIM(RTRIM(CONVERT(nvarchar(50), [BuildingDistance]))),
            ''
        ) AS [BuildingDistance_str],

        TRY_CONVERT(
            decimal(18, 6),
            NULLIF(
                LTRIM(RTRIM(CONVERT(nvarchar(50), [BuildingDistance]))),
                ''
            )
        ) AS [BuildingDistance_num]

    FROM [reporting].[SamplingPointLocation]
)

SELECT
    [CountryCode],
    [AssessmentMethodId],
    [BuildingDistance]

FROM CTE_samplingPointLocation

WHERE
       [BuildingDistance_str] IS NOT NULL
   AND (
          [BuildingDistance_num] IS NULL
       OR [BuildingDistance_num] < 0
   );

GO