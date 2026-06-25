USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPP_03_B]    Script Date: 25/06/2026 13:08:58 ******/
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


