USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[SPL_09_A]
AS

-- Creation date: 02/08/2026
-- QC rule code: SPL_09_A
-- QC rule name: Latitude

WITH CTE_samplingPointLocation AS
(
    SELECT
        [CountryCode],
        [AssessmentMethodId],
        [Latitude],

        NULLIF(
            LTRIM(RTRIM(CONVERT(nvarchar(50), [Latitude]))),
            ''
        ) AS [Latitude_str],

        TRY_CONVERT(
            decimal(18, 10),
            NULLIF(
                LTRIM(RTRIM(CONVERT(nvarchar(50), [Latitude]))),
                ''
            )
        ) AS [Latitude_num]

    FROM [reporting].[SamplingPointLocation]
)

SELECT
    [CountryCode],
    [AssessmentMethodId],
    [Latitude]

FROM CTE_samplingPointLocation

WHERE
       [Latitude_str] IS NULL

    OR [Latitude_num] IS NULL

    OR (
        CHARINDEX('.', [Latitude_str]) > 0
        AND LEN(
            SUBSTRING(
                [Latitude_str],
                CHARINDEX('.', [Latitude_str]) + 1,
                LEN([Latitude_str])
            )
        ) > 4
    )

    OR [Latitude_num] < -90

    OR [Latitude_num] > 90;

GO