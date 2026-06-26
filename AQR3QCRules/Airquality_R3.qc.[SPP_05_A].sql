USE [Airquality_R3]
GO

/****** Object:  View [qc].[[SPP_05_A]]    Script Date: 25/06/2026 13:08:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER VIEW [qc].[SPP_05_A] AS
WITH src AS (
SELECT
[CountryCode],
[AssessmentMethodId],
[ProcessActivityEnd],
NULLIF(LTRIM(RTRIM(CONVERT(nvarchar(50), [ProcessActivityEnd]))), '') AS End_str,
TRY_CONVERT(datetimeoffset(0),
NULLIF(LTRIM(RTRIM(CONVERT(nvarchar(50), [ProcessActivityEnd]))), ''),
126) AS End_as_dto, -- ISO 8601 with Z or ±HH:MM
TRY_CONVERT(datetime2(0),
NULLIF(LTRIM(RTRIM(CONVERT(nvarchar(50), [ProcessActivityEnd]))), ''),
126) AS End_as_dt2 -- ISO 8601 without offset
FROM [reporting].[SamplingProcess]
)
SELECT
[CountryCode],
[AssessmentMethodId],
[ProcessActivityEnd]
FROM src
WHERE End_str IS NOT NULL
AND End_as_dto IS NULL
AND End_as_dt2 IS NULL;
GO
