USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPL_12_A] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER VIEW [qctesting].[SPL_12_A_TEST] AS


WITH src AS
(
    SELECT
        [CountryCode],
        [AssessmentMethodId],
        [InletHeight],

        NULLIF(
            LTRIM(RTRIM(CONVERT(nvarchar(50), [InletHeight]))),
            ''
        ) AS InletHeight_str,

        TRY_CONVERT(
            decimal(9,6),
            NULLIF(LTRIM(RTRIM(CONVERT(nvarchar(50), [InletHeight]))), '')
        ) AS InletHeight_num

    FROM reporting.SamplingPointLocation
)

SELECT
    [CountryCode],
    [AssessmentMethodId],
    [InletHeight]

FROM src

WHERE
    InletHeight_str IS NOT NULL
    AND
    (
        InletHeight_num IS NULL
        OR InletHeight_num <= 0
        OR InletHeight_num >= 30
    );

GO