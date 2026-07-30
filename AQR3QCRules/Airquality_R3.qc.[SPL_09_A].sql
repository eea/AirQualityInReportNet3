USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qctesting].[SPL_09_A_TEST]
AS

WITH src AS
(
    SELECT
        [CountryCode],
        [AssessmentMethodId],
        [Latitude],

        NULLIF(
            LTRIM(RTRIM(CONVERT(nvarchar(50), [Latitude]))),
            ''
        ) AS Latitude_str,

        TRY_CONVERT(
            decimal(18,4),
            NULLIF(LTRIM(RTRIM(CONVERT(nvarchar(50), [Latitude]))), '')
        ) AS Latitude_num

    FROM reporting.SamplingPointLocation
)

SELECT
    [CountryCode],
    [AssessmentMethodId],
    [Latitude]

FROM src

WHERE
    Latitude_str IS NOT NULL
    AND
    (
        Latitude_num IS NULL

        OR Latitude_str NOT LIKE '%.___ _'

        OR Latitude_num < -90
        OR Latitude_num > 90
    );

GO