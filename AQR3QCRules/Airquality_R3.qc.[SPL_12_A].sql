USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[SPL_12_A]
AS

-- Creation date: 02/08/2026
-- QC rule code: SPL_12_A
-- QC rule name: InletHeight

WITH CTE_samplingPointLocation AS
(
    SELECT
        [CountryCode],
        [AssessmentMethodId],
        [InletHeight],

        NULLIF(
            LTRIM(RTRIM(CONVERT(nvarchar(50), [InletHeight]))),
            ''
        ) AS [InletHeight_str],

        TRY_CONVERT(
            decimal(18, 6),
            NULLIF(
                LTRIM(RTRIM(CONVERT(nvarchar(50), [InletHeight]))),
                ''
            )
        ) AS [InletHeight_num]

    FROM [reporting].[SamplingPointLocation]
)

SELECT
    [CountryCode],
    [AssessmentMethodId],
    [InletHeight]

FROM CTE_samplingPointLocation

WHERE
       [InletHeight_str] IS NULL
    OR [InletHeight_num] IS NULL
    OR [InletHeight_num] < 0
    OR [InletHeight_num] > 30;

GO