USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPL_15_A]   ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [qctesting].[SPL_15_A_TEST] AS

WITH src AS
(
    SELECT
        [CountryCode],
        [AssessmentMethodId],
        [EmissionSourceDistance],

        NULLIF(
            LTRIM(RTRIM(CONVERT(nvarchar(50), [EmissionSourceDistance]))),
            ''
        ) AS EmissionSourceDistance_str,

        TRY_CONVERT(
            decimal(9,2),
            NULLIF(LTRIM(RTRIM(CONVERT(nvarchar(50), [EmissionSourceDistance]))), '')
        ) AS EmissionSourceDistance_num

    FROM reporting.SamplingPointLocation
)

SELECT
    [CountryCode],
    [AssessmentMethodId],
    [EmissionSourceDistance]

FROM src

WHERE
    EmissionSourceDistance_str IS NOT NULL
    AND
    (
        EmissionSourceDistance_num IS NULL
        OR EmissionSourceDistance_num <= 0
        OR EmissionSourceDistance_num >= 5000
    );

GO