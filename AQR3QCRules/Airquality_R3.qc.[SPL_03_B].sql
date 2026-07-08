USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPL_03_B] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qctesting].[SPL_03_B_TEST]
AS

WITH src AS
(
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
)

SELECT
    [CountryCode],
    [AssessmentMethodId],
    [LocationBegin],
    [LocationEnd]

FROM src

WHERE
    End_dt IS NOT NULL
    AND Begin_dt IS NOT NULL
    AND Begin_dt > End_dt;


GO