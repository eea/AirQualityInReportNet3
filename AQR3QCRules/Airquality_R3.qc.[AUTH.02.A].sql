USE [Airquality_R3]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [qc].[AUTH.02.A] AS

-- Creation date: 27 August 2025
-- QC rule code: AUTH.02.A
-- QC rule name: AUTH.02.A Cross-check - [AuthorityInstanceId] AUTH.01 ARZ.05 STA.03

WITH CTE_authority AS (
  SELECT 
    LTRIM(RTRIM(NULLIF([authorityinstance], ''))) AS authorityinstance,
    LTRIM(RTRIM(NULLIF([authorityinstanceid], ''))) AS authorityinstanceid,
    LTRIM(RTRIM(NULLIF([countrycode], ''))) AS countrycode
  FROM reporting.Authority
  WHERE [authorityinstanceid] IS NOT NULL 
    AND [authorityinstance] IS NOT NULL
    AND [countrycode] IS NOT NULL
),

-- Data in reported tables?
assessment_data_present AS (
  SELECT CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END AS has_data 
  FROM reporting.AssessmentRegimeZone
),
station_data_present AS (
  SELECT CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END AS has_data 
  FROM reporting.Station
),

-- Valid zones (reference if table is not reported)
CTE_zones AS (
  SELECT DISTINCT LTRIM(RTRIM([zoneid])) AS zoneid
  FROM (
    SELECT [zoneid] FROM reporting.AssessmentRegimeZone
    WHERE (SELECT has_data FROM assessment_data_present) = 1
    UNION ALL
    SELECT [zoneid] FROM reference.AssessmentRegimeZone
    WHERE (SELECT has_data FROM assessment_data_present) = 0
  ) t
),

-- Valid network (reference if table is not reported)
CTE_networks AS (
  SELECT DISTINCT LTRIM(RTRIM([airqualitynetwork])) AS airqualitynetwork
  FROM (
    SELECT [airqualitynetwork] FROM reporting.Station
    WHERE (SELECT has_data FROM station_data_present) = 1
    UNION ALL
    SELECT [airqualitynetwork] FROM reference.Station
    WHERE (SELECT has_data FROM station_data_present) = 0
  ) t
),

-- AUTH.01: If instance = 'nuts0',  countrycode
CTE_invalid_nuts0 AS (
  SELECT *
  FROM CTE_authority
  WHERE authorityinstance = 'nuts0'
    AND authorityinstanceid <> countrycode
),

-- ARZ.05: zone/nuts(1-3) , zoneid
CTE_invalid_zones AS (
  SELECT *
  FROM CTE_authority a
  WHERE (authorityinstance = 'zone' 
       OR authorityinstance LIKE 'nuts1' 
       OR authorityinstance LIKE 'nuts2' 
       OR authorityinstance LIKE 'nuts3')
    AND NOT EXISTS (
      SELECT 1 FROM CTE_zones z
      WHERE z.zoneid = a.authorityinstanceid
    )
),

-- STA.03: network, airqualitynetwork
CTE_invalid_networks AS (
  SELECT *
  FROM CTE_authority a
  WHERE authorityinstance = 'network'
    AND NOT EXISTS (
      SELECT 1 FROM CTE_networks s
      WHERE s.airqualitynetwork = a.authorityinstanceid
    )
)

-- RESULT
SELECT 'AUTH.01' AS rule_violation, * FROM CTE_invalid_nuts0
UNION ALL
SELECT 'ARZ.05' AS rule_violation, * FROM CTE_invalid_zones
UNION ALL
SELECT 'STA.03' AS rule_violation, * FROM CTE_invalid_networks
;
GO
