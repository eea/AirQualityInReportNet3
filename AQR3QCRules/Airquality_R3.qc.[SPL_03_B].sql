USE [Airquality_R3];
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER VIEW [qc].[SPL_03_B]
AS
-- Creation date: 02/08/2026
-- QC rule code: SPL_03_B
-- QC rule name: SPL_03_B LocationBegin / LocationEnd
-- QC rule description: LocationBegin must be earlier than or equal to LocationEnd when LocationEnd is reported.

WITH CTE_samplingPointLocation AS
(
    SELECT
        [CountryCode],
        [AssessmentMethodId],
        [LocationBegin],
        [LocationEnd],
        TRY_CONVERT(
            datetimeoffset(0),
            NULLIF(
                LTRIM(RTRIM(CONVERT(nvarchar(50), [LocationBegin]))),
                ''
            ),
            126
        ) AS [LocationBegin_dt],
        TRY_CONVERT(
            datetimeoffset(0),
            NULLIF(
                LTRIM(RTRIM(CONVERT(nvarchar(50), [LocationEnd]))),
                ''
            ),
            126
        ) AS [LocationEnd_dt]
    FROM [reporting].[SamplingPointLocation]
)
SELECT
    [CountryCode],
    [AssessmentMethodId],
    [LocationBegin],
    [LocationEnd],
    'LocationEnd earlier than LocationBegin' AS [QC_FailureReason]
FROM CTE_samplingPointLocation
WHERE
    [LocationEnd_dt] IS NOT NULL
    AND [LocationBegin_dt] IS NOT NULL
    AND [LocationBegin_dt] > [LocationEnd_dt];
GO