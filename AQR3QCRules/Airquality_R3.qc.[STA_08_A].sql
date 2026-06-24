USE [Airquality_R3]
GO

/****** Object:  View [qc].[STA_08_A]    Script Date: 24/06/2026 12:29:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE   VIEW [qc].[STA_08_A] AS
SELECT
[StationEoICode],
[CountryCode],
[StationName]
FROM [reporting].[MeasurementStation]
WHERE [StationName] IS NULL
OR LEN(LTRIM(RTRIM([StationName]))) NOT BETWEEN 1 AND 150;

GO

