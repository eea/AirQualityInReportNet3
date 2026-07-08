USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPL_10_A] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [qctesting].[SPL_10_A_TEST] AS


WITH src AS
(
    SELECT
        [CountryCode],
        [AssessmentMethodId],
        [Longitude],

        NULLIF(LTRIM(RTRIM(CONVERT(nvarchar(50), [Longitude]))), '') AS Longitude_str,

        TRY_CONVERT(decimal(18,4),
            NULLIF(LTRIM(RTRIM(CONVERT(nvarchar(50), [Longitude]))), '')
        ) AS Longitude_dec
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
        Longitude_dec IS NULL
        OR Longitude_str NOT LIKE '%.___ _'
    );

GO