USE [Airquality_R3]
GO



SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
--QC code: SPP_03_A
--QC name: SPP_03_A Constraint – [AssessmentMethodId]
--QC rule description: Attribute SPP_03 must have length > 0 and < 51.

CREATE   VIEW [qc].[SPP_03_A] AS
SELECT
ProcessId,
[CountryCode],
[AssessmentMethodId]
FROM [reporting].[SamplingProcess]
WHERE AssessmentMethodId IS NULL
OR LEN(LTRIM(RTRIM(AssessmentMethodId))) NOT BETWEEN 1 AND 50;

GO


