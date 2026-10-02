USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[SPL_03_C]
AS

-- Creation date: 02/08/2026
-- QC rule code: SPL_03_C
-- QC rule name: SPL_03_C LocationBegin / LocationEnd

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
),

CTE_ordered AS
(
    SELECT
        S.*,

        MAX([LocationEnd_dt]) OVER (
            PARTITION BY [CountryCode], [AssessmentMethodId]
            ORDER BY [LocationBegin_dt]
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS [LatestPreviousEnd]

    FROM CTE_samplingPointLocation AS S
),

CTE_previousOpen AS
(
    SELECT
        O.[CountryCode],
        O.[AssessmentMethodId],
        O.[LocationBegin],
        O.[LocationEnd],
        O.[LatestPreviousEnd],
        'Previous LocationBegin has no LocationEnd' AS [Violation]

    FROM CTE_ordered AS O

    WHERE
        O.[LocationBegin_dt] IS NOT NULL
        AND O.[LocationEnd_dt] IS NULL
        AND EXISTS (
            SELECT 1
            FROM CTE_ordered AS N
            WHERE
                N.[CountryCode] = O.[CountryCode]
                AND N.[AssessmentMethodId] = O.[AssessmentMethodId]
                AND N.[LocationBegin_dt] > O.[LocationBegin_dt]
        )
),

CTE_overlappingPeriods AS
(
    SELECT
        O.[CountryCode],
        O.[AssessmentMethodId],
        O.[LocationBegin],
        O.[LocationEnd],
        O.[LatestPreviousEnd],
        'LocationBegin earlier than latest previous LocationEnd' AS [Violation]

    FROM CTE_ordered AS O

    WHERE
        O.[LocationBegin_dt] IS NOT NULL
        AND O.[LatestPreviousEnd] IS NOT NULL
        AND O.[LocationBegin_dt] < O.[LatestPreviousEnd]
)

SELECT
    [CountryCode],
    [AssessmentMethodId],
    [LocationBegin],
    [LocationEnd],
    [LatestPreviousEnd],
    [Violation]
FROM CTE_previousOpen

UNION ALL

SELECT
    [CountryCode],
    [AssessmentMethodId],
    [LocationBegin],
    [LocationEnd],
    [LatestPreviousEnd],
    [Violation]
FROM CTE_overlappingPeriods

GO