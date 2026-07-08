USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPL_03_A] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qctesting].[SPL_03_A_TEST]
AS

WITH src AS
(
    SELECT
        [CountryCode],
        [AssessmentMethodId],
        [LocationBegin],

        TRY_CONVERT(
            datetimeoffset(0),
            NULLIF(LTRIM(RTRIM(CONVERT(nvarchar(50), [LocationBegin]))), ''),
            126
        ) AS LocationBegin_dt

    FROM reporting.SamplingPointLocation
)

SELECT
    [CountryCode],
    [AssessmentMethodId],
    [LocationBegin]

FROM src

WHERE
    LocationBegin IS NOT NULL
    AND LTRIM(RTRIM(CONVERT(nvarchar(50), LocationBegin))) <> ''
    AND LocationBegin_dt IS NULL;

GO