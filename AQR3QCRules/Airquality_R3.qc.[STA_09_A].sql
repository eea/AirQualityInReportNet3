USE [Airquality_R3]
GO

/****** Object:  View [qc].[STA_09_A]    Script Date: 24/06/2026 12:29:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE   VIEW [qc].[STA_09_A] AS
SELECT
[StationEoICode],
[CountryCode],
[NetworkDocumentId]
FROM [reporting].[MeasurementStation]
WHERE NetworkDocumentId IS NULL
OR LEN(LTRIM(RTRIM(NetworkDocumentId))) NOT BETWEEN 1 AND 150;

GO
