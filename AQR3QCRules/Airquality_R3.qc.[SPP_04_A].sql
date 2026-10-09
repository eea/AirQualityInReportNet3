USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPP_04_A]    Script Date: 07/10/2026 12:32:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--QC code: SPP_04_A
--QC name: SPP_04_A Consistency  – [ProcessActivityEnd] SPP_05
--QC rule description: Attribute SPP_04 value must be <= SPP_05 if SPP_05 is not null (when SPP_04 = SPP_05 the record is meant for deletion)

CREATE OR ALTER   VIEW [qc].[SPP_04_A] AS
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


