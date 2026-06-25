USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPP_03_A]    Script Date: 25/06/2026 13:08:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   VIEW [qc].[SPP_03_A] AS
SELECT
ProcessId,
[CountryCode],
[AssessmentMethodId]
FROM [reporting].[SamplingProcess]
WHERE AssessmentMethodId IS NULL
OR LEN(LTRIM(RTRIM(AssessmentMethodId))) NOT BETWEEN 1 AND 50;

GO


