USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[SPL_03_A]
AS

-- Creation date: 02/08/2026
-- QC rule code: SPL_03_A
-- QC rule name: SPL_03_A LocationBegin

WITH CTE_samplingPointLocation AS
(
    SELECT
        [CountryCode],
        [AssessmentMethodId],
        [LocationBegin],

        TRY_CONVERT(
            datetimeoffset(0),
            NULLIF(
                LTRIM(RTRIM(CONVERT(nvarchar(50), [LocationBegin]))),
                ''
            ),
            126
        ) AS [LocationBegin_dt]

    FROM [reporting].[SamplingPointLocation]
)

SELECT
    [CountryCode],
    [AssessmentMethodId],
    [LocationBegin]

FROM CTE_samplingPointLocation

WHERE
    [LocationBegin] IS NULL
    OR LTRIM(RTRIM(CONVERT(nvarchar(50), [LocationBegin]))) = ''
    OR [LocationBegin_dt] IS NULL

GO