USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPL_03_C] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qctesting].[SPL_03_C_TEST]
AS

WITH src AS (
    SELECT
        [CountryCode],
        [AssessmentMethodId],
        [LocationBegin],
        [LocationEnd],

        TRY_CONVERT(
            datetimeoffset(0),
            NULLIF(LTRIM(RTRIM(CONVERT(nvarchar(50), [LocationBegin]))), ''),
            126
        ) AS Begin_dt,

        TRY_CONVERT(
            datetimeoffset(0),
            NULLIF(LTRIM(RTRIM(CONVERT(nvarchar(50), [LocationEnd]))), ''),
            126
        ) AS End_dt

    FROM reporting.SamplingPointLocation
),

ordered AS (
    SELECT
        s.*,

        MAX(End_dt) OVER (
            PARTITION BY [CountryCode], [AssessmentMethodId]
            ORDER BY Begin_dt
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS LatestPreviousEnd

    FROM src s
),

-- A previous LocationBegin has no LocationEnd although a newer LocationBegin exists
previous_open AS (

    SELECT
        o.[CountryCode],
        o.[AssessmentMethodId],
        o.[LocationBegin],
        o.[LocationEnd],
        CAST(NULL AS datetimeoffset(0)) AS LatestPreviousEnd,
        'Previous LocationBegin has no LocationEnd' AS Violation

    FROM ordered o

    WHERE
        o.Begin_dt IS NOT NULL
        AND o.End_dt IS NULL
        AND EXISTS (
            SELECT 1
            FROM ordered n
            WHERE n.CountryCode = o.CountryCode
              AND n.AssessmentMethodId = o.AssessmentMethodId
              AND n.Begin_dt > o.Begin_dt
        )
),

-- The new LocationBegin starts before the latest previous LocationEnd
invalid_order AS (

    SELECT
        o.[CountryCode],
        o.[AssessmentMethodId],
        o.[LocationBegin],
        o.[LocationEnd],
        o.LatestPreviousEnd,
        'LocationBegin earlier than latest previous LocationEnd' AS Violation

    FROM ordered o

    WHERE
        o.Begin_dt IS NOT NULL
        AND o.LatestPreviousEnd IS NOT NULL
        AND o.Begin_dt < o.LatestPreviousEnd
)

SELECT *
FROM previous_open

UNION ALL

SELECT *
FROM invalid_order;

GO