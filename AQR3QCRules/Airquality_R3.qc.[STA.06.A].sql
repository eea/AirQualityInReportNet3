USE [Airquality_R3]
GO

/****** Object:  View [qc].[STA.06.A]    Script Date: 21/08/2025 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [qc].[STA.06.A] AS

-- Creation date: 21 August 2025
-- QC rule code: STA.06.A
-- QC rule name: STA.06.A Format - [TimeZone]


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
            /*WHEN REGEXP_MATCHES(TimeZoneClean, '.*\s+.*') THEN 'Contains Spaces'
            WHEN LENGTH(SUBSTR(TimeZoneClean, 1, 19)) <> 19 THEN 'Invalid DateTime Length'
            WHEN NOT REGEXP_MATCHES(TimeZoneClean, '.*(Z|[+-][0-9]{2}:[0-9]{2})$') THEN 'Missing or Invalid UTC Offset'*/ -- commented in SQL Server, necessary in Reportnet 3
			WHEN TimeZoneClean LIKE '.*\s+.*' THEN 'Contains Spaces'
            WHEN LEN(SUBSTRING(TimeZoneClean, 1, 19)) <> 19 THEN 'Invalid DateTime Length'
            WHEN TimeZoneClean NOT LIKE '.*(Z|[+-][0-9]{2}:[0-9]{2})$' THEN 'Missing or Invalid UTC Offset' -- added in SQL Server, it is replaced by the line from above in Reportnet 3
            ELSE 'Valid'
        END AS TimeZoneStatus
    FROM CTE_stationTimeZone
)
SELECT *
FROM TimeZoneCheck
WHERE TimeZoneStatus <> 'Valid'


GO


