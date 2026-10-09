USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPP_03_B]    Script Date: 07/10/2026 12:24:03 ******/
-- Creation date: June 2026
--QC code: SPP_03_B
--QC name: SPP_03_B Consistency & Cross-check – [CountryCode] SPO_01 [AssessmentMethodId] SPO_02 
--QC rule description: Attribute SPP_03 must correspond to one of the values of attribute AssessmentMethodId (SPO_02) for the same CountryCode (SPO_01) in SamplingPoint table in reporting or reference data.

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   VIEW [qc].[SPP_03_B] AS
WITH sp_proc AS (
SELECT
NULLIF(LTRIM(RTRIM([CountryCode])),'') AS [CountryCode],
NULLIF(LTRIM(RTRIM([AssessmentMethodId])),'') AS [AssessmentMethodId]
FROM reporting.SamplingProcess
),
sp_point_reporting AS (
SELECT DISTINCT
NULLIF(LTRIM(RTRIM([CountryCode])),'') AS [CountryCode],
NULLIF(LTRIM(RTRIM([AssessmentMethodId])),'') AS [AssessmentMethodId]
FROM reporting.[SamplingPoint]
),
sp_point_reference AS (
SELECT DISTINCT
NULLIF(LTRIM(RTRIM([CountryCode])),'') AS [CountryCode],
NULLIF(LTRIM(RTRIM([AssessmentMethodId])),'') AS [AssessmentMethodId]
FROM [reference].[SamplingPoint]
),
check_proc AS (
SELECT
p.[CountryCode],
p.[AssessmentMethodId],
CASE WHEN EXISTS (
SELECT 1
FROM sp_point_reporting r
WHERE r.[CountryCode] = p.[CountryCode]
AND r.[AssessmentMethodId] = p.[AssessmentMethodId]
) THEN 1 ELSE 0 END AS [in_reporting],
CASE WHEN EXISTS (
SELECT 1
FROM sp_point_reference r
WHERE r.[CountryCode] = p.[CountryCode]
AND r.[AssessmentMethodId] = p.[AssessmentMethodId]
) THEN 1 ELSE 0 END AS [in_reference]
FROM sp_proc p
)
SELECT
[CountryCode],
[AssessmentMethodId],
[in_reporting],
[in_reference],
CASE
WHEN [CountryCode] IS NULL OR [AssessmentMethodId] IS NULL
THEN 'Null key in SamplingProcess'
ELSE 'AssessmentMethodId not found in SamplingPoint (reporting nor reference)'
END AS [violation]
FROM check_proc
WHERE
[CountryCode] IS NULL
OR [AssessmentMethodId] IS NULL
OR ([in_reporting] = 0 AND [in_reference] = 0);

GO


