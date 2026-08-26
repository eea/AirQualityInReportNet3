USE [Airquality_R3]
GO

/****** Object:  View [qc].[ZOG_0]    Script Date: 26/08/2026 12:39:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   VIEW [qc].[ZOG_0]
AS
-- QC rule code: ZOG_0
-- QC rule name: Status - [PK]

WITH cte_submitted AS
(
    SELECT
        NULLIF([CountryCode], '') AS [CountryCode],
        NULLIF([ZoneId], '') AS [ZoneId]
    FROM reporting.[ZoneGeometry]
),
cte_reference AS
(
    SELECT
        [CountryCode],
        [ZoneId],
        [Deletion]
    FROM reference.[ZoneGeometry]
)
SELECT
    s.[CountryCode],
    s.[ZoneId],
    CASE
        -- The submitted record does not exist in the reference dataset.
        WHEN r.[CountryCode] IS NULL
            THEN 'Addition of new record'

        -- The matching reference record is marked as deleted.
        WHEN r.[Deletion] = 1
            THEN 'Modification of existing record'

        -- The matching reference record exists and is not marked as deleted.
        ELSE 'No modification'
    END AS [record_status]
FROM cte_submitted AS s
LEFT JOIN cte_reference AS r
    ON s.[CountryCode] = r.[CountryCode]
   AND s.[ZoneId] = r.[ZoneId];
GO


