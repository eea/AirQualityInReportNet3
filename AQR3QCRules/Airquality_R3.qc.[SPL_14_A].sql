USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPL_14_A]   ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER VIEW [qctesting].[SPL_14_A_TEST] AS

WITH src AS
(
    SELECT
        [CountryCode],
        [AssessmentMethodId],
        [KerbDistance],

        NULLIF(
            LTRIM(RTRIM(CONVERT(nvarchar(50), [KerbDistance]))),
            ''
        ) AS KerbDistance_str,

        TRY_CONVERT(
            decimal(9,2),
            NULLIF(LTRIM(RTRIM(CONVERT(nvarchar(50), [KerbDistance]))), '')
        ) AS KerbDistance_num

    FROM reporting.SamplingPointLocation
)

SELECT
    [CountryCode],
    [AssessmentMethodId],
    [KerbDistance]

FROM src

WHERE
    KerbDistance_str IS NOT NULL
    AND
    (
        KerbDistance_num IS NULL
        OR KerbDistance_num <= 0
        OR KerbDistance_num >= 50
    );

GO