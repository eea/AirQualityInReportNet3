USE [Airquality_R3]
GO


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


