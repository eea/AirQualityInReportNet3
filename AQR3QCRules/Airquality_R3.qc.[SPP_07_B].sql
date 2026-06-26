USE [Airquality_R3]
GO

/****** Object:  View [qc].[[[SPP_07_B]]]    Script Date: 26/06/2026 11:02:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER VIEW [qc].[SPP_07_B] AS
SELECT
[CountryCode],
[AssessmentMethodId],
[MeasurementType],
LEN(LTRIM(RTRIM([MeasurementType]))) AS [MeasurementType_Length],
'MeasurementType length must be between 1 and 50' AS [violation]
FROM [reporting].[SamplingProcess]
WHERE
[MeasurementType] IS NULL
OR LEN(LTRIM(RTRIM([MeasurementType]))) NOT BETWEEN 1 AND 50;
GO
