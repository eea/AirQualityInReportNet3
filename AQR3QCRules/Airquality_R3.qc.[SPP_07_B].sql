USE [Airquality_R3]
GO

/****** Object:  View [qc].[SPP_07_B]    Script Date: 14/10/2026 08:32:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- Creation date: July 2026
-- QC rule code: SPP.07.B
-- QC rule name: SPP.07.B Vocabulary - [MeasurementType]
--QC rule description: Attribute SPP_07 must have length > 0 and < 51.

CREATE OR ALTER VIEW [qc].[SPP_07_B]
AS
SELECT
    [CountryCode],
    [AssessmentMethodId],
    [MeasurementType],
    LEN(LTRIM(RTRIM([MeasurementType]))) AS [MeasurementType_Length]
FROM [reporting].[SamplingProcess]
WHERE
    [MeasurementType] IS NULL
    OR LEN(LTRIM(RTRIM([MeasurementType]))) NOT BETWEEN 1 AND 50;
GO


