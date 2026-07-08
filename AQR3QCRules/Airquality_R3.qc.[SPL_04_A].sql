USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPL_04_A]  ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qctesting].[SPL_04_A_TEST]
AS

WITH src AS (
    SELECT
        [CountryCode],
        [AssessmentMethodId],
        [LocationEnd],

        NULLIF(
            LTRIM(RTRIM(CONVERT(nvarchar(50), [LocationEnd]))),
            ''
        ) AS End_str,

        TRY_CONVERT(
            datetimeoffset(0),
            NULLIF(LTRIM(RTRIM(CONVERT(nvarchar(50), [LocationEnd]))), ''),
            126
        ) AS End_as_dto,

        TRY_CONVERT(
            datetime2(0),
            NULLIF(LTRIM(RTRIM(CONVERT(nvarchar(50), [LocationEnd]))), ''),
            126
        ) AS End_as_dt2

    FROM reporting.SamplingPointLocation
)

SELECT
    [CountryCode],
    [AssessmentMethodId],
    [LocationEnd]

FROM src

WHERE
    End_str IS NOT NULL
    AND End_as_dto IS NULL
    AND End_as_dt2 IS NULL;

GO