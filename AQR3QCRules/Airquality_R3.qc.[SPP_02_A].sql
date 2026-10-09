USE [Airquality_R3]
GO

-- Creation date: October 2026
-- QC rule code: SPP_02_A
-- QC rule name: SPP_02_A Content check - [ProcessId]
-- QC rule description: ProcessId must be reported and shall identify the sampling process or equipment configuration used.

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE   VIEW [qc].SPP_02_A AS
SELECT
ProcessId,
[CountryCode],
[AssessmentMethodId]
FROM [reporting].[SamplingProcess]
WHERE ProcessId IS NULL
OR LEN(LTRIM(RTRIM(ProcessId))) NOT BETWEEN 1 AND 150;

GO


