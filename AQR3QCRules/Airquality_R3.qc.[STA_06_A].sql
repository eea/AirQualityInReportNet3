USE [Airquality_R3]
GO

/****** Object:  View [qc].[STA_06_A]    Script Date: 21/08/2025 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [qc].[STA_06_A] AS

-- Creation date: 21 August 2025
-- QC rule code: STA_06_A
-- QC rule name: STA_06_A Format - [TimeZone]


WITH CTE_stationTimeZone AS (
  SELECT 
    /*record_id,*/TimeZone,
    CASE WHEN "TimeZone" = '' THEN NULL ELSE "TimeZone" END AS "TimeZoneClean"
  --FROM dataset_35236."station" -- commented in SQL Server, necessary in Reportnet 3
  FROM reporting.Station -- added in SQL Server, it is replaced by the line from above in Reportnet 3
  WHERE "TimeZone" IS NOT NULL 
),

TimeZoneCheck AS (
    SELECT 
        /*record_id,*/
        TimeZoneClean,
        CASE
            WHEN TimeZoneClean= '' THEN 'Empty'

            WHEN TimeZoneClean LIKE '.*\s+.*' THEN 'Contains Spaces'

            WHEN TimeZoneClean NOT LIKE 'UTC%' 
                 OR (
                     TimeZoneClean <> 'UTC'
                     AND TimeZoneClean NOT LIKE 'UTC+__:__'
                     AND TimeZoneClean NOT LIKE 'UTC-__:__'
                 )
            THEN 'Invalid TimeZone Format'

            ELSE 'Valid'
        END AS TimeZoneStatus
    FROM CTE_stationTimeZone
)
SELECT *
FROM TimeZoneCheck
WHERE TimeZoneStatus <> 'Valid'


GO


