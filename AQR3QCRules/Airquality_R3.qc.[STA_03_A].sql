USE [Airquality_R3]
GO

/****** Object:  View [qc].[STA_03_A]    Script Date: 16/11/2026 14:13:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[STA_03_A] AS

-- QC rule code: STA_03_A
-- QC rule name: STA_03_A Content check - [NetworkId]
-- QC rule description: NetworkId must be provided and must not be null or empty.

SELECT
    --"record_id",
    NULLIF(LTRIM(RTRIM("CountryCode")), '')    AS "CountryCode",
    NULLIF(LTRIM(RTRIM("StationEoICode")), '') AS "StationEoICode",
    NULLIF(LTRIM(RTRIM("NetworkId")), '')      AS "NetworkId"
FROM reporting."MeasurementStation"
WHERE NULLIF(LTRIM(RTRIM("NetworkId")), '') IS NULL;
GO