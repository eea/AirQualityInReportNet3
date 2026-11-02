USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[SPO_04_A]
AS

-- QC rule code: SPO_04_A
-- QC rule name: SPO_04_A Vocabulary - [PollutantId]
-- QC rule description: PollutantId from the SamplingPoint table must be reported using a valid value from the pollutant vocabulary.

WITH sampling_points AS
(
    SELECT
        [CountryCode],
        [AssessmentMethodId],
        [PollutantId]
    FROM [reporting].[SamplingPoint]
),
pollutant_vocabulary AS
(
    SELECT DISTINCT
        TRY_CONVERT(
            int,
            REPLACE(
                LOWER(LTRIM(RTRIM([URI]))),
                'http://dd.eionet.europa.eu/vocabulary/aq/pollutant/',
                ''
            )
        ) AS [PollutantId]
    FROM [reference].[Vocabulary]
    WHERE [vocabulary] = 'pollutant'
)
SELECT
    sp.CountryCode,
    sp.AssessmentMethodId,
    sp.PollutantId
FROM sampling_points AS sp
LEFT JOIN pollutant_vocabulary AS pv
    ON sp.PollutantId = pv.PollutantId
WHERE sp.PollutantId IS NULL
   OR pv.PollutantId IS NULL
GO