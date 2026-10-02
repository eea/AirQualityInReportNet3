USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[SPL_10_A]
AS

-- Creation date: 02/08/2026
-- QC rule code: SPL_10_A
-- QC rule name: Longitude

WITH CTE_samplingPointLocation AS
(
    SELECT
        [CountryCode],
        [AssessmentMethodId],
        [Longitude],

        NULLIF(
            LTRIM(RTRIM(CONVERT(nvarchar(50), [Longitude]))),
            ''
        ) AS [Longitude_str],

        TRY_CONVERT(
            decimal(18, 10),
            NULLIF(
                LTRIM(RTRIM(CONVERT(nvarchar(50), [Longitude]))),
                ''
            )
        ) AS [Longitude_num]

    FROM [reporting].[SamplingPointLocation]
)

SELECT
    [CountryCode],
    [AssessmentMethodId],
    [Longitude]

FROM CTE_samplingPointLocation

WHERE
       [Longitude_str] IS NULL

    OR [Longitude_num] IS NULL

    OR (
        CHARINDEX('.', [Longitude_str]) > 0
        AND LEN(
            SUBSTRING(
                [Longitude_str],
                CHARINDEX('.', [Longitude_str]) + 1,
                LEN([Longitude_str])
            )
        ) > 4
    )

    OR [Longitude_num] < -180

    OR [Longitude_num] > 180;

GO