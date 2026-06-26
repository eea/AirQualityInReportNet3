USE [Airquality_R3]
GO

/****** Object:  View [qc].[[SPP_06_A]]    Script Date: 26/06/2026 11:02:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE OR ALTER VIEW [qc].[SPP_06_A] AS
WITH src AS (
SELECT
[CountryCode],
[AssessmentMethodId],
NULLIF(LTRIM(RTRIM(CONVERT(nvarchar(200), [PollutantId]))), '') AS [PollutantId_norm]
FROM [reporting].[SamplingProcess]
),
vocab AS (
SELECT DISTINCT
NULLIF(LTRIM(RTRIM([notation])), '') AS [notation_norm]
FROM [reference].[Vocabulary]
WHERE [vocabulary] = 'pollutant'
)
SELECT
s.[CountryCode],
s.[AssessmentMethodId],
s.[PollutantId_norm] AS [PollutantId]

FROM src s
LEFT JOIN vocab v
ON v.[notation_norm] = s.[PollutantId_norm]
WHERE s.[PollutantId_norm] IS NULL
OR v.[notation_norm] IS NULL;
GO





