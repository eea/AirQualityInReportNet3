USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [qc].[STA_04_B] AS

-- QC rule code: STA_04_B
-- QC rule name: STA_04_B Cross-check - [NetworkId], [NetworkName]
-- QC rule description: NetworkName shall be consistently associated with the corresponding NetworkId within each reported CountryCode.

WITH s AS (
    SELECT
        NULLIF(LTRIM(RTRIM("CountryCode")), '')  AS "CountryCode",
        NULLIF(LTRIM(RTRIM("NetworkId")), '')    AS "NetworkId",
        NULLIF(LTRIM(RTRIM("NetworkName")), '')  AS "NetworkName"
    FROM reporting."MeasurementStation"
),
conflicts AS (
    SELECT "CountryCode", "NetworkId"
    FROM s
    GROUP BY "CountryCode", "NetworkId"
    HAVING COUNT(DISTINCT "NetworkName") > 1
)
SELECT
    --"record_id",
    s."CountryCode",
    s."NetworkId",
    s."NetworkName"
FROM s
LEFT JOIN conflicts c
    ON s."CountryCode" = c."CountryCode"
   AND s."NetworkId"  = c."NetworkId"
WHERE s."NetworkName" IS NULL        -- points 1-3: not reported / null / empty
   OR c."NetworkId" IS NOT NULL      -- point 4: same NetworkId with different NetworkNames within the CountryCode
-- Pending (point 5): NetworkName consistent with NetworkId against the reference data — reference structure to be confirmed
GO