USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPP_03_B]    Script Date: 25/06/2026 13:08:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER VIEW [qc].[SPP_04_A] AS
	WITH src AS (
	SELECT
	[CountryCode],
	[AssessmentMethodId],
	[ProcessActivityBegin],
	[ProcessActivityEnd],
		TRY_CONVERT(datetimeoffset(0), NULLIF(LTRIM(RTRIM(CONVERT(nvarchar(50), [ProcessActivityBegin]))), ''), 126) AS Begin_dt,
		TRY_CONVERT(datetimeoffset(0), NULLIF(LTRIM(RTRIM(CONVERT(nvarchar(50), [ProcessActivityEnd]))), ''), 126) AS End_dt
	FROM [reporting].[SamplingProcess]
	)
	SELECT
	[CountryCode],
	[AssessmentMethodId],
	[ProcessActivityBegin],
	[ProcessActivityEnd]
	FROM src
	WHERE End_dt IS NOT NULL
	AND Begin_dt IS NOT NULL
	AND Begin_dt > End_dt;

GO
