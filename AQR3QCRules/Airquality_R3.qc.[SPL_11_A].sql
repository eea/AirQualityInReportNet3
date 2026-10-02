USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[SPL_11_A]
AS

-- Creation date: 02/08/2026
-- QC rule code: SPL_11_A
-- QC rule name: Altitude

WITH CTE_samplingPointLocation AS
(
    SELECT
        [CountryCode],
        [AssessmentMethodId],
        [Altitude],

        NULLIF(
            LTRIM(RTRIM(CONVERT(nvarchar(50), [Altitude]))),
            ''
        ) AS [Altitude_str],

        TRY_CONVERT(
            decimal(18, 6),
            NULLIF(
                LTRIM(RTRIM(CONVERT(nvarchar(50), [Altitude]))),
                ''
            )
        ) AS [Altitude_num]

    FROM [reporting].[SamplingPointLocation]
)

SELECT
    [CountryCode],
    [AssessmentMethodId],
    [Altitude]

FROM CTE_samplingPointLocation

WHERE
       [Altitude_str] IS NULL
    OR [Altitude_num] IS NULL
    OR [Altitude_num] < -10
    OR [Altitude_num] > 5700;

GO