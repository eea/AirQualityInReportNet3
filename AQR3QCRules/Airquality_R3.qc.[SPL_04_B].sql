USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPL_04_B] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[SPL_04_B]
AS

-- Creation date: 02/08/2026
-- QC rule code: SPL_04_B
-- QC rule name: LocationEnd / ProcessActivityEnd

WITH CTE_location AS (
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
        ) AS LocationBegin_dt,

        TRY_CONVERT(
            datetimeoffset(0),
            NULLIF(
                LTRIM(RTRIM(CONVERT(nvarchar(50), [LocationEnd]))),
                ''
            ),
            126
        ) AS LocationEnd_dt

    FROM [reporting].[SamplingPointLocation]
),

CTE_latest_location AS (
    SELECT
        [CountryCode],
        [AssessmentMethodId],
        [LocationBegin],
        [LocationEnd],
        [LocationBegin_dt],
        [LocationEnd_dt],

        ROW_NUMBER() OVER (
            PARTITION BY [CountryCode], [AssessmentMethodId]
            ORDER BY [LocationBegin_dt] DESC
        ) AS rn

    FROM CTE_location
),

CTE_process AS (
    SELECT
        [CountryCode],
        [AssessmentMethodId],
        [ProcessActivityBegin],
        [ProcessActivityEnd],

        TRY_CONVERT(
            datetimeoffset(0),
            NULLIF(
                LTRIM(RTRIM(CONVERT(nvarchar(50), [ProcessActivityBegin]))),
                ''
            ),
            126
        ) AS ProcessActivityBegin_dt,

        TRY_CONVERT(
            datetimeoffset(0),
            NULLIF(
                LTRIM(RTRIM(CONVERT(nvarchar(50), [ProcessActivityEnd]))),
                ''
            ),
            126
        ) AS ProcessActivityEnd_dt

    FROM [reporting].[SamplingProcess]
),

CTE_latest_process AS (
    SELECT
        [CountryCode],
        [AssessmentMethodId],
        [ProcessActivityBegin],
        [ProcessActivityEnd],
        [ProcessActivityBegin_dt],
        [ProcessActivityEnd_dt],

        ROW_NUMBER() OVER (
            PARTITION BY [CountryCode], [AssessmentMethodId]
            ORDER BY [ProcessActivityBegin_dt] DESC
        ) AS rn

    FROM CTE_process
)

SELECT
    L.[CountryCode],
    L.[AssessmentMethodId],
    L.[LocationBegin],
    L.[LocationEnd],
    P.[ProcessActivityBegin],
    P.[ProcessActivityEnd]

FROM CTE_latest_location L

INNER JOIN CTE_latest_process P
    ON L.[CountryCode] = P.[CountryCode]
    AND L.[AssessmentMethodId] = P.[AssessmentMethodId]

WHERE
    L.rn = 1
    AND P.rn = 1
    AND (
           (L.[LocationEnd_dt] IS NULL
            AND P.[ProcessActivityEnd_dt] IS NOT NULL)

        OR (L.[LocationEnd_dt] IS NOT NULL
            AND P.[ProcessActivityEnd_dt] IS NULL)

        OR (L.[LocationEnd_dt] IS NOT NULL
            AND P.[ProcessActivityEnd_dt] IS NOT NULL
            AND L.[LocationEnd_dt] <> P.[ProcessActivityEnd_dt])
    );

GO