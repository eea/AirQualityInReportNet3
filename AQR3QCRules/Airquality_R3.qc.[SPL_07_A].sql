USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qctesting].[SPL_07_A_TEST]
AS

WITH src AS
(
    SELECT
        [CountryCode],
        [AssessmentMethodId],
        [Hotspot],

        NULLIF(
            LTRIM(RTRIM(CONVERT(nvarchar(50), [Hotspot]))),
            ''
        ) AS Hotspot_str

    FROM reporting.SamplingPointLocation
)

SELECT
    [CountryCode],
    [AssessmentMethodId],
    [Hotspot]

FROM src

WHERE
    Hotspot_str IS NULL
    OR
    (
        UPPER(Hotspot_str) NOT IN
        (
            'Y',
            'N',
            'YES',
            'NO',
            'TRUE',
            'FALSE'
        )
    );

/*
    TODO:
    The official set of accepted boolean representations has not yet been defined
    in the specification.

    Once agreed, replace the provisional list above with the official values.
*/
GO