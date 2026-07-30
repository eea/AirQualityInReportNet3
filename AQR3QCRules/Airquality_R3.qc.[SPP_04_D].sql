USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPP_04_C]    Script Date: 25/06/2026 13:08:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER VIEW [qc].[SPP_04_C] AS

WITH src AS (
SELECT
	[CountryCode],
	[AssessmentMethodId],
	[ProcessActivityBegin],
	NULLIF(LTRIM(RTRIM(CONVERT(nvarchar(50), [ProcessActivityBegin]))), '') AS Begin_str,
	TRY_CONVERT(datetimeoffset(0),

	NULLIF(LTRIM(RTRIM(CONVERT(nvarchar(50), [ProcessActivityBegin]))), ''),
	126) AS Begin_as_dto, -- ISO 8601 with Z or ±HH:MM
	TRY_CONVERT(datetime2(0),

	NULLIF(LTRIM(RTRIM(CONVERT(nvarchar(50), [ProcessActivityBegin]))), ''),
	126) AS Begin_as_dt2 -- ISO 8601 without offset
FROM [reporting].[SamplingProcess]
)
SELECT
	[CountryCode],
	[AssessmentMethodId],
	[ProcessActivityBegin]
FROM src
	WHERE Begin_str IS NOT NULL
	AND Begin_as_dto IS NULL
	AND Begin_as_dt2 IS NULL;
GO
