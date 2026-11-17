USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[STA_02_B] AS

-- QC rule code: STA_02_B
-- QC rule name: STA_02_B Format - [StationEoICode]
-- QC rule description: StationEoICode must follow the official Exchange of Information (EoI) identifier format: <CountryCode><AlphanumericStationID> (e.g. AD0942A).

WITH s AS (
    SELECT
        NULLIF(LTRIM(RTRIM([StationEoICode])),'') AS [StationEoICode],
        NULLIF(LTRIM(RTRIM([CountryCode])),'')    AS [CountryCode]
    FROM [reporting].[MeasurementStation]
)
SELECT
    [CountryCode],
    [StationEoICode]
FROM s
WHERE [CountryCode] IS NOT NULL
  AND [StationEoICode] IS NOT NULL
  AND (
        LEFT([StationEoICode], LEN([CountryCode])) <> [CountryCode]                                        -- bullet 1: does not start with the reported CountryCode
     OR LEN([StationEoICode]) <= LEN([CountryCode])                                                        -- bullet 2: missing alphanumeric station ID part
     OR SUBSTRING([StationEoICode], LEN([CountryCode]) + 1, LEN([StationEoICode])) LIKE '%[^a-zA-Z0-9]%'   -- bullet 2: non-alphanumeric characters in the station ID part
      );
GO