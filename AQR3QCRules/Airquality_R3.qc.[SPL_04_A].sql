USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPL_04_A] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[SPL_04_A]
AS

-- Creation date: 02/08/2026
-- QC rule code: SPL_04_A
-- QC rule name: LocationEnd

WITH CTE_samplingPointLocation AS (
    SELECT
        [CountryCode],
        [AssessmentMethodId],
        [LocationEnd],

        NULLIF(
            LTRIM(RTRIM(CONVERT(nvarchar(50), [LocationEnd]))),
            ''
        ) AS LocationEnd_str,

        TRY_CONVERT(
            datetimeoffset(0),
            NULLIF(
                LTRIM(RTRIM(CONVERT(nvarchar(50), [LocationEnd]))),
                ''
            ),
            126
        ) AS LocationEnd_dt

    FROM [reporting].[SamplingPointLocation]
)

SELECT
    [CountryCode],
    [AssessmentMethodId],
    [LocationEnd]

FROM CTE_samplingPointLocation

WHERE
       [LocationEnd] IS NOT NULL
   AND (
          [LocationEnd_str] IS NULL
          OR [LocationEnd_dt] IS NULL
       );

GO