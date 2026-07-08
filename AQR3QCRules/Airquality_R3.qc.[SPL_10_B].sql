USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPL_10_B] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [qctesting].[SPL_10_B_TEST] AS

WITH src AS
(
    SELECT
        [CountryCode],
        [AssessmentMethodId],
        [Longitude],

        NULLIF(
            LTRIM(RTRIM(CONVERT(nvarchar(50), [Longitude]))),
            ''
        ) AS Longitude_str,

        TRY_CONVERT(
            decimal(9,6),
            NULLIF(LTRIM(RTRIM(CONVERT(nvarchar(50), [Longitude]))), '')
        ) AS Longitude_num

    FROM reporting.SamplingPointLocation
)

SELECT
    [CountryCode],
    [AssessmentMethodId],
    [Longitude]

FROM src

WHERE
    Longitude_str IS NOT NULL
    AND
    (
        Longitude_num IS NULL
        OR Longitude_num < -180
        OR Longitude_num > 180
    );

GO