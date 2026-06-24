USE [Airquality_R3]
GO

/****** Object:  View [qc].[STA_04_A]    Script Date: 24/06/2026 12:29:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE   VIEW [qc].[STA_04_A] AS
SELECT
[StationEoICode],
[CountryCode],
[NetworkName]
FROM [reporting].[MeasurementStation]
WHERE [NetworkName] IS NULL
OR LEN(LTRIM(RTRIM([NetworkName]))) NOT BETWEEN 1 AND 150;

GO

