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
        TRY_CONVERT(int, LTRIM(RTRIM([Notation]))) AS PollutantId
    FROM [reference].[Vocabulary]
    WHERE [vocabulary] COLLATE DATABASE_DEFAULT =
          'pollutant' COLLATE DATABASE_DEFAULT
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