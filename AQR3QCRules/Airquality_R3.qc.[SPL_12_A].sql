USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPL_09_B] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [qctesting].[SPL_09_B_TEST] AS


WITH src AS
(
    SELECT
        [CountryCode],
        [AssessmentMethodId],
        [Altitude],

        NULLIF(
            LTRIM(RTRIM(CONVERT(nvarchar(50), [Altitude]))),
            ''
        ) AS Altitude_str,

        TRY_CONVERT(
            decimal(9,6),
            NULLIF(LTRIM(RTRIM(CONVERT(nvarchar(50), [Altitude]))), '')
        ) AS Altitude_num

    FROM reporting.SamplingPointLocation
)

SELECT
    [CountryCode],
    [AssessmentMethodId],
    [Altitude]

FROM src

WHERE
    Altitude_str IS NOT NULL
    AND
    (
        Altitude_num IS NULL
        OR Altitude_num < -50
        OR Altitude_num > 6000
    );

GO