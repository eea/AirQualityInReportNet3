USE [Airquality_R3]
GO

/****** Object:  View [qc].[ZOG_PK]    Script Date: 26/08/2026 11:18:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [qc].[ZOG_PK]
AS
-- QC rule code: ZOG_PK
-- QC rule name: Primary key validation - [CountryCode, ZoneId]
--
-- The view returns records that violate the primary key requirements:
-- - CountryCode or ZoneId is NULL.
-- - More than one record has the same CountryCode and ZoneId combination.

WITH CTE_source AS
(
    SELECT
        [CountryCode],
        [ZoneId]
    FROM [reporting].[ZoneGeometry]
),
CTE_duplicate_keys AS
(
    SELECT
        [CountryCode],
        [ZoneId],
        COUNT(*) AS duplicate_count
    FROM CTE_source
    WHERE [CountryCode] IS NOT NULL
      AND [ZoneId] IS NOT NULL
    GROUP BY
        [CountryCode],
        [ZoneId]
    HAVING COUNT(*) > 1
)
SELECT
    s.[CountryCode],
    s.[ZoneId],
    d.duplicate_count,
    CASE
        WHEN s.[CountryCode] IS NULL
         AND s.[ZoneId] IS NULL
            THEN 'COUNTRYCODE_AND_ZONEID_NULL'

        WHEN s.[CountryCode] IS NULL
            THEN 'COUNTRYCODE_NULL'

        WHEN s.[ZoneId] IS NULL
            THEN 'ZONEID_NULL'

        WHEN d.duplicate_count IS NOT NULL
            THEN 'DUPLICATE_PRIMARY_KEY'

        ELSE 'UNKNOWN'
    END AS [QC_FailureReason]
FROM CTE_source AS s
LEFT JOIN CTE_duplicate_keys AS d
    ON d.[CountryCode] = s.[CountryCode]
   AND d.[ZoneId] = s.[ZoneId]
WHERE
    s.[CountryCode] IS NULL
    OR s.[ZoneId] IS NULL
    OR d.duplicate_count IS NOT NULL;
GO


