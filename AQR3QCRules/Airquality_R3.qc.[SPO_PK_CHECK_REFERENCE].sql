USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPO_PK_TEST]    Script Date: 10/06/2026 14:20:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [qc].[SPO_PK_CHECK_REFERENCE] AS


-- QC rule code: SPO.PK
-- QC rule name:  SPO.PK Constraint - [CountryCode,AssessmentMethodId]

WITH s AS (
	SELECT
	NULLIF(TRIM(CountryCode), '') AS CountryCode,
	NULLIF(TRIM(AssessmentMethodId), '') AS AssessmentMethodId
	FROM qctesting.SamplingPoint
	),

	r AS (
	SELECT
	NULLIF(TRIM(CountryCode), '') AS CountryCode,
	NULLIF(TRIM(AssessmentMethodId), '') AS AssessmentMethodId
	FROM reference.SamplingPoint
	),

	dups AS (
	SELECT CountryCode, AssessmentMethodId, COUNT(1) AS cnt
	FROM s
	GROUP BY CountryCode, AssessmentMethodId
	HAVING COUNT(1) > 1
	)

	SELECT
	s.CountryCode,
	s.AssessmentMethodId,
	CASE
		WHEN s.CountryCode IS NULL OR s.AssessmentMethodId IS NULL THEN 'Null key'
		WHEN d.cnt IS NOT NULL THEN 'Duplicate in submitted'
		WHEN r.AssessmentMethodId IS NULL THEN 'Missing in reference'
	ELSE 'OK'
	END AS violation

	FROM s
	LEFT JOIN dups d
	ON d.CountryCode = s.CountryCode
	AND d.AssessmentMethodId = s.AssessmentMethodId
	LEFT JOIN r
	ON r.CountryCode = s.CountryCode
	AND r.AssessmentMethodId = s.AssessmentMethodId
	WHERE
	s.CountryCode IS NULL
	OR s.AssessmentMethodId IS NULL
	OR d.cnt IS NOT NULL
	OR r.AssessmentMethodId IS NULL;
GO


