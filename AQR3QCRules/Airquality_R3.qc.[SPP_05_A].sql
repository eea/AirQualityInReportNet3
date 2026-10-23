USE [Airquality_R3];
GO

/****** Object:  View [qc].[SPP_05_A] ******/
SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

--QC code: SPP_05_A
--QC name: SPP_05_A Format – [ProcessActivityEnd]
--QC rule description: ProcessActivityEnd may be null for active sampling processes. If reported, it must be a valid datetime in ISO 8601 format and must not be empty or contain only spaces.

CREATE OR ALTER VIEW [qc].[SPP_05_A]
AS
WITH src AS
(
    SELECT
        [CountryCode],
        [AssessmentMethodId],
        [ProcessActivityEnd],
        LTRIM(RTRIM(CONVERT(nvarchar(50), [ProcessActivityEnd]))) AS End_str,
        TRY_CONVERT(
            datetimeoffset(0),
            NULLIF(
                LTRIM(RTRIM(CONVERT(nvarchar(50), [ProcessActivityEnd]))),
                ''
            ),
            126
        ) AS End_as_dto,
        TRY_CONVERT(
            datetime2(0),
            NULLIF(
                LTRIM(RTRIM(CONVERT(nvarchar(50), [ProcessActivityEnd]))),
                ''
            ),
            126
        ) AS End_as_dt2
    FROM [reporting].[SamplingProcess]
)
SELECT
    [CountryCode],
    [AssessmentMethodId],
    [ProcessActivityEnd]
FROM src
WHERE
    [ProcessActivityEnd] IS NOT NULL
    AND
    (
        End_str = ''
        OR
        (
            End_as_dto IS NULL
            AND End_as_dt2 IS NULL
        )
    );
GO