USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qctesting].[SPL_07_B_TEST]
AS

WITH src AS
(
    SELECT
        [CountryCode],
        [AssessmentMethodId],
        [SamplingPointCategory],
        [Hotspot],

        UPPER(
            NULLIF(
                LTRIM(RTRIM(CONVERT(nvarchar(50), [SamplingPointCategory]))),
                ''
            )
        ) AS SamplingPointCategory_str,

        UPPER(
            NULLIF(
                LTRIM(RTRIM(CONVERT(nvarchar(50), [Hotspot]))),
                ''
            )
        ) AS Hotspot_str

    FROM reporting.SamplingPointLocation
)

SELECT
    [CountryCode],
    [AssessmentMethodId],
    [SamplingPointCategory],
    [Hotspot]

FROM src

WHERE
    (
        SamplingPointCategory_str = 'BACKGROUND'
        AND Hotspot_str <> 'NO'
    )
    OR
    (
        SamplingPointCategory_str <> 'BACKGROUND'
        AND Hotspot_str <> 'YES'
    );

/*
    TODO:
    The dependency between SamplingPointCategory and Hotspot is provisional.

    Once the specification is finalized:
    - Confirm the complete list of SamplingPointCategory values.
    - Confirm the official boolean representations for Hotspot.
    - Update the dependency rules accordingly.
*/
GO