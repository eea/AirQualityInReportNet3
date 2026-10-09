--QC code: SPP_06_B
--QC name: SPP_06_B Cross-check & Consistency - [AssessmentMethodId] SPO_02 [PollutantId] SPO_04
--QC rule description: Combination of attribute values SPP_03 and SPP_06 must correspond to the combination of attribute values SPO_02 and SPO_04 in SamplingPoint table in reporting or reference data.

CREATE VIEW [qc].[SPP_06_B] AS
WITH sp AS (
SELECT
NULLIF(LTRIM(RTRIM([CountryCode])),'') AS [CountryCode],
NULLIF(LTRIM(RTRIM([AssessmentMethodId])),'') AS [AssessmentMethodId],
TRY_CONVERT(
int,
TRY_CONVERT(decimal(32,16), NULLIF(LTRIM(RTRIM(CONVERT(nvarchar(200), [PollutantId]))), ''))
) AS [PollutantId]
FROM [reporting].[SamplingProcess]
),
pt_rep AS (
SELECT DISTINCT
NULLIF(LTRIM(RTRIM([AssessmentMethodId])),'') AS [AssessmentMethodId],
TRY_CONVERT(
int,
TRY_CONVERT(decimal(32,16), NULLIF(LTRIM(RTRIM(CONVERT(nvarchar(200), [PollutantId]))), ''))
) AS [PollutantId]
FROM [reporting].[SamplingPoint]
),
pt_ref AS (
SELECT DISTINCT
NULLIF(LTRIM(RTRIM([AssessmentMethodId])),'') AS [AssessmentMethodId],
TRY_CONVERT(
int,
TRY_CONVERT(decimal(32,16), NULLIF(LTRIM(RTRIM(CONVERT(nvarchar(200), [PollutantId]))), ''))
) AS [PollutantId]
FROM [reference].[SamplingPoint]
)
SELECT
s.[CountryCode],
s.[AssessmentMethodId],
s.[PollutantId]
FROM sp s
WHERE
s.[AssessmentMethodId] IS NULL
OR s.[PollutantId] IS NULL
OR (
NOT EXISTS (
SELECT 1 FROM pt_rep r
WHERE r.[AssessmentMethodId] = s.[AssessmentMethodId]
AND r.[PollutantId] = s.[PollutantId]
)
AND NOT EXISTS (
SELECT 1 FROM pt_ref f
WHERE f.[AssessmentMethodId] = s.[AssessmentMethodId]
AND f.[PollutantId] = s.[PollutantId]
)
);
GO