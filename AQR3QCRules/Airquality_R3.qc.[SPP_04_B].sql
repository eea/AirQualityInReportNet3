USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPP_04_B]    Script Date: 22/10/2026 17:04:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--QC code: SPP_04_B
--QC name: SPP_04_B Consistency	[ProcessActivityBegin], [ProcessActivityEnd]
--QC rule description: ProcessActivityBegin must be earlier than or equal to ProcessActivityEnd when ProcessActivityEnd is reported.

create   VIEW [qc].[SPP_04_B] AS
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


