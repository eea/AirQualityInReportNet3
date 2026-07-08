USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPL_09_A] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [qctesting].[SPL_09_A_TEST] 
AS


WITH src AS
(
    SELECT
        [CountryCode],
        [AssessmentMethodId],
        [Latitude],

        NULLIF(LTRIM(RTRIM(CONVERT(nvarchar(50), [Latitude]))), '') AS Latitude_str,

        TRY_CONVERT(decimal(18,4),
            NULLIF(LTRIM(RTRIM(CONVERT(nvarchar(50), [Latitude]))), '')
        ) AS Latitude_dec
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
        Latitude_dec IS NULL
        OR Latitude_str NOT LIKE '%.___ _'
    );

GO