USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPL_13_A]     ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qctesting].[SPL_13_A_TEST] AS

WITH src AS
(
    SELECT
        [CountryCode],
        [AssessmentMethodId],
        [BuildingDistance],

        NULLIF(
            LTRIM(RTRIM(CONVERT(nvarchar(50), [BuildingDistance]))),
            ''
        ) AS BuildingDistance_str,

        TRY_CONVERT(
            decimal(9,2),
            NULLIF(LTRIM(RTRIM(CONVERT(nvarchar(50), [BuildingDistance]))), '')
        ) AS BuildingDistance_num

    FROM reporting.SamplingPointLocation
)

SELECT
    [CountryCode],
    [AssessmentMethodId],
    [BuildingDistance]

FROM src

WHERE
    BuildingDistance_str IS NOT NULL
    AND
    (
        BuildingDistance_num IS NULL
        OR BuildingDistance_num <= 0
        OR BuildingDistance_num >= 500
    );

GO