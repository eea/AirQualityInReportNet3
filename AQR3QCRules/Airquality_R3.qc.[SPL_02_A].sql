USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPL_02_A]   ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qctesting].[SPL_02_A_TEST]
AS

	SELECT
		[CountryCode],
		[AssessmentMethodId]
	FROM reporting.SamplingPointLocation

	WHERE AssessmentMethodId IS NULL
		OR LEN(LTRIM(RTRIM(AssessmentMethodId))) NOT BETWEEN 1 AND 50;

GO