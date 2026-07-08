USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPL_09_B] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [qctesting].[SPL_09_B_TEST] 
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
            decimal(9,6),
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
        OR Latitude_num < -90
        OR Latitude_num > 90
    );

GO