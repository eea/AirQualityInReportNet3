USE [Airquality_R3]
GO

/****** Object:  View [qc].[STA_02_A]    Script Date: 03/07/2026 11:22:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [qc].[STA_02_A] AS
WITH s AS (
SELECT
NULLIF(LTRIM(RTRIM([StationEoICode])),'') AS [StationEoICode],
NULLIF(LTRIM(RTRIM([CountryCode])),'') AS [CountryCode],
NULLIF(LTRIM(RTRIM([NetworkId])),'') AS [NetworkId]
FROM [reporting].[MeasurementStation]
WHERE [StationEoICode] IS NOT NULL
),
per_code AS (
SELECT
[StationEoICode],
COUNT(DISTINCT [CountryCode]) AS [DistinctCountryCodes],
COUNT(DISTINCT [NetworkId]) AS [DistinctNetworkIds]
FROM s
GROUP BY [StationEoICode]
)
SELECT
p.[StationEoICode],
p.[DistinctCountryCodes],
p.[DistinctNetworkIds]
FROM per_code p
WHERE p.[DistinctCountryCodes] > 1
OR p.[DistinctNetworkIds] > 1;

GO


